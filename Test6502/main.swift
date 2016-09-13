//
//  main.swift
//  Test6502
//
//  Created by Andy Best on 12/09/2016.
//
//

import Foundation

var mem:[UInt8] = [UInt8]()

func readMem(address: UInt16) -> UInt8 {
    return mem[Int(address)]
}

func writeMem(address: UInt16, value: UInt8) {
    mem[Int(address)] = value
}

mem = [UInt8](repeating: 0x0, count: 0x10000)

var cpu = CPU6502()
cpu.readMemoryCallback = readMem
cpu.writeMemoryCallback = writeMem

cpu.loadHexFileToMemory("6502_functional_test.hex")
cpu.setProgramCounter(0x0400)

while true {
    cpu.runCycles(10000)
    //sleep(200)
}
