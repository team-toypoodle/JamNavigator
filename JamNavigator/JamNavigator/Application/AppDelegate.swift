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
import BackgroundTasks
//import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // 起動後の初期化処理
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
        // PUSH Notofication w/ Firebase
//        initPushNotification()
//        application.registerForRemoteNotifications()


        // AWS Amplify
        do {
            //Amplify.Logging.logLevel = .verbose
            try Amplify.add(plugin: AWSCognitoAuthPlugin()) // for Cognito authentication
            try Amplify.add(plugin: AWSS3StoragePlugin())   // for S3 Storage access
            try Amplify.add(plugin: AWSAPIPlugin(modelRegistration: AmplifyModels())) // for GraphQL Demotabe
            try Amplify.add(plugin: AWSAPIPlugin()) // for push rest (express.js) api
            try Amplify.configure()
            print("Amplify init completed successfully!")

        } catch{
            print("Fatal error : Amplify init exception")
            return false
        }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge]){
            (granted,_) in
            if granted {
                UNUserNotificationCenter.current().delegate = self
            }
        }
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.exampleapp.localNotice.apprefresh", using: nil) { task in
            // バックグラウンド処理したい内容 ※後述します
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        BGTaskScheduler.shared.getPendingTaskRequests {
            requests in print(requests)
        }
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    
    private func handleAppRefresh(task: BGAppRefreshTask) {
          // 1日の間、何度も実行したい場合は、1回実行するごとに新たにスケジューリングに登録します
        SceneDelegate.scheduleAppRefresh()

        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1

        // 時間内に実行完了しなかった場合は、処理を解放します
        // バックグラウンドで実行する処理は、次回に回しても問題ない処理のはずなので、これでOK
        task.expirationHandler = {
          queue.cancelAllOperations()
        }

        let operation = MatchingRequestNotificationOperation()
        operation.completionBlock = {
          // 最後の処理が完了したら、必ず完了したことを伝える必要があります
          task.setTaskCompleted(success: operation.isFinished)
        }
        queue.addOperation(operation)
      }
}
