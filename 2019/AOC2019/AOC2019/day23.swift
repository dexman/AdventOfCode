//
//  day23.swift
//  AOC2019
//
//  Created by Arthur Dexter on 12/23/19.
//  Copyright © 2019 Arthur Dexter. All rights reserved.
//

import AdventOfCodeUtils
import Foundation

func day23() throws {
    let code = try IntcodeProcessor.parseIntcode(from: readInput())
//    try part1(code)
    try part2(code)
}

private func part2(_ code: [Int]) throws {
    let nics = (0..<50).map { NIC(address: $0, code: code) }
    var natPacket: (x: Int, y: Int)?
    var lastSentNatPacket: (x: Int, y: Int)?

    while true {
        guard nics.allSatisfy({ $0.canStep }) else { fatalError("NIC program halted prematurely") }
        for (src, nic) in nics.enumerated() {
            if let (dst, packet) = nic.step() {
                print("Sending \(packet) to \(dst) from \(src)")
                if dst == 255 {
                    natPacket = packet
                } else {
                    nics[dst].send(packet: packet)
                }
            }
        }

        if nics.allSatisfy({ $0.isIdle }), let nextNatPacket = natPacket {
            print("IDLE Sending \(nextNatPacket) to \(0) from \(255)")
            nics[0].send(packet: nextNatPacket)
            natPacket = nil
        }
    }

    let natPacketYValue = try lastSentNatPacket.required().y
    print("Day 23, part 02: Y value of packet sent to 255: \(natPacketYValue)") // 17298
}

private func part1(_ code: [Int]) throws {
    let nics = (0..<50).map { NIC(address: $0, code: code) }

    var packetTo255: (x: Int, y: Int)?
    while packetTo255 == nil {
        guard nics.allSatisfy({ $0.canStep }) else { fatalError("NIC program halted prematurely") }
        for (src, nic) in nics.enumerated() {
            if let (dst, packet) = nic.step() {
                print("Sending \(packet) to \(dst) from \(src)")
                if dst == 255 {
                    packetTo255 = packet
                    break
                } else {
                    nics[dst].send(packet: packet)
                }
            }
        }
    }
    let part1YValue = try packetTo255.required().y
    print("Day 23, part 01: Y value of packet sent to 255: \(part1YValue)")
}

private final class NIC {

    init(address: Int, code: [Int]) {
        self.address = address
        packetBuffer = [[address]]
        outputBuffer = []
        idleCount = 2

        weak var weakSelf: NIC?
        processor = IntcodeProcessor(
            memory: code,
            input: {
                guard let self = weakSelf else { fatalError("Attempt to read after deinit") }
                guard !self.packetBuffer.isEmpty else {
                    self.idleCount = max(0, self.idleCount - 1)
                    return -1
                }
                let input = self.packetBuffer[0].removeFirst()
                if self.packetBuffer[0].isEmpty {
                    self.packetBuffer.removeFirst()
                }
                return input
            },
            output: {
                guard let self = weakSelf else { fatalError("Attempt to write after deinit") }
                self.outputBuffer.append($0)
            })

        weakSelf = self
    }

    var isIdle: Bool {
        return idleCount == 0 && outputBuffer.isEmpty
    }

    var canStep: Bool {
        return processor.canStep
    }

    func step() -> (dst: Int, packet: (x: Int, y: Int))? {
        guard processor.canStep else { return nil }
        processor.step()

        if outputBuffer.count == 3 {
            let (dst, packet) = (outputBuffer[0], (outputBuffer[1], outputBuffer[2]))
            outputBuffer.removeAll(keepingCapacity: true)
            return (dst, packet)
        } else {
            return nil
        }
    }

    func send(packet: (x: Int, y: Int)) {
        self.idleCount = 2
        packetBuffer.append([packet.x, packet.y])
    }

    private let address: Int
    private let processor: IntcodeProcessor

    private var packetBuffer: [[Int]]
    private var outputBuffer: [Int]
    private var idleCount: Int
}
