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



let zeroAscii = Character("0").asciiValue
let nineAscii = Character("9").asciiValue

/// 结束符号
let ending = character {  $0 == "e" }


/// 整数的开始标识
let integerHead = character {  $0 == "i" }

/// list 的开始标识
let listHead = character {  $0 == "l" }

/// Dictionary 的开始标识
let dictHead = character {  $0 == "d" }

/// 冒号
let colon = character {  $0 == ":" }

/// +
let positiveSign = character {  $0 == "+" }

/// -
let negitiveSign = character {  $0 == "-" }

/// 0-9
let digit = character { ch in
    let ascii = ch.asciiValue
    return ascii >= zeroAscii && ascii <= nineAscii
}


/// 1-9
let nzDigit = character { ch in
    let ascii = ch.asciiValue
    return ascii > zeroAscii && ascii <= nineAscii
}

/// NZ_DIGIT DIGIT*;
let multiInt =  { rt in Int(String([rt.0] + rt.1))! } <^> nzDigit.followed(by: digit.many1)

///  DIGIT
let singleInt = { x in Int(String(x))! } <^> digit
/// INT : DIGIT | NZ_DIGIT DIGIT*;
let int = multiInt <|> singleInt

private func integerTransformer(sign: Character?, num: Int) -> Int {
    guard let s = sign else {
        return num
    }
    
    if s == "+" {
        return num
    } else {
        return -num
    }
}

let signedInt = integerTransformer <^> (positiveSign <|> negitiveSign).optional.followed(by: int)

func takeNCharacters(n: Int) -> Parser<Substring, String> {
    
    return Parser {
        input in
        guard input.count >= n else {
            return .fail(ParserError.eof)
        }
        
        let index = input.index(input.startIndex, offsetBy: n)
        let string = String(input[..<index])
        return .done(input.dropFirst(n), string)
    }
}

//    string     : INT ':' stringData[$INT.int];
func string() -> Parser<Substring, BencodeValue> {
    
    return { x in BencodeValue.string(x) } <^> ((int <* colon) >>- takeNCharacters)
}

//    integer    : 'i' sign=('+'|'-')? INT 'e';
func integer() -> Parser<Substring, BencodeValue> {
    
    
    return { x in BencodeValue.integer(x) } <^> signedInt.between(open: integerHead, close: ending)
}

func dict() -> Parser<Substring, BencodeValue> {
    
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
func list() -> Parser<Substring, BencodeValue> {
    
    let parseLst = (listHead >>- {
        input in
        return value().many
        }) <* ending
    
    return { BencodeValue.list($0) } <^> parseLst
}

/// dictionary : 'd' (string value)* 'e';
func value() -> Parser<Substring, BencodeValue> {
    
    return list() <|> dict() <|> integer() <|> string()
}

/// BencodeParser
public let BencodeParser = value()
