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
    var subTopicResults: [RetreivedSubtopicResult]? //may be no results
    
    var subTopicToPass: SubTopic!
    var resultToPass: RetreivedSubtopicResult?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var navbarTitle: UINavigationItem!

    @IBOutlet weak var noResultsPanel: UIView!
    
    var isFirstResult = false
    //Animations for contraints
    @IBOutlet weak var stageOneConstaint: NSLayoutConstraint!
    @IBOutlet weak var stageTwoContraint: NSLayoutConstraint!
    @IBOutlet weak var stageThreeConstraint: NSLayoutConstraint!
    @IBOutlet weak var stageFourContraint: NSLayoutConstraint!
    @IBOutlet weak var stageFiveConstraint: NSLayoutConstraint!
    
    //chart views
    @IBOutlet weak var bar1: UIView!
    @IBOutlet weak var bar2: UIView!
    @IBOutlet weak var bar3: UIView!
    @IBOutlet weak var bar4: UIView!
    @IBOutlet weak var bar5: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Title - taken from first sub parent.
        guard let subT = subTopics else { return }
        titleLabel.text = subT[0].parentTopic.description
        
        subTopicResults = DataService.instance.downloadedSubTopicResults
        
        tableView.dataSource = self
        tableView.delegate = self
        
        bar1.backgroundColor = .clear
        bar2.backgroundColor = .clear
        bar3.backgroundColor = .clear
        bar4.backgroundColor = .clear
        bar5.backgroundColor = .clear
        
        noResultsPanel.isHidden = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.reloadData()
        
        print("View did appear")
        
        var constraints = [40,40,40,40,40]
        //what if no results?
       
        //loop over subtopics - check to see if result exists. adjust relevant constraint
        
        if let subtopics = subTopics {
            for (index,topic) in subtopics.enumerated() {
                if let results = subTopicResults {
                    if let result = subtopicResult(results: results, subTopicID: topic._id) {
                        let constraint = topAnchorContant(score: result.score)
                        constraints[index] = constraint
                        noResultsPanel.isHidden = true
                    }
                }
            }
        }
        
        
        //animate one
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: {
            
            //animate autolayout
            let constraintSize = constraints.count >= 0 ? CGFloat(constraints[0]) : CGFloat(40)
            self.stageOneConstaint.constant = constraintSize
            self.view.layoutIfNeeded()
            print("Stage 1 contraint:", self.stageOneConstaint.constant)
            
            self.barColours(contraint: constraints[0], bar: self.bar1)
            
        }, completion: { finished in
    
        })
        
        //animate two
        UIView.animate(withDuration: 1, delay: 0.2, options: .curveEaseOut, animations: {
            
            //animate autolayout
            let constraintSize = constraints.count >= 1 ? CGFloat(constraints[1]) : CGFloat(40)
            self.stageTwoContraint.constant = constraintSize
            self.view.layoutIfNeeded()
            print("Stage 2 contraint:", self.stageTwoContraint.constant)
            
           self.barColours(contraint: constraints[1], bar: self.bar2)
            
        }, completion: { finished in
            
        })
        
        
        //animate three
        UIView.animate(withDuration: 1, delay: 0.4, options: .curveEaseOut, animations: {
            
            //animate autolayout
            let constraintSize = constraints.count >= 2 ? CGFloat(constraints[2]) : CGFloat(40)
            self.stageThreeConstraint.constant = constraintSize
            self.view.layoutIfNeeded()
            print("Stage 3 contraint:", self.stageThreeConstraint.constant)
            self.barColours(contraint: constraints[2], bar: self.bar3)
        }, completion: { finished in
            
        })
        
        //animate four
        UIView.animate(withDuration: 1, delay: 0.6, options: .curveEaseOut, animations: {
            
            //animate autolayout
            let constraintSize = constraints.count >= 3 ? CGFloat(constraints[3]) : CGFloat(40)
            self.stageFourContraint.constant = constraintSize
            self.view.layoutIfNeeded()
            print("Stage 4 contraint:", self.stageFourContraint.constant)
            self.barColours(contraint: constraints[3], bar: self.bar4)
        }, completion: { finished in
            
        })
        
        //animate five
        UIView.animate(withDuration: 1, delay: 0.8, options: .curveEaseOut, animations: {
            
            //animate autolayout
            let constraintSize = constraints.count >= 4 ? CGFloat(constraints[4]) : CGFloat(40)
            self.stageFiveConstraint.constant = constraintSize
            self.view.layoutIfNeeded()
            print("Stage 5 contraint:", self.stageFiveConstraint.constant)
            self.barColours(contraint: constraints[4], bar: self.bar5)
        }, completion: { finished in
            
        })
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        print("**** View will appear \n Subtopic menu *********")
        //refresh tableview following activity
        guard let subT = subTopics else { return }
        navbarTitle.title = subT[0].parentTopic.title
        
        subTopicResults = DataService.instance.downloadedSubTopicResults
        
        if isFirstResult == true {
            print("********* isFirstResult is true")
            UIView.animate(withDuration: 0.3) {
                self.noResultsPanel.isHidden = true
            }
        } else {
          print("********* isFirstResult is false")
        }
        
        tableView.reloadData()
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
                
                let inputAnswerViewController = segue.destination as! InputAnswerViewController
                inputAnswerViewController.subTopic = subTopicToPass
                inputAnswerViewController.subResult = resultToPass
              
                
            case "multipleChoiceSegue":
                
                let multipleChoiceViewController = segue.destination as! MultipleChoiceViewController
                print("RESULT TO PASS ******** \(String(describing: resultToPass))")
                multipleChoiceViewController.subResult = resultToPass
                multipleChoiceViewController.subTopic = subTopicToPass
        
                
            case "multipleChoiceImageSegue":
                let multipleChoiceImagesViewController = segue.destination as! MultipleChoiceImagesViewController
                
                multipleChoiceImagesViewController.subTopic = subTopicToPass
                multipleChoiceImagesViewController.subResult = resultToPass
                
            //TODO add additional challenges
            case "voiceInputSegue":
                let voiceInputViewController = segue.destination as! VoiceInputViewController
                voiceInputViewController.subTopic = subTopicToPass
                voiceInputViewController.subResult = resultToPass
                
            case "handWritingSegue":
                let handWritingViewController = segue.destination as! HandWritingViewController
                
                handWritingViewController.subTopic = subTopicToPass
                handWritingViewController.subResult = resultToPass
            
            default:
                return
            }
        }
    }

    func barColours(contraint: Int, bar: UIView) {
        switch contraint {
        case 0:
            bar.backgroundColor = timerGreen
        case 8:
            bar.backgroundColor = timerOrange
        case 16:
            bar.backgroundColor = timerOrange
        case 24:
            bar.backgroundColor = timerRed
        case 32:
            bar.backgroundColor = timerRed
        case 40:
            bar.backgroundColor = .clear
        default:
            bar.backgroundColor = .clear
        }
    }
    
    //calculate top anchor constant
    func topAnchorContant(score: Int) ->  Int {
        
        switch score {
        case 0:
            return 40
        case 1:
            return 32
        case 2:
            return 24
        case 3:
            return 16
        case 4:
            return 8
        case 5:
            return 0
        default:
            return 40
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
        
        var score: Int?
        
        //find related result
        //loop over results, unwrap first
        if let subTopicResults = subTopicResults {
            for result in subTopicResults {
                if result.subtopic._id == subTopics![indexPath.row]._id {
                    score = result.score
                    print("SUBTOPIC ID...", result.subtopic._id)
                    print("SCORE IN LOOP...", score!)
                }
            }
        }
        
        //print("CELL SCORE AT CELL FOR ROW AT....", score!)
        cell.setSubTopics(subTopic: subTopics![indexPath.row], score: score )
        //custom delegate
        cell.delegate = self
        
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("************* didSelectRow")
        
        subTopicToPass = subTopics![indexPath.row]
        
        //check to see if any results match
        if let subResults = subTopicResults {
            resultToPass = subtopicResult(results: subResults, subTopicID: subTopicToPass._id)
        }
        
        print("************* didSelectRow pre segue")
        
        let segue = "\(subTopicToPass.quizType)Segue"
        
        //Performing segue on main thread.
        //Was rendering UI on backgrond thread causing a delay.
        OperationQueue.main.addOperation {
            self.performSegue(withIdentifier: segue, sender: self)
        }
    }
    
}
