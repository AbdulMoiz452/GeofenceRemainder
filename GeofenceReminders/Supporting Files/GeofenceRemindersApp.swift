

import SwiftUI
import UserNotifications

@main
struct GeofenceRemindersApp: App {
    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            print("Notification authorization - Granted: \(granted), Error: \(error?.localizedDescription ?? "none")")
        }
        UNUserNotificationCenter.current().delegate = NotificationDelegate()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
