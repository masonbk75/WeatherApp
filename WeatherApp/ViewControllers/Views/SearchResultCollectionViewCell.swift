//
//  SearchResultCollectionViewCell.swift
//  WeatherApp
//
//  Created by Mason Kelly on 5/8/23.
//

import UIKit

class SearchResultCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet private var locationLabel: UILabel!
    
    // MARK: - Overrides
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

// MARK: - Configurable
extension SearchResultCollectionViewCell: Configurable {
    
    func configure(with element: String) {
        locationLabel.text = element
    }
}
