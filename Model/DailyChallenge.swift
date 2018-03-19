//
//  DailyChallenge.swift
//  maths-app
//
//  Created by P Malone on 19/03/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import Foundation

struct DailyChallenge: Codable {
    let type: String
    let description: String
    let playdate: Int
    let questions: [Question]
}

