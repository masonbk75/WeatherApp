//
//  SearchHistoryService.swift
//  WeatherApp
//
//  Created by Mason Kelly on 5/10/23.
//

import Foundation

class SearchHistoryService {
    
    // MARK: - Properties
    private let defaults: UserDefaults
    private let searchHistoryKey = "searchHistoryKey"
    private var observer: NSKeyValueObservation?
    var updatedSearches: [RecentSearch] = []
    
    // MARK: - Lazy
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
        observer = defaults.observe(\.searchHistoryKey, options: [.initial, .new], changeHandler: { defaults, change in
            guard let data = change.newValue else { return }
            self.decodeNewData(data: data)
        })
    }
    
    deinit {
        observer?.invalidate()
    }
    
    // MARK: - Interface
    func save(_ recentSearch: RecentSearch) {
        var searchHistory: [RecentSearch] = recentSearches
        guard !searchHistory.contains(where: { $0 == recentSearch }) else { return }
        searchHistory.append(recentSearch)
        do {
            let data = try JSONEncoder().encode(searchHistory)
            defaults.set(data, forKey: searchHistoryKey)
        } catch {
            debugPrint("Could not save recent search: \(recentSearch)")
        }
    }
}
   
// MARK: - Helpers
private extension SearchHistoryService {
        
    func decodeNewData(data: Data?) {
        guard let data = data else { return }
        do {
            let newSearches = try JSONDecoder().decode([RecentSearch].self, from: data)
            let unique = Array(Set(newSearches + self.updatedSearches))
            self.updatedSearches = unique
        } catch {
            debugPrint("Could not read recent searchs: \(error)")
        }
    }
}
    
// MARK: - UserDefaults
extension UserDefaults {
    
    @objc dynamic var searchHistoryKey: Data? {
        return data(forKey: "searchHistoryKey")
    }
}
