//
//  MapViewModelTests.swift
//  GeofenceReminders
//
//  Created by Macbook Pro on 13/05/2025.
//
//
//import XCTest
//import CoreData
//@testable import GeofenceReminders // Replace with your module name
//
//class CoreDataManagerTests: XCTestCase {
//    var coreDataManager: CoreDataManager!
//    var persistentContainer: NSPersistentContainer!
//
//    override func setUpWithError() throws {
//        // Set up in-memory Core Data stack
//        persistentContainer = NSPersistentContainer(name: "GeofenceReminders")
//        let description = NSPersistentStoreDescription()
//        description.type = NSInMemoryStoreType
//        persistentContainer.persistentStoreDescriptions = [description]
//        
//        persistentContainer.loadPersistentStores { _, error in
//            if let error = error {
//                fatalError("Failed to load in-memory store: \(error)")
//            }
//        }
//        
//        // Initialize CoreDataManager with the in-memory container
//        coreDataManager = CoreDataManager()
//        // Use reflection to set the private persistentContainer
//        let mirror = Mirror(reflecting: coreDataManager!)
//        if let containerProperty = mirror.children.first(where: { $0.label == "persistentContainer" }) {
//            let containerPointer = UnsafeMutablePointer<NSPersistentContainer>.allocate(capacity: 1)
//            containerPointer.pointee = persistentContainer
//            withUnsafePointer(to: containerPointer) { pointer in
//                _ = pointer.withMemoryRebound(to: NSPersistentContainer.self, capacity: 1) { bound in
//                    let _ = withUnsafeMutableBytes(of: &coreDataManager!) { raw in
//                        raw.storeBytes(of: bound, toByteOffset: 0, as: NSPersistentContainer.self)
//                    }
//                }
//            }
//        }
//    }
//
//    override func tearDownWithError() throws {
//        coreDataManager = nil
//        persistentContainer = nil
//    }
//
//    func testSaveReminderSuccess() throws {
//        // Given
//        let id = "test-id-1"
//        let name = "Test Location"
//        let latitude = 40.785091
//        let longitude = -73.968285
//        let radius = 100.0
//        let note = "Test note"
//
//        // When
//        let savedReminder = coreDataManager.saveReminder(
//            id: id,
//            name: name,
//            latitude: latitude,
//            longitude: longitude,
//            radius: radius,
//            note: note
//        )
//
//        // Then
//        XCTAssertNotNil(savedReminder, "Saved reminder should not be nil")
//        XCTAssertEqual(savedReminder?.id, id, "Saved reminder ID should match")
//        XCTAssertEqual(savedReminder?.name, name, "Saved reminder name should match")
//        XCTAssertEqual(savedReminder?.latitude, latitude, "Saved reminder latitude should match")
//        XCTAssertEqual(savedReminder?.longitude, longitude, "Saved reminder longitude should match")
//        XCTAssertEqual(savedReminder?.radius, radius, "Saved reminder radius should match")
//        XCTAssertEqual(savedReminder?.note, note, "Saved reminder note should match")
//    }
//
//    func testSaveReminderWithEmptyID() throws {
//        // Given
//        let id = ""
//        let name = "Test Location"
//        let latitude = 40.785091
//        let longitude = -73.968285
//        let radius = 100.0
//        let note = "Test note"
//
//        // When
//        let savedReminder = coreDataManager.saveReminder(
//            id: id,
//            name: name,
//            latitude: latitude,
//            longitude: longitude,
//            radius: radius,
//            note: note
//        )
//
//        // Then
//        XCTAssertNil(savedReminder, "Saving reminder with empty ID should return nil")
//    }
//
//    func testFetchReminders() throws {
//        // Given
//        let id1 = "test-id-1"
//        let name1 = "Location 1"
//        let id2 = "test-id-2"
//        let name2 = "Location 2"
//        
//        _ = coreDataManager.saveReminder(
//            id: id1,
//            name: name1,
//            latitude: 40.785091,
//            longitude: -73.968285,
//            radius: 100.0,
//            note: "Note 1"
//        )
//        _ = coreDataManager.saveReminder(
//            id: id2,
//            name: name2,
//            latitude: 41.785091,
//            longitude: -74.968285,
//            radius: 200.0,
//            note: "Note 2"
//        )
//
//        // When
//        let fetchedReminders = coreDataManager.fetchReminders()
//
//        // Then
//        XCTAssertEqual(fetchedReminders.count, 2, "Should fetch exactly 2 reminders")
//        XCTAssertTrue(fetchedReminders.contains { $0.id == id1 && $0.name == name1 }, "Reminder 1 should be fetched")
//        XCTAssertTrue(fetchedReminders.contains { $0.id == id2 && $0.name == name2 }, "Reminder 2 should be fetched")
//    }
//
//    func testDeleteReminder() throws {
//        // Given
//        let id = "test-id-1"
//        let savedReminder = coreDataManager.saveReminder(
//            id: id,
//            name: "Test Location",
//            latitude: 40.785091,
//            longitude: -73.968285,
//            radius: 100.0,
//            note: "Test note"
//        )
//        XCTAssertNotNil(savedReminder, "Reminder should be saved before deletion")
//
//        // When
//        coreDataManager.deleteReminder(savedReminder!)
//        let fetchedReminders = coreDataManager.fetchReminders()
//
//        // Then
//        XCTAssertEqual(fetchedReminders.count, 0, "No reminders should remain after deletion")
//        XCTAssertFalse(fetchedReminders.contains { $0.id == id }, "Deleted reminder should not be fetched")
//    }
//
//    func testFetchEmptyReminders() throws {
//        // When
//        let fetchedReminders = coreDataManager.fetchReminders()
//
//        // Then
//        XCTAssertEqual(fetchedReminders.count, 0, "Should fetch 0 reminders when none are saved")
//    }
//}
