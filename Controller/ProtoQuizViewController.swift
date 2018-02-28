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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let subT = subTopic {
            print(subT.questions[0].question)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeBtn(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}
