// MIT License
//
// Copyright (c) 2016 Andy Best
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation

extension CPU6502 {

    typealias AM = AddressingModeRef

    func buildInstructionTable() {
        let nopEntry = InstructionEntry(instructionName: "NOP", instructionFunction: opNOP, addressingMode: AM.implicit,
                numBytes: 1, numCycles: 2, specialCycles: false)

        instructionTable = [InstructionEntry](repeating: nopEntry, count: 256)
        add6502Opcodes()
    }

    func addInstruction(_ opcode: UInt8, ins: @escaping (AddressingMode) -> (InstructionResponse), insName: String,
                        addrMode: AddressingModeRef, numBytes: Int, numCycles: Int, specialCycles: Bool) {
        instructionTable[Int(opcode)] = InstructionEntry(instructionName: insName, instructionFunction: ins,
                addressingMode: addrMode, numBytes: numBytes, numCycles: numCycles, specialCycles: specialCycles)
    }

    func add6502Opcodes() {
        addInstruction(0x00, ins: opBRK, insName:"BRK", addrMode: AM.implicit, numBytes: 1, numCycles: 7, specialCycles: false)
        addInstruction(0x01, ins: opORA, insName:"ORA", addrMode: AM.indirectX, numBytes: 2, numCycles: 6, specialCycles: false)
        addInstruction(0x05, ins: opORA, insName:"ORA", addrMode: AM.zeroPage, numBytes: 2, numCycles: 3, specialCycles: false)
        addInstruction(0x06, ins: opASL, insName:"ASL", addrMode: AM.zeroPage, numBytes: 2, numCycles: 5, specialCycles: false)
        addInstruction(0x08, ins: opPHP, insName:"PHP", addrMode: AM.implicit, numBytes: 1, numCycles: 3, specialCycles: false)
        addInstruction(0x09, ins: opORA, insName:"ORA", addrMode: AM.accumulator, numBytes: 1, numCycles: 2, specialCycles: false)
        addInstruction(0x0A, ins: opASL, insName:"ASL", addrMode: AM.accumulator, numBytes: 1, numCycles: 6, specialCycles: false)
        addInstruction(0x0D, ins: opORA, insName:"ORA", addrMode: AM.absolute, numBytes: 3, numCycles: 4, specialCycles: false)
        addInstruction(0x0E, ins: opASL, insName:"ASL", addrMode: AM.absolute, numBytes: 3, numCycles: 6, specialCycles: false)
        addInstruction(0x10, ins: opBPL, insName:"BPL", addrMode: AM.relative, numBytes: 2, numCycles: 2, specialCycles: true)
        addInstruction(0x11, ins: opORA, insName:"ORA", addrMode: AM.indirectY, numBytes: 2, numCycles: 5, specialCycles: true)
        addInstruction(0x15, ins: opORA, insName:"ORA", addrMode: AM.zeroPageX, numBytes: 2, numCycles: 4, specialCycles: false)
        addInstruction(0x16, ins: opASL, insName:"ASL", addrMode: AM.zeroPageX, numBytes: 2, numCycles: 6, specialCycles: false)
        addInstruction(0x18, ins: opCLC, insName:"CLC", addrMode: AM.implicit, numBytes: 1, numCycles: 2, specialCycles: false)
        addInstruction(0x19, ins: opORA, insName:"ORA", addrMode: AM.absoluteY, numBytes: 3, numCycles: 4, specialCycles: true)
        addInstruction(0x1D, ins: opORA, insName:"ORA", addrMode: AM.absoluteX, numBytes: 3, numCycles: 4, specialCycles: true)
        addInstruction(0x1E, ins: opASL, insName:"ASL", addrMode: AM.absoluteX, numBytes: 3, numCycles: 7, specialCycles: false)
        addInstruction(0x20, ins: opJSR, insName:"JSR", addrMode: AM.absolute, numBytes: 3, numCycles: 6, specialCycles: false)
        addInstruction(0x21, ins: opAND, insName:"AND", addrMode: AM.indirectX, numBytes: 2, numCycles: 6, specialCycles: false)
        addInstruction(0x24, ins: opBIT, insName:"BIT", addrMode: AM.zeroPage, numBytes: 2, numCycles: 3, specialCycles: false)
        addInstruction(0x25, ins: opAND, insName:"AND", addrMode: AM.zeroPage, numBytes: 2, numCycles: 3, specialCycles: false)
        addInstruction(0x26, ins: opROL, insName:"ROL", addrMode: AM.zeroPage, numBytes: 2, numCycles: 5, specialCycles: false)
        addInstruction(0x28, ins: opPLP, insName:"PLP", addrMode: AM.implicit, numBytes: 1, numCycles: 4, specialCycles: false)
        addInstruction(0x29, ins: opAND, insName:"AND", addrMode: AM.immediate, numBytes: 2, numCycles: 2, specialCycles: false)
        addInstruction(0x2A, ins: opROL, insName:"ROL", addrMode: AM.accumulator, numBytes: 1, numCycles: 2, specialCycles: false)
        addInstruction(0x2C, ins: opBIT, insName:"BIT", addrMode: AM.absolute, numBytes: 3, numCycles: 4, specialCycles: false)
        addInstruction(0x2D, ins: opAND, insName:"AND", addrMode: AM.absolute, numBytes: 3, numCycles: 4, specialCycles: false)
        addInstruction(0x2E, ins: opROL, insName:"ROL", addrMode: AM.absolute, numBytes: 3, numCycles: 6, specialCycles: false)
        addInstruction(0x30, ins: opBMI, insName:"BMI", addrMode: AM.relative, numBytes: 2, numCycles: 2, specialCycles: true)
        addInstruction(0x31, ins: opAND, insName:"AND", addrMode: AM.indirectY, numBytes: 2, numCycles: 5, specialCycles: true)
        addInstruction(0x35, ins: opAND, insName:"AND", addrMode: AM.zeroPageX, numBytes: 2, numCycles: 4, specialCycles: false)
        addInstruction(0x36, ins: opROL, insName:"ROL", addrMode: AM.zeroPageX, numBytes: 2, numCycles: 6, specialCycles: false)
        addInstruction(0x38, ins: opSEC, insName:"SEC", addrMode: AM.implicit, numBytes: 1, numCycles: 2, specialCycles: false)
        addInstruction(0x39, ins: opAND, insName:"AND", addrMode: AM.absoluteY, numBytes: 3, numCycles: 4, specialCycles: true)
        addInstruction(0x3D, ins: opAND, insName:"AND", addrMode: AM.absoluteX, numBytes: 3, numCycles: 4, specialCycles: true)
        addInstruction(0x3E, ins: opROL, insName:"ROL", addrMode: AM.absoluteX, numBytes: 3, numCycles: 7, specialCycles: false)
        addInstruction(0x40, ins: opRTI, insName:"RTI", addrMode: AM.implicit, numBytes: 1, numCycles: 6, specialCycles: false)
        addInstruction(0x41, ins: opEOR, insName:"EOR", addrMode: AM.indirectX, numBytes: 2, numCycles: 6, specialCycles: false)
        addInstruction(0x45, ins: opEOR, insName:"EOR", addrMode: AM.zeroPage, numBytes: 2, numCycles: 3, specialCycles: false)
        addInstruction(0x46, ins: opLSR, insName:"LSR", addrMode: AM.zeroPage, numBytes: 2, numCycles: 5, specialCycles: false)
        addInstruction(0x48, ins: opPHA, insName:"PHA", addrMode: AM.implicit, numBytes: 1, numCycles: 3, specialCycles: false)
        addInstruction(0x49, ins: opEOR, insName:"EOR", addrMode: AM.immediate, numBytes: 2, numCycles: 2, specialCycles: false)
        addInstruction(0x4A, ins: opLSR, insName:"LSR", addrMode: AM.accumulator, numBytes: 1, numCycles: 2, specialCycles: false)
        addInstruction(0x4C, ins: opJMP, insName:"JMP", addrMode: AM.absolute, numBytes: 3, numCycles: 3, specialCycles: false)
        addInstruction(0x4D, ins: opEOR, insName:"EOR", addrMode: AM.absolute, numBytes: 3, numCycles: 4, specialCycles: false)
        addInstruction(0x4E, ins: opLSR, insName:"LSR", addrMode: AM.absolute, numBytes: 3, numCycles: 6, specialCycles: false)
        addInstruction(0x50, ins: opBVC, insName:"BVC", addrMode: AM.relative, numBytes: 2, numCycles: 2, specialCycles: true)
        addInstruction(0x51, ins: opEOR, insName:"EOR", addrMode: AM.indirectY, numBytes: 2, numCycles: 5, specialCycles: true)
        addInstruction(0x55, ins: opEOR, insName:"EOR", addrMode: AM.zeroPageX, numBytes: 2, numCycles: 4, specialCycles: false)
        addInstruction(0x56, ins: opLSR, insName:"LSR", addrMode: AM.zeroPageX, numBytes: 2, numCycles: 6, specialCycles: false)
        addInstruction(0x58, ins: opCLI, insName:"CLI", addrMode: AM.implicit, numBytes: 1, numCycles: 2, specialCycles: false)
        addInstruction(0x59, ins: opEOR, insName:"EOR", addrMode: AM.absoluteY, numBytes: 3, numCycles: 4, specialCycles: true)
        addInstruction(0x5D, ins: opEOR, insName:"EOR", addrMode: AM.absoluteX, numBytes: 3, numCycles: 4, specialCycles: true)
        addInstruction(0x5E, ins: opLSR, insName:"LSR", addrMode: AM.absoluteX, numBytes: 3, numCycles: 7, specialCycles: false)
        addInstruction(0x60, ins: opRTS, insName:"RTS", addrMode: AM.implicit, numBytes: 1, numCycles: 6, specialCycles: false)
        addInstruction(0x61, ins: opADC, insName:"ADC", addrMode: AM.indirectX, numBytes: 2, numCycles: 6, specialCycles: false)
        addInstruction(0x65, ins: opADC, insName:"ADC", addrMode: AM.zeroPage, numBytes: 2, numCycles: 3, specialCycles: false)
        addInstruction(0x66, ins: opROR, insName:"ROR", addrMode: AM.zeroPage, numBytes: 2, numCycles: 5, specialCycles: false)
        addInstruction(0x68, ins: opPLA, insName:"PLA", addrMode: AM.implicit, numBytes: 1, numCycles: 4, specialCycles: false)
        addInstruction(0x69, ins: opADC, insName:"ADC", addrMode: AM.immediate, numBytes: 2, numCycles: 2, specialCycles: false)
        addInstruction(0x6A, ins: opROR, insName:"ROR", addrMode: AM.accumulator, numBytes: 1, numCycles: 2, specialCycles: false)
        addInstruction(0x6C, ins: opJMP, insName:"JMP", addrMode: AM.indirect, numBytes: 3, numCycles: 5, specialCycles: false)
        addInstruction(0x6D, ins: opADC, insName:"ADC", addrMode: AM.absolute, numBytes: 3, numCycles: 4, specialCycles: false)
        addInstruction(0x6E, ins: opROR, insName:"ROR", addrMode: AM.absolute, numBytes: 3, numCycles: 6, specialCycles: false)
        addInstruction(0x70, ins: opBVS, insName:"BVS", addrMode: AM.relative, numBytes: 2, numCycles: 2, specialCycles: true)
        addInstruction(0x71, ins: opADC, insName:"ADC", addrMode: AM.indirectY, numBytes: 2, numCycles: 5, specialCycles: true)
        addInstruction(0x75, ins: opADC, insName:"ADC", addrMode: AM.zeroPageX, numBytes: 2, numCycles: 4, specialCycles: false)
        addInstruction(0x76, ins: opROR, insName:"ROR", addrMode: AM.zeroPageX, numBytes: 2, numCycles: 6, specialCycles: false)
        addInstruction(0x78, ins: opSEI, insName:"SEI", addrMode: AM.implicit, numBytes: 1, numCycles: 2, specialCycles: false)
        addInstruction(0x79, ins: opADC, insName:"ADC", addrMode: AM.absoluteY, numBytes: 3, numCycles: 4, specialCycles: true)
        addInstruction(0x7D, ins: opADC, insName:"ADC", addrMode: AM.absoluteX, numBytes: 3, numCycles: 4, specialCycles: true)
        addInstruction(0x7E, ins: opROR, insName:"ROR", addrMode: AM.absoluteX, numBytes: 3, numCycles: 7, specialCycles: false)
        addInstruction(0x81, ins: opSTA, insName:"STA", addrMode: AM.indirectX, numBytes: 2, numCycles: 6, specialCycles: false)
        addInstruction(0x84, ins: opSTY, insName:"STY", addrMode: AM.zeroPage, numBytes: 2, numCycles: 3, specialCycles: false)
        addInstruction(0x85, ins: opSTA, insName:"STA", addrMode: AM.zeroPage, numBytes: 2, numCycles: 3, specialCycles: false)
        addInstruction(0x86, ins: opSTX, insName:"STX", addrMode: AM.zeroPage, numBytes: 2, numCycles: 3, specialCycles: false)
        addInstruction(0x88, ins: opDEY, insName:"DEY", addrMode: AM.implicit, numBytes: 1, numCycles: 2, specialCycles: false)
        addInstruction(0x8A, ins: opTXA, insName:"TXA", addrMode: AM.implicit, numBytes: 1, numCycles: 2, specialCycles: false)
        addInstruction(0x8C, ins: opSTY, insName:"STY", addrMode: AM.absolute, numBytes: 3, numCycles: 4, specialCycles: false)
        addInstruction(0x8D, ins: opSTA, insName:"STA", addrMode: AM.absolute, numBytes: 3, numCycles: 4, specialCycles: false)
        addInstruction(0x8E, ins: opSTX, insName:"STX", addrMode: AM.absolute, numBytes: 3, numCycles: 4, specialCycles: false)
        addInstruction(0x90, ins: opBCC, insName:"BCC", addrMode: AM.relative, numBytes: 2, numCycles: 2, specialCycles: true)
        addInstruction(0x91, ins: opSTA, insName:"STA", addrMode: AM.indirectY, numBytes: 2, numCycles: 6, specialCycles: false)
        addInstruction(0x94, ins: opSTY, insName:"STY", addrMode: AM.zeroPageX, numBytes: 2, numCycles: 4, specialCycles: false)
        addInstruction(0x95, ins: opSTA, insName:"STA", addrMode: AM.zeroPageX, numBytes: 2, numCycles: 4, specialCycles: false)
        addInstruction(0x96, ins: opSTX, insName:"STX", addrMode: AM.zeroPageY, numBytes: 2, numCycles: 4, specialCycles: false)
        addInstruction(0x98, ins: opTYA, insName:"TYA", addrMode: AM.implicit, numBytes: 1, numCycles: 2, specialCycles: false)
        addInstruction(0x99, ins: opSTA, insName:"STA", addrMode: AM.absoluteY, numBytes: 3, numCycles: 5, specialCycles: false)
        addInstruction(0x9A, ins: opTXS, insName:"TXS", addrMode: AM.implicit, numBytes: 1, numCycles: 2, specialCycles: false)
        addInstruction(0x9D, ins: opSTA, insName:"STA", addrMode: AM.absoluteX, numBytes: 3, numCycles: 5, specialCycles: false)
        addInstruction(0xA0, ins: opLDY, insName:"LDY", addrMode: AM.immediate, numBytes: 2, numCycles: 2, specialCycles: false)
        addInstruction(0xA1, ins: opLDA, insName:"LDA", addrMode: AM.indirectX, numBytes: 2, numCycles: 6, specialCycles: false)
        addInstruction(0xA2, ins: opLDX, insName:"LDX", addrMode: AM.immediate, numBytes: 2, numCycles: 2, specialCycles: false)
        addInstruction(0xA4, ins: opLDY, insName:"LDY", addrMode: AM.zeroPage, numBytes: 2, numCycles: 3, specialCycles: false)
        addInstruction(0xA5, ins: opLDA, insName:"LDA", addrMode: AM.zeroPage, numBytes: 2, numCycles: 3, specialCycles: false)
        addInstruction(0xA6, ins: opLDX, insName:"LDX", addrMode: AM.zeroPage, numBytes: 2, numCycles: 3, specialCycles: false)
        addInstruction(0xA8, ins: opTAY, insName:"TAY", addrMode: AM.implicit, numBytes: 1, numCycles: 2, specialCycles: false)
        addInstruction(0xA9, ins: opLDA, insName:"LDA", addrMode: AM.immediate, numBytes: 2, numCycles: 2, specialCycles: false)
        addInstruction(0xAA, ins: opTAX, insName:"TAX", addrMode: AM.implicit, numBytes: 1, numCycles: 2, specialCycles: false)
        addInstruction(0xAC, ins: opLDY, insName:"LDY", addrMode: AM.absolute, numBytes: 3, numCycles: 4, specialCycles: false)
        addInstruction(0xAD, ins: opLDA, insName:"LDA", addrMode: AM.absolute, numBytes: 3, numCycles: 4, specialCycles: false)
        addInstruction(0xAE, ins: opLDX, insName:"LDX", addrMode: AM.absolute, numBytes: 3, numCycles: 4, specialCycles: false)
        addInstruction(0xB0, ins: opBCS, insName:"BCS", addrMode: AM.relative, numBytes: 2, numCycles: 2, specialCycles: true)
        addInstruction(0xB1, ins: opLDA, insName:"LDA", addrMode: AM.indirectY, numBytes: 2, numCycles: 5, specialCycles: true)
        addInstruction(0xB4, ins: opLDY, insName:"LDY", addrMode: AM.zeroPageX, numBytes: 2, numCycles: 4, specialCycles: false)
        addInstruction(0xB5, ins: opLDA, insName:"LDA", addrMode: AM.zeroPageX, numBytes: 2, numCycles: 4, specialCycles: false)
        addInstruction(0xB6, ins: opLDX, insName:"LDX", addrMode: AM.zeroPageY, numBytes: 2, numCycles: 4, specialCycles: false)
        addInstruction(0xB8, ins: opCLV, insName:"CLV", addrMode: AM.implicit, numBytes: 1, numCycles: 2, specialCycles: false)
        addInstruction(0xB9, ins: opLDA, insName:"LDA", addrMode: AM.absoluteY, numBytes: 3, numCycles: 4, specialCycles: true)
        addInstruction(0xBA, ins: opTSX, insName:"TSX", addrMode: AM.implicit, numBytes: 1, numCycles: 2, specialCycles: false)
        addInstruction(0xBC, ins: opLDY, insName:"LDY", addrMode: AM.absoluteX, numBytes: 3, numCycles: 4, specialCycles: true)
        addInstruction(0xBD, ins: opLDA, insName:"LDA", addrMode: AM.absoluteX, numBytes: 3, numCycles: 4, specialCycles: true)
        addInstruction(0xBE, ins: opLDX, insName:"LDX", addrMode: AM.absoluteY, numBytes: 3, numCycles: 4, specialCycles: true)
        addInstruction(0xC0, ins: opCPY, insName:"CPY", addrMode: AM.immediate, numBytes: 2, numCycles: 2, specialCycles: false)
        addInstruction(0xC1, ins: opCMP, insName:"CMP", addrMode: AM.indirectX, numBytes: 2, numCycles: 6, specialCycles: false)
        addInstruction(0xC4, ins: opCPY, insName:"CPY", addrMode: AM.zeroPage, numBytes: 2, numCycles: 3, specialCycles: false)
        addInstruction(0xC5, ins: opCMP, insName:"CMP", addrMode: AM.zeroPage, numBytes: 2, numCycles: 3, specialCycles: false)
        addInstruction(0xC6, ins: opDEC, insName:"DEC", addrMode: AM.zeroPage, numBytes: 2, numCycles: 5, specialCycles: false)
        addInstruction(0xC8, ins: opINY, insName:"INY", addrMode: AM.implicit, numBytes: 1, numCycles: 2, specialCycles: false)
        addInstruction(0xC9, ins: opCMP, insName:"CMP", addrMode: AM.immediate, numBytes: 2, numCycles: 2, specialCycles: false)
        addInstruction(0xCA, ins: opDEX, insName:"DEX", addrMode: AM.implicit, numBytes: 1, numCycles: 2, specialCycles: false)
        addInstruction(0xCC, ins: opCPY, insName:"CPY", addrMode: AM.absolute, numBytes: 3, numCycles: 4, specialCycles: false)
        addInstruction(0xCD, ins: opCMP, insName:"CMP", addrMode: AM.absolute, numBytes: 3, numCycles: 4, specialCycles: false)
        addInstruction(0xCE, ins: opDEC, insName:"DEC", addrMode: AM.absolute, numBytes: 3, numCycles: 6, specialCycles: false)
        addInstruction(0xD0, ins: opBNE, insName:"BNE", addrMode: AM.relative, numBytes: 2, numCycles: 2, specialCycles: true)
        addInstruction(0xD1, ins: opCMP, insName:"CMP", addrMode: AM.indirectY, numBytes: 2, numCycles: 5, specialCycles: true)
        addInstruction(0xD5, ins: opCMP, insName:"CMP", addrMode: AM.zeroPageX, numBytes: 2, numCycles: 4, specialCycles: false)
        addInstruction(0xD6, ins: opDEC, insName:"DEC", addrMode: AM.zeroPageX, numBytes: 2, numCycles: 6, specialCycles: false)
        addInstruction(0xD8, ins: opCLD, insName:"CLD", addrMode: AM.implicit, numBytes: 1, numCycles: 2, specialCycles: false)
        addInstruction(0xD9, ins: opCMP, insName:"CMP", addrMode: AM.absoluteY, numBytes: 3, numCycles: 4, specialCycles: true)
        addInstruction(0xDD, ins: opCMP, insName:"CMP", addrMode: AM.absoluteX, numBytes: 3, numCycles: 4, specialCycles: true)
        addInstruction(0xDE, ins: opDEC, insName:"DEC", addrMode: AM.absoluteX, numBytes: 3, numCycles: 7, specialCycles: false)
        addInstruction(0xE0, ins: opCPX, insName:"CPX", addrMode: AM.immediate, numBytes: 2, numCycles: 2, specialCycles: false)
        addInstruction(0xE1, ins: opSBC, insName:"SBC", addrMode: AM.indirectX, numBytes: 2, numCycles: 6, specialCycles: false)
        addInstruction(0xE4, ins: opCPX, insName:"CPX", addrMode: AM.zeroPage, numBytes: 2, numCycles: 3, specialCycles: false)
        addInstruction(0xE5, ins: opSBC, insName:"SBC", addrMode: AM.zeroPage, numBytes: 2, numCycles: 3, specialCycles: false)
        addInstruction(0xE6, ins: opINC, insName:"INC", addrMode: AM.zeroPage, numBytes: 2, numCycles: 5, specialCycles: false)
        addInstruction(0xE8, ins: opINX, insName:"INX", addrMode: AM.implicit, numBytes: 1, numCycles: 2, specialCycles: false)
        addInstruction(0xE9, ins: opSBC, insName:"SBC", addrMode: AM.immediate, numBytes: 2, numCycles: 2, specialCycles: false)
        addInstruction(0xEA, ins: opNOP, insName:"NOP", addrMode: AM.implicit, numBytes: 1, numCycles: 2, specialCycles: false)
        addInstruction(0xEC, ins: opCPX, insName:"CPX", addrMode: AM.absolute, numBytes: 3, numCycles: 4, specialCycles: false)
        addInstruction(0xED, ins: opSBC, insName:"SBC", addrMode: AM.absolute, numBytes: 3, numCycles: 4, specialCycles: false)
        addInstruction(0xEE, ins: opINC, insName:"INC", addrMode: AM.absolute, numBytes: 3, numCycles: 6, specialCycles: false)
        addInstruction(0xF0, ins: opBEQ, insName:"BEQ", addrMode: AM.relative, numBytes: 2, numCycles: 2, specialCycles: true)
        addInstruction(0xF1, ins: opSBC, insName:"SBC", addrMode: AM.indirectY, numBytes: 2, numCycles: 5, specialCycles: true)
        addInstruction(0xF5, ins: opSBC, insName:"SBC", addrMode: AM.zeroPageX, numBytes: 2, numCycles: 4, specialCycles: false)
        addInstruction(0xF6, ins: opINC, insName:"INC", addrMode: AM.zeroPageX, numBytes: 2, numCycles: 6, specialCycles: false)
        addInstruction(0xF8, ins: opSED, insName:"SED", addrMode: AM.implicit, numBytes: 1, numCycles: 2, specialCycles: false)
        addInstruction(0xF9, ins: opSBC, insName:"SBC", addrMode: AM.absoluteY, numBytes: 3, numCycles: 4, specialCycles: true)
        addInstruction(0xFD, ins: opSBC, insName:"SBC", addrMode: AM.absoluteX, numBytes: 3, numCycles: 4, specialCycles: true)
        addInstruction(0xFE, ins: opINC, insName:"INC", addrMode: AM.absoluteX, numBytes: 3, numCycles: 7, specialCycles: false)
    }
}
