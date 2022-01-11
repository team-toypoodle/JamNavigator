//
//  AwsDataRepository.swift
//  JamNavigator
//
//  Created by Manabu Tonosaki on 2021/12/20.
//

import UIKit
import Amplify


extension UIViewController {
    
    func downloadMusic (key: String, callback: @escaping (Bool, Data?) -> Void) {
        let storageOperation = Amplify.Storage.downloadData(
            key: key,
            progressListener: {
                progress in
                print("Progress: \(progress)")
            },
            resultListener: {
                (event) in
                switch event {
                case let .success(data):
                    print("Completed: \(data)")
                    callback(true, data)
                case let .failure(storageError):
                    print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
                    callback(false, nil)
            }
        })
    }

    // 音楽のデータファイルをAWSクラウドにアップロードする
    func uploadMusic(key: String, data: Data, callback: @escaping () -> Void) {
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
                    callback()
                    
                case .failure(let storageError):
                    let mes = "Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)"
                    print(mes)
                    self.alert(caption: "Error", message: mes, button1: "Cancel")
                }
            }
        )
    }
}
