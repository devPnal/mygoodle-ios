import WidgetKit
import SwiftUI

public struct Sub: Codable {
    let id: UUID
    let genreId: Int
    let title: String
    let cycleNumber: String
    let price: Float
}

struct PaymentWidgetEntry: TimelineEntry {
    let date: Date
    let totalAmount: Float
    let remainingAmount: Float
}

struct Provider: TimelineProvider {
    typealias Entry = PaymentWidgetEntry
    
    func placeholder(in context: Context) -> PaymentWidgetEntry {
        PaymentWidgetEntry(date: Date(), totalAmount: 0, remainingAmount: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (PaymentWidgetEntry) -> ()) {
        let currentDate = Date()
        let defaults = UserDefaults(suiteName: "group.com.pnalapps.mygoodle.payments")
        
        if let data = defaults?.data(forKey: "subscriptions"),
           let subscriptions = try? JSONDecoder().decode([Sub].self, from: data) {
            let entry = PaymentWidgetEntry(
                date: currentDate,
                totalAmount: calculateTotalAmount(subscriptions, for: currentDate),
                remainingAmount: calculateRemainingAmount(subscriptions, for: currentDate)
            )
            completion(entry)
        } else {
            let entry = PaymentWidgetEntry(
                date: currentDate,
                totalAmount: 0,
                remainingAmount: 0
            )
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PaymentWidgetEntry>) -> ()) {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        let currentDate = Date()
        
        let defaults = UserDefaults(suiteName: "group.com.pnalapps.mygoodle.payments")
        if let data = defaults?.data(forKey: "subscriptions"),
           let subscriptions = try? JSONDecoder().decode([Sub].self, from: data) {
            let totalAmount = calculateTotalAmount(subscriptions, for: currentDate)
            let remainingAmount = calculateRemainingAmount(subscriptions, for: currentDate)
            
            let currentEntry = PaymentWidgetEntry(
                date: currentDate,
                totalAmount: totalAmount,
                remainingAmount: remainingAmount
            )
            
            if let tomorrow = calendar.date(byAdding: .day, value: 1, to: currentDate),
               let nextMidnight = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: tomorrow) {
                
                let nextTotalAmount = calculateTotalAmount(subscriptions, for: nextMidnight)
                let nextRemainingAmount = calculateRemainingAmount(subscriptions, for: nextMidnight)
                
                let nextEntry = PaymentWidgetEntry(
                    date: nextMidnight,
                    totalAmount: nextTotalAmount,
                    remainingAmount: nextRemainingAmount
                )
                
                let timeline = Timeline(entries: [currentEntry, nextEntry], policy: .atEnd)
                completion(timeline)
                return
            }
        }
        
        let entry = PaymentWidgetEntry(
            date: currentDate,
            totalAmount: 0,
            remainingAmount: 0
        )
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }

    // 계산 함수들 추가
    private func calculateTotalAmount(_ subscriptions: [Sub], for date: Date) -> Float {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        let nowMM = dateFormatter.string(from: date)
        
        var result: Float = 0.0
        for sub in subscriptions {
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

    private func calculateRemainingAmount(_ subscriptions: [Sub], for date: Date) -> Float {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        let nowMM = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "dd"
        let nowDD = dateFormatter.string(from: date)
        
        var payed: Float = 0.0
        for sub in subscriptions {
            if (Int(sub.cycleNumber)! < 100 && Int(sub.cycleNumber)! < Int(nowDD)!) {
                payed += sub.price
            }
            else {
                if (Int(sub.cycleNumber.prefix(2)) == Int(nowMM) && Int(sub.cycleNumber.suffix(2))! < Int(nowDD)!) {
                    payed += sub.price
                }
            }
        }
        let total = calculateTotalAmount(subscriptions, for: date)
        return total - payed
    }
}

struct PaymentWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        ZStack {
            VStack {
                Text("이번 달 요약").font(.headline)
                Divider()
                Spacer()
                HStack {
                    Text("총 금액")
                        .font(.system(size: 14, weight: .bold))
                    Spacer()
                    Text("\(entry.totalAmount.formatted())")
                        .font(.system(size: 14))
                }
                Spacer()
                HStack {
                    Text("남은 금액")
                        .font(.system(size: 14, weight: .bold))
                    Spacer()
                    Text("\(entry.remainingAmount.formatted())")
                        .font(.system(size: 14))
                }
                Spacer()
                Text("마지막 업데이트: \(entry.date.formatted(.dateTime.hour().minute()))")
                                    .font(.system(size: 10))
                                    .foregroundColor(.gray)
            }
        }.frame(width: .infinity, height: .infinity)
    }
}

#Preview(as: .systemSmall) {
    PaymentWidget()
} timeline: {
    PaymentWidgetEntry(
        date: Date(),
        totalAmount: 1880000,
        remainingAmount: 30000
    )
}
