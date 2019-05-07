//
//  Result.swift
//  Siwa
//
//  Created by Mahdi on 5/7/19.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

protocol ResultProtocol {
    associatedtype type
    var isSucceeded: Bool { get }
    var info: ResultInfo { get }
}

public struct Result<Element>: ResultProtocol {
    public typealias type = Element
    public var isSucceeded: Bool
    public var value: type?
    public var info: ResultInfo
    
    public init(isSucceeded: Bool, info: ResultInfo, value: type?) {
        self.isSucceeded = isSucceeded
        self.info = info
        self.value = value
    }
}

public struct Return {
    public static func fail<T>(error: Error?, rawData: Data?, value: T?) -> Result<T> {
        let info = ResultInfo.init(error: error, rawData: rawData)
        let result = Result<T>.init(isSucceeded: false, info: info, value: value)
        return result
    }
    
    public static func success<T>(value: T?, rawData: Data?) -> Result<T> {
        let info = ResultInfo.init(error: nil, rawData: rawData)
        let result = Result<T>.init(isSucceeded: true, info: info, value: value)
        return result
    }
}

public struct ResultInfo {
    public var error: Error?
    public var rawData: Data?
    
    public init(error: Error?, rawData: Data?) {
        self.error = error
        self.rawData = rawData
    }
}

