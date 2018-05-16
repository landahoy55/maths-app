//
//  String + Extensions.swift
//  maths-app
//
//  Created by P Malone on 14/05/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import Foundation

extension String {
    
    //Check if email is correct.
    
    func isValidEmail() -> Bool {
        
        //http://emailregex.com
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        
        //https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/Predicates/Articles/pSyntax.html
        //%@ is a var arg substitution for an object value—often a string, number, or date
        //SELF MATCHES
        // The left hand expression equals the right hand expression using a regex-style comparison according to ICU v3 (for more details see the ICU User Guide for Regular Expressions).
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        
        return emailPredicate.evaluate(with: self)
    }
}
