//
//  main.swift
//  AOC2016
//
//  Created by Arthur Dexter on 11/26/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import Foundation

let start = Date()
do {
//    try day10()
//    try day11()
//    try day12()
//    try day13()
//    try day14()
//    try day15()
//    try day16()
    try day17()
} catch {
    print("Failed with error: \(error)")
}
let end = Date()
print("Completed in \(end.timeIntervalSince(start)) seconds.")
