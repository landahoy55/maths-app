//
//  MultipleChoiceImagesViewController.swift
//  maths-app
//
//  Created by P Malone on 11/05/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import UIKit
import UserNotifications

class MultipleChoiceImagesViewController: UIViewController {

    
    //Outlets
    @IBOutlet weak var timerLbl: UILabel!
    @IBOutlet weak var scoreLbl: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var questionLbl: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var answerBtn0: UIButton!
    @IBOutlet weak var answerBtn1: UIButton!
    @IBOutlet weak var answerBtn2: UIButton!
    @IBOutlet weak var answerBtn3: UIButton!
    //store buttons to manipulate
    var buttons = [UIButton]()
    
    
    //TODO: Add results popup
    var stars = [UILabel]()
    @IBOutlet var resultsPopUp: UIView!
    @IBOutlet weak var popupScoreLabel: UILabel!
    @IBOutlet weak var popupScoreTitle: UILabel!
    @IBOutlet weak var popUpCloseBtn: UIButton!
    @IBOutlet weak var star1: UILabel!
    @IBOutlet weak var star2: UILabel!
    @IBOutlet weak var star3: UILabel!
    @IBOutlet weak var star4: UILabel!
    @IBOutlet weak var star5: UILabel!
    
    
    //Variables
    var subTopic: SubTopic?
    var subResult: RetreivedSubtopicResult?
    
    var dailyChallenge: DailyChallenge?
    
    var questionIndex = 0
    var currentQuestion: Question!
    var timer = Timer()
    var score = 0
    var isHalfTime = false
    var incorrect = 0
    
    var dataService = DataService.instance
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttons.append(answerBtn0)
        buttons.append(answerBtn1)
        buttons.append(answerBtn2)
        buttons.append(answerBtn3)
        
        stars.append(star1)
        stars.append(star2)
        stars.append(star3)
        stars.append(star4)
        stars.append(star5)
        
        
        //hide the close button - reveal laters
        popUpCloseBtn.isEnabled = false
        popUpCloseBtn.alpha = 0
        
