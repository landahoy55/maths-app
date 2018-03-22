//
//  View+Extension.swift
//  maths-app
//
//  Created by P Malone on 20/02/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import UIKit

extension UIView {
  
    //set a gradient background view.
    func addVerticalGradientLayer(topColor:UIColor, bottomColor:UIColor) {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [
            topColor.cgColor,
            bottomColor.cgColor
        ]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        self.layer.insertSublayer(gradient, at: 0)
    }
}

//capture image from view
extension UIImage {
    //pass in view
    convenience init(view: UIView) {
        //create a bitmap context, with init view
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        //create an image from the context
        let image = UIGraphicsGetImageFromCurrentImageContext()
        //end opration
        UIGraphicsEndImageContext()
        //call main init
        self.init(cgImage: image!.cgImage!)
    }
}
