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
    case geoURL
    case geoNotFound
    case imageError
}

// MARK: - NetworkingService
class NetworkingService {
    
    // MARK: - Properties
    let environment: Environment
    
    private let key: String
    private let weatherBaseUrl: String = "https://api.openweathermap.org/data/2.5/weather?"
    private let geocodingBaseUrl: String = "https://api.openweathermap.org/geo/1.0/direct?"
    private let imageBaseUrl: String = "https://openweathermap.org/img/wn/"
    private let imageSuffix: String = "@2x.png"
    
    // MARK: - Initializer
    init(environment: Environment) {
        self.environment = environment
        self.key = environment.SERVICE_API_KEY
    }
    
    // MARK: - Network
    func fetchWeatherData(for coordinates: CLLocationCoordinate2D, completion: @escaping (Result<WeatherData, NetworkError>) -> Void) {
        let lat = "lat=\(coordinates.latitude)"
        let long = "&lon=\(coordinates.longitude)"
        let units = "&units=imperial"
        guard let url = URL(string: (weatherBaseUrl + lat + long + key + units)) else { return completion(.failure(.notFound)) }
        
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
    
    func fetchCoordinates(for input: String, completion: @escaping (Result<[RecentSearch], NetworkError>) -> Void) {
        let query = "q=\(input)"
        let limit = "&limit=5"
        guard let url = URL(string: (geocodingBaseUrl + query + limit + key)) else { return completion(.failure(.geoURL)) }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            guard let data = data else { return completion(.failure(.timeOut)) }
            
            do {
                let decoder = JSONDecoder()
                let data = try decoder.decode([RecentSearch].self, from: data)
                DispatchQueue.main.async { completion(.success(data)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(.geoNotFound)) }
            }
        }.resume()
    }
    
    func loadImage(named: String?, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        guard let name = named, let url = URL(string: imageBaseUrl + name + imageSuffix) else { return completion(.failure(.imageError)) }
        let fileCachePath = FileManager.default.temporaryDirectory.appending(path: url.lastPathComponent)
        
        download(url: url, toFile: fileCachePath) { error in
            do {
                let data = try Data(contentsOf: fileCachePath)
                completion(.success(data))
            } catch {
                completion(.failure(.imageError))
            }
        }
    }
    
    private func download(url: URL, toFile file: URL, completion: @escaping (Error?) ->Void) {
        let task = URLSession.shared.downloadTask(with: url) { (url, response, error) in
            guard let url = url else { return completion(error) }
            
            do {
                if FileManager.default.fileExists(atPath: file.path) {
                    try FileManager.default.removeItem(at: file)
                }
                try FileManager.default.copyItem(at: url, to: file)
                DispatchQueue.main.async { completion(nil) }
            } catch let error {
                DispatchQueue.main.async { completion(error) }
            }
        }
        task.resume()
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
