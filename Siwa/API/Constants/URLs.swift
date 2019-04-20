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
    
    private static let instagram = "https://instagram.com"
    private static let login = "/accounts/login/ajax/"

    static func getLogin() -> URL {
        return URL(string: String(format: "%@%@", instagram, login))!
    }
}
