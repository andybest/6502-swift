//
// Created by Andy Best on 09/03/2016.
// Copyright (c) 2016 andybest. All rights reserved.
//

import Foundation

enum RegisterDef {
    case aRegister
    case xRegister
    case yRegister

    case statusRegister
    case stackRegister
    case pcRegister
}

enum AddressingMode {
    case accumulator
    case implicit
    case immediate(UInt8)
    case zeroPage(UInt8)
    case zeroPageX(UInt8)
    case zeroPageY(UInt8)
    case relative(UInt8)
    case absolute(UInt16)
    case absoluteX(UInt16)
    case absoluteY(UInt16)
    case indirect(UInt16)
    case indirectX(UInt16)
    case indirectY(UInt16)

    func assemblyString() -> String {
        switch self {
        case .accumulator:
            return "A"
        case .implicit:
            return ""
        case .immediate(let val):
            let str = String(format: "%02X", val)
            return "#$\(str)"
        case .zeroPage(let val):
            let str = String(format: "%02X", val)
            return "$\(str)"
        case .zeroPageX(let val):
            let str = String(format: "%02X", val)
            return "$\(str),X"
        case .zeroPageY(let val):
            let str = String(format: "%02X", val)
            return "$\(str),Y"
        case .relative(let val):
            let str = String(format: "%02X", val)
            return "|$\(str)"
        case .absolute(let val):
            let str = String(format: "%04X", val)
            return "$\(str)"
        case .absoluteX(let val):
            let str = String(format: "%04X", val)
            return "$\(str),X"
        case .absoluteY(let val):
            let str = String(format: "%04X", val)
            return "$\(str),Y"
        case .indirect(let val):
            let str = String(format: "%04X", val)
            return "($\(str))"
        case .indirectX(let val):
            let str = String(format: "%04X", val)
            return "($\(str)),X"
        case .indirectY(let val):
            let str = String(format: "%04X", val)
            return "($\(str)),Y"

        }
    }
}

enum AddressingModeRef {
    case implicit
    case accumulator
    case immediate
    case zeroPage
    case zeroPageX
    case zeroPageY
    case relative
    case absolute
    case absoluteX
    case absoluteY
    case indirect
    case indirectX
    case indirectY
}

struct InstructionEntry {
    let instructionName:     String
    let instructionFunction: (AddressingMode) -> (InstructionResponse)
    let addressingMode:      (AddressingModeRef)
    let numBytes:            Int
    let numCycles:           Int
    let specialCycles:       Bool

    func prettyDescription() -> String {
        return "\(instructionName), Addressing mode: \(addressingMode), Cycles: \(numCycles)"
    }
}

struct InstructionResponse {
    let handlesPC: Bool
}

struct IntelHexRecord {
    let byteCount:  UInt8
    let address:    UInt16
    let recordType: UInt8
    let data:       [UInt8]
    let checksum:   UInt8
}

class CPU6502 {
    var registers: Registers
    var memory           = [UInt8](repeating: 0x00, count: 0xFFFF)
    var instructionTable = [InstructionEntry]()

    var readMemoryCallback:  ((UInt16) -> (UInt8))?
    var writeMemoryCallback: ((UInt16, UInt8) -> (Void))?

    init() {
        self.registers = Registers()
        buildInstructionTable()
        //self.reset()
    }

    func reset() {
        self.registers.s = 0xFF

        self.registers.setInterruptFlag(true)
        self.registers.setDecimalFlag(true)
        self.registers.setBreakFlag(true)
        
        self.registers.pc = getIndirectAddress(0xFFFC)
    }

    func printCPUState() {
        print("\(registers.stateString())")
    }

    func setMem(_ address: UInt16, value: UInt8) {
        guard let cb = self.writeMemoryCallback else {
            print("Error, need to set write memory callback!")
            return
        }

        cb(address, value)
    }

    func getMem(_ address: UInt16) -> UInt8 {
        guard let cb = self.readMemoryCallback else {
            print("Error, neet to set read memory callback!")
            return 0
        }

        return cb(address)
    }

    func setMemFromHexString(_ str: String, address: UInt16) {
        let data = str.uint8ArrayFromHexadecimalString()

        var currentAddress = address
        for byte in data {
            setMem(currentAddress, value: byte)
            currentAddress += 1
        }
    }

    func loadHexFileToMemory(_ path: String) {
        do {
            let file  = try String(contentsOfFile: path, encoding: String.Encoding.ascii)
            let lines = file.replacingOccurrences(of: "\r", with: "").components(separatedBy: "\n")

            var records = [IntelHexRecord]()

            for line in lines {
                let strippedLine = line.trimmingCharacters(in: CharacterSet.whitespaces)

                if strippedLine.characters.count == 0 {
                    continue
                }

                if !strippedLine.hasPrefix(":") {
                    print("Error, not valid Intel Hex format.")
                    return
                }

                let lineHex = (line as NSString).substring(from: 1).uint8ArrayFromHexadecimalString()

                let byteCount  = lineHex[0]
                let address    = (UInt16(lineHex[1]) << 8) | UInt16(lineHex[2])
                let recordType = lineHex[3]
                let data       = Array<UInt8>(lineHex[4 ..< Int(byteCount + 4)])
                let checksum   = lineHex.last

                let record = IntelHexRecord(byteCount: byteCount,
                        address: address,
                        recordType: recordType,
                        data: data,
                        checksum: checksum!)

                records.append(record)
            }

            loadRecordsToMemory(records)

        } catch {
            print("Unable to load file: \(path)")
            return
        }
    }

