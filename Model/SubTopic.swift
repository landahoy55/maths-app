//
//  SubTopic.swift
//  maths-app
//
//  Created by P Malone on 27/02/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import Foundation

struct SubTopic: Decodable {
    let title: String
    let description: String
    let stage: Int
    let questions: [Question]
    let _id: String
}
