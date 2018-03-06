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
    
    var subT: SubTopic!
    var delegate: SubTopicCellDelegate?
    
    //configure cell
    func setSubTopics(subTopic: SubTopic) {
        subT = subTopic
        topicTitleLabel.text = subTopic.title
        stageLabel.text = "Stage \(subTopic.stage)"
    }
    
    @IBAction func helpButton(_ sender: UIButton) {
        delegate?.didTapHelpIcon(subTopic: subT)
    }
    
}
