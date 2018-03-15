//
//  RoundButton.swift
//  maths-app
//
//  Created by P Malone on 15/03/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import UIKit

class RoundButton: UIButton {

        
        override func draw(_ rect: CGRect) {
            super.draw(rect)
            layer.cornerRadius = 0.5 * self.bounds.size.width
            layer.masksToBounds = true
            //layer.borderWidth = 2.0
            layer.backgroundColor = UIColor.red.cgColor
            //layer.borderColor = UIColor.white.cgColor
            
            //to set opacity
            // let opacity: CGFloat = 0.5
            // let borderColor = UIColor.white
            // layer.borderColor = borderColor.withAlphaComponent(opacity).cgColor
            
            //gradient
            // self.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
            
        }
}
