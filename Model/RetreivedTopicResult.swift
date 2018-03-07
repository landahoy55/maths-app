//
//  RetreivedTopicResult.swift
//  maths-app
//
//  Created by P Malone on 07/03/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import Foundation

struct RetreivedTopicResult: Codable {
    let _id: String
    let achieved: Bool
    let topic: RetreivedTopic
    let subTopicResults: [RetreivedSubtopicResult]
}
