//
//  HelpPromptViewController.swift
//  maths-app
//
//  Created by P Malone on 05/03/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import UIKit

class HelpPromptViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    var topic: SubTopic!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = topic.title
        descriptionLabel.text = topic.description
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    @IBAction func close(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}