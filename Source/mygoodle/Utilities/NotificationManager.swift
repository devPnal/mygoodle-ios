import UserNotifications
import SwiftUI

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    private var isNotificationActive = false
    
    func updateNotificationContent(amount: Float) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        isNotificationActive = false
        
        if amount == 0 {
            return
        }
        
        // 다음 월요일 9시에 대한 알림 설정
        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = 9
        components.minute = 0
        components.weekday = 2  // 월요일
        
        guard let nextMonday = calendar.nextDate(after: Date(), matching: components, matchingPolicy: .nextTime) else { return }
        
        scheduleNotification(for: nextMonday, amount: amount)
    }
    
    private func calculateWeeklyAmount(for monday: Date, in globalSub: GlobalSub) -> Float {
        let calendar = Calendar.current
        let startOfWeek = monday
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!
        
        var weeklyAmount: Float = 0
        
        for sub in globalSub.subs {
            if Int(sub.cycleNumber)! < 100 {
                let day = Int(sub.cycleNumber)!
                
                var currentDate = startOfWeek
                while currentDate <= endOfWeek {
                    let currentMonth = calendar.component(.month, from: currentDate)
                    let currentDay = calendar.component(.day, from: currentDate)
                    
                    if currentDay == day {
                        weeklyAmount += sub.price
                    }
                    
                    currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
                }
            }
            else {
                let month = Int(sub.cycleNumber.prefix(2))!
                let day = Int(sub.cycleNumber.suffix(2))!
                
                var currentDate = startOfWeek
                while currentDate <= endOfWeek {
                    let currentMonth = calendar.component(.month, from: currentDate)
                    let currentDay = calendar.component(.day, from: currentDate)
                    
                    if currentMonth == month && currentDay == day {
                        weeklyAmount += sub.price
                    }
                    
                    currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
                }
            }
        }
        
        return weeklyAmount
    }
    
    func scheduleYearlyNotifications(globalSub: GlobalSub) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        isNotificationActive = false
        
        let calendar = Calendar.current
        let now = Date()
        
        var nextMondays: [Date] = []
        var currentDate = now
        
        for _ in 0..<52 {
            var components = DateComponents()
            components.hour = 9
            components.minute = 0
            components.weekday = 2  // 월요일
            
            if let nextMonday = calendar.nextDate(after: currentDate,
                                                matching: components,
                                                matchingPolicy: .nextTime) {
                nextMondays.append(nextMonday)
                currentDate = nextMonday
            }
        }
        
        for monday in nextMondays {
            let weeklyAmount = calculateWeeklyAmount(for: monday, in: globalSub)
            if weeklyAmount > 0 {
                scheduleNotification(for: monday, amount: weeklyAmount)
            }
        }
    }
    
    private func scheduleNotification(for date: Date, amount: Float) {
        let content = UNMutableNotificationContent()
        content.title = String(localized: "이번 주 결제 예정 금액")
        content.body = String(localized: "이번 주에 \(amount.formatted())이 빠져나갈 예정이에요.")
        content.sound = .default
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "weeklyReminder-\(date.timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { [weak self] error in
            if error == nil {
                self?.isNotificationActive = true
            }
        }
    }
    
    func stopNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        isNotificationActive = false
    }
}
