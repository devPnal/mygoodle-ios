import SwiftUI

public enum AppDarkMode: String, CaseIterable {
    case system
    case light
    case dark
    
    var info: (id:Int, value:String) {
        switch self {
        case .system:
            return (0, String(localized: "시스템"))
        case .light:
            return (1, String(localized: "라이트"))
        case .dark:
            return (2, String(localized: "다크"))
        }
    }
}

public struct Sub: Identifiable, Codable  {
    public var id = UUID()
    let genreId: Int
    let title: String
    let cycleNumber: String
    let price: Float
    
    var cycleDisplay: String {
        let cycleMM = String(cycleNumber.prefix(2))
        let cycleDD = String(cycleNumber.suffix(2))
        return Int(cycleNumber)! < 100
            ? String(localized: "매달 \(cycleDD)일")
            : String(localized: "매해 \(cycleMM)월 \(cycleDD)일")
    }
}

public enum Genre: Int, CaseIterable {
    case culture = 0
    case technology
    case transfer
    case membership
    case others
    
    var title: LocalizedStringKey {
        switch self {
        case .culture: return LocalizedStringKey("문화")
        case .technology: return LocalizedStringKey("기술")
        case .transfer: return LocalizedStringKey("이체")
        case .membership: return LocalizedStringKey("멤버십")
        case .others: return LocalizedStringKey("기타")
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .culture: return Color(red: 0.941, green: 0.647, blue: 0.647)
        case .technology: return Color(red: 0.933, green: 0.914, blue: 0.651)
        case .transfer: return Color(red: 0.663, green: 0.914, blue: 0.6)
        case .membership: return Color(red: 0.604, green: 0.757, blue: 0.878)
        case .others: return Color(red: 0.78, green: 0.78, blue: 0.78)
        }
    }
}

public class GlobalSub: ObservableObject {
    @Published var subs: [Sub] = [
        Sub(genreId: 0, title: "초기 데이터 1", cycleNumber: "0101", price: 10000),
        Sub(genreId: 1, title: "초기 데이터 2", cycleNumber: "0201", price: 20000),
        Sub(genreId: 2, title: "초기 데이터 3", cycleNumber: "0001", price: 20000)
    ]
   
    @Published private var currentDate = Date()
    private var timer: Timer?
    private let subsKey = "SavedSubscriptions"
    
    init() {
        loadSubscriptions()
        startDateTimer()
        if !subs.isEmpty {
            updateNotification()
        }
        updateWidget()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    private func loadSubscriptions() {
        if let data = UserDefaults.standard.data(forKey: subsKey) {
            if let decoded = try? JSONDecoder().decode([Sub].self, from: data) {
                self.subs = decoded
                return
            }
        }
        
        self.subs = [
            Sub(genreId: 4, title: String(localized: "왼쪽으로 밀어서 삭제"), cycleNumber: "0000", price: 0),
            Sub(genreId: 4, title: String(localized: "오른쪽으로 밀어서 수정"), cycleNumber: "0000", price: 0)
        ]
    }
    
    private func saveSubscriptions() {
        if let encoded = try? JSONEncoder().encode(subs) {
            UserDefaults.standard.set(encoded, forKey: subsKey)
        }
    }
    
    private func startDateTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let calendar = Calendar.current
            if !calendar.isDate(Date(), inSameDayAs: self.currentDate) {
                self.currentDate = Date()
                self.objectWillChange.send()
            }
        }
    }

    func addSubscription(genreId: Int, title: String, cycleNumber: String, price: Float) {
        let item = Sub(genreId: genreId, title: title, cycleNumber: cycleNumber, price: price)
        objectWillChange.send()
        var updatedSubs = subs
        updatedSubs.append(item)
        subs = updatedSubs.sorted { $0.cycleNumber < $1.cycleNumber }
        saveSubscriptions()
        updateNotification()
        updateWidget()
    }

    func removeSubscription(id: UUID) {
        subs.removeAll { $0.id == id }
        saveSubscriptions()
        updateNotification()
        updateWidget()
    }

    func calculatePlannedMoney() -> Float {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        let nowMM = dateFormatter.string(from: currentDate)
        
        var result: Float = 0.0
        for sub in subs {
            if (Int(sub.cycleNumber)! < 100) {
                result += sub.price
            }
            else {
                if (Int(sub.cycleNumber.prefix(2)) == Int(nowMM)) {
                    result += sub.price
                }
            }
        }
        return result
    }

    func calculateLeftMoney() -> Float {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        let nowMM = dateFormatter.string(from: currentDate)
        dateFormatter.dateFormat = "dd"
        let nowDD = dateFormatter.string(from: currentDate)
        
        var payed: Float = 0.0
        for sub in subs {
           if (Int(sub.cycleNumber)! < 100 && Int(sub.cycleNumber)! < Int(nowDD)!) {
               payed += sub.price
           }
           else {
               if (Int(sub.cycleNumber.prefix(2)) == Int(nowMM) && Int(sub.cycleNumber.suffix(2))! < Int(nowDD)!) {
                   payed += sub.price
               }
           }
        }
        let result = calculatePlannedMoney() - payed
        return result
    }

    func calculateWeeklyPayments() -> Float {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2  // 1은 일요일, 2는 월요일
        let today = Date()
        
        // 현재 날짜가 속한 주의 월요일과 일요일 구하기
        let monday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        let sunday = calendar.date(byAdding: .day, value: 6, to: monday)!
        
        var weeklyAmount: Float = 0
        
        for sub in subs {
            if Int(sub.cycleNumber)! < 100 {
                let day = Int(sub.cycleNumber)!
                let currentMonth = calendar.component(.month, from: today)
                
                if let paymentDate = calendar.date(from: DateComponents(
                    year: calendar.component(.year, from: today),
                    month: currentMonth,
                    day: day
                )) {
                    if paymentDate >= monday && paymentDate <= sunday {
                        weeklyAmount += sub.price
                    }
                }
            } else {
                let month = Int(sub.cycleNumber.prefix(2))!
                let day = Int(sub.cycleNumber.suffix(2))!
                
                if let paymentDate = calendar.date(from: DateComponents(
                    year: calendar.component(.year, from: today),
                    month: month,
                    day: day
                )) {
                    if paymentDate >= monday && paymentDate <= sunday {
                        weeklyAmount += sub.price
                    }
                }
            }
        }
        
        return weeklyAmount
    }
    
    func updateNotification() {
        let weeklyAmount = calculateWeeklyPayments()
        // 구독 목록이 변경될 때만 알림 업데이트
        if !subs.isEmpty {
            NotificationManager.shared.updateNotificationContent(amount: weeklyAmount)
        } else {
            NotificationManager.shared.stopNotifications()
        }
    }
}

extension GlobalSub {
    func updateSubscription(id: UUID, genreId: Int, title: String, cycleNumber: String, price: Float) {
        if let index = subs.firstIndex(where: { $0.id == id }) {
            let updatedSub = Sub(id: id, genreId: genreId, title: title, cycleNumber: cycleNumber, price: price)
            objectWillChange.send()
            subs[index] = updatedSub
            saveSubscriptions()
            updateNotification()
            updateWidget()
        }
    }
}
