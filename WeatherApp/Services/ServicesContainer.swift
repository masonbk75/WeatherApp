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
    
    // MARK: - Start
    static func configureServices() -> ServicesContainer {
        .init(networkingService: NetworkingService(environment: Environment()),
              searchHistoryService: SearchHistoryService())
    }
}

class SearchHistoryService {
    
    // MARK: - Properties
    private let defaults: UserDefaults
    private let searchHistoryKey = "searchHistory"
    
    lazy var recentSearches: [RecentSearch] = {
        guard let data = defaults.data(forKey: searchHistoryKey) else { return [] }
        do {
            return try JSONDecoder().decode([RecentSearch].self, from: data)
        } catch {
            debugPrint("Could not read recent searchs: \(error)")
            return []
        }
    }()
    
    // MARK: - Initializer
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    // MARK: - Interface
    func save(_ recentSearch: RecentSearch) {
        var searchHistory: [RecentSearch] = recentSearches
        debugPrint("Old: \(searchHistory)")
        guard !searchHistory.contains(where: { $0 == recentSearch }) else { return }
        searchHistory.append(recentSearch)
        do {
            let data = try JSONEncoder().encode(searchHistory)
            debugPrint("new: \(data.first)")
            defaults.set(data, forKey: searchHistoryKey)
        } catch {
            debugPrint("Could not save recent search: \(recentSearch)")
        }
    }
}
