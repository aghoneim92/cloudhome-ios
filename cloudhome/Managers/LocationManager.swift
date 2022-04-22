//
//  LocationManager.swift
//  cloudhome
//
//  Created by Ahmed Ghoneim on 31/03/2022.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    var continuation: CheckedContinuation<Void, Never>? = nil
    
    func getAuthorizationStatus() -> CLAuthorizationStatus {
        return locationManager.authorizationStatus
    }
    
    func requestPermissions() async {
        return await withCheckedContinuation { continuation in
            self.continuation = continuation
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        continuation?.resume()
        continuation = nil
    }
}
