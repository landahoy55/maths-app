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
    }
    
    
    @IBAction func logOut(_ sender: UIButton) {
    
        AuthorisationService.instance.logOut()
        dismiss(animated: true, completion: nil)
        
    }
    
    
}
