import WidgetKit

extension GlobalSub {
    func updateWidget() {
        let defaults = UserDefaults(suiteName: "group.com.pnalapps.mygoodle.payments")
        defaults?.set(calculatePlannedMoney(), forKey: "totalAmount")
        defaults?.set(calculateLeftMoney(), forKey: "remainingAmount")
        
        // 위젯 리로드 요청
        WidgetCenter.shared.reloadAllTimelines()
    }
}
