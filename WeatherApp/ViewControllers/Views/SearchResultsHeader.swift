//
//  SearchResultsHeader.swift
//  WeatherApp
//
//  Created by Mason Kelly on 5/8/23.
//

import UIKit

class SearchResultsHeader: UICollectionReusableView {
    
    // MARK: - IBOutlets
    @IBOutlet private var headerLabel: UILabel!
    
    // MARK: - Subtype
    enum DisplayMode {
        case recentSearches
        case newResults
        case emptyResults
        
        var header: String {
            switch self {
            case .recentSearches: return "Recent Searches"
            case .newResults: return "Results"
            case .emptyResults: return "No results found. Please enter a new search"
            }
        }
        
        var textColor: UIColor {
            switch self {
            case .newResults, .recentSearches: return .darkGray
            case .emptyResults: return .red
            }
        }
    }
    
    // MARK: - Override
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

// MARK: - Configurable
extension SearchResultsHeader: Configurable {
    
    func configure(with element: DisplayMode) {
        headerLabel.text = element.header
        headerLabel.textColor = element.textColor
    }
}
