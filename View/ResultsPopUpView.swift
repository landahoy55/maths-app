//
//  ResultsPopUpView.swift
//  maths-app
//
//  Created by P Malone on 15/03/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import UIKit

class ResultsPopUpView: UIView {

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        //rounded
        layer.cornerRadius = 15
        layer.masksToBounds = true
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 4
        
        //gradient
        self.gradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
    }

}
