//
//  MenuViewController.swift
//  JamNavigator
//
//  Created by Manabu Tonosaki on 2021/12/10.
//

import UIKit

class MenuViewController: UIViewController {
    
    var userSub: String = ""    // ユーザー認証した時に収集した、ユーザーを識別するID
    
    // Viewが表示された直後に初期化などを行う
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
    }
}
