//
//  ServicesContainer.swift
//  WeatherApp
//
//  Created by Mason Kelly on 5/4/23.
//

import Foundation

struct ServicesContainer {
    
    // MARK: - Properties
    let networkingService: NetworkingService
    let searchHistoryService: SearchHistoryService
    let iconService: IconService
    
    // MARK: - Start
    static func configureServices() -> ServicesContainer {
        .init(networkingService: NetworkingService(environment: Environment()),
              searchHistoryService: SearchHistoryService(), iconService: IconService())
    }
}
