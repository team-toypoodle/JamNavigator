//
//  MenuViewController.swift
//  JamNavigator
//
//  Created by Manabu Tonosaki on 2021/12/10.
//

import UIKit
import AVFAudio

class MenuViewController: UIViewController, AVAudioPlayerDelegate {
    var userSub: String = ""    // ユーザー認証した時に収集した、ユーザーを識別するID
    
    @IBOutlet weak var matchingButton: UIButton!
    @IBOutlet weak var notificationBadgeImage: UIImageView!
    @IBOutlet weak var meetButton: UIButton!
    @IBOutlet weak var meetNotificationBadgeImage: UIImageView!
    
    var meetsItem: Demotape? = nil
    
    // Viewが表示された直後に初期化などを行う
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        applyEnableDisableDesign(control: matchingButton, sw: false)
        applyEnableDisableDesign(control: meetButton, sw: false)
    }
    
    // ビュー表示後
    override func viewDidAppear(_ animated: Bool) {
        
        print("---------------------”目立つ”------------------------")
        
        // クラウドマッチング、バッジの表示
        listMatchingItems(targetUseId: userSub) {success, matchingItems in
            if success, let matchingItems = matchingItems {
                let sw = (matchingItems.count > 0)
                DispatchQueue.main.async {
                    self.notificationBadgeImage.isHidden = !sw
                    self.applyEnableDisableDesign(control: self.matchingButton, sw: sw)
                }
            }
        }
        
        // 現地集合バッジの表示
        listMeetsItems(targetUseId: userSub) {success, matchingItems in
            print("success : ",success,matchingItems)
            if success, let matchingItems = matchingItems {
                let sw = (matchingItems.count > 0)
                if sw {
                    self.meetsItem = matchingItems[0]
                }
                DispatchQueue.main.async {
                    self.meetNotificationBadgeImage.isHidden = !sw
                    self.applyEnableDisableDesign(control: self.meetButton, sw: sw)
                }
            }
        }
    }
    
    // 画面遷移時に、次のViewControllerに 情報を渡す（Reactの props みたいな）
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
            case "segueMenuToRec":
                print("Navi: Menu --> Rec")
                let recView = segue.destination as! RecordingViewController
                recView.userSub = userSub
            case "segueMenuToList":
                print("Navi: Menu --> All-List")
                let listView = segue.destination as! DemotapesTableViewClass
                listView.userSub = userSub
            case "segueMenuToMatchConfirm":
                print("Navi: Menu --> Confirm-List")
                let listView = segue.destination as! MatchConfirmTableViewController
                listView.userSub = userSub
            case "segueMenuToMeets":
                print("Navi: Menu --> Meets")
                let meetsView = segue.destination as! MeetsViewController
                meetsView.userSub = userSub
                meetsView.meetsItem = meetsItem
                
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
    
    // マッチングボタン
    @IBAction func didTapMatchingButton(_ sender: UIButton) {
        performSegue(withIdentifier: "segueMenuToMatchConfirm", sender: self)
    }
    
    // 現地集合ボタン
    @IBAction func didTapMeetsButton(_ sender: Any) {
        performSegue(withIdentifier: "segueMenuToMeets", sender: self)
    }
}

