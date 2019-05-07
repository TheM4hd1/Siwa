//
//  VerificationMethods.swift
//  Siwa
//
//  Created by Mahdi on 5/7/19.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

public enum VerificationMethod: String {
    case email = "1"
    case sms = "0"
}

public enum VerificationResponse {
    case codeSent
    case failed
    case unknown
}

public enum ChallengeVerificationResponse {
    case accepted
    case incorrect
    case loginFailed
    case noRedirect
    case unknown
}
