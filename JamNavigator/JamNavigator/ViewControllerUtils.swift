//
//  ViewControllerUtils.swift
//  JamNavigator
//
//  Created by Manabu Tonosaki on 2021/12/10.
//

import UIKit

extension UIViewController {
    func alert(caption: String, message: String, button1: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: caption, message: message, preferredStyle:  UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: button1, style: UIAlertAction.Style.cancel,
            handler: {
                (action: UIAlertAction!) -> Void in
                print("tapped cancelled on login error dialog.")
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
