import UserNotifications
import SwiftUI

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    private var isNotificationActive = false
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("알림 권한이 승인되었습니다")
            }
        }
    }
    
    func updateNotificationContent(amount: Float) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        isNotificationActive = false
        
        if amount == 0 {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = String(localized: "이번 주 결제 예정 금액")
        content.body = String(localized: "이번 주에 \(amount.formatted())이 빠져나갈 예정이에요.")
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 9
        dateComponents.minute = 0
        dateComponents.weekday = 2
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "weeklyReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if error == nil {
                self.isNotificationActive = true
            }
        }
    }
    
    func checkNotificationStatus(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }
    
    func stopNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        isNotificationActive = false
    }
}
