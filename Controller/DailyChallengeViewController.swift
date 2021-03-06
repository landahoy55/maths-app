//
//  DailyChallengeViewController.swift
//  maths-app
//
//  Created by P Malone on 14/03/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import UIKit

class DailyChallengeViewController: UIViewController {
    
    var dataService = DataService.instance
    var dailyChallenge: DailyChallenge?
    
    @IBOutlet var challengeNotAvailableView: UIView!
    @IBOutlet weak var viewToShow: UIView!
    @IBOutlet weak var playButton: RoundButton!
    @IBOutlet weak var pulseView: UIView!
    @IBOutlet weak var challengeDescription: UILabel!
    @IBOutlet weak var challengeAvailableLabel: UILabel!
    
    var isAvailable = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //check to see if a challenge is available
        //pass to var
        if (dataService.downloadedChallenge != nil) {
            isAvailable = true
            dailyChallenge = dataService.downloadedChallenge
            challengeDescription.text = dailyChallenge?.description
            challengeDescription.alpha = 1
            challengeAvailableLabel.alpha = 1
        }
            
        //show not available view if no challenge is present
        if !isAvailable {
            challengeNotAvailableView.center = viewToShow.center
            viewToShow.addSubview(challengeNotAvailableView)
        }
        
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //pulse play button
        animatePulseView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let identifier = segue.identifier {
            
            switch identifier {
                
                case "multipleChoiceSegue":
                let multipleChoiceViewController = segue.destination as! MultipleChoiceViewController
                multipleChoiceViewController.dailyChallenge = dailyChallenge
                
                case "inputSegue":
                let inputAnswerViewController = segue.destination as! InputAnswerViewController
                inputAnswerViewController.dailyChallenge = dailyChallenge
            
                default: return
            }
            
        }
        
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
    
    @IBAction func playChallenge(_ sender: UIButton) {
        guard let dc = dailyChallenge else { return }
        let segue = "\(dc.type)Segue"
        performSegue(withIdentifier: segue, sender: self)

    }
    
}
