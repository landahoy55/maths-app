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
    //https://developer.apple.com/documentation/quartzcore/cagradientlayer
    func gradientLayer(topColor:UIColor, bottomColor:UIColor) {
       
        let gradient = CAGradientLayer()
        
        gradient.frame = self.bounds
        gradient.colors = [
            topColor.cgColor,
            bottomColor.cgColor
        ]
        
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        
        //add to the top.
        self.layer.insertSublayer(gradient, at: 0)
    }

    //Set alpha to almost 0 then return, Repeat for one second.
    func flashing() {
        
        self.alpha = 0.2
        UIView.animate(withDuration: 1, delay: 0.0, options: [.curveLinear, .repeat, .autoreverse], animations: {
            self.alpha = 1.0
        }, completion: nil)
        
    }
}

//capture image from view
//Ref https://github.com/brianadvent/CoreMLHandwritingRecognition
extension UIImage {
    //pass in view
    convenience init(view: UIView) {
        
        //Take image of view
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        //create an image from the context
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //call main init - as we're in a convience inti
        self.init(cgImage: image!.cgImage!)
    }
}
