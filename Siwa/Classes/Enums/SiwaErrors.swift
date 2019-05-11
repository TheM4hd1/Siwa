//
//  SiwaErrors.swift
//  Siwa
//
//  Created by Mahdi on 5/7/19.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

public enum SiwaErrors: Error {
    case authenticationRequired
    case usernameRequired
    case passwordRequired
    case checkpointMissing
    case twofactorMissing
}

extension SiwaErrors: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .authenticationRequired:
            return NSLocalizedString(
                "User authentication data music be specified.",
                comment: ""
            )
        case .usernameRequired:
            return NSLocalizedString(
                "username must be specified.",
                comment: ""
            )
        case .passwordRequired:
            return NSLocalizedString(
                "password must be specified.",
                comment: ""
            )
        case .checkpointMissing:
            return NSLocalizedString(
                "checkpoint url notfound",
                comment: ""
            )
        case .twofactorMissing:
            return NSLocalizedString(
                "twofactor data notfound",
                comment: ""
            )
        }
    }
}
