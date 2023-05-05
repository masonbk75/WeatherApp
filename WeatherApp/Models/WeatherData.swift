//
//  WeatherData.swift
//  WeatherApp
//
//  Created by Mason Kelly on 5/4/23.
//

import Foundation

// MARK: - WeatherData
struct WeatherData: Decodable {
    let cityName: String
    let overview: [Overview]
    let mainTemp: MainTemperature
    
    enum CodingKeys: String, CodingKey {
        case cityName = "name"
        case overview = "weather"
        case mainTemp = "main"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.cityName = try container.decode(String.self, forKey: .cityName)
        self.overview = try container.decode([Overview].self, forKey: .overview)
        self.mainTemp = try container.decode(MainTemperature.self, forKey: .mainTemp)
    }
}

// MARK: - MainTemperature
struct MainTemperature: Decodable {
    let temp: Double
    let feelsLike: Double
    let min: Double // optional
    let max: Double
    let humidity: Double
    
    enum CodingKeys: String, CodingKey {
        case temp, humidity
        case feelsLike = "feels_like"
        case min = "temp_min"
        case max = "temp_max"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.temp = try container.decode(Double.self, forKey: .temp)
        self.humidity = try container.decode(Double.self, forKey: .humidity)
        self.feelsLike = try container.decode(Double.self, forKey: .feelsLike)
        self.min = try container.decode(Double.self, forKey: .min)
        self.max = try container.decode(Double.self, forKey: .max)
    }
}

// MARK: - Overview
struct Overview: Decodable {
    let description: String
    let iconName: String
    
    enum CodingKeys: String, CodingKey {
        case description
        case iconName = "icon"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.description = try container.decode(String.self, forKey: .description)
        self.iconName = try container.decode(String.self, forKey: .iconName)
    }
}
