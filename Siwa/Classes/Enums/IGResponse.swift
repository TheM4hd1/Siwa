//
//  IGResponse.swift
//  Siwa
//
//  Created by Mahdi on 5/7/19.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

/// Instagram responses
public enum IGResponse {
    case success
    case loginRequired
    case checkpointRequired
    case twoFactorRequired
    case checkpointLoop
    case alreadyLoggedIn
    case actionBlocked
    case inccorrectPassword
    case invalidUsername
    case dataMissing
    case unknwon
}
