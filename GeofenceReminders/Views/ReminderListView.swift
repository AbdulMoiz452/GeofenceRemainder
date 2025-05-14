



import SwiftUI

struct ReminderListView: View {
    @ObservedObject var viewModel: ReminderListViewModel
    @ObservedObject var mapViewModel: MapViewModel
    @State private var notificationDelegate = NotificationDelegate()

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.reminders, id: \.id) { reminder in
                    VStack(alignment: .leading) {
                        Text(reminder.name ?? "Unknown")
                            .font(.headline)
                        Text(reminder.note ?? "No note")
                            .font(.subheadline)
                        Text("Radius: \(Int(reminder.radius))m")
                            .font(.caption)
                        Text("Coordinates: \(String(format: "%.6f", reminder.latitude)), \(String(format: "%.6f", reminder.longitude))")
                            .font(.caption)
                    }
                }
                .onDelete { indexSet in
                    indexSet.forEach { viewModel.deleteReminder(viewModel.reminders[$0]) }
                }

                // Control buttons
                Button("Request Location Authorization") {
                    mapViewModel.requestAuthorization()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                Button("Test Notification") {
                    mapViewModel.testNotification()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                Button("Clear Geofences") {
                    mapViewModel.clearGeofences()
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .navigationTitle("Reminders")
            // Log display
            .safeAreaInset(edge: .bottom) {
                List(mapViewModel.logMessages, id: \.self) { message in
                    Text(message)
                        .font(.caption)
                }
                .frame(height: 150)
            }
        }
        .onAppear {
            UNUserNotificationCenter.current().delegate = notificationDelegate
        }
    }
}

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
        print("Notification will present: \(notification.request.identifier)")
    }
}

struct ReminderListView_Previews: PreviewProvider {
    static var previews: some View {
        ReminderListView(viewModel: ReminderListViewModel(), mapViewModel: MapViewModel(reminderListViewModel: ReminderListViewModel()))
    }
}



