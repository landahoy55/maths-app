//
//  UILabel+Extensions.swift
//  maths-app
//
//  Created by P Malone on 01/03/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {

    func startFlashTwoSeconds() {
        print("start flash")
        UIView.animate(withDuration: 2,
              delay:0.0,
              options:[.allowUserInteraction, .curveEaseInOut, .autoreverse, .repeat],
              animations: { self.alpha = 0.5 },
              //ide suggested weak self...
              completion: {
                [weak self] _ in self?.alpha = 1.0 }
                )
    }
    
    //use to fade in stars.
    func fadeIn() {
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 1
        })
    }

    
    //drop all animations.
    func stopAnimation() {
        
        self.layer.removeAllAnimations()
        self.layoutIfNeeded()
        self.alpha = 1
    }
    

}
