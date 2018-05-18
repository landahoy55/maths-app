//
//  InputAnswerViewController.swift
//  maths-app
//
//  Created by P Malone on 28/02/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import UIKit
import UserNotifications

class InputAnswerViewController: UIViewController {

    var subTopic: SubTopic?
    var subResult: RetreivedSubtopicResult?
    var dailyChallenge: DailyChallenge?
    
    var questionIndex = 0
    var currentQuestion: Question!
    
    //link to progressBar - done
    var timer = Timer()
    var score = 0 // currently using index
    var isHalfTime = false
    var inputAnswer = ""
    var isFirstTime = true
    
    var dataService = DataService.instance
    
    var subtopicResultsReturned = false
    
    //outlets - timer
    @IBOutlet weak var timeRemainingBar: UIProgressView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!
    
    //outlets - question and answer
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    
    //Results popup
    @IBOutlet weak var star1: UILabel!
    @IBOutlet weak var star2: UILabel!
    @IBOutlet weak var star3: UILabel!
    @IBOutlet weak var star4: UILabel!
    @IBOutlet weak var star5: UILabel!
    var stars = [UILabel]()
    @IBOutlet var resultsPopUp: UIView!
    @IBOutlet weak var resultsTitleLabel: UILabel!
    @IBOutlet weak var resultsScoreLabel: UILabel!
    @IBOutlet weak var popUpCloseBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        
        answerLabel.text = "0"
        
        stars.append(star1)
        stars.append(star2)
        stars.append(star3)
        stars.append(star4)
        stars.append(star5)
        
        popUpCloseBtn.isEnabled = false
        popUpCloseBtn.alpha = 0
        
        loadQuestions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("***** view did appear")
        startTimer()

