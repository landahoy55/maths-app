//
//  menuCollectionViewCell.swift
//  maths-app
//
//  Created by P Malone on 05/03/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import UIKit

class menuCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    
    func configureCell(title: String, description: String, numberAchieved: Int){
        
        //set title
        self.titleLabel.text = title
        
        //set descrtion
        self.descriptionLabel.text = description
        
        //set completion
        //function to
        var display = ":("
        
        switch numberAchieved {
        case 0:
            display = "0/5 complete 🙃"
            //scoreLabel.textColor = .white
            //scoreLabel.blinking()
        case 1:
            display = "1/5 complete 👎"
            //scoreLabel.textColor = timerRed
        case 2:
            display = "2/5 complete 🤔"
            //scoreLabel.textColor = timerOrange
        case 3:
            display = "3/5 complete ☺️"
            //scoreLabel.textColor = timerOrange
        case 4:
            display = "4/5 complete 😘"
            //scoreLabel.textColor = timerGreen
        case 5:
            display = "5/5 complete 😍"
            //scoreLabel.textColor = timerGreen
        default:
            display = "Try now!"
            //scoreLabel.textColor = .white
            //scoreLabel.blinking()
        }
        
        self.scoreLabel.text = display
        
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        layer.cornerRadius = 14.0
        layer.masksToBounds = true
        
        self.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
    }
    
}
