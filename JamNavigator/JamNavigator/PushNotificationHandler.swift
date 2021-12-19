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
    func pushRemote(topic: String, title: String, message: String) {
//        let message = #"{"type": "token", "title": "ぴよぴよ", "body": "鳥さんです！"}"#
//        let request = RESTRequest(path: "/push/e1-g15ILyUOCgr1bi5tlB8:APA91bGQouAWNFK7si71ubBWQ4XkSgoO-uiBl-4euf7GiztOWNg0BVLteoA04yzwdtqCQTgNxNFuchLyElOWQTHvcwIEzNlqRpGDRru4lCQTJl_dtkz0HRMk6GYfKYVOrqEdasuJI0vo", body: message.data(using: .utf8))
        var json = #"{"type": "topic", "title": "@@TITLE@@", "body": "@@BODY@@"}"#
        json = json.replacingOccurrences(of: "@@TITLE@@", with: title)
        json = json.replacingOccurrences(of: "@@BODY@@", with: message)
        let path = "/push/\(topic)"
        let request = RESTRequest(path: path , body: json.data(using: .utf8))
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

    // リモート通知を要求する
    func pushRemote(registrationToken: String, title: String, message: String) {
//        let message = #"{"type": "token", "title": "ぴよぴよ", "body": "鳥さんです！"}"#
//        let request = RESTRequest(path: "/push/e1-g15ILyUOCgr1bi5tlB8:APA91bGQouAWNFK7si71ubBWQ4XkSgoO-uiBl-4euf7GiztOWNg0BVLteoA04yzwdtqCQTgNxNFuchLyElOWQTHvcwIEzNlqRpGDRru4lCQTJl_dtkz0HRMk6GYfKYVOrqEdasuJI0vo", body: message.data(using: .utf8))
        var json = #"{"type": "token", "title": "@@TITLE@@", "body": "@@BODY@@"}"#
        json = json.replacingOccurrences(of: "@@TITLE@@", with: title)
        json = json.replacingOccurrences(of: "@@BODY@@", with: message)
        let path = "/push/\(registrationToken)"
        let request = RESTRequest(path: path , body: json.data(using: .utf8))
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

extension AppDelegate : UNUserNotificationCenterDelegate, MessagingDelegate {
    
    // Firebase PUSH通知 初期化処理
    func initPushNotification() {
        FirebaseApp.configure()

        //Messaging.messaging().delegate = self  commented out because of cannot assign value of type error.
        UNUserNotificationCenter.current().requestAuthorization(    // PUSH通知の受信機能 有効化1
            options: [.alert, .sound, .badge]){
            (granted, _) in
            if granted {
                UNUserNotificationCenter.current().delegate = self
                
            } else {
                print("ERROR: JamNavi: PUSH Authorization error")
            }
        }
        
        Messaging.messaging().delegate = self
        Messaging.messaging().token {
            token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
            }
        }
    }

    // 通知用トークンを取得（アプリ再インストールなどで変更されるが、再起動ぐらいでは変わらない値）
    func getFcmToken() -> String? {
        let token = Messaging.messaging().fcmToken  // [START log_fcm_reg_token]
        return token
    }
    
    // PUSH通知対応
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // Print message ID.
        if let messageID = userInfo["gcm.message_id"] {
            print("Message ID: \(messageID)")
        }
    }
    
    // サイレント通知対応
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Print message ID.
        if let messageID = userInfo["gcm.message_id"] {
            print("Message ID: \(messageID)")
        }
        completionHandler(UIBackgroundFetchResult.newData)
    }

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
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")

        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
          name: Notification.Name("FCMToken"),
          object: nil,
          userInfo: dataDict
        )
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
      }
}
