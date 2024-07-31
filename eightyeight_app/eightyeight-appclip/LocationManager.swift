//
//  LocationManager.swift
//  eightyeight-appclip
//
//  Created by yoshioka on 2024/07/30.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    
    @Published var latitude: Double?
    @Published var longtitude: Double?
    @Published var placeName: String?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        debugPrint("didUpdateLocations with \(locations.count) locations")
        guard let location = locations.last else { return }
        latitude = location.coordinate.latitude
        longtitude = location.coordinate.longitude
        debugPrint("New location : \(location.coordinate.latitude), \(location.coordinate.longitude)")
        
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                debugPrint("Failed to find placemark: \(error.localizedDescription)")
                return
            }
            
            guard let placemark = placemarks?.first else {
                debugPrint("No placemark found")
                return
            }
            
            debugPrint("New placemark name = \(String(describing: placemark.name))")
            debugPrint("New placement full = \(String(describing: placemarks))")
            self.placeName = placemark.name
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugPrint("Failed to find user's location: \(error.localizedDescription)")
        latitude = nil
        longtitude = nil
        placeName = nil
    }
}
