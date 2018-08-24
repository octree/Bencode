//
//  BencodeValue.swift
//  Bencode
//
//  Created by Octree on 2018/8/24.
//  Copyright © 2018年 Octree. All rights reserved.
//

import Foundation

public indirect enum BencodeValue {
    
    case integer(Int)
    case string(String)
    case list([BencodeValue])
    case dict([String: BencodeValue])
}
