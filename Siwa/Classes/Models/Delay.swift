//
//  Delay.swift
//  Siwa
//
//  Created by Mahdi on 5/7/19.
//  Copyright © 2019 Mahdi. All rights reserved.
//

import Foundation

public struct Delay {
    public var min: Double = 0
    public var max: Double = 0
    public static let `default` = Delay(min: 1, max: 3)
    public static let zero = Delay(min: 0, max: 0)
    
    public init(min: Double, max: Double) {
        self.max = max
        self.min = min
    }
    
    func random() -> Double {
        return Double.random(in: min...max)
    }
}
