//
//  VCTests.swift
//  maths-appTests
//
//  Created by P Malone on 18/05/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import XCTest
@testable import Maths_App

class VCTests: XCTestCase {
    
    let service = DataService.instance
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        print("Here")
        service.getAllTopics()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        service.getAllTopics()
    }
    
    
}
