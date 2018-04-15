//
//  SubTopicCell.swift
//  maths-app
//
//  Created by P Malone on 05/03/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import UIKit

//delegate to display help screen
protocol SubTopicCellDelegate {
    
    func didTapHelpIcon(subTopic: SubTopic)

}

class SubTopicCell: UITableViewCell {
    
    @IBOutlet weak var topicTitleLabel: UILabel!
    @IBOutlet weak var stageLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var stageTypeLabel: UILabel!
    
    var subT: SubTopic!
    var delegate: SubTopicCellDelegate?
    
    //configure cell
    func setSubTopics(subTopic: SubTopic, score: Int? = nil) {
        subT = subTopic
        topicTitleLabel.text = subTopic.title
        stageLabel.text = "Stage \(subTopic.stage)"
        
        switch subTopic.quizType {
        case "input":
            stageTypeLabel.text = "Input Answers"
        case "multipleChoice":
            stageTypeLabel.text = "Multiple Choice"
        default:
            stageTypeLabel.text = ""
        }
        
        
        if let score = score {
            print("CELL SCORE ON CREATION....", score)
            scoreLabel.text = "\(score)/5"
            
            switch score {
            case 0:
            scoreLabel.textColor = .black
            case 1:
            scoreLabel.textColor = timerRed
            case 2:
            scoreLabel.textColor = .black
            case 3:
            scoreLabel.textColor = .black
            case 4:
            scoreLabel.textColor = timerGreen
            case 5:
            scoreLabel.textColor = timerGreen
            scoreLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
            
            default:
            scoreLabel.textColor = .black
            }
            
        } else {
            scoreLabel.text = "0/0"
        }
        
        
        
    }
    
    @IBAction func helpButton(_ sender: UIButton) {
        delegate?.didTapHelpIcon(subTopic: subT)
    }
    
}
