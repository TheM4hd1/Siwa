//
//  APIBuilder.swift
//  Siwa
//
//  Created by Mahdi on 4/20/19.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

public protocol APIBuilderProtocol {
    func setUser() -> APIBuilderProtocol
    func setURLSession() -> APIBuilderProtocol
    func setRequestDelay() -> APIBuilderProtocol
    func build() throws -> APIHandlerProtocol
}

public class APIBuilder: APIBuilderProtocol {
    public func setUser() -> APIBuilderProtocol {
        return self
    }
    
    public func setURLSession() -> APIBuilderProtocol {
        return self
    }
    
    public func setRequestDelay() -> APIBuilderProtocol {
        return self
    }
    
    public func build() throws -> APIHandlerProtocol {
        return APIHandler()
    }
}
