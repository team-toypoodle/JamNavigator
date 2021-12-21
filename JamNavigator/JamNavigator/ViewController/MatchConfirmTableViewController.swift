//
//  MatchConfirmTableViewController.swift
//  JamNavigator
//
//  Created by Manabu Tonosaki on 2021/12/20.
//

import UIKit

class MatchConfirmTableViewController : DemotapesTableViewBase {

    
    private var matchingFirstItem: Demotape? = nil  // TODO: 複数同時マッチング非対応のため、最初のマッチングレコードだけ処理する

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
                if users.count >= 2 {   // 自分＋誰かがマッチングレコードある場合は、マッチング要求きている状態
                    self.matchingFirstItem = matchingItems[0]
                }
                
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
    
    // マッチング拒否
    @IBAction func didTapReject(_ sender: Any) {

        guard let matchingFirstItem = matchingFirstItem else {
            print("マッチングアイテムがない状態で、Rejectボタンが押されたので無視する")
            return
        }
        // ステータスを更新する
        updateMatchingStatus(from: matchingFirstItem, status: "DONE"){
            success, newItem in
            
            if success {
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
    // 画面遷移時に、次のViewControllerに 情報を渡す（Reactの props みたいな）
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //segueConfirmToRequest
        switch segue.identifier {
        case "segueConfirmToRequest":
                guard let destination = segue.destination as? RequestViewController else {
                    fatalError("\(segue.destination) Error")
                }
                destination.demotape = matchingFirstItem
                destination.userSub = userSub
        default:
            print("Warning: missing segue identifire = \(segue.identifier ?? "nil")")
            break
        }
    }
    

    
    // マッチングOK
    @IBAction func didTapMatch(_ sender: Any) {
        performSegue(withIdentifier: "segueConfirmToRequest", sender: self)
    }
}
