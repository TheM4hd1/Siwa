//
//  UserHandler.swift
//  Siwa
//
//  Created by Mahdi on 4/20/19.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

public protocol UserHandlerProtocol {
    func login()
    func logout()
}

class UserHandler: UserHandlerProtocol {
    static let shared = UserHandler()
    private init() {
        
    }
    
    func login() {
        
    }
    
    func logout() {
        
    }
}
