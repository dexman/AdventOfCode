//
//  day04.swift
//  AOC2015
//
//  Created by Arthur Dexter on 11/20/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import CryptoKit
import Foundation

func day04() throws {
    let secretKey = try readInput(day: 4).trimmingCharacters(in: .whitespacesAndNewlines)

    for i in (0..<1000000) {
        let value = "\(secretKey)\(i)"
        guard let data = value.data(using: .utf8) else {
            throw NSError(domain: "day04", code: 0, userInfo: nil)
        }
        let digest = Insecure.MD5.hash(data: data)
        let prefix = Array(digest.prefix(3))
        if prefix.count >= 3, prefix[0] == 0, prefix[1] == 0, prefix[2] < 0x10 {
            print("Day04, part01: answer=\(i)")
            break
        }
    }

    for i in (0..<2000000) {
        let value = "\(secretKey)\(i)"
        guard let data = value.data(using: .utf8) else {
            throw NSError(domain: "day04", code: 0, userInfo: nil)
        }
        let digest = Insecure.MD5.hash(data: data)
        if digest.starts(with: [0, 0, 0]) {
            print("Day04, part02: answer=\(i)")
            break
        }
    }
}
