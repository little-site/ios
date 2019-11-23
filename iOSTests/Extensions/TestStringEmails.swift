//
//  TestStringEmails.swift
//  iOSTests
//
//  Created by David Hariri on 2019-09-14.
//  Copyright © 2019 David Hariri. All rights reserved.
//

import Foundation
import XCTest
@testable import User
 
class TestsStringEmails: XCTestCase {
    func testFalseEmails() {
        // var emailsTrue: ["david@little.site", "d@dh.com"]
        var emailsFalse = ["david@", "d@f", "david@little", "david@", "@david.com"]
        
        var testUser = User()
        
        for email in emailsFalse {
            XCTAssertFalse(email.isValidEmail())
        }
    }
}
