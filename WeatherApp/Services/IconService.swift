//
//  IconService.swift
//  WeatherApp
//
//  Created by Mason Kelly on 5/10/23.
//

import Foundation

class IconService {
    
    // MARK: - Properties
    private let imageBaseUrl: String = "https://openweathermap.org/img/wn/"
    private let imageSuffix: String = "@2x.png"
    
    // MARK: - Interface
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
    
    // MARK: - Helpers
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
