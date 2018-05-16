//
//  VoiceInputViewController.swift
//  maths-app
//
//  Created by P Malone on 20/03/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import UIKit
import Speech
import UserNotifications

//enum to indicate status
enum SpeechStatus {
    case ready
    case recognizing
    case unavailable
}

//Speech recongniser delegate required to access methods
//plist variables also set
class VoiceInputViewController: UIViewController, SFSpeechRecognizerDelegate {

    @IBOutlet weak var voiceButton: UIButton!
    @IBOutlet weak var detectedSpeechLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var timerProgressView: UIProgressView!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var correctLabel: UILabel!
    @IBOutlet weak var initialInformationString: UILabel!
    @IBOutlet weak var microphoneImageView: UIImageView!
    var microphoneImages: [UIImage] = []
    
    //Results pop up view
    var stars = [UILabel]()
    @IBOutlet var resultsPopUp: UIView!
    @IBOutlet weak var popupScoreLabel: UILabel!
    @IBOutlet weak var popupScoreTitle: UILabel!
    @IBOutlet weak var star1: UILabel!
    @IBOutlet weak var star2: UILabel!
    @IBOutlet weak var star3: UILabel!
    @IBOutlet weak var star4: UILabel!
    @IBOutlet weak var star5: UILabel!
    @IBOutlet weak var popupCloseBtn: UIButton!
    
    
    
    //required speech vars
    let audioEngine = AVAudioEngine() //required when working with audio
    let speechRecogniser: SFSpeechRecognizer? = SFSpeechRecognizer() //recognition can be nil, so optional
    var request = SFSpeechAudioBufferRecognitionRequest() //controls the buffer for live recording
    var recognitionTask: SFSpeechRecognitionTask? //manage task - allowing start/stop
    
    var status: SpeechStatus = .ready
    var isFirstTime = true
    
    
    //single digits returned as word. Set spelt words to ints.
    let helperStringToNumbers: [String: Int] = [
    
        "one" : 1,
        "two" : 2,
        "three" : 3,
        "four" : 4,
        "five" : 5,
        "six" : 6,
        "seven" : 7,
        "eight" : 8,
        "nine" : 9,
    ]
    
    
    //questions
    var subTopic: SubTopic?
    var subResult: RetreivedSubtopicResult?
    
    var questionIndex = 0
    var currentQuestion: Question!
    
    //additional variables
    var timer = Timer()
    var dataService = DataService.instance
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("STATUS....", status)
        
        //create animation array
        microphoneImages = createImageArray(total: 3, imagePrefix: "microphone")
        
        //set correct label to hidden
        correctLabel.alpha = 0
        //set initial animation to static image
        microphoneImageView.alpha = 0
        initialInformationString.alpha = 0
        voiceButton.alpha = 0
        
        
        popupCloseBtn.isEnabled = true
        popupCloseBtn.alpha = 0
        
        stars.append(star1)
        stars.append(star2)
        stars.append(star3)
        stars.append(star4)
        stars.append(star5)
        
        loadQuestions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
      
        let micImage = UIImage(named: "microphone-0.png")
        microphoneImageView.image = micImage
        UIView.animate(withDuration: 0.3) {
            self.microphoneImageView.alpha = 1
            self.initialInformationString.alpha = 1
            self.voiceButton.alpha = 1
        }
        
