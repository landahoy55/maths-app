//
//  menuCellCollectionViewCell.swift
//  maths-app
//
//  Created by P Malone on 05/03/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import UIKit

class menuCellCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        layer.cornerRadius = 14.0
        layer.masksToBounds = true
        
        self.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        
    }
    
}
