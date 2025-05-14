


import Foundation

class ReminderListViewModel: ObservableObject {
    @Published var reminders: [GeofenceReminder] = []
    private let coreDataManager = CoreDataManager.shared
    
    init() {
        loadReminders()
    }
    
    func loadReminders() {
        reminders = coreDataManager.fetchReminders()
    }
    
    func refreshReminders() {
        loadReminders()
    }
    
    func deleteReminder(_ reminder: GeofenceReminder) {
        coreDataManager.deleteReminder(reminder)
        loadReminders()
    }
}
