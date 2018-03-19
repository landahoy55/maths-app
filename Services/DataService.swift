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
    func topicResultsLoaded()
}

//retreive data
class DataService {
    
    static let instance = DataService()
    
    weak var delegate: DataServiceDelegate?
    
    var downloadedTopics = [Topic]()
    var downloadedSubTopicResults = [RetreivedSubtopicResult]()
    var downloadedTopicResults = [RetreivedTopicResult]()
    var downloadedChallenge: DailyChallenge?
    var recentSubTopicResult: String?
    var accountDetails: Account?
    
    
    //register device token
    func registerDeviceToken(device token: String){
        
        let json = ["device":token]
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        guard let url = URL(string: POST_TOKEN) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: json, options: [])
            let task = session.dataTask(with: request, completionHandler: { (data, response, err) in
                if (err == nil) {
                    //success
                    //cast to access statuscode
                    let statusCode = (response as! HTTPURLResponse).statusCode
                    print("URL Session Task Succeeded: HTTP\(statusCode)")
                    
                    //check for statusCode - can this be altered? 409 is already registered - WILL TRIGGER LOGIN
                    if statusCode != 200 && statusCode != 409 {
                        return
                    } else {
                        //if status codes ok...
                        return
                    }
                    //Failed
                } else {
                    print("URL Session Task Failed: \(String(describing: err?.localizedDescription))")
                }
            })
            task.resume()
            session.finishTasksAndInvalidate()
        } catch let jsonErr {
            print(jsonErr)
        }
        
    }
    
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
    //URL is: GET_USER
    
    func getUserId(completion: @escaping callback) {

        // if let key = UserDefaults.standard.object(forKey: DEFAULTS_TOKEN) {
        //      print(key)
        // } else {
        //      print("Doesn't exist")
        // }
        
        //create session
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)

        guard let URL = URL(string: GET_USER) else { return }
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
                    completion(true)
                    
                    //call delegate method
                    //self.delegate?.userLoaded()
                    
                } catch let jsonErr {
                    print("Error serialzing json", jsonErr)
                    completion(false)
                }
                
            } else {
                print("task failed: \(String(describing: err?.localizedDescription))")
                completion(false)
            
            }
        }

        task.resume()
        session.finishTasksAndInvalidate()

    }
    
    //get user account - ideally to show the name on screen.
    func getUserAccount(userId: String, completion: @escaping callback){

        
        //create session
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        //create URL
        guard let URL = URL(string: "\(GET_USER_DETAILS)\(userId)") else { return }
        var request = URLRequest(url: URL)
        request.httpMethod = "GET"
        
        //get token - need to handle error here.
        let token = UserDefaults.standard.object(forKey: DEFAULTS_TOKEN) as! String
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = session.dataTask(with: request) { (data, response, err) in
            
            if (err == nil) {
                
                guard let data = data else { return }
                do {
                    
                    let dataAsString = String(data: data, encoding: .utf8)
                    print(dataAsString!)
                    
                    let account = try JSONDecoder().decode(Account.self, from: data)
                    print("****** ACCOUNT", account)
                    self.accountDetails = account
                    completion(true)
                    
                    //call delegate method
                    //self.delegate?.userLoaded()
                    
                } catch let jsonErr {
                    print("Error serialzing json", jsonErr)
                    completion(false)
                }
                
            } else {
                print("task failed: \(String(describing: err?.localizedDescription))")
                completion(false)
                
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
                    self.downloadedSubTopicResults = result
                    
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
                        print("***** THIS IS THE RESPONSE ******")
                        
                        // let dataAsString = String(data: data!, encoding: .utf8)
                        // print(dataAsString!)
                        
                        guard let data = data else { return completion(false) }
                        
                        do {
                            
                           let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, AnyObject>
                            
                            if let result = result?["createdId"] as? String {
                                print(result)
                                self.recentSubTopicResult = result
                            print("****** SERIALIZED NEW RESULT *****")
                            }
                           completion(true)
                        } catch let err {
                            print("Error serialising JSON", err)
                            completion(false)
                        }
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
    func updateSubTopicResult(newResult: SubtopicResult, idToUpdate: String, completion: @escaping callback) {
        
        //Prepare JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            
            let data = try encoder.encode(newResult)
            print(String(data: data, encoding: .utf8)!)
            
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
            
            guard let URL = URL(string: "\(PUT_SUBTOPIC_RESULT)\(idToUpdate)") else { return }
            print(URL)
            
            var request = URLRequest(url: URL)
            request.httpMethod = "PUT"
            
            //create task
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
    
    
    
    //Get topic results
    func getTopicResult(_ user: String, completion: @escaping callback) {
        //create session
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        guard let URL = URL(string: "\(GET_TOPIC_RESULT)\(user)") else { return }
        
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
                    
                    self.downloadedTopicResults = result
                    self.delegate?.topicResultsLoaded()
                    completion(true)
                    
                    //call delegate method
                    //self.delegate?.userLoaded()
                    
                } catch let jsonErr {
                    print("Error serialzing json", jsonErr)
                    completion(false)
                }
                
            } else {
                print("task failed: \(String(describing: err?.localizedDescription))")
                completion(false)
            }
        }
        
        task.resume()
        session.finishTasksAndInvalidate()
        
    }
    
    
    //Post topic results
    func postNewTopicResult(_ topicResult: TopicResult, completion: @escaping callback) {
        
        print("****** POST NEW TOPIC RESULT *********")
        
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
    
    
    //Update topic results - overriding array, not pushing
    func updateTopicResult(newResult: TopicResult, idToUpdate: String, completion: @escaping callback) {
        
        print("****** UPDATE TOPIC RESULT *********")
        
        //Prepare JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            
            let data = try encoder.encode(newResult)
            print(String(data: data, encoding: .utf8)!)
            
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
            
            guard let URL = URL(string: "\(PUT_TOPIC_RESULT)\(idToUpdate)") else { return }
            print(URL)
            
            var request = URLRequest(url: URL)
            request.httpMethod = "PUT"
            
            //create task
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
    
    
    //Daily Challenge
    //Get challenge
    func getDailyChallenge(completion: @escaping callback) {
        
        //create date string
        let date = Date() //now
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYMMdd"
        let dateAsString = dateFormatter.string(from: date)
        
        //create session
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        //URL
        guard let URL = URL(string: "\(GET_DAILY_CHALLENGE)\(dateAsString)") else { return }
        
        //Request
        var request = URLRequest(url: URL)
        request.httpMethod = "GET"
        
        //task
        let task = session.dataTask(with: request) { (data, response, err) in
            
            if (err == nil) {
                
                guard let data = data else { return }
                
                do {
                    let result = try JSONDecoder().decode(DailyChallenge.self, from: data)
                    print("*****DAILY CHALLENGE *****",result)
                    self.downloadedChallenge = result
                    completion(true)
                } catch let jsonErr {
                    print("Error serializing json", jsonErr)
                    completion(false)
                }
             } else {
                print("task failed: \(String(describing: err?.localizedDescription))")
                    completion(false)
                }
        }
        
        //to end task
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
}
