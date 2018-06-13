//
//  slightRoundedView.swift
//  maths-app
//
//  Created by P Malone on 28/02/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import UIKit

class slightRoundedView: UIView {

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        //rounded
        layer.cornerRadius = 5.0
        layer.masksToBounds = true
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 2.0
        
        //gradient
        self.gradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
    }

}
