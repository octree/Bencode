//
//  ViewController.swift
//  Demo
//
//  Created by Octree on 2018/8/23.
//  Copyright © 2018年 Octree. All rights reserved.
//

import UIKit
import Bencode

struct Fuck: Decodable {
    
    var name: String
    var age: Int?
    var you: You
    var ints: [Int]
}

struct You: Decodable {

    var name: String
    enum CodingKeys: String, CodingKey {
        case name = "name x"
    }
}

func testingBytes(fromString string: String) -> ArraySlice<UInt8> {
    
    return [UInt8](string.data(using: .utf8)!)[...]
}

func test() {
    
    print(BencodeParser.parse(testingBytes(fromString: "i1234e")))
    print(BencodeParser.parse(testingBytes(fromString: "14:helloworld helloworld")))
    print(BencodeParser.parse(testingBytes(fromString: "l7:tolstoyi42ee")))
    print(BencodeParser.parse(testingBytes(fromString: "d6:string11:Hello World7:integeri12345e4:dictd3:key36:This is a string within a dictionarye4:listli1ei2ei3ei4e6:stringi5edeee")))
    print(BencodeParser.parse([UInt8](bt())[...]))
}

func bt() -> Data {
    
    let path = Bundle.main.path(forResource: "test", ofType: "txt")!
    return try! Data(contentsOf: URL(fileURLWithPath: path))
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        test()
        do {
            let decoder = BDecoder()
            let txt = "d4:name6:Octree4:intsli123ei234ee3:youd6:name x3:Biuee";
            let rt = try decoder.decode(Fuck.self, from: txt.data(using: .utf8)!)
            print(rt)
        } catch {
            print(error)
        }
        decodeTest()
    }
}

