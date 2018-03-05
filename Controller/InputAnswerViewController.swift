//
//  InputAnswerViewController.swift
//  maths-app
//
//  Created by P Malone on 28/02/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import UIKit

class InputAnswerViewController: UIViewController {

    var subTopic: SubTopic?
    var questionIndex = 0
    var currentQuestion: Question!
    
    
    var timer = Timer()
    var score = 0 // currently using index
    var isHalfTime = false
    var inputAnswer = ""
    var isFirstTime = true
    
    
    //outlets - timer
    @IBOutlet weak var timerProgressView: UIProgressView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!
    
    //outlets - question and answer
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        
        answerLabel.text = "0"
        
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
        
        
    }
    
    func setQuestionLayout() {
        
        currentQuestion = subTopic?.questions[questionIndex]
        questionLabel.text = currentQuestion.question
        
        reset()
        
        print("***** Correct answer: \(currentQuestion.correctAnswer)")
        
        scoreLabel.text = String(questionIndex)
        
        //Is this the most appropriate place
        if questionIndex >= 3 {
            countdownLabel.blink()
        }
        
        if isHalfTime {
            countdownLabel.blink()
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
            close()
        } else if timerProgressView.progress <= 0.2 {
            
            timerProgressView.progressTintColor = timerRed
        } else if timerProgressView.progress <= 0.5 {
            timerProgressView.progressTintColor = timerOrange
            isHalfTime = true
        }
    }
    
    func close() {
        dismiss(animated: true, completion: nil)
        timer.invalidate()
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
            questionIndex += 1
            loadQuestions()
        } else {
          //if incorrect clear label - use animations to suggest answers
            print("wrong")
            sender.shake()
            reset()
        }
    }
}
