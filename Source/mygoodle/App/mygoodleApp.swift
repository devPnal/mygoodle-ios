import SwiftUI
import WidgetKit

@main
struct mygoodleApp: App {
    
    @StateObject private var globalSub = GlobalSub()
    @AppStorage("AppDarkMode") private var appDarkMode = 0

    init() {
        let notificationGlobalSub = GlobalSub()
        NotificationManager.shared.requestAuthorization()
        if UserDefaults.standard.bool(forKey: "WeeklyNotificationEnabled") {
            NotificationManager.shared.updateNotificationContent(amount: notificationGlobalSub.calculateWeeklyPayments())
        }
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    var currentAppDarkMode: ColorScheme? {
        if appDarkMode == AppDarkMode.system.info.id {
            return .none
        }
        else if appDarkMode == AppDarkMode.light.info.id {
            return .light
        }
        else if appDarkMode == AppDarkMode.dark.info.id {
            return .dark
        }
        return .none
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(globalSub)
                .preferredColorScheme(currentAppDarkMode)
                .onAppear {
                    globalSub.updateNotification()
                }
        }
    }
}
