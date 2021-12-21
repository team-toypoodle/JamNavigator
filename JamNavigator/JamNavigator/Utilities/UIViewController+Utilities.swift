//
//  ViewControllerUtils.swift
//  JamNavigator
//
//  Created by Manabu Tonosaki on 2021/12/10.

import UIKit
import AVFoundation

//店の構造体を宣言
struct Address {
    var id: String
    var name: String
    var address: String
}

//店の配列
let addresses = [
    Address(id: "KARA-000001", name: "JOYSOUND 名駅三丁目店", address: "愛知県名古屋市中村区名駅3丁目14−6"),
    Address(id: "KARA-000002", name: "ジャンカラ 名駅東口店", address: "愛知県名古屋市中村区名駅4丁目10−20"),
    Address(id: "KARA-000003", name: "ビッグエコー名駅4丁目店", address: "愛知県名古屋市中村区名駅4丁目5−18")
    
]

extension UIViewController {
    
    
    func alert(caption: String, message: String, button1: String, callback: (() -> Void)? = nil ) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: caption, message: message, preferredStyle:  UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: button1, style: UIAlertAction.Style.cancel,
            handler: {
                (action: UIAlertAction!) -> Void in
                print("tapped cancelled on login error dialog.")
            }))
            self.present(alert, animated: true, completion: callback)
        }
    }
    
    func getLocalAudioUrl() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docsDirect = paths[0]
        let url = docsDirect.appendingPathComponent("recording.m4a")
        return url
    }
    
    // コントロールの Enable・Disableの状態を一括して行う
    func applyEnableDisableDesign(control: UIControl, sw: Bool) {
        if sw {
            control.isEnabled = true
            control.alpha = 1.0
        } else {
            control.isEnabled = false
            control.alpha = 0.25
        }
        
    }
}
