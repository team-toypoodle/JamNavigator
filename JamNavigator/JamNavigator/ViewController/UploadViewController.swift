//
//  UploadViewController.swift
//  JamNavigator
//
//  Created by Tasuku Furuki on 2021/12/09.
//

import UIKit
import Amplify
import AWSS3StoragePlugin
import NaturalLanguage

class UploadViewController: UIViewController,UITextFieldDelegate {
    
    var userSub: String = ""    // ユーザー認証した時に収集した、ユーザーを識別するID

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
            
            // 作成日の文字列を作成する
            let formatter1 = DateFormatter()
            formatter1.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateTimeStr = formatter1.string(from: Date())
            
            let instNames = [(checkGuitar, "Guitar"),(checkPiano, "Piano"),(checkViolin, "Violin"),(checkOther,"Other")].filter { $0.0.isOn }.map {
                $0.1
            }
            
            let genreNames = [(checkClassical, "Classical"),(checkJazz, "Jazz"),(checkRock, "Rock"),(checkGenreOther,"Other")].filter { $0.0.isOn }.map {
                $0.1
            }
//            guard let fcmtoken = getFcmToken() else {
//                fatalError("fcmtokenはエラー処理をしていません")
//            }
//            let attrs = ["FCMTOKEN=\(fcmtoken)"]
            // GraphQL（データベース）にデモテープ情報を新規作成・登録する
            let tape = Demotape(
                name: titleText.text ?? "(no title)",
                generatedDateTime: dateTimeStr,
                userId: userSub,
//                attributes: attrs,
                s3StorageKey: uploadkey,
                hashMemo: commentText.text,
                instruments: instNames,
                genres: genreNames,
                nStar: 0    // 0 means no star yet.

            )
            createData(tape: tape)
        }
        catch let ex {
            alert(caption: "Error", message: ex.localizedDescription, button1: "Cancel")
        }
    }
    
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var checkGuitar: UISwitch!
    @IBOutlet weak var checkPiano: UISwitch!
    @IBOutlet weak var checkViolin: UISwitch!
    @IBOutlet weak var checkOther: UISwitch!
    @IBOutlet weak var checkClassical: UISwitch!
    @IBOutlet weak var checkJazz: UISwitch!
    @IBOutlet weak var checkRock: UISwitch!
    @IBOutlet weak var checkGenreOther: UISwitch!
    
    
    @IBAction func tapwhitespace(_ sender: UITapGestureRecognizer) {
        titleText.resignFirstResponder()
        commentText.resignFirstResponder()
    }
}
