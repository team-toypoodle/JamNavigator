//
//  AwsDataRepository.swift
//  JamNavigator
//
//  Created by Manabu Tonosaki on 2021/12/20.
//

import UIKit
import Amplify

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
    
    // 音楽のデータファイルをAWSクラウドにアップロードする
    func uploadMusic(key: String, data: Data) {
        _ = Amplify.Storage.uploadData(
            key: key,
            data: data,
            progressListener: {
                progress in
                print("Progress: \(progress)")
            },
            resultListener: {
                event in
                switch event {
                case .success(let data):
                    print("Completed: \(data)")
                    DispatchQueue.main.async {
                        self.dismiss(animated: true)
                    }
                    
                case .failure(let storageError):
                    let mes = "Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)"
                    print(mes)
                    self.alert(caption: "Error", message: mes, button1: "Cancel")
                }
            }
        )
    }
    
    // デモテープの一覧をクラウドから収集
    func listDemotapes(callback: @escaping (Bool, List<Demotape>?) -> Void) {
        let demotape = Demotape.keys
        let predicate = (demotape.userId != "MATCHING")
        Amplify.API.query(request: .paginatedList(Demotape.self, where: predicate, limit: 1000)) {
            event in
            switch event {
            case .success(let result):
                switch result {
                case .success(let tapes):
                    print("Successfully retrieved list of todos count=: \(tapes.count)")
                    callback(true, tapes)
                    
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
