//
//  User.swift
//  Siwa
//
//  Created by Mahdi on 5/7/19.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

public struct User: Codable {
    public var username: String
    public var password: String
    public var csrftoken: String
    public var id: String
    
    public init(username: String, password: String) {
        self.username = username
        self.password = password
        self.csrftoken = ""
        self.id = ""
    }
}


public struct LoggedInUser: Codable {
    var config: UserConfigItem?
}

public struct UserConfigItem: Codable {
    var csrf_token: String?
    var viewer: ConfigItemViewer?
    var viewerId: String?
}

public struct ConfigItemViewer: Codable {
    var biography: String?
    var external_url: String?
    var full_name: String?
    var has_phone_number: Bool?
    var has_profile_pic: Bool?
    var id: String?
    var is_joined_recently: Bool?
    var is_private: Bool?
    var profile_pic_url: String?
    var profile_pic_url_hd: String?
    var username: String?
    var badge_count: String?
}
