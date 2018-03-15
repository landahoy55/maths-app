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
    func blinking() {
        self.alpha = 1.0
        UIView.animate(withDuration: 1,
            delay: 0.0,
            options: [.curveEaseInOut, .autoreverse, .repeat],
            animations: { [weak self] in self?.alpha = 0.6 },
            completion: { [weak self] _ in self?.alpha = 1.0 })
    }
    
    func startBlink() {
        print("start blink")
        UIView.animate(withDuration: 0.8,
              delay:0.0,
              options:[.allowUserInteraction, .curveEaseInOut, .autoreverse, .repeat],
              animations: { self.alpha = 0.5 },
              completion: nil)
    }

    func startBlinkTwoSeconds() {
        print("start blink")
        UIView.animate(withDuration: 2,
              delay:0.0,
              options:[.allowUserInteraction, .curveEaseInOut, .autoreverse, .repeat],
              animations: { self.alpha = 0.5 },
              completion: {[weak self] _ in self?.alpha = 1.0 })
    }

    func stopBlink() {
        print("stop blink")
        self.layer.removeAllAnimations()
        alpha = 1
    }
    
    func fadeIn() {
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 1
        })
    }

    func nukeAllAnimations() {
        
        self.layer.removeAllAnimations()
        self.layoutIfNeeded()
        self.alpha = 1
    }

}
