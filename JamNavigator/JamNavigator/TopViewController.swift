//
//  ViewController.swift
//  JamNavigator
//
//  Created by Tasuku Furuki on 2021/12/08.
//

import UIKit

class TopViewController: UIViewController {
    
    var userSub: String = ""    // ユーザー認証した時に収集した、ユーザーを識別するID
    
    @IBOutlet weak var textFieldUsername: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    
    // Viewが表示された直後に初期化などを行う
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCurrentAuthSession()   // 自動認証を トライしてみる

        //以下は、サインアップの手順サンプル
        //signUp(username: "tonosaki", password: "tonotono", email: "manabu@tomarika.com") // received 568764
        //confirmSignUp(for: "tonosaki", with: "568764")
        
        //以下は、ログインの手順サンプル
        //signIn(username: "tonosaki", password: "tonotono")
        
        // サインアウトのサンプル
        //signOutGlobally()
    }
    
    // 画面遷移時に、次のViewControllerに 情報を渡す（Reactの props みたいな）
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case "segueTopToMenu":
            print("Navi: Top --> Menu")
            let menuView = segue.destination as! MenuViewController
            menuView.userSub = userSub

            // TODO: Delete this because of test code by Tono
            pushRemote()
            
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
                self.fetchCurrentAuthSession()
                
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

