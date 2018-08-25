//
//  _BDecoingStorage.swift
//  Bencode
//
//  Created by Octree on 2018/8/24.
//  Copyright © 2018年 Octree. All rights reserved.
//

import Foundation

struct _BDecodingStorage {
    
    private(set) var containers: [BencodeValue?] = []
    var count: Int { return containers.count }
    var topContainer: BencodeValue? {
        
        precondition(!self.containers.isEmpty, "Empty container stack.")
        return self.containers.last!
    }
    
    mutating func push(container: BencodeValue?) {
        
        containers.append(container)
    }
    
    mutating func pop() {
        
        precondition(!self.containers.isEmpty, "Empty container stack.")
        self.containers.removeLast()
    }
    
    init() { }
}
