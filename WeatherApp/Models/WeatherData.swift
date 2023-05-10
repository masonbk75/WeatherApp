//
//  WeatherData.swift
//  WeatherApp
//
//  Created by Mason Kelly on 5/4/23.
//

import Foundation
import CoreLocation

// MARK: - WeatherData
struct WeatherData: Decodable {
    let coord: Coordinates
    let cityName: String
    let overview: [Overview]
    let mainTemp: MainTemperature
    let rain: Rain?
    let snow: Snow?
    let clouds: Clouds
    let wind: Wind
    
    enum CodingKeys: String, CodingKey {
        case rain, snow, clouds, wind, coord
        case cityName = "name"
        case overview = "weather"
        case mainTemp = "main"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.coord = try container.decode(Coordinates.self, forKey: .coord)
        self.cityName = try container.decode(String.self, forKey: .cityName)
        self.overview = try container.decode([Overview].self, forKey: .overview)
        self.mainTemp = try container.decode(MainTemperature.self, forKey: .mainTemp)
        self.rain = try container.decodeIfPresent(Rain.self, forKey: .rain)
        self.snow = try container.decodeIfPresent(Snow.self, forKey: .snow)
        self.clouds = try container.decode(Clouds.self, forKey: .clouds)
        self.wind = try container.decode(Wind.self, forKey: .wind)
    }
}

// MARK: - Coordinates
struct Coordinates: Decodable {
    let lon: CLLocationDegrees
    let lat: CLLocationDegrees
}

// MARK: - MainTemperature
struct MainTemperature: Decodable {
    let temp: Double
    let feelsLike: Double
    let humidity: Double
    
    enum CodingKeys: String, CodingKey {
        case temp, humidity
        case feelsLike = "feels_like"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.temp = try container.decode(Double.self, forKey: .temp)
        self.humidity = try container.decode(Double.self, forKey: .humidity)
        self.feelsLike = try container.decode(Double.self, forKey: .feelsLike)
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

// MARK: - Rain
struct Rain: Decodable {
    let pastHour: Double?
    let pastThreeHours: Double?
    
    enum CodingKeys: String, CodingKey {
        case pastHour = "1h"
        case pastThreeHours = "3h"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.pastHour = try container.decodeIfPresent(Double.self, forKey: .pastHour)
        self.pastThreeHours = try container.decodeIfPresent(Double.self, forKey: .pastThreeHours)
    }
}

// MARK: - Snow
struct Snow: Decodable {
    let pastHour: Double?
    let pastThreeHours: Double?
    
    enum CodingKeys: String, CodingKey {
        case pastHour = "1h"
        case pastThreeHours = "3h"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.pastHour = try container.decodeIfPresent(Double.self, forKey: .pastHour)
        self.pastThreeHours = try container.decodeIfPresent(Double.self, forKey: .pastThreeHours)
    }
}

// MARK: - Wind
struct Wind: Decodable {
    let speed: Double
    let deg: Double
}

// MARK: - Clouds
struct Clouds: Decodable {
    let all: Double
}
