//
//  HomeViewController.swift
//  maths-app
//
//  Created by P Malone on 20/02/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {


    @IBOutlet weak var nameLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        //Show name
        nameLbl.text = UserDefaults.standard.string(forKey: DEFAULTS_EMAIL)
        
        //set gradient
        view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        
        //Conform
        DataService.instance.delegate = self
        DataService.instance.getAllTopics()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let protoQuizViewController = segue.destination as? ProtoQuizViewController {
            protoQuizViewController.subTopic = DataService.instance.downloadedTopics[0].subTopics[1]
        }
    }
    
    
    @IBAction func logOut(_ sender: UIButton) {
        AuthorisationService.instance.logOut()
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func getTopicsBtn(_ sender: UIButton) {
        topicsLoaded()
    }
    
    @IBAction func quizBtn(_ sender: UIButton) {
        
    }
}

extension HomeViewController: DataServiceDelegate {
    func topicsLoaded() {
        print("********* Clicked")
        print(DataService.instance.downloadedTopics[0].subTopics[1])
    }
}
