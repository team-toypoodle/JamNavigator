//
//  ViewController.swift
//  JamNavigator
//
//  Created by Tasuku Furuki on 2021/12/08.
//

import UIKit

class TopViewController: UIViewController {
    
    var userSub: String = ""    // ユーザー認証した時に収集した、ユーザーを識別するID
    
    // Viewが表示された直後に初期化などを行う
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchCurrentAuthSession()   // 自動認証を トライしてみる
        
        //以下は、サインアップの手順サンプル
        //signUp(username: "tonosaki", password: "tonotono", email: "manabu@tomarika.com") // received 568764
        //confirmSignUp(for: "tonosaki", with: "568764")
        
        //以下は、ログインの手順サンプル
        //signIn(username: "tonosaki", password: "tonotono")
    }
    
    // 画面遷移時に、次のViewControllerに 情報を渡す（Reactの props みたいな）
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case "segueTopToMenu":
            print("Navi: Top --> Menu")
            let menuView = segue.destination as! MenuViewController
            menuView.userSub = userSub
        default:
            print("Warning: missing segue identifire = \(segue.identifier ?? "nil")")
            break
        }
    }
}

