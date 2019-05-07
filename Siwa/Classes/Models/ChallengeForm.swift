//
//  ChallengeForm.swift
//  Siwa
//
//  Created by Mahdi on 5/7/19.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

public struct ChallengeForm: Codable {
    public var entryData: EntryData?
}

public struct EntryData: Codable {
    public var Challenge: [EntryDataChallengeItem]?
}

public struct EntryDataChallengeItem: Codable {
    public var extraData: ChallengeItemExtraData?
}

public struct ChallengeItemExtraData: Codable {
    public var content: [ExtraDataContent]?
}

public struct ExtraDataContent: Codable {
    public var fields: [ContentField]?
}

public struct ContentField: Codable {
    public var values: [FieldsItem]?
}

public struct FieldsItem: Codable {
    public var label: String?
    public var selected: Bool?
    public var value: Int?
}
