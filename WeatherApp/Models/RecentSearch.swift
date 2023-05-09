//
//  RecentSearch.swift
//  WeatherApp
//
//  Created by Mason Kelly on 5/8/23.
//

import Foundation
import CoreLocation

struct RecentSearch: Codable, Equatable, Hashable {
    let name: String
    let lat: CLLocationDegrees
    let lon: CLLocationDegrees
    
    var coordinates: CLLocationCoordinate2D {
        let coords: CLLocationCoordinate2D = .init(latitude: lat, longitude: lon)
        return coords
    }
    
    // MARK: - Initializer
    init(name: String, lat: CLLocationDegrees, lon: CLLocationDegrees) {
        self.name = name
        self.lat = lat
        self.lon = lon
    }
    
    // MARK: - Convenience
    init(weatherData: WeatherData) {
        self.init(name: weatherData.cityName, lat: weatherData.coord.lat, lon: weatherData.coord.lon)
    }
}
