//
//  UIViewController+AppSync.swift
//  JamNavigator
//
//  Created by Manabu Tonosaki on 2021/12/21.
//

import UIKit
import Amplify
import AWSPluginsCore

extension UIViewController {
    
    //  AWS GraphQLに新しい, デモテープインスタンスを保存する
    func createData(tape: Demotape) {
        Amplify.API.mutate(request: .create(tape)) {
            event in
            switch event {
                case .success(let result):
                    switch result {
                        case .success(let demotape):
                            print("Successfully created the demotape: \(demotape)")
                        case .failure(let graphQLError):
                            print("Failed to create graphql \(graphQLError)")
                    }
                case .failure(let apiError):
                    print("Failed to create a demotape", apiError)
            }
        }
    }
    
    // マッチングステータスを変更する（ステータスは進む方向のみ）
    func updateMatchingStatus(from: Demotape, status: String, callback: @escaping (Bool, Demotape?) -> Void) {
        
        // TODO: GraphQLで、delete / update がナゾの理由で使えないので、create（打ち消し）で ステータスを変更（進める）
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let newMatchingItem = Demotape(
            name: status,
            generatedDateTime: formatter1.string(from: Date()),
            userId: from.userId,
            attributes: from.attributes,
            s3StorageKey: from.s3StorageKey,
            hashMemo: from.hashMemo,
            instruments: from.instruments,
            genres: from.genres,
            nStar: from.nStar,
            comments: from.comments
        )
        self.createData(tape: newMatchingItem)
    }
    
    // IDを指定して、マッチングインスタンスを取得する（コールバックで）
    func getMatchingItem(idString: String, callback: @escaping (Bool, Demotape?) -> Void) {
        getDemotape(idString: idString, callback: callback)
    }
    
    // IDを指定して、デモテープインスタンスを取得する（コールバックで）
    func getDemotape(idString: String, callback: @escaping (Bool, Demotape?) -> Void) {
        Amplify.API.query(request: .get(Demotape.self, byId: idString)) {
            event in
            switch event {
                case .success(let result):
                    switch result {
                        case .success(let demotape):
                            guard let demotape = demotape else {
                                print("Could not find demotape")
                                return
                            }
                            print("Successfully retrieved demotape: \(demotape)")
                            callback(true, demotape)
                            
                        case .failure(let error):
                            print("Got failed result with \(error.errorDescription)")
                            callback(false, nil)
                    }
                case .failure(let error):
                    print("Got failed event with error \(error)")
                    callback(false, nil)
            }
        }
    }
    
    // デモテープの一覧をクラウドから収集
    func listDemotapes(callback: @escaping (Bool, Array<Demotape>?) -> Void) {
        let demotape = Demotape.keys
        let predicate = (demotape.userId != "MATCHING")
        Amplify.API.query(request: .paginatedList(Demotape.self, where: predicate, limit: 1000)) {
            event in
            switch event {
                case .success(let result):
                    switch result {
                        case .success(let tapes):
                            print("Successfully retrieved list of todos count=: \(tapes.count)")
                            callback(true, Array<Demotape>(tapes))
                            
                        case .failure(let error):
                            print("Got failed result with \(error.errorDescription)")
                            callback(false, nil)
                    }
                case .failure(let error):
                    print("Got failed event with error \(error)")
                    callback(false, nil)
            }
        }
    }
    
    // 指定ユーザーに関する マッチング（or 候補）の一覧をコールバックで返す
    func listMatchingItems(targetUseId: String, callback: @escaping (Bool, Array<Demotape>?) -> Void) {
        let demotape = Demotape.keys
        let predicate = (demotape.userId == "MATCHING" && (demotape.name == "WAITING_FIRSTMATCHING" || demotape.name == "DONE"))
        Amplify.API.query(request: .paginatedList(Demotape.self, where: predicate, limit: 1000)) {
            event in
            switch event {
                case .success(let result):
                    switch result {
                        case .success(let tapes):
                            print("Successfully retrieved list of todos count=: \(tapes.count)")
                            var matchingItems = Array<Demotape>()
                            for tape in tapes {
                                if let uses = tape.instruments {
                                    if uses.contains(targetUseId) {
                                        matchingItems.append(tape)
                                    }
                                }
                            }
                            let grouping = Dictionary(grouping: matchingItems) {
                                $0.s3StorageKey ?? "nil"
                            }
                            var ret = Array<Demotape>()
                            for item in matchingItems {
                                if grouping[item.s3StorageKey ?? "nil"]?.count == 1 {
                                    ret.append(item)
                                }
                            }
                            callback(true, ret)
                            
                        case .failure(let error):
                            print("Got failed result with \(error.errorDescription)")
                            callback(false, nil)
                    }
                case .failure(let error):
                    print("Got failed event with error \(error)")
                    callback(false, nil)
            }
        }
    }
    
    // デモテープの一覧をクラウドから収集
    func listDemotapes(removeUserId: String, userIds: [String], callback: @escaping (Bool, Array<Demotape>?) -> Void) {
        let demotape = Demotape.keys
        let predicate = (demotape.userId != "MATCHING")
        Amplify.API.query(request: .paginatedList(Demotape.self, where: predicate, limit: 1000)) {
            event in
            switch event {
                case .success(let result):
                    switch result {
                        case .success(let tapes):
                            print("Successfully retrieved list of todos count=: \(tapes.count)")
                            var targetUserOnlyTapes = Array<Demotape>()
                            for tape in tapes {
                                if userIds.contains(tape.userId) && tape.userId != removeUserId {
                                    targetUserOnlyTapes.append(tape)
                                }
                            }
                            callback(true, targetUserOnlyTapes)
                            
                        case .failure(let error):
                            print("Got failed result with \(error.errorDescription)")
                            callback(false, nil)
                    }
                case .failure(let error):
                    print("Got failed event with error \(error)")
                    callback(false, nil)
            }
        }
    }
}

