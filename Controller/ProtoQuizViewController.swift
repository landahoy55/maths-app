//
//  ProtoQuizViewController.swift
//  maths-app
//
//  Created by P Malone on 27/02/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import UIKit

class ProtoQuizViewController: UIViewController {
    
    //injected on load
    var subTopic: SubTopic?
    //count
    var questionIndex = 0
    //current question - optional to start with.
    var currentQuestion: Question!
    //time, score
    var timer = Timer()
    var score = 0
    
    //Outlets
    
    @IBOutlet weak var questionLabel: UILabel!
    
    //add to array?
    var buttons = [UIButton]() //add buttons?
    @IBOutlet weak var answerButton0: UIButton!
    @IBOutlet weak var answerButton1: UIButton!
    @IBOutlet weak var answerButton2: UIButton!
    @IBOutlet weak var answerButton3: UIButton!
    
    @IBOutlet weak var timerProgressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //append buttons
        buttons.append(answerButton0)
        buttons.append(answerButton1)
        buttons.append(answerButton2)
        buttons.append(answerButton3)
        
        //Move in a bit.
        loadQuestion()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let subT = subTopic {
            print(subT.questions[0].question)
        }
    }

    func loadQuestion() {
        currentQuestion = subTopic?.questions[questionIndex]
        setQuestionLayout()
    }
    
    //including buttons
    func setQuestionLayout() {
        questionLabel.text = currentQuestion.question
        for (index, button) in buttons.enumerated() {
            print(button.tag)
            print(currentQuestion.answers[index].answer)
            button.setTitle(currentQuestion.answers[index].answer, for: .normal)
        }
    }
    
    @IBAction func closeBtn(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func answerPressed(_ sender: UIButton) {
        
    }
    
}
