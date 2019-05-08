//
//  URLs.swift
//  Siwa
//
//  Created by Mahdi on 4/20/19.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

struct URLs {
    private init() {

    }
    
    private static let instagram = "https://www.instagram.com"
    private static let loginPath = "/accounts/login/ajax/"
    private static let twoFactorPath = "/accounts/login/ajax/two_factor/"
    private static let twoFactorResendPath = "/accounts/send_two_factor_login_sms/"
    static func home() -> URL {
        return URL(string: instagram)!
    }
    
    static func login() -> URL {
        return URL(string: String(format: "%@%@", instagram, loginPath))!
    }
    
    static func checkpoint(url: String) -> URL {
        return URL(string: String(format: "%@%@", instagram, url))!
    }
    
    static func twoFactor() -> URL {
        return URL(string: String(format: "%@%@", instagram, twoFactorPath))!
    }
    
    static func resendTwoFactorCode() -> URL {
        return URL(string: String(format: "%@%@", instagram, twoFactorResendPath))!
    }
}
