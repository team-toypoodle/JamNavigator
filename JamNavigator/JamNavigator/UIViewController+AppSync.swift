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
        let predicate = (demotape.userId == "MATCHING")
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
                    callback(true, matchingItems)
                    
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

