//
//  ViewControllerUtils.swift
//  JamNavigator
//
//  Created by Manabu Tonosaki on 2021/12/10.

import UIKit

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
