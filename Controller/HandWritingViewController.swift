//
//  HandWritingViewController.swift
//  maths-app
//
//  Created by P Malone on 22/03/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import UIKit
import UserNotifications
import Vision

//Vision frame work combines CoreML, classificaion models and images/video
//https://developer.apple.com/documentation/vision/classifying_images_with_vision_and_core_ml

//Code extended from Brian Advent open source project series
//Intergration with scoring system and multiple characters added
//Additional handling of images added to allow for white background - consistent with UI
//Ref https://github.com/brianadvent/CoreMLHandwritingRecognition

class HandWritingViewController: UIViewController {

    //Outlets
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var timeRemainingBar: UIProgressView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var digit1: DigitDrawView!
    @IBOutlet weak var digit2: DigitDrawView!
    @IBOutlet weak var recognisedLabel: UILabel!
    
    @IBOutlet weak var correctLabel: UILabel!
    @IBOutlet weak var helpLabel: UILabel!
    
    var stars = [UILabel]()
    @IBOutlet var resultsPopUp: UIView!
    @IBOutlet weak var resultScoreTitle: UILabel!
    @IBOutlet weak var resultsScoreLabel: UILabel!
    @IBOutlet weak var star1: UILabel!
    @IBOutlet weak var star2: UILabel!
    @IBOutlet weak var star3: UILabel!
    @IBOutlet weak var star4: UILabel!
    @IBOutlet weak var star5: UILabel!
    @IBOutlet weak var popUpCloseBtn: UIButton!
    
    
    var subTopic: SubTopic?
    var subResult: RetreivedSubtopicResult?
    var isFromHomeScreen: Bool?
    
    
    var currentQuestion: Question!
    var questionIndex = 0
    var timer = Timer()
    var dataService = DataService.instance
    
    var writingAreas = [DigitDrawView]() //to loop over writing areas
    var requests = [VNRequest]() //to store requests
    var possibleAnswer: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        writingAreas.append(digit1)
        writingAreas.append(digit2)
        
        startTimer()
        //set up questions
        loadQuestions()
        //prepare pretrained model
        modelSetUp()
        
        stars.append(star1)
        stars.append(star2)
        stars.append(star3)
        stars.append(star4)
        stars.append(star5)
        popUpCloseBtn.isEnabled = false
        popUpCloseBtn.alpha = 0
        
