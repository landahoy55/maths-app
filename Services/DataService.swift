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
                //                //let dataAsString = String(data: data, encoding: .utf8)
                //                let dataAsString = String(data: data, encoding: .utf8)
                //                print(dataAsString!)
                
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
    
    //POST subtopic result
    
}
