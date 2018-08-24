//
//  ViewController.swift
//  Demo
//
//  Created by Octree on 2018/8/23.
//  Copyright © 2018年 Octree. All rights reserved.
//

import UIKit
import Bencode


func test() {
    
    print(BencodeParser.parse("i-123123e"))
    print(BencodeParser.parse("14:helloworld helloworld"))
    print(BencodeParser.parse("l7:tolstoyi42ee"))
    print(BencodeParser.parse("d6:string11:Hello World7:integeri12345e4:dictd3:key36:This is a string within a dictionarye4:listli1ei2ei3ei4e6:stringi5edeee"))
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        test()
    }


}

