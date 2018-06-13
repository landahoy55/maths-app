//
//  AuthorisationService.swift
//  maths-app
//
//  Created by P Malone on 20/02/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import Foundation

class AuthorisationService {
    
    //singleton instance to get up and running
    static let instance = AuthorisationService()
    
    //Computed Getters and Setters for UserDefaults to access or set
    var isRegistered: Bool? {
        get {
            return UserDefaults.standard.bool(forKey: DEFAULTS_REGISTERED) == true
        } set {
            UserDefaults.standard.set(newValue, forKey: DEFAULTS_REGISTERED)
        }
    }
    
    //computed property to set authentication
    var isAuthenticated: Bool? {
        get {
            return UserDefaults.standard.bool(forKey: DEFAULTS_AUTHENTICATED) == true
        } set {
            UserDefaults.standard.set(newValue, forKey: DEFAULTS_AUTHENTICATED)
        }
    }
    
    //email
    var email: String? {
        get {
            return UserDefaults.value(forKey: DEFAULTS_EMAIL) as? String
        } set {
            UserDefaults.standard.set(newValue, forKey: DEFAULTS_EMAIL)
        }
    }
    
    
    var authToken: String? {
        get {
            return UserDefaults.value(forKey: DEFAULTS_TOKEN) as? String
        } set {
            UserDefaults.standard.set(newValue, forKey: DEFAULTS_TOKEN)
        }
    }

    
    //All URL Sessions need
        // - what is being passed in - JSON
        // - configuration - default is fine
        // - URL
        // - Headers
        // - Request - throws error
        // - Sessions run async so handle correctly
    
    //Register User
        //set up user
        //set up url session
        //process request
    func registerUser(email username: String, password: String, name: String, completion: @escaping callback) {
        
        //json response - should this be a model? Refactor?
        let json = ["email": username, "name": name, "password": password]
        
        let sessionConfig = URLSessionConfiguration.default
        
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        //use guard to exit it not correct - set userdefaults and asycn callback
        guard let URL = URL(string: POST_REGISTER) else {
            isRegistered = false
            completion(false)
            return
        }
        
        //Set up request headers
        var request = URLRequest(url: URL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        //carry out request
        do {
            
            request.httpBody = try JSONSerialization.data(withJSONObject: json, options: [])
           
            let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
                if (error == nil) {
                    //success
                    //cast to access statuscode
                    let statusCode = (response as! HTTPURLResponse).statusCode
                    print("URL Session Task Succeeded: HTTP\(statusCode)")
                    
                    //check for statusCode - can this be altered? 409 is already registered - WILL TRIGGER LOGIN
                    if statusCode != 200 && statusCode != 409 {
                        self.isRegistered = false
                        completion(false)
                        return
                    } else {
                        //if status codes ok...
                        self.isRegistered = true
                        completion(true)
                    }
                    
                //Failed
                } else {
                    print("URL Session Task Failed: \(String(describing: error?.localizedDescription))")
                    completion(false)
                }
            })
            
            //resume must be called for async to work
            task.resume()
            session.finishTasksAndInvalidate()
            
        } catch let err {
            
            self.isRegistered = false
            completion(false)
            print(err)
        
        }
        
    }
    
    
    
    //Login
        //All URL Sessions need
        // - what is being passed in - JSON
        // - configuration - default is fine
        // - URL
        // - Headers
        // - Request - throws error
        // - Sessions run async so handle correctly
    func logIn(email username: String, password: String, completion: @escaping callback) {
        
        //JSON to send. email and password.
        let json = ["email": username, "password": password]
        
        let sessionConfig = URLSessionConfiguration.default
    
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        //exit if issue with URL
        guard let URL = URL(string: POST_LOGIN) else {
            isAuthenticated = false
            completion(false)
            return
        }
        
        var request = URLRequest(url: URL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: json, options: [])
            
            let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
                //success
                if (error == nil) {
                    //case response to URL response to access status
                    let statusCode = (response as! HTTPURLResponse).statusCode
                    print("URL Session Task Succeeded");
                    
                    if statusCode != 200 {
                        completion(false)
                        return
                    } else {
                        //check for data to be returned
                        guard let data = data else {
                            completion(false)
                            return
                        }
                        //Get token...
                            do {
                                let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, AnyObject>
                                if result != nil {
                                    print(result!)
                                    if let email = result?["user"] as? String {
                                        //success!
                                        if let token = result?["token"] as? String {
                                            self.email = email
                                            print(email)
                                            self.authToken = token
                                            self.isRegistered = true
                                            self.isAuthenticated = true
                                            completion(true)
                                        } else {
                                            completion(false)
                                        }
                                    } else {
                                        completion(false)
                                    }
                                } else {
                                    completion(false)
                                }
                        } catch let err {
                            completion(false)
                            print(err)
                        }
                    }
                    
                //fail
                } else {
                    print("URL Session Task Failec: \(error!.localizedDescription)")
                    completion(false)
                    return
                }
            })
            //removed error
            task.resume()
            session.finishTasksAndInvalidate()
        } catch let err {
            print(err)
            completion(false)
        }
    }

    //logout
    func logOut() {
        isRegistered = false
        isAuthenticated = false
    }
    
}



















