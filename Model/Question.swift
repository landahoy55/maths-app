//
//  Question.swift
//  maths-app
//
//  Created by P Malone on 27/02/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import Foundation

struct Question: Decodable {
    let question: String
    let correctAnswer: String
    let _id: String
    let answers: [Answer]
}
