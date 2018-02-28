//
//  Constants.swift
//  maths-app
//
//  Created by P Malone on 20/02/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import Foundation
import UIKit

//callbacks type alias - short cuts
typealias callback = (_ success: Bool) -> ()

//Base URLs
let BASE_API_URL = "https://morning-journey-26383.herokuapp.com/v1"

//Add other URLs - get questions and results

//Register URL
let POST_REGISTER = "\(BASE_API_URL)/account/register"
let POST_LOGIN = "\(BASE_API_URL)/account/login"
let GET_USER_DETAILS = "\(BASE_API_URL)/account/me"
let POST_LOGOUT = "\(BASE_API_URL)/account/logout"
let GET_TOPICS = "\(BASE_API_URL)/topic"

//User Defaults Set Up

//Bools
let DEFAULTS_REGISTERED = "isRegistered"
let DEFAULTS_AUTHENTICATED = "isAuthenticated"

//Auth Email and Token - should this be in Keychain?
let DEFAULTS_EMAIL = "email"
let DEFAULTS_TOKEN = "authToken"

//colours
let primaryColor = UIColor(red: 210/255, green: 109/255, blue: 180/255, alpha: 1)
let secondaryColor = UIColor(red: 52/255, green: 148/255, blue: 230/255, alpha: 1)

//timer colours - http://uicolor.xyz/#/hex-to-ui
let timerGreen = UIColor(red:0.15, green:0.65, blue:0.36, alpha:1.0)
let timerOrange = UIColor(red:1.00, green:0.64, blue:0.00, alpha:1.0)
let timerRed = UIColor(red:0.86, green:0.19, blue:0.14, alpha:1.0)
