//
//  MenuViewController.swift
//  JamNavigator
//
//  Created by Manabu Tonosaki on 2021/12/10.
//

import UIKit

class MenuViewController: UIViewController {
    
    
    // Viewが表示された直後に初期化などを行う
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
    }
    
    var userSub: String = ""    // ユーザー認証した時に収集した、ユーザーを識別するID
    // 画面遷移時に、次のViewControllerに 情報を渡す（Reactの props みたいな）
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case "segueMenuToRec":
            print("Navi: Menu --> Rec")
            let recView = segue.destination as! RecordingViewController
            recView.userSub = userSub
        case "segueMenuToList":
                print("Navi: Menu --> List")
                let listView = segue.destination as! DemotapesTableViewClass
                listView.userSub = userSub
        default:
            print("Warning: missing segue identifire = \(segue.identifier ?? "nil")")
            break
        }
    }
    
    @IBAction func didTapLogoff(_ sender: Any) {
        signOutGlobally() {
            (success, errMessage) in
            
            if success {
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            } else {
                self.alert(caption: "WARNING", message: errMessage ?? "logoff error", button1: "Cancel")
            }
        }
    }
}

