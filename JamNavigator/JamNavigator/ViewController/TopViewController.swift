//
//  ViewController.swift
//  JamNavigator
//
//  Created by Tasuku Furuki on 2021/12/08.
//

import UIKit
import Firebase

class TopViewController: UIViewController {
    
    var userSub: String = ""    // ユーザー認証した時に収集した、ユーザーを識別するID
    
    @IBOutlet weak var textFieldUsername: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    
    // Viewが表示された直後に初期化などを行う
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fcmtoken = getFcmToken()
        pushRemote(registrationToken: fcmtoken!, title: "テスト", message: "本日は晴天なり")

        fetchCurrentAuthSession() {   // 自動認証を トライしてみる
            usersub in
            if let usersub = usersub  {
                self.userSub = usersub
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "segueTopToMenu", sender: self)
                    
                }
            } else {
                print("自動認証できないので、手動ログイン待ちになりました")
            }
        }
    }
    
    @objc func displayFCMToken(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        if let fcmToken = userInfo["token"] as? String {
            print("Received FCM token: \(fcmToken)")
        }
    }

    // 画面遷移時に、次のViewControllerに 情報を渡す（Reactの props みたいな）
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case "segueTopToMenu":
            print("Navi: Top --> Menu")
            let menuView = segue.destination as! MenuViewController
            menuView.userSub = userSub
            
        case "segueTopToSignup":
            let signupView = segue.destination as! SignupViewController
            signupView.username = textFieldUsername.text ?? ""
            signupView.password = textFieldPassword.text ?? ""
            break
            
        default:
            print("Warning: missing segue identifire = \(segue.identifier ?? "nil")")
            break
        }
    }
    
    func checkLoginFields() -> Bool {
        guard let username = textFieldUsername.text else {  // textFieldUsernameが入力されてなかったら return
            print("usename = nil is not accepted")
            return false
        }
        guard let password = textFieldPassword.text else {  // textFieldPasswordが入力されてなかったら return
            print("password = nil is not accepted")
            return false
        }
        if username.count < 2 || password.count < 2 {       // 入力文字が短すぎたら return
            print( "Expecting a little longer account information" )
            return false
        }
        if username.count > 120 || password.count > 120 {   // 入力文字が長すぎたら return
            print( "Expecting a little shorter account information" )
            return false
        }
        return true
    }
    
    // ログインボタンがタップされた時に実行されるイベント
    @IBAction func didTapLoginButton(_ sender: UIButton) {
        if !checkLoginFields() {
            return
        }
        let username = textFieldUsername.text!
        let password = textFieldPassword.text!

        signIn(username: username, password: password) {
            (success, errMessage) in
            
            if success {
                self.fetchCurrentAuthSession() {
                    usersub in
                    if let usersub = usersub {
                        self.userSub = usersub
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "segueTopToMenu", sender: self)
                        }
                    }
                }
                
            } else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "WARNING", message:  "Login failure!\n\(errMessage ?? "unknown error")", preferredStyle:  UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel,
                    handler: {
                        (action: UIAlertAction!) -> Void in
                        print("tapped cancelled on login error dialog.")
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}

