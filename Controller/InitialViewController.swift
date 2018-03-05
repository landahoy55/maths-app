//
//  InitialViewController.swift
//  maths-app
//
//  Created by P Malone on 20/02/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DataService.instance.getAllTopics()
    }
    
    override func viewDidAppear(_ animated: Bool) {
       
        //TODO: Check to see if user is authenticated - go to home screen
        //TODO: If not perform segue to menu
        
        if AuthorisationService.instance.isAuthenticated == true {
            
            
            performSegue(withIdentifier: "toHomeWithAuthVC", sender: nil)
            
        } else {
            performSegue(withIdentifier: "toMenuVC", sender: nil)
        }
    
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
