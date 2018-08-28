//
//  Parser.swift
//  Bencode
//
//  Created by Octree on 2018/8/24.
//  Copyright © 2018年 Octree. All rights reserved.
//

import Foundation
import ParserCombinator
import FP

struct Tokens {
    static let i: UInt8 = 0x69
    static let l: UInt8 = 0x6c
    static let d: UInt8 = 0x64
    static let e: UInt8 = 0x65
    static let zero: UInt8 = 0x30
    static let nine: UInt8 = 0x39
    static let colon: UInt8 = 0x3a
    static let plus: UInt8 = 0x2b
    static let minus: UInt8 = 0x2d
}

public typealias Byte = UInt8

func byte(matching condition: @escaping (Byte) -> Bool) -> Parser<ArraySlice<Byte>, Byte> {
    
    return Parser {
        input in
        guard let first = input.first else {
            return .fail(ParserError.eof)
        }
        
        guard condition(first) else {
            return .fail(ParserError.notMatch)
        }
        
        return .done(input.dropFirst(), first)
    }
}

/// 结束符号
let ending = byte { $0 == Tokens.e }


/// 整数的开始标识
let integerHead =  byte { $0 == Tokens.i }

/// list 的开始标识
let listHead = byte { $0 == Tokens.l }

/// Dictionary 的开始标识
let dictHead = byte { $0 == Tokens.d }

/// 冒号
let colon = byte { $0 == Tokens.colon }

/// +
let positiveSign = byte { $0 == Tokens.plus }

/// -
let negitiveSign = byte { $0 == Tokens.minus }

/// 0-9
let digit = byte { $0 >= Tokens.zero && $0 <= Tokens.nine }


/// 1-9
let nzDigit = byte { $0 > Tokens.zero && $0 <= Tokens.nine }

/// NZ_DIGIT DIGIT*;

let multiInt =  { rt in ([rt.0] + rt.1).int! } <^> nzDigit.followed(by: digit.many1)

///  DIGIT
let singleInt = { x in [x].int! } <^> digit
/// INT : DIGIT | NZ_DIGIT DIGIT*;
let int = multiInt <|> singleInt

private func integerTransformer(sign: Byte?, num: Int) -> Int {
    guard let s = sign else {
        return num
    }
    if s == Tokens.plus {
        return num
    } else {
        return -num
    }
}

let signedInt = integerTransformer <^> (positiveSign <|> negitiveSign).optional.followed(by: int)

func takeNBytes(n: Int) -> Parser<ArraySlice<Byte>, [Byte]> {
    
    return Parser {
        input in
        
        guard input.count >= n else {
            return .fail(ParserError.eof)
        }
        
        let start = input.startIndex
        let end = input.index(input.startIndex, offsetBy: n)
        let rt = input[start ..< end]
        return .done(input.dropFirst(n), Array(rt))
    }
}

func takeString(withByteLength length: Int) -> Parser<ArraySlice<Byte>, String> {
    
    return takeNBytes(n: length).then {
        bytes in
        let text = bytes.string
        return Parser {
            input in
            if let txt = text {
                return .done(input, txt)
            } else {
                return .fail(ParserError.notMatch)
            }
        }
    }
}

//    string     : INT ':' stringData[$INT.int];
func string() -> Parser<ArraySlice<Byte>, BencodeValue> {
    
    return { x in BencodeValue.string(x) } <^> ((int <* colon) >>- takeString)
}

//    integer    : 'i' sign=('+'|'-')? INT 'e';
func integer() -> Parser<ArraySlice<Byte>, BencodeValue> {
    
    
    return { x in BencodeValue.integer(x) } <^> signedInt.between(open: integerHead, close: ending)
}

func dict() -> Parser<ArraySlice<Byte>, BencodeValue> {
    
    let parseKV = (dictHead >>- {
        input in
        return string().followed(by: value()).many
        }) <* ending
    
    return {
        (lst: [(BencodeValue, BencodeValue)]) in
        
        var dict = [String: BencodeValue]()
        for elt in lst {
            if case let .string(key) = elt.0 {
                dict[key] = elt.1
            }
        }
        return BencodeValue.dict(dict)
        } <^> parseKV
}

/// list       : 'l' value* 'e';
func list() -> Parser<ArraySlice<Byte>, BencodeValue> {
    
    let parseLst = (listHead >>- {
        input in
        return value().many
        }) <* ending
    
    return { BencodeValue.list($0) } <^> parseLst
}

/// dictionary : 'd' (string value)* 'e';
func value() -> Parser<ArraySlice<Byte>, BencodeValue> {
    
    return list() <|> dict() <|> integer() <|> string()
}

/// BencodeParser
public let BencodeParser = value()
