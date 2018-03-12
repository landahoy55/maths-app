//
//  MidRoundedButton.swift
//  maths-app
//
//  Created by P Malone on 10/03/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import Foundation

import UIKit

class MidRoundedButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    func setUp() {
        //style
        //        print("here")
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 2.0
        self.layer.cornerRadius = 15
        self.clipsToBounds = true
    }
    
    //required methods
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUp()
    }
}
