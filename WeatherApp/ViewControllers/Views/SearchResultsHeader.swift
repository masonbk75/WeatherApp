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
    
    // MARK: - Override
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

// MARK: - Configurable
extension SearchResultsHeader: Configurable {
    
    func configure(with element: String) {
        headerLabel.text = element
    }
}
