//
//  Question.swift
//  maths-app
//
//  Created by P Malone on 27/02/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import Foundation
//decode
struct Question: Codable {
    let question: String
    let correctAnswer: String
    let _id: String
    let answers: [Answer]
    let imageurl: String?
    
    //imageURL may be optional...
    //    https://developer.apple.com/documentation/swift/keyeddecodingcontainer/2893445-decodeifpresent
    //decodeIfPresent key
    //Requires initialiser and enum stating keys.
}
