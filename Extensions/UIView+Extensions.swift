//
//  UILabel+Extensions.swift
//  maths-app
//
//  Created by P Malone on 28/02/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func blink() {
        self.alpha = 0.2
        UIView.animate(withDuration: 1, delay: 0.0, options: [.curveLinear, .repeat, .autoreverse], animations: {
            self.alpha = 1.0
        }, completion: nil)
    }
    
}