        answerLabel.startBlinkTwoSeconds()
  
//        if let subT = subTopic {
//            print(subT)
//        }
    }

    func loadQuestions() {
        
        //unwrap optional, perform ternary operator
        //close when question index reaches count of questions - generally 5
        if let subT = subTopic {
            questionIndex < subT.questions.count ? setQuestionLayout() : close()
        }
        
        if let dailyChallenge = dailyChallenge {
            print("****** DAILYCHALLENGE FOUND")
            questionIndex < dailyChallenge.questions.count ? setQuestionLayout() : close()
        }
        
        
    }
    
    func setQuestionLayout() {
        
        //check to see if subtopic or daily challenge
        if subTopic != nil {
            currentQuestion = subTopic?.questions[questionIndex]
            
        }
        
        if dailyChallenge != nil {
            currentQuestion = dailyChallenge?.questions[questionIndex]
        }
        
        questionLabel.text = currentQuestion.question
        
        //reset()
        scoreLabel.text = String(questionIndex)
        
        if questionIndex > 0 {
            UIView.transition(with: scoreLabel, duration: 0.4, options: .transitionCrossDissolve, animations: {
                self.scoreLabel.textColor = timerGreen
            }, completion: { (success) in
                if success {
                    UIView.transition(with: self.scoreLabel, duration: 0.2, options: .transitionCrossDissolve, animations: {
                        self.scoreLabel.textColor = .black
                    }, completion: nil)
                }
            })
        }
        
 
        
        questionLabel.alpha = 0
        UIView.animate(withDuration: 0.7) {
            self.questionLabel.alpha = 1
        }
        
        questionLabel.text = currentQuestion.question
        
        
        //Is this the most appropriate place
        if questionIndex >= 3 {
            countdownLabel.blink()
        }
        
        if isHalfTime {
            countdownLabel.blink()
        }
        
    }
    
    func startTimer() {
        timeRemainingBar.tintColor = timerGreen
        timeRemainingBar.trackTintColor = UIColor.white
        //progress set to full.
        timeRemainingBar.progress = 1.0
        
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTimerProgress), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimerProgress(){
        
        //remove 1 60th
        timeRemainingBar.progress -= 0.01/60
        
        //seconds to display
        let countdown = Int((timeRemainingBar.progress) * 60)
        print(countdown)
        
        countdownLabel.text = String(countdown)
        
        //change tracking color.
        if timeRemainingBar.progress <= 0 {
            print("Out of time")
            close()
        } else if timeRemainingBar.progress <= 0.2 {
            timeRemainingBar.progressTintColor = timerRed
        } else if timeRemainingBar.progress <= 0.5 {
            timeRemainingBar.progressTintColor = timerOrange
            isHalfTime = true
        }
    }
    
    
    func scheduleNotificaion() {
        //check to see if permissions granted - 2 is granted
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("User settings notification ******* \(settings.authorizationStatus.rawValue)")
            
            //if authorised.
            if settings.authorizationStatus.rawValue == 2 {
                
                //currently set to one minute after completing - for testing.
                NotificationService.instance.request(time: 60)
                
                //if a request has been set remove and replace
                UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { ( pending ) in
                    for request in pending {
                        print("Pending requests ******** \(request.identifier)")
                    }
                })
            }
        }
    }
    
    func close() {
        // dismiss(animated: true, completion: nil)
        // timer.invalidate()
        //update score label
        scoreLabel.text = String(questionIndex)
        
        //add emitter to view
//        if questionIndex >= 4 {
//            let emitter = Emitter.createEmitter()
//            emitter.emitterPosition = CGPoint(x: resultsPopUp.frame.width / 2.0, y: 0)
//            emitter.emitterSize = CGSize(width: resultsPopUp.frame.width, height: 1)
//            resultsPopUp.layer.addSublayer(emitter)
//        }
        
        if questionIndex < 3 {
            print("Standard Emitter")
            let emitter = Emitter.createEmitter()
            emitter.emitterPosition = CGPoint(x: resultsPopUp.frame.width / 2.0, y: 0)
            emitter.emitterSize = CGSize(width: resultsPopUp.frame.width, height: 1)
            resultsPopUp.layer.addSublayer(emitter)
        }
        
        if questionIndex == 3 {
            print("Bronze Emitter")
            let emitter = BronzeEmitter.createEmitter()
            emitter.emitterPosition = CGPoint(x: resultsPopUp.frame.width / 2.0, y: 0)
            emitter.emitterSize = CGSize(width: resultsPopUp.frame.width, height: 1)
            resultsPopUp.layer.addSublayer(emitter)
        }
        
        if questionIndex == 4 {
            print("Silver Emitter")
            let emitter = SilverEmitter.createEmitter()
            emitter.emitterPosition = CGPoint(x: resultsPopUp.frame.width / 2.0, y: 0)
            emitter.emitterSize = CGSize(width: resultsPopUp.frame.width, height: 1)
            resultsPopUp.layer.addSublayer(emitter)
        }
        
        if questionIndex >= 5 {
            print("Gold Emitter")
            let emitter = GoldEmitter.createEmitter()
            emitter.emitterPosition = CGPoint(x: resultsPopUp.frame.width / 2.0, y: 0)
            emitter.emitterSize = CGSize(width: resultsPopUp.frame.width, height: 1)
            resultsPopUp.layer.addSublayer(emitter)
        }
        
        
        //set score label test
        switch questionIndex {
        case 0:
            resultsTitleLabel.text = "Oops"
        case 1:
            resultsTitleLabel.text = "Keep trying"
        case 2:
            resultsTitleLabel.text = "Go again!"
        case 3:
            resultsTitleLabel.text = "Almost there"
        case 4:
            resultsTitleLabel.text = "Great!"
        case 5:
            resultsTitleLabel.text = "Awesome!!"
        default:
            resultsTitleLabel.text = "Score"
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
                if index <= self.questionIndex - 1 {
                    star.fadeIn()
                }
            }
        }
        
        resultsScoreLabel.text = "\(questionIndex)/5"
        
        
        timer.invalidate() //timer was running between screens
        
        if subTopic != nil {
            recordSubTopicResult()
            
            //authorise notification
            NotificationService.instance.authorise()
            
            //schedule with check for authorisation
            scheduleNotificaion()
            
        }
        
        if dailyChallenge != nil {
            
            //set close button to active
            popUpCloseBtn.alpha = 1
            popUpCloseBtn.isEnabled = true
            
            //authorise notification - will prompt user if not auth
            NotificationService.instance.authorise()
            
            //schedule with check for authorisation
            scheduleNotificaion()
            
        }
        
    }
    
    func recordSubTopicResult() {
        
        guard let sub = subTopic?._id else { return }
        guard let topicId = subTopic?.parentTopic._id else { return }
        guard let id = UserDefaults.standard.string(forKey: DEFAULTS_USERID) else { return }
        
        let score = String(questionIndex)
        let subAchieved: String
        
        if score == "5" {
            subAchieved = "true"
        } else {
            subAchieved = "false"
        }
        
        //create subtopic result || updated.
        // if result exists...
        if let subTopicResult = subResult {
            
            //put new result
            let result = SubtopicResult(achieved: subAchieved, score: score, subtopic: sub, id: id)
            
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
            let subtopicResult = SubtopicResult(achieved: subAchieved, score: score, subtopic: sub, id: id)
            //Post subtopic result
            print("**** ABOUT TO POST NEW SUB *****")
            print(subtopicResult)
            dataService.postNewSubtopicResult(subtopicResult) { (success) in
                if (success) {
                    print("Posted new sub result")
                    //                    print(self.dataService.recentSubTopicResult!)
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
                                    print("************\n REDOWNLOADED RESUTLS - 1 \n************")
                                    self.dataService.getSubTopicResults(id, completion: { (success) in
                                        if (success) {
                                            self.subtopicResultsReturned = true
                                            print("SUB TOPIC RESULTS RETURNED")
                                            
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
                                    print("************\n REDOWNLOADED RESUTLS - 2 \n************")
                                    self.dataService.getSubTopicResults(id, completion: { (success) in
                                        
                                        if (success) {
                                            self.subtopicResultsReturned = true
                                            print("SUB TOPIC RESULTS RETURNED")
                                            
                                            
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
    
    
    fileprivate func reset() {
        inputAnswer = ""
        answerLabel.text = "0"
    }
   
    //add number buttons to answer - all buttons connected
    @IBAction func buttonTapped(_ sender: UIButton) {
        
       
        answerLabel.nukeAllAnimations()
        
        //removes leading 0
        if answerLabel.text == "0" {
            answerLabel.text = ""
        }
        
        inputAnswer += String(sender.tag)
        answerLabel.text = inputAnswer
    }
    
    //reset var and label
    @IBAction func clearButtonTapped(_ sender: UIButton) {
        sender.pulsate()
        reset()
    }
    
    
    @IBAction func confirmButtonTapped(_ sender: UIButton) {
        
        //if correct move to next question and clear inputAnswer
        if inputAnswer == currentQuestion.correctAnswer {
            print("confirm")
            sender.pulsate()
            
            //haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            correctSoundPlayer.play()
            
            questionIndex += 1
            loadQuestions()
            reset()
        } else {
          //if incorrect clear label - use animations to suggest answers
            print("wrong")
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            wrongSoundPlayer.play()
            
            //animate to red
            UIView.transition(with: questionLabel, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.questionLabel.textColor = .red
            }) { (success) in
                if (success) {
                    UIView.transition(with: self.questionLabel, duration: 0.3, options: .transitionCrossDissolve, animations: {
                        self.questionLabel.textColor = .white
                    })
                }
            }
            
            
            sender.shake()
            reset()
        }
    }
    
    @IBAction func popupCloseButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}
