import SwiftUI
import WidgetKit

@main
struct mygoodleApp: App {
    
    @StateObject private var globalSub = GlobalSub()
    @AppStorage("AppDarkMode") private var appDarkMode = 0
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        let notificationGlobalSub = GlobalSub()
        if UserDefaults.standard.bool(forKey: "WeeklyNotificationEnabled") {
            notificationGlobalSub.updateNotification()
            (UIApplication.shared.delegate as? AppDelegate)?.scheduleAppRefresh()
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
                    if UserDefaults.standard.bool(forKey: "WeeklyNotificationEnabled") {
                        globalSub.updateNotification()  // 여기 추가
                    }
                }
        }
    }
}
