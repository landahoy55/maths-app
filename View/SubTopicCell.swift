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
    @IBOutlet weak var medalImage: UIImageView!
    
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
            scoreLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
            case 1:
            scoreLabel.textColor = timerRed
            scoreLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
            case 2:
            scoreLabel.textColor = .black
            scoreLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
            case 3:
            scoreLabel.textColor = .black
            medalImage.image = UIImage(named: "Bronze.png")
            case 4:
            scoreLabel.textColor = timerGreen
            medalImage.image = UIImage(named: "Silver.png")
            case 5:
            scoreLabel.textColor = timerGreen
            scoreLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
            medalImage.image = UIImage(named: "Gold.png")
            
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
