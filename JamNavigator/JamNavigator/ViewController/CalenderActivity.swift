import UIKit
import EventKit

class CalenderActivity: UIActivity {
    
    let eventStore = EKEventStore()
   
    override var activityTitle: String? {
        return "Calender"
    }
    override var activityImage: UIImage? {
        return UIImage(systemName: "calender")
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
        allowAuthorization(activityItems: activityItems)
    }
    
    func addCalenderEvent(activityItems: [Any]) {
        let event = EKEvent(eventStore: eventStore)
        event.title = activityItems[0] as? String
        event.startDate = activityItems[1] as? Date
        event.endDate = activityItems[2] as? Date
        event.calendar = eventStore.defaultCalendarForNewEvents
        do {
            try eventStore.save(event, span: .thisEvent)
        } catch {
            let nserror = error as NSError
            print(nserror)
        }
    }
    
    func allowAuthorization(activityItems: [Any]) {
        if getAuthorization_status() {
            addCalenderEvent(activityItems: activityItems)
            return
        }
        eventStore.requestAccess(to: .event) {(granted, error) in
            if granted {
                self.addCalenderEvent(activityItems: activityItems)
                return
            }
            print("Not allowed")
        }
    }

    func getAuthorization_status() -> Bool {
        let status = EKEventStore.authorizationStatus(for: .event)
        
        switch status {
        case .notDetermined:
            print("NotDetermined")
            return false
        case .denied:
            print("Denied")
            return false
        case .authorized:
            print("Authorized")
            return true
        case .restricted:
            print("Restricted")
            return false
        }
    }
}