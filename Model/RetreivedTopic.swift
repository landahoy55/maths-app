//
//  RetreivedTopic.swift
//  maths-app
//
//  Created by P Malone on 07/03/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import Foundation

struct RetreivedTopic: Codable {
    let subTopics: [String]
    let _id: String
    let title: String
    let description: String
}
