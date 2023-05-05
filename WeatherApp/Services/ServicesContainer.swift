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
    let authService: AuthService
    
    // MARK: - Start
    static func configureServices() -> ServicesContainer {
        .init(networkingService: NetworkingService(environment: Environment()),
              searchHistoryService: SearchHistoryService(),
              authService: AuthService())
    }
}

class SearchHistoryService {
    
    // MARK: - Properties
    private let defaults: UserDefaults
    private let searchHistory = "searchHistory"
    
    // MARK: - Initializer
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    // MARK: - Interface
}

// dont need this
class AuthService {
    
    // MARK: - Properties
    private let defaults: UserDefaults
    private let firstTimeViewing = "firstTimeViewing"
    
    // MARK: - Initializer
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    // MARK: - Interface
    func isReturningUser() -> Bool {
        defaults.bool(forKey: firstTimeViewing)
    }
    
    func userHasViewed() {
        defaults.set(true, forKey: firstTimeViewing)
    }
}
