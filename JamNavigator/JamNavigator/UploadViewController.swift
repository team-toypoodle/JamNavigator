//
//  UploadViewController.swift
//  JamNavigator
//
//  Created by Tasuku Furuki on 2021/12/09.
//

import UIKit
import Amplify
import AWSS3StoragePlugin

class UploadViewController: UIViewController,UITextFieldDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.]
        titleText.delegate = self
        commentText.delegate = self
    }
    
    // アップロードボタン押下時の処理（クラウドに保存したい）
    @IBAction func uploadButton(_ sender: Any) {
        
        do {
            // ローカルに保存されている音声ファイルを取得する
            let filename = getLocalAudioUrl()
            let music: Data = try Data(contentsOf: filename)
            print( "------- music data size = \(music.count) bytes" )
            
            // クラウドに保存する 重複しないファイル名を作成する
            let uploadkey = "m-\(UUID().uuidString.lowercased()).m4a"
            print("New upload key = \(uploadkey)")
            
            // AWS S3にアップロード
            uploadMusic(key: uploadkey, data: music)
        }
        catch let ex {
            alert(caption: "Error", message: ex.localizedDescription, button1: "Cancel")
        }
    }
    
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var commentText: UITextField!
    
    @IBAction func tapwhitespace(_ sender: UITapGestureRecognizer) {
        titleText.resignFirstResponder()
        commentText.resignFirstResponder()
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
}
