//
//  VoiceInputViewController.swift
//  maths-app
//
//  Created by P Malone on 20/03/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import UIKit
import Speech

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
    
    //required speech vars
    let audioEngine = AVAudioEngine() //required when working with audio
    let speechRecogniser: SFSpeechRecognizer? = SFSpeechRecognizer() //recognition can be nil, so optional - can also set region - possible better to be british?
    var request = SFSpeechAudioBufferRecognitionRequest() //controls the buffer for live recording
    var recognitionTask: SFSpeechRecognitionTask? //manage task - allowing start/stop
    
    var status: SpeechStatus = .ready
    var isFirstTime = true
    
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
    var questionIndex = 0
    var currentQuestion: Question!
    var timer = Timer()
    
    
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
        
        //starTimer()
        //triggerRecording()
    }

    
    //create image arrays for animation - could be broken out into extension.
    func animate(imageView: UIImageView, images: [UIImage]) {
            imageView.animationImages = images
            imageView.animationDuration = 1.5
            imageView.startAnimating()
    }
    
    func createImageArray(total: Int, imagePrefix: String) -> [UIImage] {
        var imageArray: [UIImage] = []
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
        cancelRecording()
        timer.invalidate()
        dismiss(animated: true, completion: nil)
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
        guard let myRecongiser = SFSpeechRecognizer() else {
            
            //TODO - show in UI
            //recongiser not supported
            return
        }
        
        if !myRecongiser.isAvailable {
            
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
                    
                    self.detectedSpeechLabel.text = bestString
                    
                    //results are passed back as an array.
                    //check last string... in our case for a number
                    var lastString: String = ""
                    //loop over returned speech
                    for segment in result.bestTranscription.segments {
                        
                        //Exit closure block prior to deallocation
                        if self.questionIndex == 5 {
                            return
                        }
                        
                        //find last part
                        let indexTo = bestString.index(bestString.startIndex, offsetBy: segment.substringRange.location)
                        lastString = String(bestString[indexTo...])
//                        print("LAST STRING", lastString)
                        var resultToCheck: String? = nil //clear string
                        resultToCheck = lastString //pass in last part of results
//                        print("STRING TO ", resultToCheck) //debugging
                        
                        //grab answer t0 check
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
        
        
//        audioEngine.stop()
//        request.endAudio()
//        // Cancel the previous task if it's running
//        if let recognitionTask = recognitionTask {
//            recognitionTask.cancel()
//            self.recognitionTask = nil
//        }
    
    }
    
    //logic in recording function.
//    func checkAnswer(guess: String) {
//
//        if let subtopic = subTopic{
//            let correctAnswer = subtopic.questions[questionIndex].correctAnswer
//            print("********* ANSWER *********", correctAnswer)
//
//            if guess == correctAnswer {
//                print("Correct!!")
//                cancelRecording()
//                questionIndex += 1
//
//                //load question triggers recording - not working correctly
//                loadQuestions()
//                return
//            }
//
//            if guess != correctAnswer {
//                print("NOT correct")
//                //cancelRecording()
//                //triggerRecording()
//
//            }
//        }
//    }
    
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
                
//                UIView.animate(withDuration: 1, delay: 0, options: .autoreverse, animations: {
//                    self.correctLabel.alpha = 1
//                })
                
//                UIView.animate(withDuration: 1, delay: 0, options: .autoreverse, animations: {
//                    self.correctLabel.alpha = 1
//                }, completion: { (success) in
//                    self.correctLabel.alpha = 0
//                })
                
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
