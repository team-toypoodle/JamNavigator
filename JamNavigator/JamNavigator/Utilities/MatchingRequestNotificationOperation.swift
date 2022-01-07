import UIKit

class MatchingRequestNotificationOperation: Operation {
    override func main() {
        let content = UNMutableNotificationContent()
        content.title = "お知らせ"
        content.body = "local通知"
        content.sound = UNNotificationSound.default
        let intervaltrigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "Notification", content: content, trigger: intervaltrigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
