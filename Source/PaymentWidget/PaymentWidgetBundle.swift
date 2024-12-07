import WidgetKit
import SwiftUI

@main
struct PaymentWidgetBundle: WidgetBundle {
    var body: some Widget {
        PaymentWidget()
    }
}

struct PaymentWidget: Widget {
    private let kind: String = "PaymentWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PaymentWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("결제 금액 위젯")
        .description("이번 달 총 결제 금액과 남은 결제 금액을 표시합니다")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