        //Now starts when player hits button
        //starTimer()
        //triggerRecording()
    }

    
    //create image arrays for animation - could be broken out into extension.
    func animate(imageView: UIImageView, images: [UIImage]) {
            imageView.animationImages = images
            imageView.animationDuration = 1.5
            imageView.startAnimating()
    }
    
    
    //attempt at adding prefixed images to array rather than .append
    func createImageArray(total: Int, imagePrefix: String) -> [UIImage] {
        var imageArray: [UIImage] = []
        //loop over count and and check for prefix.
        for imageCount  in 0..<total {
            //create name
            let imageName = "\(imagePrefix)-\(imageCount).png"
            //find image
            let image = UIImage(named: imageName)!
            imageArray.append(image)
        }
        return imageArray
    }
    
    
    func loadQuestions() {
        
        //unwrap subtopic
        //prepare next question - or close.
        if let subT = subTopic {
            questionIndex < subT.questions.count ? setQuestionLayout() : close()
        }

    }
    
    func setQuestionLayout() {
        currentQuestion = subTopic?.questions[questionIndex]
        questionLabel.text = currentQuestion.question
        
        //animate question label
        questionLabel.alpha = 0
        UIView.animate(withDuration: 0.7) {
            self.questionLabel.alpha = 1
        }
        
        scoreLabel.text = String(questionIndex)
        print(questionIndex)
    }
    
    //required as closure block remain in memory
    deinit {
        print("Deinit called")
        audioEngine.stop()
        request.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        //remove the node - singleton so accessible.
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionTask?.cancel()
    }
    
    func close() {
        
        //Carry out networking here.
        //Present popup
        cancelRecording()
        timer.invalidate()
        
        
        //update score label
        scoreLabel.text = String(questionIndex)
        
        //add emitter to view
        if questionIndex < 3 {
            let emitter = Emitter.createEmitter()
            emitter.emitterPosition = CGPoint(x: resultsPopUp.frame.width / 2.0, y: 0)
            emitter.emitterSize = CGSize(width: resultsPopUp.frame.width, height: 1)
            resultsPopUp.layer.addSublayer(emitter)
        }
        
        if questionIndex == 3 {
            let emitter = BronzeEmitter.createEmitter()
            emitter.emitterPosition = CGPoint(x: resultsPopUp.frame.width / 2.0, y: 0)
            emitter.emitterSize = CGSize(width: resultsPopUp.frame.width, height: 1)
            resultsPopUp.layer.addSublayer(emitter)
        }
        
        if questionIndex == 4 {
            let emitter = SilverEmitter.createEmitter()
            emitter.emitterPosition = CGPoint(x: resultsPopUp.frame.width / 2.0, y: 0)
            emitter.emitterSize = CGSize(width: resultsPopUp.frame.width, height: 1)
            resultsPopUp.layer.addSublayer(emitter)
        }
        
        if questionIndex >= 5 {
            let emitter = GoldEmitter.createEmitter()
            emitter.emitterPosition = CGPoint(x: resultsPopUp.frame.width / 2.0, y: 0)
            emitter.emitterSize = CGSize(width: resultsPopUp.frame.width, height: 1)
            resultsPopUp.layer.addSublayer(emitter)
        }
        
        //set score desc label
        switch questionIndex {
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
                if index <= self.questionIndex - 1 {
                    star.fadeIn()
                }
            }
        }
        
        popupScoreLabel.text = "\(questionIndex)/5"
        
        //networking
    
        if subTopic != nil {
            recordSubTopicResult()
            
            //authorise notification - will prompt user if not auth
            NotificationService.instance.authorise()
            
            //schedule with check for authorisation
            scheduleNotificaion()
        }
        
        // this should be in the popup close button.
        // dismiss(animated: true, completion: nil)
    }
    
    //Networking funcs
    //Create or update subtopic result
    func recordSubTopicResult() {
        
        guard let sub = subTopic?._id else { return }
        guard let topicId = subTopic?.parentTopic._id else { return }
        guard let id = UserDefaults.standard.string(forKey: DEFAULTS_USERID) else { return }
        
        let scoreToRecord = String(questionIndex)
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
                                                    self.popupCloseBtn.alpha = 1
                                                    self.popupCloseBtn.isEnabled = true
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
                                                    self.popupCloseBtn.alpha = 1
                                                    self.popupCloseBtn.isEnabled = true
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
    
    func startTimer() {
        timerProgressView.tintColor = timerGreen
        timerProgressView.trackTintColor = UIColor.white
        timerProgressView.progress = 1.0
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTimerProgress), userInfo: nil, repeats: true)
    }
    

    @objc func updateTimerProgress(){
        
        timerProgressView.progress -= 0.01/30
        
        //countdown timer - not 100% accurate
        let countdown = Int((timerProgressView.progress / 3.33) * 100)
        countdownLabel.text = String(countdown)
        
        if timerProgressView.progress <= 0 {
            print("Out of time")
            close() //exit when reaches 0
        } else if timerProgressView.progress <= 0.2 {
            
            timerProgressView.progressTintColor = timerRed
        } else if timerProgressView.progress <= 0.5 {
            timerProgressView.progressTintColor = timerOrange
        }
    }
    
    
    func recordAndRecogniseSpeechWithCallback(completion: @escaping callback) {
        
        print("Voice recognition started")
        
        //clear any preexisting tasks - shouldn't occur
        if let recognitionTask = recognitionTask {
            print("task exists", recognitionTask)
            recognitionTask.cancel()
            self.recognitionTask = nil
            request.endAudio()
        }
        
        status = .recognizing
        voiceButton.setTitle("Stop", for: .normal)
        
        //Audio engine uses 'nodes' to process audio.
        //inputNode is a singleton for the incoming audio
        //https://developer.apple.com/documentation/avfoundation/avaudionode
        
        let node = audioEngine.inputNode
        
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            self.request.append(buffer)
        }
        
        //start and stop the audio engine - handling error
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch  {
            return print(error)
        }
        
        //further checks, making sure recogniser is supported
        guard let recogniser = SFSpeechRecognizer() else {
            
            //TODO - show in UI
            //recongiser not supported
            return
        }
        
        if !recogniser.isAvailable {
            
            //TODO - show in UI
            //recogniser is not availble at current time
            return
        }
    
        
        //begin recognition
        recognitionTask = speechRecogniser?.recognitionTask(with: request, resultHandler: { (result, err) in
            
            //added to prevent error second time around - result being nil
            if result != nil {
                //check result
                if let result = result {
                    
                    for transcriptions in result.transcriptions {
                        print("TRANSCRIPTION", transcriptions.formattedString)
                        var stringToCheck = ""
                        stringToCheck = transcriptions.formattedString
                        print("STRING TO CHECK", stringToCheck)
                    }
                    
                    let bestString = result.bestTranscription.formattedString
                    print("Best string", bestString)
                    
                    // let test = result.transcriptions
                    // print("TEST", test[0].segments[0].substring)
                    
                    //TODO - check if this should be on main thread.
                    self.detectedSpeechLabel.text = bestString
                    
                    //results are passed back as an array.
                    //check last string... in this case for a number
                    var lastString: String = ""
                    //loop over returned speech
                    for segment in result.bestTranscription.segments {
                        
                        //Exit closure block prior to deallocation
                        if self.questionIndex == 5 {
                            //exit point
                            return
                        }
                        
                        //find last part
                        let indexTo = bestString.index(bestString.startIndex, offsetBy: segment.substringRange.location)
                        lastString = String(bestString[indexTo...])
//                        print("LAST STRING", lastString)
                        var resultToCheck: String? = nil //clear string
                        resultToCheck = lastString //last part of results
//                        print("STRING TO ", resultToCheck) //debugging
                        
                        //answer to check
                        let correctAnswer = self.subTopic?.questions[self.questionIndex].correctAnswer
//                        print("********* ANSWER *********", correctAnswer)
                        
                        //exit out of function with completion handler if successful
                        if resultToCheck == correctAnswer {
                            print("Correct!!")
                            //cancelRecording()
                            //questionIndex += 1
                            
                            //load question triggers recording - not working correctly
                            //loadQuestions()
                            
                            //run completion block if answer is correct
                            completion(true)
                            return //can remove
                        }
                        
                        //Results from 1 through to 9 are analysed as words - look through dictionary to return number.
                        if resultToCheck != correctAnswer {
                            print("NOT correct")
                            
                            //check is value is in dictionary
                            for (key, value) in self.helperStringToNumbers {
                                if resultToCheck == key && String(value) == correctAnswer {
                                  completion(true)
                                }
                            }
                            
                            //cancelRecording()
                            //triggerRecording()
                        }
                        
                        //check answer here. Return callback?
                        //self.checkAnswer(guess: resultToCheck!) //guess - replace with game logic.
                        
                        //return
                    }
                    
                } else if let error = err {
                    print("ERRRORRR *****", error)
                }
            }
        })
        
    }
    
    func cancelRecording() {
        print("Recording stopped")
        
        //replace animation with static image
        microphoneImageView.stopAnimating()
        let micImage = UIImage(named: "microphone-0.png")
        microphoneImageView.image = micImage
        
        //animate help
        UIView.animate(withDuration: 0.5) {
            self.initialInformationString.alpha = 1
        }
        
        voiceButton.setTitle("Start", for: .normal)
        audioEngine.stop()
        request.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        //remove the node - singleton so accessible.
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionTask?.cancel()
        status = .ready
        
    
    }
    

    
    func triggerRecording() {
        
        //swtich on whether recording or not...
        
        switch status {
        case .ready:
            //recordAndRecogniseSpeech()
            startGame()
        case .recognizing:
            cancelRecording()
        case .unavailable:
            return //TODO: PRESENT ALERT OR DISMISS
        }
    }
    
    func startGame(){
        
        //start animation - uiimageview animation
        animate(imageView: microphoneImageView, images: microphoneImages)
        
        //animate out initial information
        UIView.animate(withDuration: 0.5) {
            self.initialInformationString.alpha = 0
        }
        
    
        //remains in the recording function for lifecycle of challenge.
        recordAndRecogniseSpeechWithCallback { (success) in
            if success {
                print("WINNING")
                self.questionIndex += 1
                
                //TODO: Check should this should be on the main thread
                
                //animate correct label
                //nested animation block used.
                //animation with options block causing issue with last frame.
                UIView.animate(withDuration: 0.5, animations: {
                    self.correctLabel.alpha = 1
                }, completion: { (success) in
                    UIView.animate(withDuration: 0.5, animations: {
                        self.correctLabel.alpha = 0
                    })
                })
                
                self.loadQuestions()
            }
            
            if !success {
                print("******* HERE IN THE FALSE SECTION")
                //no false return from completion handler as yet
            }
            
        }
    }
    
    @IBAction func voiceButtonTapped(_ sender: UIButton) {
        
        //begin timer first time only
        if isFirstTime {
          startTimer()
          isFirstTime = false
        }

        triggerRecording()
        
    }
    
    @IBAction func popUpCloseBtn(_ sender: UIButton) {
    
        //remove task if still in memory
        if let recognitionTask = recognitionTask {
            print("task exists", recognitionTask)
            recognitionTask.cancel()
            self.recognitionTask = nil
            request.endAudio()
        }
        
        //stop audio engine
        audioEngine.stop()
        request.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        //remove the node - singleton so accessible.
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionTask?.cancel()
        
        dismiss(animated: true, completion: nil)
    
    }
    
    
    @IBAction func closeButton(_ sender: UIButton) {
        //memory leak?
        
        if let recognitionTask = recognitionTask {
            print("task exists", recognitionTask)
            recognitionTask.cancel()
            self.recognitionTask = nil
            request.endAudio()
        }
        
        audioEngine.stop()
        request.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        //remove the node - singleton so accessible.
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionTask?.cancel()
        
        dismiss(animated: true, completion: nil)
    }
    
}
