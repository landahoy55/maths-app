//
//  TopicResult.swift
//  maths-app
//
//  Created by P Malone on 07/03/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import Foundation
//code
struct TopicResult: Codable {
    let achieved: String
    let topic: String
    let id: String
    let subTopicResults: [String]
}

