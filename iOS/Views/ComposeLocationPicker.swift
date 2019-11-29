//
//  LocationPicker.swift
//  iOS
//
//  Created by David Hariri on 2019-11-17.
//  Copyright © 2019 David Hariri. All rights reserved.
//

import SwiftUI
import CoreLocation
import MapKit

final class LocationProvider: NSObject, ObservableObject, CLLocationManagerDelegate {
    var manager: CLLocationManager
    var isEnabled: Bool = false
    var locations: [CLLocation]
    @Published var places: [CLPlacemark]
    
    override init() {
        self.manager = CLLocationManager()
        self.locations = []
        self.places = []
        
        super.init()
        
        self.manager.requestWhenInUseAuthorization()
        self.manager.delegate = self
    }
    
    func fetchNearbyPlaces(completion: @escaping (_ places: [CLPlacemark]) -> Void) {
        completion([])
    }
    
    func translateLocationsToPlaces() {
        var matchingItems:[MKMapItem] = []
        
        if self.locations.count < 1 {
            return
        }
        
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(self.locations[0],
                    completionHandler: { (placemarks, error) in
            if error == nil {
                self.places = placemarks!
                print(self.places)
            }
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            print("Enabled location services")
            self.manager.startUpdatingLocation()
            self.isEnabled = true
        default:
            print("Denied or disabled location services")
            self.isEnabled = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locations = locations
        self.translateLocationsToPlaces()
        self.manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

struct LocationCellView: View {
    var place: CLPlacemark
    
    init(_ place: CLPlacemark) {
        self.place = place
    }
    
    var body: some View {
        Button(action: {
            self.choosePlace()
        }) {
            Text(place.name!)
        }
    }
    
    private func choosePlace() {
        print("yo")
    }
}

struct LocationPickerView: View {
    @EnvironmentObject var locProvider: LocationProvider
    
    var body: some View {
        VStack(alignment: .leading) {
            List {
                ForEach(self.locProvider.places, id: \.name) { place in
                    LocationCellView(place)
                }
            }
        }
    }
}
