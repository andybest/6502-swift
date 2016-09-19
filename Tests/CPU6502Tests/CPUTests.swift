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


class CPUTests: XCTestCase {

    var cpu:CPU6502 = CPU6502()

    override func setUp() {
        super.setUp()
        cpu = CPU6502()
        cpu.reset()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testCPUResetState() {
        self.cpu.reset()

        expect(self.cpu.getStackPointer()).to(equal(0xFF))

        expect(self.cpu.registers.a).to(equal(0x00))
        expect(self.cpu.registers.x).to(equal(0x00))
        expect(self.cpu.registers.y).to(equal(0x00))

        expect(self.cpu.registers.getInterruptFlag()).to(beTrue())
        expect(self.cpu.registers.getBreakFlag()).to(beTrue())
        expect(self.cpu.registers.getDecimalFlag()).to(beTrue())
    }

}
