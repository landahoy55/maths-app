//
//  DataService.swift
//  maths-app
//
//  Created by P Malone on 27/02/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import Foundation


//protocol to trigger update
protocol DataServiceDelegate: class {
    func topicsLoaded()
}

//retreive data
class DataService {
    
    static let instance = DataService()
    
    weak var delegate: DataServiceDelegate?
    var downloadedTopics = [Topic]()
    
    
    
    
    func getAllTopics() {
        
        //create session
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        //create request
        guard let URL = URL(string: GET_TOPICS) else { return }
        var request = URLRequest(url: URL)
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request) { (data, response, err) in
            
            if (err == nil) {
                //perform task
                guard let data = data else { return }
                // let dataAsString = String(data: data, encoding: .utf8)
                // let dataAsString = String(data: data, encoding: .utf8)
                // print(dataAsString!)
                
                do {
                    let topics = try JSONDecoder().decode([Topic].self, from: data)
                    self.downloadedTopics = topics
                    self.delegate?.topicsLoaded()
                } catch let jsonErr {
                    print("Error serialzing json", jsonErr)
                }
                
            } else {
                print("task failed: \(String(describing: err?.localizedDescription))")
            }
            
        }
        
        task.resume()
        session.finishTasksAndInvalidate()
        
    }
    

    
    //Get user information - Document ID for user and save to user defaults
    //URL is: GET_USER_DETAILS
    
    func getUserInformation() {

        // if let key = UserDefaults.standard.object(forKey: DEFAULTS_TOKEN) {
        //      print(key)
        // } else {
        //      print("Doesn't exist")
        // }
        
        //create session
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)

        guard let URL = URL(string: GET_USER_DETAILS) else { return }
        var request = URLRequest(url: URL)
        request.httpMethod = "GET"

        //get token - need to handle error here.
        let token = UserDefaults.standard.object(forKey: DEFAULTS_TOKEN) as! String
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = session.dataTask(with: request) { (data, response, err) in

            if (err == nil) {

                guard let data = data else { return }
                do {
                    
                    let user = try JSONDecoder().decode(User.self, from: data)
                    print(user)
                    // set in userdefaults
                    UserDefaults.standard.set(user.id, forKey:DEFAULTS_USERID )
                    
                    //call delegate method
                    //self.delegate?.userLoaded()
                    
                } catch let jsonErr {
                    print("Error serialzing json", jsonErr)
                }
                
            } else {
                print("task failed: \(String(describing: err?.localizedDescription))")
            
            }
        }

        task.resume()
        session.finishTasksAndInvalidate()

    }
    
    //Subtopic Results
    //Get subtopic results - can perform update once we get back. May need to create new, or add optional values to model
    func getSubTopicResults(_ user: String, completion: @escaping callback) {
        
        //create session
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        guard let URL = URL(string: "\(GET_SUBTOPIC_RESULT)\(user)") else { return }
        
        print(URL)
        
        var request = URLRequest(url: URL)
        request.httpMethod = "GET"
        
        //get token - need to handle error here.
        let token = UserDefaults.standard.object(forKey: DEFAULTS_TOKEN) as! String
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = session.dataTask(with: request) { (data, response, err) in
            
            if (err == nil) {
                
                guard let data = data else { return }
                do {
                    
                //  let dataAsString = String(data: data, encoding: .utf8)
                //
                //  print(dataAsString!)
                    
                    let result = try JSONDecoder().decode([RetreivedSubtopicResult].self, from: data)
                    print(result)
                    
                    //TODO:WORK WITH RESULT
                    
                    //call delegate method
                    //self.delegate?.userLoaded()
                    
                } catch let jsonErr {
                    print("Error serialzing json", jsonErr)
                }
                
            } else {
                print("task failed: \(String(describing: err?.localizedDescription))")
                
            }
        }
        
        task.resume()
        session.finishTasksAndInvalidate()
        
    }
    
    
    //Post subtopic results
    //    Headers - Authorization Bearer \(token)
    //    Content-Type - application/json
    //    {
    //    "achieved":"true",
    //    "score":"5",
    //    "subtopic":"5a954a498956bf2b2d1a5ef0",
    //    "id": "5a8af7bfe545301f55a60e60"
    //    }
    
    //includes completion handler to help with success/fail
    func postNewSubtopicResult(_ subtopicResult: SubtopicResult, completion: @escaping callback) {
        
        //prepare JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let data = try encoder.encode(subtopicResult)
            print(String(data: data, encoding: .utf8)!)
            
            //post
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
            
            //check url
            guard let URL = URL(string: POST_SUBTOPIC_RESULT) else { return }
            
            //create request
            var request = URLRequest(url: URL)
            request.httpMethod = "POST"
            
            //get token
            let token = UserDefaults.standard.object(forKey: DEFAULTS_TOKEN) as! String
            
            //set headers
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            //set body
            request.httpBody = data
            
            let task = session.dataTask(with: request, completionHandler: { (data, response, err) in
                if (err == nil) {
                    //success
                    //check for status 200 - it not auth was not successful
                    //if it is - then good.
                    let statusCode = (response as! HTTPURLResponse).statusCode
                    print("POST Succeeded. HTTP \(statusCode)")
                    
                    if statusCode != 200 {
                        print("NOT 200")
                        completion(false)
                    } else {
                        //can reload from here by call get and delegate.
                        completion(true)
                    }
                } else {
                    print("URL SESSION TASK FAILED: \(String(describing: err?.localizedDescription))")
                    completion(false)
                }
            })
            
            task.resume()
            session.finishTasksAndInvalidate()
            
        } catch let jsonErr {
            print("Error serialzing json", jsonErr)
            completion(false)
        }
       
    }
    
    //Update subtopic results - may need completion handler.
    
    
    
    
    //Get topic results
    func getTopicResult(_ user: String, completion: @escaping callback) {
        //create session
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        guard let URL = URL(string: "\(GET_TOPIC_RESULT)\(user)") else { return }
        
        print(URL)
        
        var request = URLRequest(url: URL)
        request.httpMethod = "GET"
        
        //get token - need to handle error here.
        let token = UserDefaults.standard.object(forKey: DEFAULTS_TOKEN) as! String
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = session.dataTask(with: request) { (data, response, err) in
            
            if (err == nil) {
                
                guard let data = data else { return }
                do {
                    
                    //  let dataAsString = String(data: data, encoding: .utf8)
                    //
                    //  print(dataAsString!)
                    
                    let result = try JSONDecoder().decode([RetreivedTopicResult].self, from: data)
                    print(result)
                    
                    //TODO:WORK WITH RESULT
                    
                    //call delegate method
                    //self.delegate?.userLoaded()
                    
                } catch let jsonErr {
                    print("Error serialzing json", jsonErr)
                }
                
            } else {
                print("task failed: \(String(describing: err?.localizedDescription))")
                
            }
        }
        
        task.resume()
        session.finishTasksAndInvalidate()
        
    }
    
    
    //Post topic results
    func postNewTopicResult(_ topicResult: TopicResult, completion: @escaping callback) {
        
        //prepare JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let data = try encoder.encode(topicResult)
        
            print(String(data: data, encoding: .utf8)!)
            print(data)
            
            //post
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
            
            //check url
            guard let URL = URL(string: POST_TOPIC_RESULT) else { return }
            
            //create request
            var request = URLRequest(url: URL)
            request.httpMethod = "POST"
            
            //get token
            let token = UserDefaults.standard.object(forKey: DEFAULTS_TOKEN) as! String
            
            //set headers
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            //set body
            request.httpBody = data
            
            
            let task = session.dataTask(with: request, completionHandler: { (data, response, err) in
                if (err == nil) {
                    //success
                    //check for status 200 - it not auth was not successful
                    //if it is - then good.
                    let statusCode = (response as! HTTPURLResponse).statusCode
                    print("POST Succeeded. HTTP \(statusCode)")

                    if statusCode != 200 {
                        print("NOT 200")
                        completion(false)
                    } else {
                        //can reload from here by call get and delegate.
                        completion(true)
                    }
                } else {
                    print("URL SESSION TASK FAILED: \(String(describing: err?.localizedDescription))")
                    completion(false)
                }
            })
            
            task.resume()
            session.finishTasksAndInvalidate()
            
        } catch let jsonErr {
            print("Error serialzing json", jsonErr)
            completion(false)
        }
        
    }
    //Update topic results
}
