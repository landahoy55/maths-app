//
//  SubTopicViewController.swift
//  maths-app
//
//  Created by P Malone on 05/03/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import UIKit

class SubTopicViewController: UIViewController {

    //injections
    var subTopics: [SubTopic]?
    var subTopicResults: [RetreivedSubtopicResult]?
    
    var subTopicToPass: SubTopic!
    var resultToPass: RetreivedSubtopicResult?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let subT = subTopics else { return }
        titleLabel.text = subT[0].parentTopic.title
        
        print("********* SUB TOPIC RESULTS **********")
        print(subTopicResults!)
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
        
        
        //Go to quizzes
        if let identifier = segue.identifier {
            switch identifier {
            case "helpSegue":
                let helpPromptViewController = segue.destination as! HelpPromptViewController
                helpPromptViewController.topic = subTopicToPass
            case "inputSegue":
                return
            case "multipleChoiceSegue":
                
                let multipleChoiceViewController = segue.destination as! MultipleChoiceViewController
                multipleChoiceViewController.subResult = resultToPass
                multipleChoiceViewController.subTopic = subTopicToPass
            
            default:
                return
            }
        }
    }


    //If a result already exists for a level to be played it will show result.
    func subtopicResult(results: [RetreivedSubtopicResult], subTopicID: String) -> RetreivedSubtopicResult? {
        
        for result in results {
            if result.subtopic._id == subTopicID {
                return result
            }
        }
        
        return nil
    }
    


}

extension SubTopicViewController: SubTopicCellDelegate {
    func didTapHelpIcon(subTopic: SubTopic) {
        subTopicToPass = subTopic
        performSegue(withIdentifier: "helpSegue", sender: self)
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
        cell.selectionStyle = .none
        //cell config carried out in set up
        cell.setSubTopics(subTopic: subTopics![indexPath.row])
        //custom delegate
        cell.delegate = self
        
        return cell
        
    }
    
    //passing quiz on to view controller - only multiple choice at this point
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        subTopicToPass = subTopics![indexPath.row]
        //call func here.
        if let subResults = subTopicResults {
            resultToPass = subtopicResult(results: subResults, subTopicID: subTopicToPass._id)
        }
        
        performSegue(withIdentifier: "multipleChoiceSegue", sender: self)
     
    }
    
}
