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

// Instruction tests based on tests for PY65
// https://github.com/mnaberez/py65

import Foundation
import XCTest
import Nimble


class InstructionTests: XCTestCase {

    var cpu:CPU6502 = CPU6502()
    var mem:[UInt8] = [UInt8]()

    override func setUp() {
        super.setUp()
        cpu = CPU6502()
        mem = [UInt8](repeating: 0x0, count: 0x10000)
        
        cpu.readMemoryCallback =  { (address:UInt16) -> UInt8 in
            return self.mem[Int(address)]
        }

        cpu.writeMemoryCallback =  { (address:UInt16, value:UInt8) in
            self.mem[Int(address)] = value
        }
        
        cpu.reset()
    }

    override func tearDown() {
        super.tearDown()
    }

    /* ADC Absolute addressing */

    func testADCWithBCDOffAbsoluteCarryClearInAccumulatorZeros() {
        self.cpu.setMem(0xC000, value:0x00)

        _ = self.cpu.opADC(AddressingMode.absolute(0xC000))

        expect(self.cpu.registers.a).to(equal(0x00))
        expect(self.cpu.registers.getCarryFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
    }

    func testADCWithBCDOffAbsoluteCarrySetInAccumulatorZeros() {
        self.cpu.setMem(0xC000, value:0x00)
        self.cpu.registers.setCarryFlag(true)

        _ = self.cpu.opADC(AddressingMode.absolute(0xC000))

        expect(self.cpu.registers.a).to(equal(0x01))
        expect(self.cpu.registers.getCarryFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }

    func testADCWithBCDOffAbsoluteCarryClearInNoCarryClearOut() {
        self.cpu.setMem(0xC000, value:0xFE)
        self.cpu.registers.a = 0x01

        _ = self.cpu.opADC(AddressingMode.absolute(0xC000))

        expect(self.cpu.registers.a).to(equal(0xFF))
        expect(self.cpu.registers.getCarryFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }

    func testADCWithBCDOffAbsoluteCarryClearInCarrySetOut() {
        self.cpu.setMem(0xC000, value:0xFF)
        self.cpu.registers.a = 0x02

        _ = self.cpu.opADC(AddressingMode.absolute(0xC000))

        expect(self.cpu.registers.a).to(equal(0x01))
        expect(self.cpu.registers.getCarryFlag()).to(beTrue())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }

    func testADCWithBCDOffAbsoluteOverflowClearNoCarry01Plus01() {
        self.cpu.setMem(0xC000, value:0x01)
        self.cpu.registers.a = 0x01

        _ = self.cpu.opADC(AddressingMode.absolute(0xC000))

        expect(self.cpu.registers.a).to(equal(0x02))
        expect(self.cpu.registers.getOverflowFlag()).to(beFalse())
    }

    func testADCWithBCDOffAbsoluteOverflowClearNoCarry01PlusFF() {
        self.cpu.setMem(0xC000, value:0xFF)
        self.cpu.registers.a = 0x01

        _ = self.cpu.opADC(AddressingMode.absolute(0xC000))

        expect(self.cpu.registers.a).to(equal(0x00))
        expect(self.cpu.registers.getOverflowFlag()).to(beFalse())
    }

    func testADCWithBCDOffAbsoluteOverflowSetNoCarry7FPlus01() {
        self.cpu.setMem(0xC000, value:0x01)
        self.cpu.registers.a = 0x7F

        _ = self.cpu.opADC(AddressingMode.absolute(0xC000))

        expect(self.cpu.registers.a).to(equal(0x80))
        expect(self.cpu.registers.getOverflowFlag()).to(beTrue())
    }

    func testADCWithBCDOffAbsoluteOverflowSetNoCarry80PlusFF() {
        self.cpu.setMem(0xC000, value:0xFF)
        self.cpu.registers.a = 0x80

        _ = self.cpu.opADC(AddressingMode.absolute(0xC000))

        expect(self.cpu.registers.a).to(equal(0x7F))
        expect(self.cpu.registers.getOverflowFlag()).to(beTrue())
    }

    func testADCWithBCDOffAbsoluteOverflowSetOn80Plus80() {
        self.cpu.setMem(0xC000, value:0x40)
        self.cpu.registers.a = 0x40

        _ = self.cpu.opADC(AddressingMode.absolute(0xC000))

        expect(self.cpu.registers.a).to(equal(0x80))
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
        expect(self.cpu.registers.getOverflowFlag()).to(beTrue())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }

    /* ADC Zero Page */

    func testADCWithBCDOffZPCarryClearInAccumulatorZeros() {
        self.cpu.setMem(0x00B0, value:0x00)

        _ = self.cpu.opADC(AddressingMode.zeroPage(0xB0))

        expect(self.cpu.registers.a).to(equal(0x00))
        expect(self.cpu.registers.getCarryFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
    }

    func testADCWithBCDOffZPCarrySetInAccumulatorZeros() {
        self.cpu.setMem(0x00B0, value:0x00)
        self.cpu.registers.setCarryFlag(true)

        _ = self.cpu.opADC(AddressingMode.zeroPage(0xB0))

        expect(self.cpu.registers.a).to(equal(0x01))
        expect(self.cpu.registers.getCarryFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }

    func testADCWithBCDOffZPCarryClearInNoCarryClearOut() {
        self.cpu.setMem(0x00B0, value:0xFE)
        self.cpu.registers.a = 0x01

        _ = self.cpu.opADC(AddressingMode.zeroPage(0xB0))

        expect(self.cpu.registers.a).to(equal(0xFF))
        expect(self.cpu.registers.getCarryFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }

    func testADCWithBCDOffZPCarryClearInCarrySetOut() {
        self.cpu.setMem(0x00B0, value:0xFF)
        self.cpu.registers.a = 0x02

        _ = self.cpu.opADC(AddressingMode.zeroPage(0xB0))

        expect(self.cpu.registers.a).to(equal(0x01))
        expect(self.cpu.registers.getCarryFlag()).to(beTrue())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }

    func testADCWithBCDOffZPOverflowClearNoCarry01Plus01() {
        self.cpu.setMem(0x00B0, value:0x01)
        self.cpu.registers.a = 0x01

        _ = self.cpu.opADC(AddressingMode.zeroPage(0xB0))

        expect(self.cpu.registers.a).to(equal(0x02))
        expect(self.cpu.registers.getOverflowFlag()).to(beFalse())
    }

    func testADCWithBCDOffZPOverflowClearNoCarry01PlusFF() {
        self.cpu.setMem(0x00B0, value:0xFF)
        self.cpu.registers.a = 0x01

        _ = self.cpu.opADC(AddressingMode.zeroPage(0xB0))

        expect(self.cpu.registers.a).to(equal(0x00))
        expect(self.cpu.registers.getOverflowFlag()).to(beFalse())
    }

    func testADCWithBCDOffZPOverflowSetNoCarry7FPlus01() {
        self.cpu.setMem(0x00B0, value:0x01)
        self.cpu.registers.a = 0x7F

        _ = self.cpu.opADC(AddressingMode.zeroPage(0xB0))

        expect(self.cpu.registers.a).to(equal(0x80))
        expect(self.cpu.registers.getOverflowFlag()).to(beTrue())
    }

    func testADCWithBCDOffZPOverflowSetNoCarry80PlusFF() {
        self.cpu.setMem(0x00B0, value:0xFF)
        self.cpu.registers.a = 0x80

        _ = self.cpu.opADC(AddressingMode.zeroPage(0xB0))

        expect(self.cpu.registers.a).to(equal(0x7F))
        expect(self.cpu.registers.getOverflowFlag()).to(beTrue())
    }

    func testADCWithBCDOffZPOverflowSetOn80Plus80() {
        self.cpu.setMem(0x00B0, value:0x40)
        self.cpu.registers.a = 0x40

        _ = self.cpu.opADC(AddressingMode.zeroPage(0xB0))

        expect(self.cpu.registers.a).to(equal(0x80))
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
        expect(self.cpu.registers.getOverflowFlag()).to(beTrue())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }

    /* ADC Immediate */

    func testADCWithBCDOffImmediateCarryClearInAccumulatorZeros() {
        _ = self.cpu.opADC(AddressingMode.immediate(0x00))

        expect(self.cpu.registers.a).to(equal(0x00))
        expect(self.cpu.registers.getCarryFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
    }

    func testADCWithBCDOffImmediateCarrySetInAccumulatorZeros() {
        self.cpu.registers.setCarryFlag(true)

        _ = self.cpu.opADC(AddressingMode.immediate(0x00))

        expect(self.cpu.registers.a).to(equal(0x01))
        expect(self.cpu.registers.getCarryFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }

    func testADCWithBCDOffImmediateCarryClearInNoCarryClearOut() {
        self.cpu.registers.a = 0x01

        _ = self.cpu.opADC(AddressingMode.immediate(0xFE))

        expect(self.cpu.registers.a).to(equal(0xFF))
        expect(self.cpu.registers.getCarryFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }

    func testADCWithBCDOffImmediateCarryClearInCarrySetOut() {
        self.cpu.registers.a = 0x02

        _ = self.cpu.opADC(AddressingMode.immediate(0xFF))

        expect(self.cpu.registers.a).to(equal(0x01))
        expect(self.cpu.registers.getCarryFlag()).to(beTrue())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }

    func testADCWithBCDOffImmediateOverflowClearNoCarry01Plus01() {
        self.cpu.registers.a = 0x01

        _ = self.cpu.opADC(AddressingMode.immediate(0x01))

        expect(self.cpu.registers.a).to(equal(0x02))
        expect(self.cpu.registers.getOverflowFlag()).to(beFalse())
    }

    func testADCWithBCDOffImmediateOverflowClearNoCarry01PlusFF() {
        self.cpu.registers.a = 0x01

        _ = self.cpu.opADC(AddressingMode.immediate(0xFF))

        expect(self.cpu.registers.a).to(equal(0x00))
        expect(self.cpu.registers.getOverflowFlag()).to(beFalse())
    }

    func testADCWithBCDOffImmediateOverflowSetNoCarry7FPlus01() {
        self.cpu.registers.a = 0x7F

        _ = self.cpu.opADC(AddressingMode.immediate(0x01))

        expect(self.cpu.registers.a).to(equal(0x80))
        expect(self.cpu.registers.getOverflowFlag()).to(beTrue())
    }

    func testADCWithBCDOffImmediateOverflowSetNoCarry80PlusFF() {
        self.cpu.registers.a = 0x80

        _ = self.cpu.opADC(AddressingMode.immediate(0xFF))

        expect(self.cpu.registers.a).to(equal(0x7F))
        expect(self.cpu.registers.getOverflowFlag()).to(beTrue())
    }

    func testADCWithBCDOffImmediateOverflowSetOn80Plus80() {
        self.cpu.registers.a = 0x40

        _ = self.cpu.opADC(AddressingMode.immediate(0x40))

        expect(self.cpu.registers.a).to(equal(0x80))
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
        expect(self.cpu.registers.getOverflowFlag()).to(beTrue())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }

    /* ASL Accumulator */

    func testASLAccumulatorSetsZFlag() {
        self.cpu.registers.a = 0x00

        _ = self.cpu.opASL(AddressingMode.accumulator)

        expect(self.cpu.registers.a).to(equal(0x00))
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
    }

    func testASLAccumulatorSetsNFlag() {
        self.cpu.registers.a = 0x40

        _ = self.cpu.opASL(AddressingMode.accumulator)

        expect(self.cpu.registers.a).to(equal(0x80))
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
    }

    func testASLAccumulatorShiftsOutZero() {
        self.cpu.registers.a = 0x7F

        _ = self.cpu.opASL(AddressingMode.accumulator)

        expect(self.cpu.registers.a).to(equal(0xFE))
        expect(self.cpu.registers.getCarryFlag()).to(beFalse())
    }

    func testASLAccumulatorShiftsOutOne() {
        self.cpu.registers.a = 0xFF

        _ = self.cpu.opASL(AddressingMode.accumulator)

        expect(self.cpu.registers.a).to(equal(0xFE))
        expect(self.cpu.registers.getCarryFlag()).to(beTrue())
    }

    func testASLAccumulator80SetsZFlag() {
        self.cpu.registers.a = 0x80

        _ = self.cpu.opASL(AddressingMode.accumulator)

        expect(self.cpu.registers.a).to(equal(0x00))
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
    }

    /* ASL Absolute */

    func testASLAbsoluteSetsZFlag() {
        self.cpu.setMem(0xABCD, value: 0x00)

        _ = self.cpu.opASL(AddressingMode.absolute(0xABCD))

        expect(self.cpu.getMem(0xABCD)).to(equal(0x00))
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
    }

    func testASLAbsoluteSetsNFlag() {
        self.cpu.setMem(0xABCD, value: 0x40)

        _ = self.cpu.opASL(AddressingMode.absolute(0xABCD))

        expect(self.cpu.getMem(0xABCD)).to(equal(0x80))
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
    }

    func testASLAbsoluteShiftsOutZero() {
        self.cpu.setMem(0xABCD, value: 0x7F)

        _ = self.cpu.opASL(AddressingMode.absolute(0xABCD))
        
        expect(self.cpu.getMem(0xABCD)).to(equal(0xFE))
        expect(self.cpu.registers.getCarryFlag()).to(beFalse())
    }

    func testASLAbsoluteShiftsOutOne() {
        self.cpu.setMem(0xABCD, value: 0xFF)

        _ = self.cpu.opASL(AddressingMode.absolute(0xABCD))

        expect(self.cpu.getMem(0xABCD)).to(equal(0xFE))
        expect(self.cpu.registers.getCarryFlag()).to(beTrue())
    }

    func testASLAbsolute80SetsZFlag() {
        self.cpu.setMem(0xABCD, value: 0x80)

        _ = self.cpu.opASL(AddressingMode.absolute(0xABCD))

        expect(self.cpu.getMem(0xABCD)).to(equal(0x00))
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
    }
    
    /* AND Absolute */
    
    func testANDAbsoluteAllZerosSettingZeroFlag() {
        self.cpu.registers.a = 0xFF
        self.cpu.setMemFromHexString("2D CD AB", address: 0x0000)
        self.cpu.setMemFromHexString("00", address: 0xABCD)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0003))
        expect(self.cpu.registers.a).to(equal(0x0))
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
    }
    
    func testANDAbsoluteZerosAndOnesSettingNegativeFlag() {
        self.cpu.registers.a = 0xFF
        self.cpu.setMemFromHexString("2D CD AB", address: 0x0000)
        self.cpu.setMemFromHexString("AA", address: 0xABCD)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0003))
        expect(self.cpu.registers.a).to(equal(0xAA))
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
    }
    
    /* BEQ */
    
    func testBEQZeroSetBranchesRelativeForward() {
        self.cpu.registers.setZeroFlag(true)
        self.cpu.setMemFromHexString("F0 06", address: 0x0000)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002 + 0x06))
    }
    
    func testBEQZeroSetBranchesRelativeBackward() {
        self.cpu.registers.setZeroFlag(true)
        let rel = 0x06 ^ 0xFF + 1
        self.cpu.setMem(0x0050, value:0xF0)
        self.cpu.setMem(0x0051, value:UInt8(rel))
        self.cpu.setProgramCounter(0x0050)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(UInt16.subtractWithOverflow(0x0052, 6).0))
    }
    
    func testBEQZeroClearDoesNotBranch() {
        self.cpu.registers.setZeroFlag(false)
        self.cpu.setMemFromHexString("F0 06", address: 0x0000)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002))
    }
    
