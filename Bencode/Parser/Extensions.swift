//
//  Extensions.swift
//  Bencode
//
//  Created by Octree on 2018/8/24.
//  Copyright © 2018年 Octree. All rights reserved.
//

import Foundation


internal extension Sequence where Iterator.Element == Byte {
    
    var int: Int? {
        guard let string = String(bytes: self, encoding: .ascii)
            else { return nil }
        return Int(string)
    }
    
    var string: String? {
        return String(bytes: self, encoding: .ascii)
    }
}
