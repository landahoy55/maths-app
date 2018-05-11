//
//  MultipleChoiceImagesViewController.swift
//  maths-app
//
//  Created by P Malone on 11/05/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import UIKit

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
        dismiss(animated: true, completion: nil)
    }
    
    //TODO: networking and notifications
    
    
    
    //TODO: Confirm action...
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
