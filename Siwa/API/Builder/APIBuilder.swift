//
//  APIBuilder.swift
//  Siwa
//
//  Created by Mahdi on 4/20/19.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

public protocol APIBuilderProtocol {
    func setUser(user: User) -> APIBuilderProtocol
    func setURLSession(urlSession: URLSession) -> APIBuilderProtocol
    func setRequestDelay(delay: Delay) -> APIBuilderProtocol
    func build() throws -> APIHandler
}

public class APIBuilder: APIBuilderProtocol {
    
    private var _user: User?
    private var _delay: Delay?
    private var _urlSession: URLSession?
    
    public func setUser(user: User) -> APIBuilderProtocol {
        _user = user
        return self
    }
    
    public func setURLSession(urlSession: URLSession) -> APIBuilderProtocol {
        _urlSession = urlSession
        return self
    }
    
    public func setRequestDelay(delay: Delay) -> APIBuilderProtocol {
        _delay = delay
        return self
    }
    
    public func build() throws -> APIHandler {
        guard let user = _user else { throw SiwaErrors.authenticationRequired }
        
        if _urlSession == nil {
            _urlSession = URLSession(configuration: .default)
        }
        
        if _delay == nil {
            _delay = .default
        }
        
        return try APIHandler(user: user, urlSession: _urlSession!, delay: _delay!)
    }
}
