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

private func encodedData(for string: String) -> Data {
    
    let d = string.data(using: .utf8)!
    return "\(d.count)".data(using: .utf8)! + d
}

private let kBencodeDictStart = Data(bytes: [Tokens.d])
private let kBencodeListStart = Data(bytes: [Tokens.l])
private let kBencodeEnd = Data(bytes: [Tokens.e])

extension BencodeValue {

    var data: Data {

        switch self {
        case let .integer(int):
            return "i\(int)e".data(using: .utf8)!
        case let .string(str):
            return encodedData(for: str)
        case let .list(values):
            return values.reduce(kBencodeListStart, {
                $0 + $1.data
            }) + kBencodeEnd
        case let .dict(dict):
            
            let kvData = dict.reduce(kBencodeDictStart) { return $0 + encodedData(for: $1.key) + $1.1.data }
            return kvData + kBencodeEnd
        }
    }
}
