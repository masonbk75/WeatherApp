//
//  NetworkingService.swift
//  WeatherApp
//
//  Created by Mason Kelly on 5/4/23.
//

import Foundation
import CoreLocation

enum NetworkError: Error {
    case timeOut
    case notFound
}

// MARK: - NetworkingService
class NetworkingService {
    
    // MARK: - Properties
    let environment: Environment
    
    private let key: String
    private let weatherBaseUrl: String = "https://api.openweathermap.org/data/2.5/weather?"
    private let geocodingBaseUrl: String = "https://api.openweathermap.org/geo/1.0/direct?"
    
    // MARK: - Initializer
    init(environment: Environment) {
        self.environment = environment
        self.key = environment.SERVICE_API_KEY
    }
    
    // MARK: - Network
    func fetchWeatherData(for coordinates: CLLocationCoordinate2D, completion: @escaping (Result<WeatherData, NetworkError>) -> Void) {
        let lat = "lat=\(coordinates.latitude)"
        let long = "&lon=\(coordinates.longitude)"
        guard let url = URL(string: (weatherBaseUrl + lat + long + key)) else { return completion(.failure(.notFound)) }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            guard let data = data else { return completion(.failure(.timeOut)) }
            
            do {
                let decoder = JSONDecoder()
                let data = try decoder.decode(WeatherData.self, from: data)
                DispatchQueue.main.async { completion(.success(data)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(.notFound)) }
            }
        }.resume()
    }
}

// MARK: - Environmen
class Environment {
    
    let dictionary: NSDictionary
    var SERVICE_API_KEY: String { dictionary.object(forKey: "SERVICE_API_KEY") as? String ?? "" }
    
    init(resourceName: String = "Keys") {
        guard let filePath = Bundle.main.path(forResource: resourceName, ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: filePath) else { fatalError("\(resourceName) not found") }
        self.dictionary = plist
    }
}
