import SwiftUI
import BackgroundTasks

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        registerBackgroundTasks()
        return true
    }
    
    func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "com.pnalapps.mygoodle.refresh",
            using: nil
        ) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
    }
    
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.pnalapps.mygoodle.refresh")
        request.earliestBeginDate = Calendar.current.date(byAdding: .hour, value: 24, to: Date())
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
        }
    }
    
    func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh()
        
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        let globalSub = GlobalSub()
        if UserDefaults.standard.bool(forKey: "WeeklyNotificationEnabled") {
            let weeklyAmount = globalSub.calculateWeeklyPayments()
            NotificationManager.shared.updateNotificationContent(amount: weeklyAmount)
            task.setTaskCompleted(success: true)
        } else {
            task.setTaskCompleted(success: false)
        }
    }
}
