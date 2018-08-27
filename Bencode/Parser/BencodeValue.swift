//
//  BencodeValue.swift
//  Bencode
//
//  Created by Octree on 2018/8/24.
//  Copyright © 2018年 Octree. All rights reserved.
//

import Foundation


/// BencodeValue
///
/// - integer: 整数
/// - string: 字符串
/// - list: 列表
/// - dict: 字典序列
public indirect enum BencodeValue {
    
    case integer(Int)
    case string(String)
    case list([BencodeValue])
    case dict([String: BencodeValue])
}

//extension BencodeValue {
//
//    var data: Data {
//
//        switch self {
//        case let .integer(int):
//            return "i\(int)e".data(using: .utf8)!
//        case let .string(str):
//            let d = str.data(using: .utf8)!
//            return "\(d.count)".data(using: .utf8)! + d
//        case let .list(values):
//            return values.reduce("l".data(using: .utf8)!, {
//                $0 + $1.data
//            }) + "e".data(using: .utf8)!;
//        case let .dict(dict):
//            return d
//        }
//    }
//}
