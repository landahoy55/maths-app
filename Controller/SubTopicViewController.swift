//
//  SubTopicViewController.swift
//  maths-app
//
//  Created by P Malone on 05/03/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import UIKit

class SubTopicViewController: UIViewController {

    //inject
    var subTopics: [SubTopic]?
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
    }
    
}

extension SubTopicViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let topics = subTopics else { return 0 }
        
        return topics.count
    }
    
    //TODO - Configure cells in cell class - not here
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "SubTopicCell") as! SubTopicCell
        cell.topicTitleLabel.text = subTopics![indexPath.row].title
        
        return cell
        
    }
    
}
