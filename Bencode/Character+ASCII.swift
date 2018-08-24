//
//  Character+ASCII.swift
//  Bencode
//
//  Created by Octree on 2018/8/24.
//  Copyright © 2018年 Octree. All rights reserved.
//

import Foundation

extension Character {
    var asciiValue: Int {
        get {
            let s = String(self).unicodeScalars
            return Int(s[s.startIndex].value)
        }
    }
}
