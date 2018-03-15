//
//  DailyChallengeViewController.swift
//  maths-app
//
//  Created by P Malone on 14/03/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import UIKit

class DailyChallengeViewController: UIViewController {
    
    
    @IBOutlet var challengeNotAvailableView: UIView!
    @IBOutlet weak var viewToShow: UIView!
    @IBOutlet weak var playButton: RoundButton!
    
    @IBOutlet weak var pulseView: UIView!
    
    let isAvilable = true

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        guard isAvilable else {
            challengeNotAvailableView.center = viewToShow.center
            viewToShow.addSubview(challengeNotAvailableView)
            return
        }
        
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        animatePulseView()
    }
    
    func animatePulseView(){
        
        pulseView.alpha = 0.6
        pulseView.layer.cornerRadius = self.pulseView.frame.size.width / 2
        
        //can also add in autoreverse.
        //pulsing a view behind the button
        UIView.animate(withDuration: 2, delay: 0, options: [.curveEaseInOut, .repeat], animations: {
            self.pulseView.alpha = 0
            self.pulseView.transform = CGAffineTransform(scaleX: 14, y: 14)
        }) { (success) in
            self.pulseView.transform = CGAffineTransform.identity
        }
        
    }
}