        loadQuestions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        startTimer()
    }

    
    //timer functions
    func startTimer() {
        progressBar.tintColor = timerGreen
        progressBar.trackTintColor = UIColor.white
        progressBar.progress = 1.0
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTimerProgress), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimerProgress(){
        
        progressBar.progress -= 0.01/30
        
        //countdown timer - not 100% accurate, almost 30 seconds though
        let countdown = Int((progressBar.progress / 3.33) * 100)
        timerLbl.text = String(countdown)
        
        if progressBar.progress <= 0 {
            print("Out of time")
        close()
        } else if progressBar.progress <= 0.2 {
            
            progressBar.progressTintColor = timerRed
        } else if progressBar.progress <= 0.5 {
            progressBar.progressTintColor = timerOrange
        isHalfTime = true
        }
    }
    
    
    //load questions
    func loadQuestions() {
        //unwrap optional, perform ternary operator
        //close when question index reaches count of questions.
        if let subT = subTopic {
            print("****** SUBTOPIC FOUND")
            questionIndex < subT.questions.count ? setQuestionLayout() : close()
        }
        
        if let dailyChallenge = dailyChallenge {
            print("****** DAILYCHALLENGE FOUND")
            questionIndex < dailyChallenge.questions.count ? setQuestionLayout() : close()
        }
        
    }
    
    //setQuestionLayout
    func setQuestionLayout() {
    
        //check to see if subtopic or daily challenge
        if subTopic != nil {
            currentQuestion = subTopic?.questions[questionIndex]
            
        }
        
        if dailyChallenge != nil {
            currentQuestion = dailyChallenge?.questions[questionIndex]
        }
        
        
        //set questions
        incorrect = 0
        questionLbl.text = currentQuestion.question
        
        
        //animate in question
        questionLbl.alpha = 0
        imageView.alpha = 0
    
        UIView.animate(withDuration: 0.5) {
            self.questionLbl.alpha = 1
            self.imageView.alpha = 1
        }
        
        print("**URL**", currentQuestion.imageurl!)

        //downloading image.
        imageView.downloadImageFromURL(imgURL: currentQuestion.imageurl!)
        
        questionLbl.text = currentQuestion.question
        
        for (index, button) in buttons.enumerated() {
            print(button.tag)
            print(currentQuestion.answers[index].answer)
            button.setTitle(currentQuestion.answers[index].answer, for: .normal)
            //button.backgroundColor = UIColor.clear
            button.titleLabel?.minimumScaleFactor = 0.5
            button.titleLabel?.numberOfLines = 0
            button.titleLabel?.adjustsFontSizeToFitWidth = true
        }
        
        scoreLbl.text = String(score)
        
        //animate score to green briefly
        if score > 0 {
            UIView.transition(with: scoreLbl, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.scoreLbl.textColor = timerGreen
            }, completion: { (success) in
                if success {
                    UIView.transition(with: self.scoreLbl, duration: 0.3, options: .transitionCrossDissolve, animations: {
                        self.scoreLbl.textColor = .black
                    }, completion: nil)
                }
            })
        }
        
        //Extra emphasis on time remaining
        if questionIndex >= 3 {
            timerLbl.blink()
        }
        
        if isHalfTime {
            timerLbl.blink()
        }
        
    }
    
    //TODO: Close logic - present
    func close() {
        
        //dismiss(animated: true, completion: nil)
        
        //disable buttons
        for button in buttons {
            button.isEnabled = false
        }
        
        scoreLbl.text = String(score)
        
        //emitters
        //add emitter to view - placed at top and 1 tall
        
        if score < 3 {
            let emitter = Emitter.createEmitter()
            emitter.emitterPosition = CGPoint(x: resultsPopUp.frame.width / 2.0, y: 0)
            emitter.emitterSize = CGSize(width: resultsPopUp.frame.width, height: 1)
            resultsPopUp.layer.addSublayer(emitter)
        }
        
        if score == 3 {
            let emitter = BronzeEmitter.createEmitter()
            emitter.emitterPosition = CGPoint(x: resultsPopUp.frame.width / 2.0, y: 0)
            emitter.emitterSize = CGSize(width: resultsPopUp.frame.width, height: 1)
            resultsPopUp.layer.addSublayer(emitter)
        }
        
        if score == 4 {
            let emitter = SilverEmitter.createEmitter()
            emitter.emitterPosition = CGPoint(x: resultsPopUp.frame.width / 2.0, y: 0)
            emitter.emitterSize = CGSize(width: resultsPopUp.frame.width, height: 1)
            resultsPopUp.layer.addSublayer(emitter)
        }
        
        if score >= 5 {
            let emitter = GoldEmitter.createEmitter()
            emitter.emitterPosition = CGPoint(x: resultsPopUp.frame.width / 2.0, y: 0)
            emitter.emitterSize = CGSize(width: resultsPopUp.frame.width, height: 1)
            resultsPopUp.layer.addSublayer(emitter)
        }
        
        //set score label test
        switch score {
        case 0:
            popupScoreTitle.text = "Oops"
        case 1:
            popupScoreTitle.text = "Keep trying"
        case 2:
            popupScoreTitle.text = "Go again!"
        case 3:
            popupScoreTitle.text = "Almost there"
        case 4:
            popupScoreTitle.text = "Great!"
        case 5:
            popupScoreTitle.text = "Awesome!!"
        default:
            popupScoreTitle.text = "Score"
        }
        
        
        //adding popup subview
        resultsPopUp.center = view.center
        //transparent
        resultsPopUp.alpha = 0
        //add to view
        view.addSubview(resultsPopUp)
        //animate opactiy back to 1
        
        //fade in popup
        //then fade in stars representing scores
        UIView.animate(withDuration: 1, animations: {
            self.resultsPopUp.alpha = 1
        }) { (success) in
            for (index, star) in self.stars.enumerated() {
                if index <= self.score - 1 {
                    star.fadeIn()
                }
            }
        }
        
        popupScoreLabel.text = "\(score)/5"
        
        //clear timer from memory
        timer.invalidate()
        
        //log results
        if subTopic != nil {
            recordSubTopicResult()
            
            //authorise notification - will prompt user if not auth
            NotificationService.instance.authorise()
            
            //schedule with check for authorisation
            scheduleNotificaion()
        }
        
        
    }
    
    //TODO: networking and notifications
    func scheduleNotificaion() {
        //check to see if permissions granted - 2 is granted
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("User settings notification ******* \(settings.authorizationStatus.rawValue)")
            
            //if authorised.
            if settings.authorizationStatus.rawValue == 2 {
                
                //currently set to one minute after completing - for testing.
                NotificationService.instance.timerRequest(with: 60)
                
                //if a request has been set remove and replace
                //This might not be neccessary. Can only schedule one notification with id
                UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { ( pending ) in
                    for request in pending {
                        print("Pending requests ******** \(request.identifier)")
                    }
                })
            }
        }
    }
    
    
    //networking calls and logic
    //Create or update subtopic result
    
    func recordSubTopicResult() {
        
        guard let sub = subTopic?._id else { return }
        guard let topicId = subTopic?.parentTopic._id else { return }
        guard let id = UserDefaults.standard.string(forKey: DEFAULTS_USERID) else { return }
        
        let scoreToRecord = String(score)
        let subAchieved: String
        
        if scoreToRecord == "5" {
            subAchieved = "true"
        } else {
            subAchieved = "false"
        }
        
        //create subtopic result || updated.
        // if result exists...
        if let subTopicResult = subResult {
            
            //put new result
            let result = SubtopicResult(achieved: subAchieved, score: scoreToRecord, subtopic: sub, id: id)
            
            dataService.updateSubTopicResult(newResult: result, idToUpdate: subTopicResult._id, completion: { (success) in
                if (success) {
                    print("Updated sub result")
                    
                    self.recordTopicResult(subTopicResult: subTopicResult._id, topicID: topicId, userID: id)
                } else {
                    print("Error")
                }
            })
            
        } else {
            //post a new one
            let subtopicResult = SubtopicResult(achieved: subAchieved, score: scoreToRecord, subtopic: sub, id: id)
            //Post subtopic result
            print("**** ABOUT TO POST NEW SUB *****")
            print(subtopicResult)
            dataService.postNewSubtopicResult(subtopicResult) { (success) in
                if (success) {
                    print("Posted new sub result")
                    //print(self.dataService.recentSubTopicResult!)
                    if let recentResult = self.dataService.recentSubTopicResult {
                        print("********* RECENT SUB - \(recentResult)")
                        self.recordTopicResult(subTopicResult: recentResult, topicID: topicId, userID: id)
                    }
                } else {
                    print("Error")
                }
            }
        }
    }
    
    //create or update topic result
    func recordTopicResult(subTopicResult: String, topicID: String, userID: String) {
        
        //create topic result
        
        //get topic results
        guard let id = UserDefaults.standard.string(forKey: DEFAULTS_USERID) else { return }
        dataService.getTopicResult(id) { (success) in
            
            if (success) {
                
                let topicResults = self.dataService.downloadedTopicResults
                
                if let result = topicResults.first(where: {$0.topic._id == self.subTopic?.parentTopic._id}) {
                    print("******* FOUND A TOPIC RESULT ********")
                    
                    //UPDATE topic result - need subtopic result!
                    //append result - if array count is five then adjust achieved.
                    
                    let topic = result.topic._id
                    var subTopicResultsArray = [String]()
                    
                    //existing results - could check to see if achieved here?
                    for subs in result.subTopicResults {
                        subTopicResultsArray.append(subs._id)
                    }
                    
                    subTopicResultsArray.append(subTopicResult)
                    
                    //check for duplicates and remove
                    let deDuplicatedSubTopicResultsArray = Array(Set(subTopicResultsArray))
                    
                    let achieved: String
                    
                    // check to see if all results are in.
                    if deDuplicatedSubTopicResultsArray.count == 5 {
                        achieved = "true"
                    } else {
                        achieved = "false"
                    }
                    
                    let topicResult = TopicResult(achieved: achieved, topic: topic, id: id, subTopicResults: deDuplicatedSubTopicResultsArray)
                    
                    let currentId = result._id
                    self.dataService.updateTopicResult(newResult: topicResult, idToUpdate: currentId, completion: { (success) in
                        if success {
                            print("Updated topic!!")
                            //Redownload results
                            self.dataService.getTopicResult(id) { (success) in
                                if success {
                                    print("************\n REDOWNLOADED RESUTLS \n************")
                                    self.dataService.getSubTopicResults(id, completion: { (success) in
                                        
                                        if (success) {
                                            print("Fade in button here")
                                            DispatchQueue.main.async {
                                                
                                                UIView.animate(withDuration: 0.3, animations: {
                                                    self.popUpCloseBtn.alpha = 1
                                                    self.popUpCloseBtn.isEnabled = true
                                                })
                                                
                                            }
                                        }
                                    })
                                }
                            }
                        }
                    })
                    
                } else {
                    print("******* FOUND NO TOPIC RESULT ********")
                    
                    //CREATE topic result - set to false as not all five achieved.
                    
                    let topicResult = TopicResult(achieved: "false", topic: topicID, id: userID, subTopicResults: [subTopicResult])
                    //post
                    self.dataService.postNewTopicResult(topicResult, completion: { (success) in
                        if success {
                            print("TOPIC saved")
                            //redownload here
                            self.dataService.getTopicResult(id) { (success) in
                                if success {
                                    print("************\n REDOWNLOADED RESUTLS \n************")
                                    self.dataService.getSubTopicResults(id, completion: { (success) in
                                        
                                        if (success) {
                                            
                                            print("Fade in button here")
                                            DispatchQueue.main.async {
                                                UIView.animate(withDuration: 0.3, animations: {
                                                    self.popUpCloseBtn.alpha = 1
                                                    self.popUpCloseBtn.isEnabled = true
                                                })
                                            }
                                            
                                        }
                                        
                                    })
                                }
                            }
                        }
                    })
                }
            }
        }
    }
    
    @IBAction func popupClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func answerPressed(_ sender: UIButton) {
        //check to see if correct answer pressed
        if sender.titleLabel?.text == currentQuestion.correctAnswer {
            
            sender.pulsate()
            print("correct answer pressed")
            
            //haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            correctSoundPlayer.play()
            
            questionIndex += 1
            score += 1
            //show next question
            loadQuestions()
            
            
        } else {
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            
            sender.shake()
            print("Oops - Incorrect answer pressed")
            wrongSoundPlayer.play()
            
            //animate to red
            UIView.transition(with: questionLbl, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.questionLbl.textColor = .red
            }) { (success) in
                if (success) {
                    UIView.transition(with: self.questionLbl, duration: 0.3, options: .transitionCrossDissolve, animations: {
                        self.questionLbl.textColor = .white
                    })
                }
            }
            
            incorrect += 1
            print("Incorrect Count", incorrect)
            
            if incorrect >= 2 {
                questionIndex += 1
                loadQuestions()
            }
        
        }
        
    }
    
}
