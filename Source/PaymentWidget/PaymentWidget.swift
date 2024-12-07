import WidgetKit
import SwiftUI

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
        let entry = PaymentWidgetEntry(
            date: Date(),
            totalAmount: loadTotalAmount(),
            remainingAmount: loadRemainingAmount()
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PaymentWidgetEntry>) -> ()) {
        let currentDate = Date()
        let entry = PaymentWidgetEntry(
            date: currentDate,
            totalAmount: loadTotalAmount(),
            remainingAmount: loadRemainingAmount()
        )
        
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func loadTotalAmount() -> Float {
        let defaults = UserDefaults(suiteName: "group.com.pnalapps.mygoodle.payments")
        return defaults?.float(forKey: "totalAmount") ?? 0
    }
    
    private func loadRemainingAmount() -> Float {
        let defaults = UserDefaults(suiteName: "group.com.pnalapps.mygoodle.payments")
        return defaults?.float(forKey: "remainingAmount") ?? 0
    }
}

// 위젯 뷰
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
