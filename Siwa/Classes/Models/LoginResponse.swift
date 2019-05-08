//
//  LoginResponse.swift
//  Siwa
//
//  Created by Mahdi on 5/7/19.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

// this model holds data which returned from server,
// when login function called.
// detect results if data contains any of following items:
// 1- checkpoint_required
// 2- two_factor_required
// 3- authenticated
public struct LoginResponse: Codable {
    public var message: String?
    public var checkpointUrl: String?
    public var lock: Bool?
    public var user: Bool?
    public var authenticated: Bool?
    public var userId: String?
    public var fr: String?
    public var twoFactorRequired: Bool?
    public var twoFactorInfo: TwoFactorInfo?
    public var status: String?
}

public struct TwoFactor: Codable {
    public var message: String?
    public var twoFactorRequired: Bool?
}

public struct TwoFactorInfo: Codable {
    public var username: String?
    public var smsTwoFactorOn: Bool?
    public var totpTwoFactorOn: Bool?
    public var obfuscatedPhoneNumber: String?
    public var twoFactorIdentifier: String?
    public var phoneVerificationSettings: PhoneVerificationSettings?
}

public struct PhoneVerificationSettings: Codable {
    public var maxSmsCount: Int?
    public var resendSmsDelaySec: Int?
    public var robocallAfterMaxSms: Bool?
    public var robocallCountDownTimeSec: Int?
}
