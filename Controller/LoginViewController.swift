//
//  LoginViewController.swift
//  maths-app
//
//  Created by P Malone on 20/02/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //set gradient
        view.gradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
    }

    //Login
    @IBAction func loginBtn(_ sender: UIButton) {
        
        //basic validation
        guard let email = emailText.text, emailText.text != "", let pass = passwordText.text, passwordText.text != "" else {
            self.showAlert(with: "Error", message: "Please enter an email and password")
            return
        }
        
        if (emailText.text?.isValidEmail() == false) {
            showAlert(with: "Email", message: "Check email address format")
            return
        }
        
        AuthorisationService.instance.logIn(email: email, password: pass) { (success) in
            
            //handle with callback
            if success {
                self.dismiss(animated: true, completion: nil)
            } else {
                //Do all UI work on main thread
                OperationQueue.main.addOperation {
                    self.showAlert(with: "Error", message: "Incorrect username or password")
                }
            }
        }
    
    }
    
    //dismiss VC
    @IBAction func cancelBtn(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    
    }
    
    //Handle error
    //TODO: Replace with text on screen?
    func showAlert(with title: String?, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    

}
