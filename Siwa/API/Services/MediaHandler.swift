//
//  MediaHandler.swift
//  Siwa
//
//  Created by Mahdi on 4/20/19.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

public protocol MediaHandlerProtocol {
    func like()
}

class MediaHandler: MediaHandlerProtocol {
    static let shared = MediaHandler()
    private init() {
        
    }
    
    func like() {
        
    }
}