        correctLabel.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //fade out label
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            
            UIView.animate(withDuration: 0.5, animations: {
                self.helpLabel.alpha = 0
            })
            
        }
    }
    
    func modelSetUp() {
        
        //prepare model
        //load in model
        guard let visionModel = try? VNCoreMLModel(for: MNIST().model) else {
            print("Model not available")
            //exit if issue with model
            dismiss(animated: true, completion: nil)
            return
        }
        
        //Set up request
        //requests can now be called with VNImageRequestHandler
        let request = VNCoreMLRequest(model: visionModel, completionHandler: self.classificationRequest)
        
        //tidying
        self.requests.removeAll()
        self.requests = [request]
    }
    
    //Handle request
    func classificationRequest(request: VNRequest, error: Error?) {
        
        //request contains an array of results, type ANY - what has been observed
        guard let observations = request.results else {
            print("no observation");
            return
        }
        print("Observations ********", observations)
        
        //results are in order by confidence. Needs to be cast as an observation to get at properties.
        let classification = observations.first as! VNClassificationObservation
        
        //returns the result
        let classificationId = classification.identifier
        print("Classified", classificationId)
    
        //push result var
        possibleAnswer += classificationId
        
        //display - move back to main thread to update label.
        DispatchQueue.main.async {
            //Configure label
            self.recognisedLabel.text = self.possibleAnswer
            //check answer
            self.checkAnswer(possibleAnswer: self.possibleAnswer)
        }
    
    }
    
    //Model requires a 28 x 28 monochrome images.
    //Convert canvas into 28 x 28 images.
    func performRequest(canvas: DigitDrawView) {
        
        
        //create image from view
        let image = UIImage(view: canvas)
        //scale to 28 x 28 as per model
        let scaledImage = scaleImage(image: image, toSize: CGSize(width: 28, height: 28))
        
        //Invert colour - model prefers black background
        //https://developer.apple.com/library/content/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/filter/ci/CIColorMonochrome
        let imageToinvert = CIImage(image: scaledImage)
        guard let filter = CIFilter(name: "CIColorInvert") else {
            print("issue with filter")
            return
        }
        
        filter.setValue(imageToinvert, forKey: kCIInputImageKey)
        
        let imageToRequest = convertCIImageToCGImage(inputImage: filter.outputImage!)
        
        //prepare request
        let imageRequestHandler = VNImageRequestHandler(cgImage: imageToRequest!, options: [:])
        
        //process
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
    
    func checkAnswer(possibleAnswer: String) {
        
        if possibleAnswer == currentQuestion.correctAnswer {
            questionIndex += 1
            loadQuestions()
            clear()
            
            //animate correct label
            UIView.animate(withDuration: 1, animations: {
                self.correctLabel.alpha = 1
            }, completion: { (success) in
                UIView.animate(withDuration: 1, animations: {
                    self.correctLabel.alpha = 0
                })
            })
           
        } else {

            //falling through here as two requests are being processed - for each canvas.
            //Use a flag, or process answer in a different way?
            
            //clear()
            
        }
        
    }
    
    
    //MARK: Set up
    func loadQuestions() {
        if let subT = subTopic {
            print("**** SUBTOPIC AVAILABLE *****")
            questionIndex < subT.questions.count ? setQuestionLayout() : close()
        }
    }
    
    func setQuestionLayout() {
        currentQuestion = subTopic?.questions[questionIndex]
        questionLabel.text = currentQuestion.question
        scoreLabel.text = String(questionIndex)
    }
    
    func startTimer() {
        timeRemainingBar.tintColor = timerGreen
        timeRemainingBar.trackTintColor = UIColor.white
        timeRemainingBar.progress = 1.0
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTimerProgress), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimerProgress(){
        
        timeRemainingBar.progress -= 0.01/60
        
        
        let countdown = Int((timeRemainingBar.progress) * 60)
        countdownLabel.text = String(countdown)
        
        if timeRemainingBar.progress <= 0 {
            print("Out of time")
            close()
        } else if timeRemainingBar.progress <= 0.2 {
            
            timeRemainingBar.progressTintColor = timerRed
        } else if timeRemainingBar.progress <= 0.5 {
            timeRemainingBar.progressTintColor = timerOrange
        }
    }
    
    func close() {
        
        //present popup
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
        
        //set score label test
        switch questionIndex {
        case 0:
            resultScoreTitle.text = "Oops"
        case 1:
            resultScoreTitle.text = "Keep trying"
        case 2:
            resultScoreTitle.text = "Go again!"
        case 3:
            resultScoreTitle.text = "Almost there"
        case 4:
            resultScoreTitle.text = "Great!"
        case 5:
            resultScoreTitle.text = "Awesome!!"
        default:
            resultScoreTitle.text = "Score"
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
                print("QUESTION INDEX", self.questionIndex)
                
                if index <= self.questionIndex - 1 {
                    star.fadeIn()
                }
            }
        }
        
        resultsScoreLabel.text = "\(questionIndex)/5"
        
    
        timer.invalidate()
        
        if isFromHomeScreen == true {
            
            print("Is from home screen block")
            
            UIView.animate(withDuration: 0.3, animations: {
                self.popUpCloseBtn.alpha = 1
                self.popUpCloseBtn.isEnabled = true
            })
            
            return
        }
        
        //networking
        if subTopic != nil {
            recordSubTopicResult()
            
            //authorise notification - will prompt user if not auth
            NotificationService.instance.authorise()
            
            //schedule with check for authorisation
            scheduleNotificaion()
        }
        
    }
    
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
    
    func clear() {
        
        //if content is in canvas clear
        for canvas in writingAreas {
            if canvas.path != nil {
                canvas.clearCanvas()
            }
        }
        
        //reset
        possibleAnswer = ""
        recognisedLabel.text = possibleAnswer
        
        //reset vision - may not be necessary.
        modelSetUp()
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
                //This might not be neccessary. Can only schedule one notification with id
                UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { ( pending ) in
                    for request in pending {
                        print("Pending requests ******** \(request.identifier)")
                    }
                })
            }
        }
    }
    
    @IBAction func confirmButtonTapped(_ sender: UIButton) {
        
        
        
        for (index, canvas) in writingAreas.enumerated() {
            
            print("CANVAS :", index)

            //first time - blank canvas may be nil - no result captured.
            if canvas.path != nil {
                
//                print("CANVAS IS EMPTY:", canvas.path.cgPath.isEmpty)
                
                //check to see if empty - canvas paths are nil if blank
                //allowing users to write in either canvas
                if canvas.path.cgPath.isEmpty == false {
                    performRequest(canvas: canvas)
                    //answer checked following request
                }
            }
        }
        
    }
    
    
    @IBAction func popUpCloseBtn(_ sender: UIButton) {
    
        dismiss(animated: true, completion: nil)
        
    }
    
    
    @IBAction func clearButtonTapped(_ sender: UIButton) {
    
        clear()
    
    }
    
    //Helper methods
    //models requires 28 x 28
    func scaleImage (image: UIImage, toSize size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        return newImage!
    }
    
    //No initaliser to create CGImage from CIImage - CIImages are data - not for presentation
    func convertCIImageToCGImage(inputImage: CIImage) -> CGImage? {
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(inputImage, from: inputImage.extent) {
            return cgImage
        }
        return nil
    }

}
