//
//  AppDelegate.swift
//  JamNavigator
//
//  Created by Tasuku Furuki on 2021/12/08.
//

import UIKit
import Amplify
import AWSCognitoAuthPlugin
import AWSS3StoragePlugin
import AWSAPIPlugin
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // 起動後の初期化処理
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
        // PUSH Notofication w/ Firebase
        do {
            FirebaseApp.configure()
            UNUserNotificationCenter.current().requestAuthorization(    // PUSH通知の受信機能 有効化1
                options: [.alert, .sound, .badge]){
                (granted, _) in
                if granted {
                    UNUserNotificationCenter.current().delegate = self
                }
            }
            application.registerForRemoteNotifications()
        }
                
        // AWS Amplify
        do {
            //Amplify.Logging.logLevel = .verbose
            try Amplify.add(plugin: AWSCognitoAuthPlugin()) // for Cognito authentication
            try Amplify.add(plugin: AWSS3StoragePlugin())   // for S3 Storage access
            try Amplify.add(plugin: AWSAPIPlugin(modelRegistration: AmplifyModels())) // for GraphQL Demotabe
            try Amplify.configure()
            print("Amplify init completed successfully!")

        } catch{
            print("Fatal error : Amplify init exception")
            return false
        }
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
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
}
