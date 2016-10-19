//
//  GraphModel.swift
//  GraphingCalculator
//
//  Created by Swapnil Harsule on 10/16/16.
//  Copyright © 2016 Swapnil Harsule. All rights reserved.
//

import Foundation

struct GraphInfo {
    
    typealias funcForResult = (Double, AnyObject) -> Double
    
    var xyEquation: AnyObject?
    var getValFunc: funcForResult?
}
