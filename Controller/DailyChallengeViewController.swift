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
    let isAvilable = false

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//       if isAvilable {
//           //show challenge available
//       } else  {
//           //show challenge unavilable
//            challengeNotAvailableView.center = viewToShow.center
//            viewToShow.addSubview(challengeNotAvailableView)
//       }
        
        guard isAvilable else {
            challengeNotAvailableView.center = viewToShow.center
            viewToShow.addSubview(challengeNotAvailableView)
            return
        }
        
    navigationController?.navigationBar.prefersLargeTitles = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
