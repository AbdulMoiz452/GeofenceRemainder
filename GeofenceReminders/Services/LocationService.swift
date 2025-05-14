//
//  LocationService.swift
//  GeofenceReminders
//
//  Created by Macbook Pro on 13/05/2025.
//

import Foundation
import CoreLocation

protocol LocationServiceProtocol {
    func requestAuthorization()
    func startMonitoring(region: CLCircularRegion)
}

class LocationService: NSObject, LocationServiceProtocol, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
    }
    
    func startMonitoring(region: CLCircularRegion) {
        locationManager.startMonitoring(for: region)
    }
}
