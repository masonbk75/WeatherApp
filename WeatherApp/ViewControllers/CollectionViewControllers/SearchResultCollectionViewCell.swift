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
    
    // MARK: - Properties
    private var locationText: String = "hey"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        locationLabel.text = locationText
    }
}

// MARK: - Configurable
extension SearchResultCollectionViewCell: Configurable {
    
    func configure(with element: String) {
        locationText = element
        locationLabel.text = locationText
    }
}
