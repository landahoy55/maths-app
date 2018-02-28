//
//  ProtoQuizViewController.swift
//  maths-app
//
//  Created by P Malone on 27/02/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import UIKit

class MultipleChoiceViewController: UIViewController {
    
    //injected on load
    var subTopic: SubTopic?
    //count
    var questionIndex = 0
    //current question - optional to start with.
    var currentQuestion: Question!
    //time, score
    var timer = Timer()
    var score = 0 //CURRENTLY USING QUESITON INDEX... WHAT ABOUT INCORRECT
    var isHalfTime = false
    
    //Outlets
    @IBOutlet weak var questionLabel: UILabel!
    var buttons = [UIButton]() //add buttons?
    @IBOutlet weak var answerButton0: UIButton!
    @IBOutlet weak var answerButton1: UIButton!
    @IBOutlet weak var answerButton2: UIButton!
    @IBOutlet weak var answerButton3: UIButton!
    @IBOutlet weak var timerProgressView: UIProgressView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //append buttons
        buttons.append(answerButton0)
        buttons.append(answerButton1)
        buttons.append(answerButton2)
        buttons.append(answerButton3)
        
        //Move in a bit.
        loadQuestion()
        
        //set background
        view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        startTimer()
        
//        if let subT = subTopic {
//            print(subT.questions[0].question)
//        }
    }

    func loadQuestion() {
        // Falling through...
        //        if questionIndex <= 6 {
        //            currentQuestion = subTopic?.questions[questionIndex]
        //            setQuestionLayout()
        //        } else {
        //            dismiss(animated: true, completion: nil)
        //        }
        
        //unwrap optional, perform ternary operator
        //close when question index reaches count of questions.
        if let subT = subTopic {
            questionIndex < subT.questions.count ? setQuestionLayout() : close()
        }
        
    }
    
    //including buttons
    func setQuestionLayout() {
        currentQuestion = subTopic?.questions[questionIndex]
        questionLabel.text = currentQuestion.question
        
        for (index, button) in buttons.enumerated() {
            print(button.tag)
            print(currentQuestion.answers[index].answer)
            button.setTitle(currentQuestion.answers[index].answer, for: .normal)
            button.backgroundColor = UIColor.clear
        }
        
        scoreLabel.text = String(questionIndex)
        
        if questionIndex >= 3 {
            countdownLabel.blink()
        }
        
        if isHalfTime {
            countdownLabel.blink()
        }
        
    }
    
    //timer functions
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
        timer.invalidate() //timer was running between screens
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func answerPressed(_ sender: UIButton) {
        
        //check to see if correct answer pressed
        if sender.titleLabel?.text == currentQuestion.correctAnswer {
            
            sender.pulsate()
            print("correct answer pressed")
            
//            UIView.animate(withDuration: 2, animations: {
//                self.questionLabel.textColor = UIColor.green
//            }, completion: { (_) in
//                self.questionIndex += 1
//                //show next question
//                self.loadQuestion()
//            })
            
            questionIndex += 1
            //show next question
            loadQuestion()
            
            
        } else {
            sender.shake()
            print("Oops - Incorrect answer pressed")
        }
    }
    
}