    func loadRecordsToMemory(_ records: [IntelHexRecord]) {
        for record in records {
            // Check if it is a data record.
            if record.recordType != 0x00 {
                continue
            }

            var address = record.address

            for byte in record.data {
                self.setMem(address, value: byte)
                address = address &+ 1
            }
        }
    }

    func getZero(_ address: UInt8) -> UInt8 {
        return getMem(UInt16(address))
    }

    func getProgramCounter() -> UInt16 {
        return registers.pc
    }

    func setProgramCounter(_ value: UInt16) {
        registers.pc = value
    }

    func getStackPointer() -> UInt8 {
        return registers.s
    }

    func push8(_ value: UInt8) {
        setMem(UInt16(registers.s) + 0x0100, value: value)
        registers.s = registers.s &- 1
    }

    func push16(_ value: UInt16) {
        push8(UInt8((value >> 8) & 0xFF))
        push8(UInt8(value & 0xFF))
    }

    func pop8() -> UInt8 {
        registers.s = registers.s &+ 1
        return getMem(UInt16(registers.s) + 0x0100)
    }

    func pop16() -> UInt16 {
        return UInt16(pop8()) | (UInt16(pop8()) << 8)
    }

    func runCycles(_ numCycles: Int) -> Int {
        var cycles = 0
        while cycles < numCycles {
            let opcode = getMem(getProgramCounter())
            cycles += executeOpcode(opcode)
        }

        return cycles
    }

    func getModeForCurrentOpcode(_ mode: AddressingModeRef, numBytes: Int) -> AddressingMode {
        switch (mode) {
        case .implicit:
            return AddressingMode.implicit
        case .accumulator:
            return AddressingMode.accumulator
        case .immediate:
            return AddressingMode.immediate(getMem(getProgramCounter() + 1))
        case .zeroPage:
            return AddressingMode.zeroPage(getMem(getProgramCounter() + 1))
        case .zeroPageX:
            return AddressingMode.zeroPageX(getMem(getProgramCounter() + 1))
        case .zeroPageY:
            return AddressingMode.zeroPageY(getMem(getProgramCounter() + 1))
        case .relative:
            return AddressingMode.relative(getMem(getProgramCounter() + 1))
        case .absolute:
            return AddressingMode.absolute(UInt16(getMem(getProgramCounter() + 1)) | (UInt16(getMem(getProgramCounter() + 2)) << UInt16(8)))
        case .absoluteX:
            return AddressingMode.absoluteX(UInt16(getMem(getProgramCounter() + 1)) | (UInt16(getMem(getProgramCounter() + 2)) << UInt16(8)))
        case .absoluteY:
            return AddressingMode.absoluteY(UInt16(getMem(getProgramCounter() + 1)) | (UInt16(getMem(getProgramCounter() + 2)) << UInt16(8)))
        case .indirect:
            return AddressingMode.indirect(UInt16(getMem(getProgramCounter() + 1)) | (UInt16(getMem(getProgramCounter() + 2)) << UInt16(8)))
        case .indirectX:
            if(numBytes == 2)
            {
                return AddressingMode.indirectX(UInt16(getMem(getProgramCounter() + 1)))
            }
            return AddressingMode.indirectX(UInt16(getMem(getProgramCounter() + 1)) | (UInt16(getMem(getProgramCounter() + 2)) << UInt16(8)))
        case .indirectY:
            if(numBytes == 2)
            {
                return AddressingMode.indirectY(UInt16(getMem(getProgramCounter() + 1)))
            }
            return AddressingMode.indirectY(UInt16(getMem(getProgramCounter() + 1)) | (UInt16(getMem(getProgramCounter() + 2)) << UInt16(8)))
        }
    }

    func executeOpcode(_ opcode: UInt8) -> Int {
        let instruction    = instructionTable[Int(opcode)]
        let addressingMode = getModeForCurrentOpcode(instruction.addressingMode, numBytes: instruction.numBytes)
        let addr           = String(format: "0x%2X", getProgramCounter())

        setProgramCounter(getProgramCounter() + UInt16(instruction.numBytes))
        _ = instruction.instructionFunction(addressingMode)

        /*if !response.handlesPC {
            setProgramCounter(getProgramCounter() + UInt16(instruction.numBytes))
        }*/

        print("Executing instruction at \(addr): \(instruction.instructionName) \(addressingMode.assemblyString())")
        printCPUState()
        return instruction.numCycles
    }

    func breakExecuted() {
        //print("Break executed at address \(self.registers.pc)")
    }

}

