//
//  MatchConfirmTableViewController.swift
//  JamNavigator
//
//  Created by Manabu Tonosaki on 2021/12/20.
//

import UIKit

class MatchConfirmTableViewController : DemotapesTableViewBase {

    override func viewDidLoad() {
        super.viewDidLoad()

        // 対象ユーザー一覧を生成する
        listMatchingItems(targetUseId: userSub) {
            success, matchingItems in
            if success, let matchingItems = matchingItems {
                
                let unionUsers = matchingItems
                    .compactMap{ $0.instruments }
                    .flatMap{ $0.compactMap{ $0 } }
                let users = Array(Set(unionUsers))  // 重複を取り除く
                
                // 対象ユーザーに限定したデモテープ一覧を作成する
                self.listDemotapes(removeUserId: self.userSub, userIds: users) {
                    (success, list) in
                    if success {
                        if let list = list{
                            self.demotapes = list
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
        tableView.allowsSelection = true
    }

}
