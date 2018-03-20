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
    
    //required speech vars
    let audioEngine = AVAudioEngine() //required when working with audio
    let speechRecogniser: SFSpeechRecognizer? = SFSpeechRecognizer() //recognition can be nil, so optional - can also set region - possible better to be british?
    let request = SFSpeechAudioBufferRecognitionRequest() //controls the buffer for live recording
    var recognitionTask: SFSpeechRecognitionTask? //manage task - allowing start/stop
    
    var status: SpeechStatus = .ready
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("STATUS....", status)
    }

    func recordAndRecogniseSpeech() {
        
        print("Voice recognition started")
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
        
        var resultToCheck: String = "" //empty string to store the last results each time around
        
        
        //begin recognition
        recognitionTask = speechRecogniser?.recognitionTask(with: request, resultHandler: { (result, err) in
            
            //added to prevent error second time around - result being nil
            if result != nil {
                //check result
                if let result = result {
                    
//                    for transcriptions in result.transcriptions {
//                        print("TRANSCRIPTION", transcriptions.formattedString)
//                        stringToCheck = ""
//                        stringToCheck = transcriptions.formattedString
//                    }
                    
                    
                    
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
                        
                        //find last part
                        let indexTo = bestString.index(bestString.startIndex, offsetBy: segment.substringRange.location)
                        lastString = String(bestString[indexTo...])
                        
                        resultToCheck = "" //clear string
                        resultToCheck = lastString //pass in last part of results
                        print("STRING TO ", resultToCheck) //debugging
                        self.testQuestion(guess: resultToCheck) //guess - replace with game logic.
                    }
                    
                } else if let error = err {
                    print("ERRRORRR *****", error)
                }
            }
        })
        
    }
    
    func cancelRecording() {
        print("Recording stopped")
        status = .ready
        voiceButton.setTitle("Start", for: .normal)
        audioEngine.stop()
        request.endAudio()
        //remove the node - singleton so accessible.
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionTask?.cancel()
        
        
//        audioEngine.stop()
//        request.endAudio()
//        // Cancel the previous task if it's running
//        if let recognitionTask = recognitionTask {
//            recognitionTask.cancel()
//            self.recognitionTask = nil
//        }
    }
    
    
    func testQuestion(guess: String) {
        
        let answer = "36"
        
        if guess == answer {
            print("Correct!!")
            cancelRecording()
        }
        
    }
    
    
    @IBAction func voiceButtonTapped(_ sender: UIButton) {
        
        //swtich on whether recording or not...
        switch status {
        case .ready:
            recordAndRecogniseSpeech()
        case .recognizing:
            cancelRecording()
        case .unavailable:
            return //TODO: PRESENT ALERT OR DISMISS
        }
        
    }
    
    @IBAction func closeButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}