    /* BIT Absolute */
    
    func testBITAbsoluteCopiesBit7OfMemoryToNFlagWhen0() {
        self.cpu.registers.setSignFlag(false)
        self.cpu.setMemFromHexString("2C ED FE", address: 0x0000)
        self.cpu.setMem(0xFEED, value: 0xFF)
        self.cpu.registers.a = 0xFF
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
    }
    
    func testBITAbsoluteCopiesBit7OfMemoryToNFlagWhen1() {
        self.cpu.registers.setSignFlag(true)
        self.cpu.setMemFromHexString("2C ED FE", address: 0x0000)
        self.cpu.setMem(0xFEED, value: 0x00)
        self.cpu.registers.a = 0xFF
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
    }
    
    func testBITAbsoluteCopiesBit6OfMemoryToVFlagWhen0() {
        self.cpu.registers.setOverflowFlag(false)
        self.cpu.setMemFromHexString("2C ED FE", address: 0x0000)
        self.cpu.setMem(0xFEED, value: 0xFF)
        self.cpu.registers.a = 0xFF
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.registers.getOverflowFlag()).to(beTrue())
    }
    
    func testBITAbsoluteCopiesBit6OfMemoryToVFlagWhen1() {
        self.cpu.registers.setOverflowFlag(true)
        self.cpu.setMemFromHexString("2C ED FE", address: 0x0000)
        self.cpu.setMem(0xFEED, value: 0x00)
        self.cpu.registers.a = 0xFF
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.registers.getOverflowFlag()).to(beFalse())
    }
    
    func testBITAbsoluteStoresResultOfAndWhenZeroInZPreservesAWhen1()
    {
        self.cpu.registers.setZeroFlag(false)
        self.cpu.setMemFromHexString("2C ED FE", address: 0x0000)
        self.cpu.setMem(0xFEED, value: 0x00)
        self.cpu.registers.a = 0x01
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
        expect(self.cpu.registers.a).to(equal(0x01))
        expect(self.cpu.getMem(0xFEED)).to(equal(0x00))
    }
    
    func testBITAbsoluteStoresResultOfAndWhenNonZeroInZPreservesAWhen0()
    {
        self.cpu.registers.setZeroFlag(true)
        self.cpu.setMemFromHexString("2C ED FE", address: 0x0000)
        self.cpu.setMem(0xFEED, value: 0x01)
        self.cpu.registers.a = 0x01
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
        expect(self.cpu.registers.a).to(equal(0x01))
        expect(self.cpu.getMem(0xFEED)).to(equal(0x01))
    }
    
    /* BIT Zero Page */
    
    func testBITZeroPageCopiesBit7OfMemoryToNFlagWhen0()
    {
        self.cpu.registers.setSignFlag(false)
        self.cpu.setMemFromHexString("24 10", address: 0x0000)
        self.cpu.setMem(0x0010, value: 0xFF)
        self.cpu.registers.a = 0xFF
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.registers.pc).to(equal(0x0002))
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
    }
    
    func testBITZeroPageCopiesBit7OfMemoryToNFlagWhen1()
    {
        self.cpu.registers.setSignFlag(true)
        self.cpu.setMemFromHexString("24 10", address: 0x0000)
        self.cpu.setMem(0x0010, value: 0x00)
        self.cpu.registers.a = 0xFF
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.registers.pc).to(equal(0x0002))
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
    }
    
    func testBITZeroPageCopiesBit6OfMemoryToVFlagWhen0()
    {
        self.cpu.registers.setOverflowFlag(false)
        self.cpu.setMemFromHexString("24 10", address: 0x0000)
        self.cpu.setMem(0x0010, value: 0xFF)
        self.cpu.registers.a = 0xFF
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.registers.pc).to(equal(0x0002))
        expect(self.cpu.registers.getOverflowFlag()).to(beTrue())
    }
    
    func testBITZeroPageCopiesBit6OfMemoryToVFlagWhen1()
    {
        self.cpu.registers.setOverflowFlag(true)
        self.cpu.setMemFromHexString("24 10", address: 0x0000)
        self.cpu.setMem(0x0010, value: 0x00)
        self.cpu.registers.a = 0xFF
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.registers.pc).to(equal(0x0002))
        expect(self.cpu.registers.getOverflowFlag()).to(beFalse())
    }
    
    func testBITZeroPageStoresResultOfAndInZPreservesAWhen1()
    {
        self.cpu.registers.setZeroFlag(false)
        self.cpu.setMemFromHexString("24 10", address: 0x0000)
        self.cpu.setMem(0x0010, value: 0x00)
        self.cpu.registers.a = 0x01
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.registers.pc).to(equal(0x0002))
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
        expect(self.cpu.registers.a).to(equal(0x01))
        expect(self.cpu.getMem(0x0010)).to(equal(0x00))
    }

    func testBITZeroPageStoresResultOfAndWhenNonZeroInZPreservesA()
    {
        self.cpu.registers.setZeroFlag(true)
        self.cpu.setMemFromHexString("24 10", address: 0x0000)
        self.cpu.setMem(0x0010, value: 0x01)
        self.cpu.registers.a = 0x01
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.registers.pc).to(equal(0x0002))
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
        expect(self.cpu.registers.a).to(equal(0x01))
        expect(self.cpu.getMem(0x0010)).to(equal(0x01))
    }
    
    func testBITZeroPageStoresResultOfAndWhenZeroInZPreservesA()
    {
        self.cpu.registers.setZeroFlag(false)
        self.cpu.setMemFromHexString("24 10", address: 0x0000)
        self.cpu.setMem(0x0010, value: 0x00)
        self.cpu.registers.a = 0x01
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.registers.pc).to(equal(0x0002))
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
        expect(self.cpu.registers.a).to(equal(0x01))
        expect(self.cpu.getMem(0x0010)).to(equal(0x00))
    }
    
    /* BMI */
    
    func testBMINegativeSetBranchesRelativeForward() {
        self.cpu.registers.setSignFlag(true)
        self.cpu.setMemFromHexString("30 06", address: 0x0000)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002 + 0x006))
    }
    
    func testBMINegativeSetBranchesRelativeBackward() {
        self.cpu.registers.setSignFlag(true)
        let rel = 0x06 ^ 0xFF + 1
        self.cpu.setMem(0x0050, value:0x30)
        self.cpu.setMem(0x0051, value:UInt8(rel))
        self.cpu.setProgramCounter(0x0050)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(UInt16.subtractWithOverflow(0x0052, 6).0))
    }
    
    func testBMINegativeClearDoesNotBranch() {
        self.cpu.registers.setSignFlag(false)
        
        self.cpu.setMemFromHexString("30 06", address: 0x0000)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002))
    }
    
    /* BNE */
    
    func testBNEZeroClearBranchesRelativeForward() {
        self.cpu.registers.setZeroFlag(false)
        self.cpu.setMemFromHexString("D0 06", address: 0x0000)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002 + 0x006))
    }
    
    func testBNEZeroClearBranchesRelativeBackward() {
        self.cpu.registers.setZeroFlag(false)
        let rel = 0x06 ^ 0xFF + 1
        self.cpu.setMem(0x0050, value:0xD0)
        self.cpu.setMem(0x0051, value:UInt8(rel))
        self.cpu.setProgramCounter(0x0050)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(UInt16.subtractWithOverflow(0x0052, 6).0))
    }
    
    func testBNEZeroSetDoesNotBranch() {
        self.cpu.registers.setZeroFlag(true)
        
        self.cpu.setMemFromHexString("D0 06", address: 0x0000)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002))
    }
    
    /* BPL */
    
    func testBPLNegativeClearBranchesRelativeForward() {
        self.cpu.registers.setSignFlag(false)
        self.cpu.setMemFromHexString("10 06", address: 0x0000)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002 + 0x006))
    }
    
    func testBPLNegativeClearBranchesRelativeBackward() {
        self.cpu.registers.setSignFlag(false)
        let rel = 0x06 ^ 0xFF + 1
        self.cpu.setMem(0x0050, value:0x10)
        self.cpu.setMem(0x0051, value:UInt8(rel))
        self.cpu.setProgramCounter(0x0050)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(UInt16.subtractWithOverflow(0x0052, 6).0))
    }
    
    func testBPLNegativeSetDoesNotBranch() {
        self.cpu.registers.setSignFlag(true)
        
        self.cpu.setMemFromHexString("10 06", address: 0x0000)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002))
    }
    
    /* BRK */
    
    func testBRKPushesPCPlus2AndStatusThenSetsPCToIRQVector() {
        self.cpu.registers.setStatusByte(0x00)
        
        self.cpu.setMemFromHexString("CD AB", address: 0xFFFE)
        self.cpu.setMem(0xC000, value: 0x00)
        self.cpu.setProgramCounter(0xC000)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0xABCD))
        
        expect(self.cpu.getMem(0x01FF)).to(equal(0xC0))
        expect(self.cpu.getMem(0x01FE)).to(equal(0x02))
        expect(self.cpu.getMem(0x01FD)).to(equal(0x30))
        
        expect(self.cpu.registers.getBreakFlag()).to(beTrue())
        expect(self.cpu.registers.getInterruptFlag()).to(beTrue())
    }
    
    /* BVC */
    
    func testBVCOverflowClearBranchesRelativeForward() {
        self.cpu.registers.setOverflowFlag(false)
        self.cpu.setMemFromHexString("50 06", address: 0x0000)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002 + 0x006))
    }
    
    func testBVCOverflowClearBranchesRelativeBackward() {
        self.cpu.registers.setOverflowFlag(false)
        let rel = 0x06 ^ 0xFF + 1
        self.cpu.setMem(0x0050, value:0x50)
        self.cpu.setMem(0x0051, value:UInt8(rel))
        self.cpu.setProgramCounter(0x0050)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(UInt16.subtractWithOverflow(0x0052, 6).0))
    }
    
    func testBVCOverflowSetDoesNotBranch() {
        self.cpu.registers.setOverflowFlag(true)
        
        self.cpu.setMemFromHexString("50 06", address: 0x0000)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002))
    }
    
    /* BVS */
    
    func testBVSOverflowSetBranchesRelativeForward() {
        self.cpu.registers.setOverflowFlag(true)
        self.cpu.setMemFromHexString("70 06", address: 0x0000)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002 + 0x006))
    }
    
    func testBVSOverflowSetBranchesRelativeBackward() {
        self.cpu.registers.setOverflowFlag(true)
        let rel = 0x06 ^ 0xFF + 1
        self.cpu.setMem(0x0050, value:0x70)
        self.cpu.setMem(0x0051, value:UInt8(rel))
        self.cpu.setProgramCounter(0x0050)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(UInt16.subtractWithOverflow(0x0052, 6).0))
    }
    
    func testBVSOverflowClearDoesNotBranch() {
        self.cpu.registers.setOverflowFlag(false)
        
        self.cpu.setMemFromHexString("70 06", address: 0x0000)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002))
    }
    
    /* CLC */
    func testCLCClearsCarryFlag() {
        self.cpu.registers.setCarryFlag(true)
        self.cpu.setMem(0x0000, value: 0x18)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0001))
        expect(self.cpu.registers.getCarryFlag()).to(beFalse())
    }
    
    /* CLD */
    func testCLDClearsDecimalFlag() {
        self.cpu.registers.setDecimalFlag(true)
        self.cpu.setMem(0x0000, value: 0xD8)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0001))
        expect(self.cpu.registers.getDecimalFlag()).to(beFalse())
    }
    
    /* CLI */
    func testCLIClearsInterruptFlag() {
        self.cpu.registers.setInterruptFlag(true)
        self.cpu.setMem(0x0000, value: 0x58)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0001))
        expect(self.cpu.registers.getInterruptFlag()).to(beFalse())
    }
    
    /* CLV */
    func testCLVClearsOverflowFlag() {
        self.cpu.registers.setOverflowFlag(true)
        self.cpu.setMem(0x0000, value: 0xB8)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0001))
        expect(self.cpu.registers.getOverflowFlag()).to(beFalse())
    }
    
    /* DEC Absolute */
    
    func testDECAbsoluteDecrementsMemory() {
        self.cpu.setMemFromHexString("CE CD AB", address: 0x0000)
        self.cpu.setMem(0xABCD, value: 0x10)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0003))
        expect(self.cpu.getMem(0xABCD)).to(equal(0x0F))
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }
    
    func testDECAbsoluteBelow0RollsOverAndSetsNegativeFlag() {
        self.cpu.setMemFromHexString("CE CD AB", address: 0x0000)
        self.cpu.setMem(0xABCD, value: 0x00)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0003))
        expect(self.cpu.getMem(0xABCD)).to(equal(0xFF))
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }
    
    func testDECAbsoluteSetsZeroFlagWhenDecrementingToZero() {
        self.cpu.setMemFromHexString("CE CD AB", address: 0x0000)
        self.cpu.setMem(0xABCD, value: 0x01)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0003))
        expect(self.cpu.getMem(0xABCD)).to(equal(0x00))
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
    }
    
    /* DEC ZP */
    
    func testDECZeroPageDecrementsMemory() {
        self.cpu.setMemFromHexString("C6 10", address: 0x0000)
        self.cpu.setMem(0x0010, value: 0x10)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002))
        expect(self.cpu.getMem(0x0010)).to(equal(0x0F))
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }
    
    func testDECZeroPageBelow0RollsOverAndSetsNegativeFlag() {
        self.cpu.setMemFromHexString("C6 10", address: 0x0000)
        self.cpu.setMem(0x0010, value: 0x00)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002))
        expect(self.cpu.getMem(0x0010)).to(equal(0xFF))
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }
    
    func testDECZeroPageSetsZeroFlagWhenDecrementingToZero() {
        self.cpu.setMemFromHexString("C6 10", address: 0x0000)
        self.cpu.setMem(0x0010, value: 0x01)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002))
        expect(self.cpu.getMem(0x0010)).to(equal(0x00))
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
    }
    
    /* DEC Absolute X Indexed */
    
    func testDECAbsoluteXDecrementsMemory() {
        self.cpu.setMemFromHexString("DE CD AB", address: 0x0000)
        self.cpu.registers.x = 0x03
        self.cpu.setMem(0xABCD + 0x03, value: 0x10)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0003))
        expect(self.cpu.getMem(0xABCD + 0x03)).to(equal(0x0F))
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }
    
    func testDECAbsoluteXBelow0RollsOverAndSetsNegativeFlag() {
        self.cpu.setMemFromHexString("DE CD AB", address: 0x0000)
        self.cpu.registers.x = 0x03
        self.cpu.setMem(0xABCD + 0x03, value: 0x00)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0003))
        expect(self.cpu.getMem(0xABCD + 0x03)).to(equal(0xFF))
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }
    
    func testDECAbsoluteXSetsZeroFlagWhenDecrementingToZero() {
        self.cpu.setMemFromHexString("DE CD AB", address: 0x0000)
        self.cpu.registers.x = 0x03
        self.cpu.setMem(0xABCD + 0x03, value: 0x01)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0003))
        expect(self.cpu.getMem(0xABCD + 0x03)).to(equal(0x00))
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
    }
    
    /* DEC ZP X Indexed */
    
    func testDECXZeroPageDecrementsMemory() {
        self.cpu.setMemFromHexString("D6 10", address: 0x0000)
        self.cpu.registers.x = 0x03
        self.cpu.setMem(0x0010 + 0x03, value: 0x10)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002))
        expect(self.cpu.getMem(0x0010 + 0x03)).to(equal(0x0F))
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }
    
    func testDECXZeroPageBelow0RollsOverAndSetsNegativeFlag() {
        self.cpu.setMemFromHexString("D6 10", address: 0x0000)
        self.cpu.registers.x = 0x03
        self.cpu.setMem(0x0010 + 0x03, value: 0x00)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002))
        expect(self.cpu.getMem(0x0010 + 0x03)).to(equal(0xFF))
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }
    
    func testDECXZeroPageSetsZeroFlagWhenDecrementingToZero() {
        self.cpu.setMemFromHexString("D6 10", address: 0x0000)
        self.cpu.registers.x = 0x03
        self.cpu.setMem(0x0010 + 0x03, value: 0x01)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002))
        expect(self.cpu.getMem(0x0010 + 0x03)).to(equal(0x00))
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
    }
    
    /* DEX */
    
    func testDEXDecrementsX() {
        self.cpu.registers.x = 0x10
        self.cpu.setMemFromHexString("CA", address: 0x0000)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0001))
        expect(self.cpu.registers.x).to(equal(0x0F))
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }
    
    func testDEXBelow0RollsOverAndSetsNegativeFlag() {
        self.cpu.registers.x = 0x00
        self.cpu.setMemFromHexString("CA", address: 0x0000)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0001))
        expect(self.cpu.registers.x).to(equal(0xFF))
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }
    
    func testDEXSetsZeroFlagWhenDecrementingToZero() {
        self.cpu.registers.x = 0x01
        self.cpu.setMemFromHexString("CA", address: 0x0000)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0001))
        expect(self.cpu.registers.x).to(equal(0x00))
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
    }
    
    /* DEY */
    
    func testDEYDecrementsY() {
        self.cpu.registers.y = 0x10
        self.cpu.setMemFromHexString("88", address: 0x0000)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0001))
        expect(self.cpu.registers.y).to(equal(0x0F))
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }
    
    func testDEYBelow0RollsOverAndSetsNegativeFlag() {
        self.cpu.registers.y = 0x00
        self.cpu.setMemFromHexString("88", address: 0x0000)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0001))
        expect(self.cpu.registers.y).to(equal(0xFF))
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }
    
    func testDEYSetsZeroFlagWhenDecrementingToZero() {
        self.cpu.registers.y = 0x01
        self.cpu.setMemFromHexString("88", address: 0x0000)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0001))
        expect(self.cpu.registers.y).to(equal(0x00))
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
    }
    
    /* EOR Absolute */
    
    func testEORAbsoluteFlipsBitsOverSettingZFlag() {
        self.cpu.setMemFromHexString("4D CD AB", address: 0x0000)
        self.cpu.registers.a = 0xFF
        self.cpu.setMem(0xABCD, value: 0xFF)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0003))
        expect(self.cpu.registers.a).to(equal(0x00))
        expect(self.cpu.getMem(0xABCD)).to(equal(0xFF))
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
    }
    
    func testEORAbsoluteFlipsBitsOverSettingNFlag() {
        self.cpu.setMemFromHexString("4D CD AB", address: 0x0000)
        self.cpu.registers.a = 0x00
        self.cpu.setMem(0xABCD, value: 0xFF)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0003))
        expect(self.cpu.registers.a).to(equal(0xFF))
        expect(self.cpu.getMem(0xABCD)).to(equal(0xFF))
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }
    
    /* EOR ZP */
    
    func testEORZPFlipsBitsOverSettingZFlag() {
        self.cpu.setMemFromHexString("45 10", address: 0x0000)
        self.cpu.registers.a = 0xFF
        self.cpu.setMem(0x10, value: 0xFF)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002))
        expect(self.cpu.registers.a).to(equal(0x00))
        expect(self.cpu.getMem(0x10)).to(equal(0xFF))
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
    }
    
    func testEORZPFlipsBitsOverSettingNFlag() {
        self.cpu.setMemFromHexString("45 10", address: 0x0000)
        self.cpu.registers.a = 0x00
        self.cpu.setMem(0x10, value: 0xFF)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002))
        expect(self.cpu.registers.a).to(equal(0xFF))
        expect(self.cpu.getMem(0x10)).to(equal(0xFF))
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }
    
    /* EOR Immediate */
    
    func testEORImmediateFlipsBitsOverSettingZFlag() {
        self.cpu.setMemFromHexString("49 FF", address: 0x0000)
        self.cpu.registers.a = 0xFF
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002))
        expect(self.cpu.registers.a).to(equal(0x00))
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
    }
    
    func testEORImmediateFlipsBitsOverSettingNFlag() {
        self.cpu.setMemFromHexString("49 FF", address: 0x0000)
        self.cpu.registers.a = 0x00
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002))
        expect(self.cpu.registers.a).to(equal(0xFF))
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }
    
    /* EOR Absolute X Indexed */
    
    func testEORAbsoluteXFlipsBitsOverSettingZFlag() {
        self.cpu.setMemFromHexString("5D CD AB", address: 0x0000)
        self.cpu.registers.a = 0xFF
        self.cpu.registers.x = 0x03
        self.cpu.setMem(0xABCD + 0x03, value: 0xFF)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0003))
        expect(self.cpu.registers.a).to(equal(0x00))
        expect(self.cpu.getMem(0xABCD + 0x03)).to(equal(0xFF))
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
    }
    
    func testEORAbsoluteXFlipsBitsOverSettingNFlag() {
        self.cpu.setMemFromHexString("5D CD AB", address: 0x0000)
        self.cpu.registers.a = 0x00
        self.cpu.registers.x = 0x03
        self.cpu.setMem(0xABCD + 0x03, value: 0xFF)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0003))
        expect(self.cpu.registers.a).to(equal(0xFF))
        expect(self.cpu.getMem(0xABCD + 0x03)).to(equal(0xFF))
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }
    
    /* EOR Absolute Y Indexed */
    
    func testEORAbsoluteYFlipsBitsOverSettingZFlag() {
        self.cpu.setMemFromHexString("59 CD AB", address: 0x0000)
        self.cpu.registers.a = 0xFF
        self.cpu.registers.y = 0x03
        self.cpu.setMem(0xABCD + 0x03, value: 0xFF)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0003))
        expect(self.cpu.registers.a).to(equal(0x00))
        expect(self.cpu.getMem(0xABCD + 0x03)).to(equal(0xFF))
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
    }
    
    func testEORAbsoluteYFlipsBitsOverSettingNFlag() {
        self.cpu.setMemFromHexString("59 CD AB", address: 0x0000)
        self.cpu.registers.a = 0x00
        self.cpu.registers.y = 0x03
        self.cpu.setMem(0xABCD + 0x03, value: 0xFF)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0003))
        expect(self.cpu.registers.a).to(equal(0xFF))
        expect(self.cpu.getMem(0xABCD + 0x03)).to(equal(0xFF))
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }
    
    
    /* EOR Indirect X Indexed */
    
    func testEORIndirectXFlipsBitsOverSettingZFlag() {
        self.cpu.setMemFromHexString("41 10", address: 0x0000)
        self.cpu.setMemFromHexString("CD AB", address: 0x0013)
        self.cpu.registers.a = 0xFF
        self.cpu.registers.x = 0x03
        self.cpu.setMem(0xABCD, value: 0xFF)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002))
        expect(self.cpu.registers.a).to(equal(0x00))
        expect(self.cpu.getMem(0xABCD)).to(equal(0xFF))
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
    }
    
    func testEORIndirectXFlipsBitsOverSettingNFlag() {
        self.cpu.setMemFromHexString("41 10", address: 0x0000)
        self.cpu.setMemFromHexString("CD AB", address: 0x0013)
        self.cpu.registers.a = 0x00
        self.cpu.registers.x = 0x03
        self.cpu.setMem(0xABCD, value: 0xFF)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002))
        expect(self.cpu.registers.a).to(equal(0xFF))
        expect(self.cpu.getMem(0xABCD)).to(equal(0xFF))
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }
    
    /* EOR Indirect Y Indexed */
    
    func testEORIndirectYFlipsBitsOverSettingZFlag() {
        self.cpu.setMemFromHexString("51 10", address: 0x0000)
        self.cpu.setMemFromHexString("CD AB", address: 0x0010)
        self.cpu.registers.a = 0xFF
        self.cpu.registers.y = 0x03
        self.cpu.setMem(0xABCD + 0x03, value: 0xFF)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002))
        expect(self.cpu.registers.a).to(equal(0x00))
        expect(self.cpu.getMem(0xABCD + 0x03)).to(equal(0xFF))
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
    }
    
    func testEORIndirectYFlipsBitsOverSettingNFlag() {
        self.cpu.setMemFromHexString("51 10", address: 0x0000)
        self.cpu.setMemFromHexString("CD AB", address: 0x0010)
        self.cpu.registers.a = 0x00
        self.cpu.registers.y = 0x03
        self.cpu.setMem(0xABCD + 0x03, value: 0xFF)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002))
        expect(self.cpu.registers.a).to(equal(0xFF))
        expect(self.cpu.getMem(0xABCD + 0x03)).to(equal(0xFF))
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }
    
    /* EOR ZP X Indexed */
    
    func testZPXFlipsBitsOverSettingZFlag() {
        self.cpu.setMemFromHexString("55 10", address: 0x0000)
        self.cpu.setMemFromHexString("FF", address: 0x0013)
        self.cpu.registers.a = 0xFF
        self.cpu.registers.x = 0x03
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002))
        expect(self.cpu.registers.a).to(equal(0x00))
        expect(self.cpu.getMem(0x0010 + 0x03)).to(equal(0xFF))
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
    }
    
    func testEORZPXFlipsBitsOverSettingNFlag() {
        self.cpu.setMemFromHexString("55 10", address: 0x0000)
        self.cpu.setMemFromHexString("FF", address: 0x0013)
        self.cpu.registers.a = 0x00
        self.cpu.registers.x = 0x03
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002))
        expect(self.cpu.registers.a).to(equal(0xFF))
        expect(self.cpu.getMem(0x0010 + 0x03)).to(equal(0xFF))
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }

    
    /* INC Absolute */
    
    func testINCAbsoluteIncrementsMemory() {
        self.cpu.setMemFromHexString("EE CD AB", address: 0x0000)
        self.cpu.setMem(0xABCD, value: 0x09)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0003))
        expect(self.cpu.getMem(0xABCD)).to(equal(0x0A))
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
    }
    
    func testINCAbsoluteIncrementsMemoryRollsOverAndSetsZeroFlag() {
        self.cpu.setMemFromHexString("EE CD AB", address: 0x0000)
        self.cpu.setMem(0xABCD, value: 0xFF)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0003))
        expect(self.cpu.getMem(0xABCD)).to(equal(0x00))
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
    }
    
    func testINCAbsoluteSetsNegativeFlagWhenIncrementingAbove7F() {
        self.cpu.setMemFromHexString("EE CD AB", address: 0x0000)
        self.cpu.setMem(0xABCD, value: 0x7F)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0003))
        expect(self.cpu.getMem(0xABCD)).to(equal(0x80))
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
    }
    
    /* INC ZP */
    
    func testINCZPIncrementsMemory() {
        self.cpu.setMemFromHexString("E6 10", address: 0x0000)
        self.cpu.setMem(0x0010, value: 0x09)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002))
        expect(self.cpu.getMem(0x0010)).to(equal(0x0A))
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
    }
    
    func testINCZPIncrementsMemoryRollsOverAndSetsZeroFlag() {
        self.cpu.setMemFromHexString("E6 10", address: 0x0000)
        self.cpu.setMem(0x0010, value: 0xFF)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002))
        expect(self.cpu.getMem(0x0010)).to(equal(0x00))
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
    }
    
    func testINCZPSetsNegativeFlagWhenIncrementingAbove7F() {
        self.cpu.setMemFromHexString("E6 10", address: 0x0000)
        self.cpu.setMem(0x0010, value: 0x7F)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002))
        expect(self.cpu.getMem(0x0010)).to(equal(0x80))
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
    }
    
    /* INC Absolute X */
    
    func testINCAbsoluteXIncrementsMemory() {
        self.cpu.setMemFromHexString("FE CD AB", address: 0x0000)
        self.cpu.setMem(0xABCD + 0x03, value: 0x09)
        self.cpu.registers.x = 0x03
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0003))
        expect(self.cpu.getMem(0xABCD + 0x03)).to(equal(0x0A))
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
    }
    
    func testINCAbsoluteXIncrementsMemoryRollsOverAndSetsZeroFlag() {
        self.cpu.setMemFromHexString("FE CD AB", address: 0x0000)
        self.cpu.setMem(0xABCD + 0x03, value: 0xFF)
        self.cpu.registers.x = 0x03
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0003))
        expect(self.cpu.getMem(0xABCD)).to(equal(0x00))
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
    }
    
    func testINCAbsoluteXSetsNegativeFlagWhenIncrementingAbove7F() {
        self.cpu.setMemFromHexString("FE CD AB", address: 0x0000)
        self.cpu.setMem(0xABCD + 0x03, value: 0x7F)
        self.cpu.registers.x = 0x03
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0003))
        expect(self.cpu.getMem(0xABCD + 0x03)).to(equal(0x80))
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
    }
    
    
    /* INC ZP X */
    
    func testINCZPXIncrementsMemory() {
        self.cpu.setMemFromHexString("F6 10", address: 0x0000)
        self.cpu.setMem(0x0010 + 0x03, value: 0x09)
        self.cpu.registers.x = 0x03
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002))
        expect(self.cpu.getMem(0x0010 + 0x03)).to(equal(0x0A))
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
    }
    
    func testINCZPXIncrementsMemoryRollsOverAndSetsZeroFlag() {
        self.cpu.setMemFromHexString("F6 10", address: 0x0000)
        self.cpu.setMem(0x0010 + 0x03, value: 0xFF)
        self.cpu.registers.x = 0x03
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002))
        expect(self.cpu.getMem(0x0010 + 0x03)).to(equal(0x00))
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
    }
    
    func testINCZPXSetsNegativeFlagWhenIncrementingAbove7F() {
        self.cpu.setMemFromHexString("F6 10", address: 0x0000)
        self.cpu.setMem(0x0010 + 0x03, value: 0x7F)
        self.cpu.registers.x = 0x03
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002))
        expect(self.cpu.getMem(0x0010 + 0x03)).to(equal(0x80))
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
    }
    
    /* INX */
    
    func testINXIncrementsX() {
        self.cpu.setMemFromHexString("E8", address: 0x0000)
        self.cpu.registers.x = 0x09
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0001))
        expect(self.cpu.registers.x).to(equal(0x0A))
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
    }
    
    func testINXAboveFFRollsOverAndSetsZeroFlag() {
        self.cpu.setMemFromHexString("E8", address: 0x0000)
        self.cpu.registers.x = 0xFF
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0001))
        expect(self.cpu.registers.x).to(equal(0x00))
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
    }
    
    func testINXSetsNegativeFlagWhenIncrementingAbove7F() {
        self.cpu.setMemFromHexString("E8", address: 0x0000)
        self.cpu.registers.x = 0x7F
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0001))
        expect(self.cpu.registers.x).to(equal(0x80))
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
    }
    
    
    /* INY */
    
    func testINYIncrementsY() {
        self.cpu.setMemFromHexString("C8", address: 0x0000)
        self.cpu.registers.y = 0x09
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0001))
        expect(self.cpu.registers.y).to(equal(0x0A))
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
    }
    
    func testINYAboveFFRollsOverAndSetsZeroFlag() {
        self.cpu.setMemFromHexString("C8", address: 0x0000)
        self.cpu.registers.y = 0xFF
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0001))
        expect(self.cpu.registers.y).to(equal(0x00))
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
    }
    
    func testINYSetsNegativeFlagWhenIncrementingAbove7F() {
        self.cpu.setMemFromHexString("C8", address: 0x0000)
        self.cpu.registers.y = 0x7F
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0001))
        expect(self.cpu.registers.y).to(equal(0x80))
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
    }


    /* JMP Absolute */
    
    func testJMPAbsoluteJumpsToAbsoluteAddress() {
        self.cpu.setMemFromHexString("4C CD AB", address: 0x0000)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0xABCD))
    }
    
    /* JMP Indirect */
    
    func testJMPIndirectJumpsToIndirectAddress() {
        self.cpu.setMemFromHexString("6C 00 02", address: 0x0000)
        self.cpu.setMemFromHexString("CD AB", address: 0x0200)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0xABCD))
    }

    /* JSR */

    func testJSRPushesPCPlus2AndSetsPC() {
        self.cpu.setMemFromHexString("20 D2 FF", address:0xC000)
        self.cpu.setProgramCounter(0xC000)
        _ = self.cpu.runCycles(1)

        expect(self.cpu.registers.pc).to(equal(0xFFD2))
        expect(self.cpu.getStackPointer()).to(equal(0xFD))
        expect(self.mem[0x01FF]).to(equal(0xC0))
        expect(self.mem[0x01FE]).to(equal(0x02))
    }
    
    
    /* LDA Absolute */
    
    func testLDAAbsoluteLoadsASetsNFlag() {
        self.cpu.registers.a = 0x00
        self.cpu.setMemFromHexString("AD CD AB", address: 0x0000)
        self.cpu.setMemFromHexString("80", address: 0xABCD)
        _ = cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0003))
        expect(self.cpu.registers.a).to(equal(0x80))
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }
    
    func testLDAAbsoluteLoadsASetsZFlag() {
        self.cpu.registers.a = 0x00
        self.cpu.setMemFromHexString("AD CD AB", address: 0x0000)
        self.cpu.setMemFromHexString("00", address: 0xABCD)
        _ = cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0003))
        expect(self.cpu.registers.a).to(equal(0x00))
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
    }
    
    
    /* LDA ZP */
    
    func testLDAZPLoadsASetsNFlag() {
        self.cpu.registers.a = 0x00
        self.cpu.setMemFromHexString("A5 10", address: 0x0000)
        self.cpu.setMemFromHexString("80", address: 0x0010)
        _ = cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002))
        expect(self.cpu.registers.a).to(equal(0x80))
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }
    
    func testLDAZPLoadsASetsZFlag() {
        self.cpu.registers.a = 0x00
        self.cpu.setMemFromHexString("A5 10", address: 0x0000)
        self.cpu.setMemFromHexString("00", address: 0x0010)
        _ = cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002))
        expect(self.cpu.registers.a).to(equal(0x00))
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
    }
    
    
    /* LDA Immediate */
    
    func testLDAImmediateLoadsASetsNFlag() {
        self.cpu.registers.a = 0x00
        self.cpu.setMemFromHexString("A9 80", address: 0x0000)
        _ = cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002))
        expect(self.cpu.registers.a).to(equal(0x80))
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }
    
    func testLDAImmediateLoadsASetsZFlag() {
        self.cpu.registers.a = 0x00
        self.cpu.setMemFromHexString("A9 00", address: 0x0000)
        _ = cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002))
        expect(self.cpu.registers.a).to(equal(0x00))
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
    }
    
    
    /* LDA Absolute X */
    
    func testLDAAbsoluteXLoadsASetsNFlag() {
        self.cpu.registers.a = 0x00
        self.cpu.registers.x = 0x03
        self.cpu.setMemFromHexString("BD CD AB", address: 0x0000)
        self.cpu.setMemFromHexString("80", address: 0xABCD + 0x03)
        _ = cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0003))
        expect(self.cpu.registers.a).to(equal(0x80))
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }
    
    func testLDAAbsoluteXLoadsASetsZFlag() {
        self.cpu.registers.a = 0x00
        self.cpu.registers.x = 0x03
        self.cpu.setMemFromHexString("BD CD AB", address: 0x0000)
        self.cpu.setMemFromHexString("00", address: 0xABCD + 0x03)
        _ = cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0003))
        expect(self.cpu.registers.a).to(equal(0x00))
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
    }
    
    func testLDAAbsoluteXDoesNotPageWrap() {
        self.cpu.registers.a = 0x00
        self.cpu.registers.x = 0xFF
        self.cpu.setMemFromHexString("BD 80 00", address: 0x0000)
        self.cpu.setMemFromHexString("42", address: 0x0080 + 0xFF)
        _ = cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0003))
        expect(self.cpu.registers.a).to(equal(0x42))
    }
    
    
    /* LDA Absolute Y */
    
    func testLDAAbsoluteYLoadsASetsNFlag() {
        self.cpu.registers.a = 0x00
        self.cpu.registers.y = 0x03
        self.cpu.setMemFromHexString("B9 CD AB", address: 0x0000)
        self.cpu.setMemFromHexString("80", address: 0xABCD + 0x03)
        _ = cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0003))
        expect(self.cpu.registers.a).to(equal(0x80))
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }
    
    func testLDAAbsoluteYLoadsASetsZFlag() {
        self.cpu.registers.a = 0x00
        self.cpu.registers.y = 0x03
        self.cpu.setMemFromHexString("B9 CD AB", address: 0x0000)
        self.cpu.setMemFromHexString("00", address: 0xABCD + 0x03)
        _ = cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0003))
        expect(self.cpu.registers.a).to(equal(0x00))
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
    }
    
    func testLDAAbsoluteYDoesNotPageWrap() {
        self.cpu.registers.a = 0x00
        self.cpu.registers.y = 0xFF
        self.cpu.setMemFromHexString("B9 80 00", address: 0x0000)
        self.cpu.setMemFromHexString("42", address: 0x0080 + 0xFF)
        _ = cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0003))
        expect(self.cpu.registers.a).to(equal(0x42))
    }
    
    /* LDA Indirect X */
    
    func testLDAIndirectXLoadsASetsNFlag() {
        self.cpu.registers.a = 0x00
        self.cpu.registers.x = 0x03
        self.cpu.setMemFromHexString("A1 10", address: 0x0000)
        self.cpu.setMemFromHexString("CD AB", address: 0x0013)
        self.cpu.setMemFromHexString("80", address: 0xABCD)
        _ = cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002))
        expect(self.cpu.registers.a).to(equal(0x80))
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }
    
    func testLDAIndirectXLoadsASetsZFlag() {
        self.cpu.registers.a = 0x00
        self.cpu.registers.x = 0x03
        self.cpu.setMemFromHexString("A1 10", address: 0x0000)
        self.cpu.setMemFromHexString("CD AB", address: 0x0013)
        self.cpu.setMemFromHexString("00", address: 0xABCD)
        _ = cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002))
        expect(self.cpu.registers.a).to(equal(0x00))
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
    }
    
    
    /* LDA Indirect Y */
    
    func testLDAIndirectYLoadsASetsNFlag() {
        self.cpu.registers.a = 0x00
        self.cpu.registers.y = 0x03
        self.cpu.setMemFromHexString("B1 10", address: 0x0000)
        self.cpu.setMemFromHexString("CD AB", address: 0x0010)
        self.cpu.setMemFromHexString("80", address: 0xABCD + 0x03)
        _ = cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002))
        expect(self.cpu.registers.a).to(equal(0x80))
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }
    
    func testLDAIndirectYLoadsASetsZFlag() {
        self.cpu.registers.a = 0x00
        self.cpu.registers.y = 0x03
        self.cpu.setMemFromHexString("B1 10", address: 0x0000)
        self.cpu.setMemFromHexString("CD AB", address: 0x0010)
        self.cpu.setMemFromHexString("00", address: 0xABCD + 0x03)
        _ = cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002))
        expect(self.cpu.registers.a).to(equal(0x00))
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
    }
    
    
    /* LDA ZP X */
    
    func testLDAZPXLoadsASetsNFlag() {
        self.cpu.registers.a = 0x00
        self.cpu.registers.x = 0x03
        self.cpu.setMemFromHexString("B5 10", address: 0x0000)
        self.cpu.setMemFromHexString("80", address: 0x0010 + 0x03)
        _ = cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002))
        expect(self.cpu.registers.a).to(equal(0x80))
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }
    
    func testLDAZPXLoadsASetsZFlag() {
        self.cpu.registers.a = 0x00
        self.cpu.registers.x = 0x03
        self.cpu.setMemFromHexString("B5 10", address: 0x0000)
        self.cpu.setMemFromHexString("00", address: 0x0010 + 0x03)
        _ = cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002))
        expect(self.cpu.registers.a).to(equal(0x00))
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
    }
    
    
    /* LDX Absolute */
    
    func testLDXAbsoluteLoadsXSetsNFlag() {
        self.cpu.registers.x = 0x00
        self.cpu.setMemFromHexString("AE CD AB", address: 0x0000)
        self.cpu.setMemFromHexString("80", address: 0xABCD)
        _ = cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0003))
        expect(self.cpu.registers.x).to(equal(0x80))
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }
    
    func testLDXAbsoluteLoadsXSetsZFlag() {
        self.cpu.registers.x = 0xFF
        self.cpu.setMemFromHexString("AE CD AB", address: 0x0000)
        self.cpu.setMemFromHexString("00", address: 0xABCD)
        _ = cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0003))
        expect(self.cpu.registers.x).to(equal(0x00))
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
    }
    
    
    /* LDX ZP */
    
    func testLDXZPLoadsXSetsNFlag() {
        self.cpu.registers.x = 0x00
        self.cpu.setMemFromHexString("A6 10", address: 0x0000)
        self.cpu.setMemFromHexString("80", address: 0x0010)
        _ = cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002))
        expect(self.cpu.registers.x).to(equal(0x80))
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }
    
    func testLDXZPLoadsXSetsZFlag() {
        self.cpu.registers.x = 0xFF
        self.cpu.setMemFromHexString("A6 10", address: 0x0000)
        self.cpu.setMemFromHexString("00", address: 0x0010)
        _ = cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002))
        expect(self.cpu.registers.x).to(equal(0x00))
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
    }
    
    
    /* LDX Immediate */
    
    func testLDXImmediateLoadsXSetsNFlag() {
        self.cpu.registers.x = 0x00
        self.cpu.setMemFromHexString("A2 80", address: 0x0000)
        _ = cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002))
        expect(self.cpu.registers.x).to(equal(0x80))
        expect(self.cpu.registers.getSignFlag()).to(beTrue())
        expect(self.cpu.registers.getZeroFlag()).to(beFalse())
    }
    
    func testLDXImmediateLoadsXSetsZFlag() {
        self.cpu.registers.x = 0xFF
        self.cpu.setMemFromHexString("A2 00", address: 0x0000)
        _ = cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0002))
        expect(self.cpu.registers.x).to(equal(0x00))
        expect(self.cpu.registers.getSignFlag()).to(beFalse())
        expect(self.cpu.registers.getZeroFlag()).to(beTrue())
    }

    
    /* PHA */
    
    func testPHAPushesAAndUpdatesSP() {
        self.cpu.registers.a = 0xAB
        self.cpu.setMemFromHexString("48", address: 0x0000)
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0001))
        expect(self.cpu.registers.a).to(equal(0xAB))
        expect(self.cpu.getMem(0x01FF)).to(equal(0xAB))
        expect(self.cpu.registers.s).to(equal(0xFE))
    }
    
    /* PHP */
    
    func testPHPPushesProcessorStatusAndUpdatesSP() {
        for flags in 0x00..<0x100 {
            let bf = UInt8(1 << 4)
            let unused = UInt8(1 << 5)
            
            self.cpu.reset()
            self.cpu.registers.setStatusByte(UInt8(flags) | bf | unused)
            
            self.cpu.setMemFromHexString("08", address: 0x0000)
            _ = cpu.runCycles(1)
            
            expect(self.cpu.getProgramCounter()).to(equal(0x0001))
            expect(self.cpu.getMem(0x1FF)).to(equal(UInt8(flags) | bf | unused))
            expect(self.cpu.registers.s).to(equal(0xFE))
        }
    }
    
    
    /* PLP */
    
    func testPLPPullsTopByteFromStackIntoAAndUpdatesSP() {
        self.cpu.setMemFromHexString("28", address: 0x0000)
        self.cpu.setMemFromHexString("BA", address: 0x01FF)
        self.cpu.registers.s = 0xFE
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0x0001))
        expect(self.cpu.registers.p).to(equal(0xBA))
        expect(self.cpu.registers.s).to(equal(0xFF))
    }

    
    /* RTS */
    
    func testRTS() {
        self.cpu.setMem(0x0000, value: 0x60)
        self.cpu.setMemFromHexString("03 C0", address:0x1FE)
        self.cpu.setProgramCounter(0x0)
        self.cpu.registers.s = 0xFD
        
        _ = self.cpu.runCycles(1)
        
        expect(self.cpu.getProgramCounter()).to(equal(0xC004))
        expect(self.cpu.registers.s).to(equal(0xFF))
    }
}
