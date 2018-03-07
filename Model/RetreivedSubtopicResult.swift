//
//  RetreivedSubtopicResult.swift
//  maths-app
//
//  Created by P Malone on 07/03/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import Foundation
//code
struct RetreivedSubtopicResult: Codable {
    let _id: String
    let score: Int
    let achieved: Bool
    let subtopic: SubTopic
}
