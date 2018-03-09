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
    var subTopicResults: [RetreivedSubtopicResult]? //result not updating on this screen. Can a delegate method after update help?
    
    var subTopicToPass: SubTopic!
    var resultToPass: RetreivedSubtopicResult?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Title - taken from first sub parent.
        guard let subT = subTopics else { return }
        titleLabel.text = subT[0].parentTopic.title
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    //segue logic
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
                
                print("************* prepare for segue")
                
                let multipleChoiceViewController = segue.destination as! MultipleChoiceViewController
                print("RESULT TO PASS ******** \(String(describing: resultToPass))")
                multipleChoiceViewController.subResult = resultToPass
                multipleChoiceViewController.subTopic = subTopicToPass
            
            default:
                return
            }
        }
    }


    //Find a result that matches the current topic - is this what is causing the delay?
    func subtopicResult(results: [RetreivedSubtopicResult], subTopicID: String) -> RetreivedSubtopicResult? {
        print("PRIOR TO ENTERING LOOP")
        for result in results {
            print("LOOPING")
            if result.subtopic._id == subTopicID {
                return result
            }
        }
        return nil
    }
}


//Delegate method. Cell is owner, will present topic help.

extension SubTopicViewController: SubTopicCellDelegate {
    func didTapHelpIcon(subTopic: SubTopic) {
        print("**** HELP ICON TAPPED *****")
        subTopicToPass = subTopic
        performSegue(withIdentifier: "helpSegue", sender: self)
    }
}

//Required tableview delegate methods.
extension SubTopicViewController: UITableViewDataSource, UITableViewDelegate {
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let subTopics = subTopics else { return 0 }
        return subTopics.count
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "SubTopicCell") as! SubTopicCell
        cell.selectionStyle = .none
        
        //is there a way to avoid the force?
        cell.setSubTopics(subTopic: subTopics![indexPath.row])
        //custom delegate
        cell.delegate = self
        
        return cell
        
    }
    
    //TODO: Is this method not performing segue after a challenge has been complete?
    //passing quiz on to view controller - only multiple choice at this point
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("************* didSelectRow")
        
        subTopicToPass = subTopics![indexPath.row]
        
        //check to see if any results match
        if let subResults = subTopicResults {
            resultToPass = subtopicResult(results: subResults, subTopicID: subTopicToPass._id)
        }
        
        print("************* didSelectRow pre segue")
        
        //Performing segue on main thread.
        //Was rendering UI on backgrond thread causing a delay.
        OperationQueue.main.addOperation {
            self.performSegue(withIdentifier: "multipleChoiceSegue", sender: self)
        }
    }
    
}
