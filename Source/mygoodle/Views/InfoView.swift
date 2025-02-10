import SwiftUI

struct InfoView: View {
    @AppStorage("AppDarkMode") private var appDarkMode = 0
    @AppStorage("WeeklyNotificationEnabled") private var notificationEnabled = false
    @Environment(\.dismiss) private var dismiss
    @State private var showingDisclaimerAlert = false
    @State private var showingNotificationAlert = false
    @StateObject private var globalSub = GlobalSub()
    
    var body: some View {
        NavigationStack {
            List {
                Section(footer: Link("시스템 알림 설정", destination: URL(string: UIApplication.openSettingsURLString)!)) {
                    Picker("화면 테마", selection: $appDarkMode) {
                        ForEach(AppDarkMode.allCases, id:\.self) { item in
                            Text(item.info.value).tag(item.info.id)
                        }
                    }.onChange(of: appDarkMode) { dismiss(); }
                    HStack {
                        Text("주간 알림")
                        Spacer()
                        Toggle("", isOn: $notificationEnabled)
                            .labelsHidden()
                            .onChange(of: notificationEnabled) { oldValue, newValue in
                                if newValue {
                                    requestNotificationPermission()
                                } else {
                                    NotificationManager.shared.stopNotifications()
                                }
                            }
                    }
                }
                    
                Section {
                    HStack {
                        Text("버전")
                        Spacer()
                        Text(String((Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String)!))
                            .foregroundStyle(Color.gray)
                    }
                    HStack {
                        Text("만든 사람")
                        Spacer()
                        Text("프날 Pnal (apps@pnal.dev)")
                            .foregroundStyle(Color.gray)
                    }
                }
                Section {
                    Link("공식 사이트", destination: URL(string: "https://pnal.dev/mygoodle")!)
                    Link("이 앱에 대한 소스코드 보러 가기", destination: URL(string: "https://github.com/devPnal/mygoodle-ios")!)
                    Button(action: {
                        self.showingDisclaimerAlert.toggle()
                    }, label: {
                        Text("면책 조항")
                    }).alert(isPresented: $showingDisclaimerAlert) {
                        Alert(title: Text("면책 조항"), message: Text("본 앱에서 계산하는 금액은 틀릴 수 있으니, 반드시 교차 검증하여 지출 계획을 세우시기 바랍니다."),
                              dismissButton: .default(Text("확인")))
                    }
                }
            }
            .navigationTitle("설정 및 정보")
            .alert("알림 권한 필요", isPresented: $showingNotificationAlert) {
                Button("설정으로 이동") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("취소") {
                    notificationEnabled = false
                }
            } message: {
                Text("주간 알림을 받으려면 설정에서 알림을 허용해주세요.")
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            DispatchQueue.main.async {
                if success {
                    // NotificationManager.shared.updateNotificationContent(amount: GlobalSub().calculateWeeklyPayments()) //단일 알림 생성 방식
                    NotificationManager.shared.scheduleYearlyNotifications(globalSub: globalSub) //52주 알림 생성 방식
                } else {
                    notificationEnabled = false
                    showingNotificationAlert = true
                }
            }
        }
    }
}
