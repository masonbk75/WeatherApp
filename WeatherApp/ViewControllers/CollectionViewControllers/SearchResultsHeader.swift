//
//  SearchResultsHeader.swift
//  WeatherApp
//
//  Created by Mason Kelly on 5/8/23.
//

import UIKit

class SearchResultsHeader: UICollectionReusableView {
    
    @IBOutlet private var headerLabel: UILabel!
    
    private var header: String = "header"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        headerLabel.text = header
    }
}

extension SearchResultsHeader: Configurable {
    
    func configure(with element: String) {
        header = element
    }
}
