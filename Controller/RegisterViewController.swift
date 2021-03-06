//
//  RegisterViewController.swift
//  maths-app
//
//  Created by P Malone on 20/02/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Part of keyboard handling
        // self.nameText.delegate = self
        // self.passwordText.delegate = self
        // self.emailText.delegate = self
    
        //set gradient
        view.gradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
    }

    
    @IBAction func registerBtn(_ sender: UIButton) {
        
        //basic validation
        guard let name = nameText.text, nameText.text != "", let email = emailText.text, emailText.text != "", let pass = passwordText.text, passwordText.text != "" else {
            self.showAlert(with: "Error", message: "Please enter name, email and password")
            return
        }
        
        
        //check for valid email using extension
        if (emailText.text?.isValidEmail() == false) {
            
            showAlert(with: "Email", message: "Is your email address formatted correctly?")
            return
        }
        
        
        //check password is 8 digits
        if (passwordText.text?.count)! < 4 {
         showAlert(with: "Password", message: "Your password needs to be 4 characters")
            
            passwordText.text = ""
            
            return
        }
        
        
        //Call register method - then login user
        AuthorisationService.instance.registerUser(email: email, password: pass, name: name) { (success) in
                //login
                if success {
                    AuthorisationService.instance.logIn(email: email, password: pass, completion: { (success) in
                        if success {
                            self.dismiss(animated: true, completion: nil)
                        } else {
                         //get on main thread to handle UI
                            OperationQueue.main.addOperation {
                                self.showAlert(with: "Oops", message: "Already Registered")
                                
                                //clear form
                                self.nameText.text = ""
                                self.emailText.text = ""
                                self.passwordText.text = ""
                                
                            }
                        }
                    })
                } else {
                    OperationQueue.main.addOperation {
                        self.showAlert(with: "Error", message: "Uknown error creating account... oops")
                }
            }
        }
    }
    
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

//handling keyboard
extension RegisterViewController {
    //hide keyboard when touching outside
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
