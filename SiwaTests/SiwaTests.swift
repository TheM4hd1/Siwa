//
//  SiwaTests.swift
//  SiwaTests
//
//  Created by Mahdi on 4/20/19.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import XCTest
@testable import Siwa

class SiwaTests: XCTestCase {

    func testLogin() {
        let exp = expectation(description: "login function failed in test")
        let user = User.init(username: "swiftyinsta", password: "xxxxxx")
        let urlSession = URLSession(configuration: .default)
        
        do {
            let handler = try APIBuilder()
            .setURLSession(urlSession: urlSession)
            .setRequestDelay(delay: .zero)
            .setUser(user: user)
            .build()
            
            handler.login { (result) in
                print(result)
                exp.fulfill()
            }
        } catch {
            print(error.localizedDescription)
        }
        
        waitForExpectations(timeout: 30, handler: nil)
    }
}
