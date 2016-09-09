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
import XCTest
import Nimble

class RegistersTests: XCTestCase {

    var registers:Registers = Registers()

    override func setUp() {
        super.setUp()
        registers = Registers()
    }

    override func tearDown() {
        super.tearDown()
    }

    // Mark - Status Register

    func testStatusRegisterDefaultState() {
        // Test default state
        expect(self.registers.p).to(equal(0b00100000))
    }

    func testStatusRegisterCarryFlag() {
        expect(self.registers.getCarryFlag()).to(equal(false))

        self.registers.setCarryFlag(true)

        expect(self.registers.p).to(equal(0b00100001))
        expect(self.registers.getCarryFlag()).to(beTrue())
    }

    func testStatusRegisterZeroFlag() {
        expect(self.registers.getZeroFlag()).to(equal(false))

        self.registers.setZeroFlag(true)

        expect(self.registers.p).to(equal(0b00100010))
        expect(self.registers.getZeroFlag()).to(beTrue())
    }

    func testStatusRegisterInterruptFlag() {
        expect(self.registers.getInterruptFlag()).to(equal(false))

        self.registers.setInterruptFlag(true)

        expect(self.registers.p).to(equal(0b00100100))
        expect(self.registers.getInterruptFlag()).to(beTrue())
    }

    func testStatusRegisterDecimalFlag() {
        expect(self.registers.getDecimalFlag()).to(equal(false))

        self.registers.setDecimalFlag(true)

        expect(self.registers.p).to(equal(0b00101000))
        expect(self.registers.getDecimalFlag()).to(beTrue())
    }

    func testStatusRegisterBreakFlag() {
        expect(self.registers.getBreakFlag()).to(equal(false))

        self.registers.setBreakFlag(true)

        expect(self.registers.p).to(equal(0b00110000))
        expect(self.registers.getBreakFlag()).to(beTrue())
    }

    func testStatusRegisterOverflowFlag() {
        expect(self.registers.getOverflowFlag()).to(equal(false))

        self.registers.setOverflowFlag(true)

        expect(self.registers.p).to(equal(0b01100000))
        expect(self.registers.getOverflowFlag()).to(beTrue())
    }

    func testStatusRegisterSignFlag() {
        expect(self.registers.getSignFlag()).to(equal(false))

        self.registers.setSignFlag(true)

        expect(self.registers.p).to(equal(0b10100000))
        expect(self.registers.getSignFlag()).to(beTrue())
    }

}
