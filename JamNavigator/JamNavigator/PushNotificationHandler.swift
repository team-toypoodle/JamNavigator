//
//  PushNotificationHandler.swift
//  JamNavigator
//
//  Created by Manabu Tonosaki on 2021/12/16.
//

import Foundation
import Firebase
import UserNotifications
import UIKit
import Amplify

extension UIViewController {
    
    // リモート通知を要求する
    func pushRemote() {
        let message = #"{"message": "my new Todo"}"#
        let request = RESTRequest(path: "/push/123", body: message.data(using: .utf8))
        Amplify.API.post(request: request) {
            result in
            switch result {
            case .success(let data):
                let str = String(decoding: data, as: UTF8.self)
                print("＋＋＋＋＋", str)
                    
            case .failure(let apiError):
                print("＋＋＋＋＋", apiError)
            }
        }
    }

    // ローカル通知を出す
    func pushLocal(title: String, body: String, delaySeconds: Double = 0.0, sound: UNNotificationSound = .default) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = sound

        let intervalTrigger = UNTimeIntervalNotificationTrigger(timeInterval: delaySeconds, repeats: false)
        let request = UNNotificationRequest(identifier: "localpush-\(title)-\(body)", content: content, trigger: intervalTrigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil) // 通知登録
    }

}

extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // HACK:アプリがフォアグランドにいるときにPUSHされたイベント処理
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        let userInfo = notification.request.content.userInfo
        if let messageID = userInfo["gcm.message_id"] {
            print("Message ID: \(messageID)")
        }
        print("======= PUSH1 \(userInfo)")
        //completionHandler([])
        completionHandler([ .badge, .sound, .banner ])
   }

    // HACK:ユーザーが通知バナーをタップした時に発火するイベント処理
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let messageID = userInfo["gcm.message_id"] {
            print("Message ID: \(messageID)")
        }
        print("======= PUSH2 \(userInfo)")
        completionHandler()
    }
}
