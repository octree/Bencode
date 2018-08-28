//
//  _BEncodingStorage.swift
//  Bencode
//
//  Created by Octree on 2018/8/26.
//  Copyright © 2018年 Octree. All rights reserved.
//

import Foundation

struct _BEncodingStorage {
    
    private(set) var containers: [Any] = []
    init() { }
    var count: Int { return containers.count }
    
    mutating func pushKeyedContainer() -> NSMutableDictionary {
        
        let dictionary = NSMutableDictionary()
        self.containers.append(dictionary)
        return dictionary
    }
    
    mutating func pushUnkeyedContainer() -> NSMutableArray {
        
        let array = NSMutableArray()
        self.containers.append(array)
        return array
    }
    
    mutating func push(container: Any) {
        
        self.containers.append(container)
    }
    
    mutating func pop() -> Any {
        
        precondition(!self.containers.isEmpty, "Empty container stack.")
        return self.containers.popLast()!
    }
}
