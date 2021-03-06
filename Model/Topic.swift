//
//  Topic.swift
//  maths-app
//
//  Created by P Malone on 27/02/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import Foundation
//Decode
struct Topic: Codable {
    let title: String
    let description: String
    let subTopics: [SubTopic]
    let _id: String
}
