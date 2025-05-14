import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "GeofenceReminders")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            } else {
                print("Core Data stack loaded successfully")
            }
        }
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveReminder(id: String, name: String, latitude: Double, longitude: Double, radius: Double, note: String) -> GeofenceReminder? {
        guard !id.isEmpty else {
            print("Error: Reminder ID cannot be empty")
            return nil
        }
        
        let context = viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "GeofenceReminder", in: context) else {
            print("Error: Entity 'GeofenceReminder' not found in Core Data model")
            return nil
        }
        
        let reminder = GeofenceReminder(entity: entity, insertInto: context)
        reminder.id = id
        reminder.name = name
        reminder.latitude = latitude
        reminder.longitude = longitude
        reminder.radius = radius
        reminder.note = note
        
        do {
            try context.save()
            print("Reminder saved successfully: \(name)")
            return reminder
        } catch {
            print("Failed to save reminder: \(error)")
            return nil
        }
    }
    
    func fetchReminders() -> [GeofenceReminder] {
        let context = viewContext
        let fetchRequest: NSFetchRequest<GeofenceReminder> = GeofenceReminder.fetchRequest()
        
        do {
            let reminders = try context.fetch(fetchRequest)
            print("Fetched \(reminders.count) reminders")
            return reminders
        } catch {
            print("Failed to fetch reminders: \(error)")
            return []
        }
    }
    
    func deleteReminder(_ reminder: GeofenceReminder) {
        let context = viewContext
        context.delete(reminder)
        
        do {
            try context.save()
            print("Reminder deleted successfully")
        } catch {
            print("Failed to delete reminder: \(error)")
        }
    }
}
