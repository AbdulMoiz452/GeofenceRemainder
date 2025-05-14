

import Foundation
import MapKit
import Combine
import CoreLocation
import UserNotifications

class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var locations: [Location] = []
    @Published var reminders: [GeofenceReminder] = []
    @Published var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.785091, longitude: -73.968285),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @Published var showPermissionAlert: Bool = false
    @Published var isOffline: Bool = false
    @Published var logMessages: [String] = [] // Added for geofence event logging

    private let locationManager = CLLocationManager()
    private let networkService: NetworkServiceProtocol
    private let coreDataManager: CoreDataManager
    private let reminderListViewModel: ReminderListViewModel
    private var cancellables = Set<AnyCancellable>()

    init(reminderListViewModel: ReminderListViewModel) {
        self.networkService = NetworkService()
        self.coreDataManager = CoreDataManager.shared
        self.reminderListViewModel = reminderListViewModel
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                let message = granted ? "Notification permission granted" : "Notification permission denied: \(error?.localizedDescription ?? "Unknown")"
                self.logMessages.append(message)
                print(message)
            }
        }
        UNUserNotificationCenter.current().delegate = self
        print("MapViewModel initialized")
        print("Monitored regions at init: \(locationManager.monitoredRegions.map { $0.identifier })")
        fetchLocations()
        loadReminders()
        requestAuthorization()
    }

    func requestAuthorization() {
        print("Requesting always authorization")
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
    }

    func clearGeofences() {
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [region.identifier])
        }
        DispatchQueue.main.async {
            self.logMessages.append("Cleared all monitored regions")
            print("Cleared all monitored regions")
        }
    }

    func fetchLocations() {
        networkService.fetchLocations()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure = completion {
                    self?.isOffline = true
                    self?.logMessages.append("Network fetch failed: Offline mode")
                    print("Network fetch failed: Offline mode")
                }
            } receiveValue: { [weak self] locations in
                self?.locations = locations
                self?.isOffline = false
                let message = "Fetched locations: \(locations.map { "\($0.name): \($0.latitude), \($0.longitude)" })"
                self?.logMessages.append(message)
                print(message)
            }
            .store(in: &cancellables)
    }

    func loadReminders() {
        reminders = coreDataManager.fetchReminders()
        reminders.forEach { reminder in
            startMonitoring(reminder: reminder)
        }
    }

    func saveReminder(location: Location, radius: Double, note: String) {
        let uniqueId = location.id.isEmpty ? UUID().uuidString : location.id
        if let reminder = coreDataManager.saveReminder(
            id: uniqueId,
            name: location.name,
            latitude: location.latitude,
            longitude: location.longitude,
            radius: radius,
            note: note
        ) {
            reminders.append(reminder)
            startMonitoring(reminder: reminder)
            DispatchQueue.main.async {
                self.reminderListViewModel.refreshReminders()
                self.logMessages.append("Saved reminder: \(reminder.name ?? "unknown")")
                print("Saved reminder: \(reminder.name ?? "unknown")")
            }
            // Test time-based notification
            let testContent = UNMutableNotificationContent()
            testContent.title = "Test Notification"
            testContent.body = "Testing notification system for \(location.name)"
            testContent.sound = .default
            let testTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let testRequest = UNNotificationRequest(identifier: "test_\(uniqueId)", content: testContent, trigger: testTrigger)
            UNUserNotificationCenter.current().add(testRequest) { error in
                let message = error != nil ? "Test notification error: \(error!)" : "Test notification scheduled for \(uniqueId)"
                DispatchQueue.main.async {
                    self.logMessages.append(message)
                    print(message)
                }
            }
        } else {
            let message = "Failed to save reminder for location: \(location.name)"
            DispatchQueue.main.async {
                self.logMessages.append(message)
                print(message)
            }
        }
    }

    func startMonitoring(reminder: GeofenceReminder) {
        guard let id = reminder.id else {
            let message = "Error: Reminder ID is nil for \(reminder.name ?? "unknown")"
            DispatchQueue.main.async {
                self.logMessages.append(message)
                print(message)
            }
            return
        }
        let coordinate = CLLocationCoordinate2D(latitude: reminder.latitude, longitude: reminder.longitude)
        guard reminder.radius > 0, -90...90 ~= reminder.latitude, -180...180 ~= reminder.longitude else {
            let message = "Error: Invalid geofence parameters for \(reminder.name ?? "unknown") - lat: \(reminder.latitude), lon: \(reminder.longitude), radius: \(reminder.radius)"
            DispatchQueue.main.async {
                self.logMessages.append(message)
                print(message)
            }
            return
        }
        let region = CLCircularRegion(center: coordinate, radius: reminder.radius, identifier: id)
        region.notifyOnEntry = true
        region.notifyOnExit = true
        locationManager.startMonitoring(for: region)
        let message = "Started monitoring geofence: ID=\(id), Name=\(reminder.name ?? "unknown"), Center=(\(coordinate.latitude), \(coordinate.longitude)), Radius=\(reminder.radius)m"
        DispatchQueue.main.async {
            self.logMessages.append(message)
            print(message)
        }

        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Geofence Alert"
        notificationContent.body = "You have entered/exited \(reminder.name ?? "a location")"
        notificationContent.sound = .default

        let trigger = UNLocationNotificationTrigger(region: region, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: notificationContent, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            let message = error != nil ? "Failed to schedule notification for \(id): \(error!)" : "Notification scheduled for \(id): \(reminder.name ?? "unknown")"
            DispatchQueue.main.async {
                self.logMessages.append(message)
                print(message)
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let statusMessage: String
        print("Location authorization status changed: \(status.rawValue)")
        switch status {
        case .authorizedAlways:
            statusMessage = "Always authorization granted"
            locationManager.startUpdatingLocation() // Ensure location updates
        case .authorizedWhenInUse:
            statusMessage = "When in use authorization granted"
            print("Requesting always authorization again")
            locationManager.requestAlwaysAuthorization()
        case .denied:
            statusMessage = "Location access denied"
            showPermissionAlert = true
        case .restricted:
            statusMessage = "Location access restricted"
            showPermissionAlert = true
        case .notDetermined:
            statusMessage = "Authorization not determined"
            print("Authorization still not determined")
        @unknown default:
            statusMessage = "Unknown authorization status"
        }
        DispatchQueue.main.async {
            self.logMessages.append("Authorization status: \(statusMessage)")
            print("Logged: \(statusMessage)")
        }
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let message = "Entered geofence: \(region.identifier)"
        DispatchQueue.main.async {
            self.logMessages.append(message)
            print(message)
        }
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let message = "Exited geofence: \(region.identifier)"
        DispatchQueue.main.async {
            self.logMessages.append(message)
            print(message)
        }
    }

    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        let message = "Geofence monitoring failed for \(region?.identifier ?? "unknown"): \(error.localizedDescription)"
        DispatchQueue.main.async {
            self.logMessages.append(message)
            print(message)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let message = "Location update: (\(location.coordinate.latitude), \(location.coordinate.longitude))"
            print(message)
        }
    }

    // Test notification for debugging
    func testNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.body = "Testing notification system"
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "test_\(UUID().uuidString)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
        DispatchQueue.main.async {
            self.logMessages.append("Test notification scheduled")
            print("Test notification scheduled")
        }
    }
}

extension MapViewModel: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let message = "Notification will present: \(notification.request.identifier)"
        DispatchQueue.main.async {
            self.logMessages.append(message)
            print(message)
        }
        completionHandler([.banner, .sound, .badge])
    }
}
