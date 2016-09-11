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

    func clearCarry() {
        registers.setCarryFlag(false)
    }

    func calculateCarry(_ value: UInt16) -> Bool {
        return value & 0xFF00 > 0
    }

    func calculateZero(_ value: UInt16) -> Bool {
        return value & 0x00FF == 0
    }

    func calculateOverflow(_ result: UInt16, acc: UInt8, value: UInt8) -> Bool {
        return ((result ^ UInt16(acc)) & (result ^ UInt16(value)) & 0x0080) > UInt16(0)
    }

    func calculateSign(_ value: UInt16) -> Bool {
        // Value > 127
        return value & 0x0080 > 0
    }

    func getIndirect(_ address: UInt16) -> UInt8 {
        let indirectAddress: UInt16 = address
        return getMem(UInt16(getMem(indirectAddress)) | (UInt16(getMem(indirectAddress + 1)) << 8))
    }

    func getIndirectX(_ address: UInt16) -> UInt8 {
        return getIndirect(address + UInt16(registers.x))
    }

    func getIndirectY(_ address: UInt16) -> UInt8 {
        let indirectAddress: UInt16 = address
        return getMem((UInt16(getMem(indirectAddress)) | (UInt16(getMem(indirectAddress + 1)) << 8)) + UInt16(registers.y))
    }
    
    func getIndirectYAddress(_ address: UInt16) -> UInt16 {
        let indirectAddress: UInt16 = address
         return (UInt16(getMem(indirectAddress)) | (UInt16(getMem(indirectAddress + 1)) << 8)) + UInt16(registers.y)
    }

    func valueForAddressingMode(_ mode: AddressingMode) -> UInt8 {
        switch mode {
        case .accumulator:
            return registers.a
        case .immediate(let val):
            return val
        case .zeroPage(let val):
            return getZero(val)
        case .zeroPageX(let val):
            return getZero(UInt8.addWithOverflow(val, registers.x).0)
        case .absolute(let val):
            return getMem(val)
        case .absoluteX(let val):
            return getMem(UInt16.addWithOverflow(val, UInt16(registers.x)).0)
        case .absoluteY(let val):
            return getMem(UInt16.addWithOverflow(val, UInt16(registers.y)).0)
        case .indirect(let val):
            return getIndirect(val)
        case .indirectX(let val):
            return getIndirectX(val)
        case .indirectY(let val):
            return getIndirectY(val)
        default: // This should raise an exception
            return 0
        }
    }

    func addressForAddressingMode(_ mode: AddressingMode) -> UInt16 {
        switch mode {
        case .immediate(let val):
            return UInt16(val)
        case .zeroPage(let val):
            return UInt16(val)
        case .zeroPageX(let val):
            return UInt16(UInt8.addWithOverflow(val, registers.x).0)
        case .absolute(let val):
            return val
        case .absoluteX(let val):
            return UInt16.addWithOverflow(val, UInt16(registers.x)).0
        case .absoluteY(let val):
            return UInt16.addWithOverflow(val, UInt16(registers.y)).0
        case .indirect(let val):
            return UInt16(getIndirect(val))
        case .indirectX(let val):
            return UInt16(getIndirectX(val))
        case .indirectY(let val):
            return getIndirectYAddress(val)
        case .relative(let val):
            return UInt16(val)
        default: // This should raise an exception
            return 0
        }
    }

    func setValueForAddressingMode(_ value: UInt8, mode: AddressingMode) {
        switch mode {
        case .accumulator:
            registers.a = value;
            break
        default:
            let addr = addressForAddressingMode(mode)
            setMem(addr, value: value)
            break
        }
    }

    func defaultResponse() -> InstructionResponse {
        return InstructionResponse(handlesPC: false)
    }
    
    func branchRelative(relVal: UInt16) {
        if relVal & (1 << 7) > 0 {
            let comp = (~relVal & 0x7f) + 1
            self.setProgramCounter(UInt16.subtractWithOverflow(registers.pc, comp).0)
        } else {
            self.setProgramCounter(UInt16.addWithOverflow(registers.pc, relVal).0)
        }
    }

    func opADC(_ mode: AddressingMode) -> InstructionResponse {
        let value          = valueForAddressingMode(mode)

        // Add the value to accumulator, add 1 if carry flag is active
        let result: UInt16 = UInt16(registers.a) +
                UInt16(value) +
                UInt16(registers.boolToInt(registers.getCarryFlag()))

        registers.setCarryFlag(calculateCarry(result))
        registers.setZeroFlag(calculateZero(result))
        registers.setOverflowFlag(calculateOverflow(result, acc: registers.a, value: value))
        registers.setSignFlag(calculateSign(result))

        registers.a = UInt8(result & UInt16(0xFF))

        return defaultResponse()
    }

    func opAND(_ mode: AddressingMode) -> InstructionResponse {
        let value = valueForAddressingMode(mode)

        registers.a &= value
        registers.setSignFlag(calculateSign(UInt16(registers.a)))
        registers.setZeroFlag(calculateSign(UInt16(registers.a)))

        return defaultResponse()
    }

    func opASL(_ mode: AddressingMode) -> InstructionResponse {
        let value          = valueForAddressingMode(mode)
        let result: UInt16 = UInt16(value) << UInt16(1)

        registers.setCarryFlag(calculateCarry(result))
        registers.setZeroFlag(calculateZero(result))
        registers.setSignFlag(calculateSign(result))

        setValueForAddressingMode(UInt8(result & 0xFF), mode: mode)

        return defaultResponse()
    }

    func opBCC(_ mode: AddressingMode) -> InstructionResponse {
        if !registers.getCarryFlag() {
            let relativeAddress = addressForAddressingMode(mode)
            self.branchRelative(relVal: relativeAddress)
            return InstructionResponse(handlesPC: true)
        }
        return defaultResponse()
    }

    func opBCS(_ mode: AddressingMode) -> InstructionResponse {
        if registers.getCarryFlag() {
            let relativeAddress = addressForAddressingMode(mode)
            self.branchRelative(relVal: relativeAddress)
            return InstructionResponse(handlesPC: true)
        }
        return defaultResponse()
    }

    func opBEQ(_ mode: AddressingMode) -> InstructionResponse {
        if registers.getZeroFlag() {
            let relativeAddress = addressForAddressingMode(mode)
            self.branchRelative(relVal: relativeAddress)
            return InstructionResponse(handlesPC: true)
        }
        return defaultResponse()
    }

    func opBIT(_ mode: AddressingMode) -> InstructionResponse {
        let value  = valueForAddressingMode(mode)
        let result = UInt16(registers.a) & UInt16(value)
        
        registers.setOverflowFlag(result & 64 > 0)
        registers.setZeroFlag(calculateZero(result))
        registers.setSignFlag(calculateSign(result))
        return defaultResponse()
    }

    func opBMI(_ mode: AddressingMode) -> InstructionResponse {
        if registers.getSignFlag() {
            let relativeAddress = addressForAddressingMode(mode)
            self.branchRelative(relVal: relativeAddress)
            return InstructionResponse(handlesPC: true)
        }
        return defaultResponse()
    }

    func opBNE(_ mode: AddressingMode) -> InstructionResponse {
        if !registers.getZeroFlag() {
            let relativeAddress = addressForAddressingMode(mode)
            self.branchRelative(relVal: relativeAddress)
            return InstructionResponse(handlesPC: true)
        }
        return defaultResponse()
    }

    func opBPL(_ mode: AddressingMode) -> InstructionResponse {
        if !registers.getSignFlag() {
            let relativeAddress = addressForAddressingMode(mode)
            self.branchRelative(relVal: relativeAddress)
            return InstructionResponse(handlesPC: true)
        }
        return defaultResponse()
    }

    func opBRK(_ mode: AddressingMode) -> InstructionResponse {
        setProgramCounter(getProgramCounter() &+ 1)
        push16(getProgramCounter())
        push8(registers.getStatusByte())
        registers.setInterruptFlag(true)
        setProgramCounter(UInt16(getMem(0xFFFE)) | (UInt16(0xFFFF) << 8))

        breakExecuted()
        return InstructionResponse(handlesPC: true)
    }

    func opBVC(_ mode: AddressingMode) -> InstructionResponse {
        if !registers.getOverflowFlag() {
            let relativeAddress = addressForAddressingMode(mode)
            self.branchRelative(relVal: relativeAddress)
            return InstructionResponse(handlesPC: true)
        }
        return defaultResponse()
    }

    func opBVS(_ mode: AddressingMode) -> InstructionResponse {
        if registers.getOverflowFlag() {
            let relativeAddress = addressForAddressingMode(mode)
            self.branchRelative(relVal: relativeAddress)
            return InstructionResponse(handlesPC: true)
        }
        return defaultResponse()
    }

    func opCLC(_ mode: AddressingMode) -> InstructionResponse {
        registers.setCarryFlag(false)
        return defaultResponse()
    }

    func opCLD(_ mode: AddressingMode) -> InstructionResponse {
        registers.setDecimalFlag(false)
        return defaultResponse()
    }

    func opCLI(_ mode: AddressingMode) -> InstructionResponse {
        registers.setInterruptFlag(false)
        return defaultResponse()
    }

    func opCLV(_ mode: AddressingMode) -> InstructionResponse {
        registers.setOverflowFlag(false)
        return defaultResponse()
    }

    func opCMP(_ mode: AddressingMode) -> InstructionResponse {
        let value  = valueForAddressingMode(mode)
        let value8 = UInt8(value & 0xFF)
        let result = UInt8.subtractWithOverflow(registers.a, value)

        if registers.a >= value8 {
            registers.setCarryFlag(true)
        } else {
            registers.setCarryFlag(false)
        }

        if registers.a == value8 {
            registers.setZeroFlag(true)
        } else {
            registers.setZeroFlag(false)
        }

        registers.setSignFlag(calculateSign(UInt16(result.0)))
        return defaultResponse()
    }

    func opCPX(_ mode: AddressingMode) -> InstructionResponse {
        let value  = valueForAddressingMode(mode)
        let value8 = UInt8(value & 0xFF)
        let result = UInt8.subtractWithOverflow(registers.x, value)

        if registers.x >= value8 {
            registers.setCarryFlag(true)
        } else {
            registers.setCarryFlag(false)
        }

        if registers.x == value8 {
            registers.setZeroFlag(true)
        } else {
            registers.setZeroFlag(false)
        }

        registers.setSignFlag(calculateSign(UInt16(result.0)))
        return defaultResponse()
    }

    func opCPY(_ mode: AddressingMode) -> InstructionResponse {
        let value  = valueForAddressingMode(mode)
        let value8 = UInt8(value & 0xFF)
        let result = UInt16(registers.y) - UInt16(value)

        if registers.y >= value8 {
            registers.setCarryFlag(true)
        } else {
            registers.setCarryFlag(false)
        }

        if registers.y == value8 {
            registers.setZeroFlag(true)
        } else {
            registers.setZeroFlag(false)
        }

        registers.setSignFlag(calculateSign(result))
        return defaultResponse()
    }

    func opDEC(_ mode: AddressingMode) -> InstructionResponse {
        let result = UInt16(registers.a) - UInt16(1)
        registers.setZeroFlag(calculateZero(result))
        registers.setSignFlag(calculateSign(result))
        registers.a = UInt8(result & 0xFF)
        return defaultResponse()
    }

    func opDEX(_ mode: AddressingMode) -> InstructionResponse {
        let result = UInt16(registers.x) - UInt16(1)
        registers.setZeroFlag(calculateZero(result))
        registers.setSignFlag(calculateSign(result))
        registers.x = UInt8(result & 0xFF)
        return defaultResponse()
    }

    func opDEY(_ mode: AddressingMode) -> InstructionResponse {
        let result = UInt16(registers.y) - UInt16(1)
        registers.setZeroFlag(calculateZero(result))
        registers.setSignFlag(calculateSign(result))
        registers.y = UInt8(result & 0xFF)
        return defaultResponse()
    }

    func opEOR(_ mode: AddressingMode) -> InstructionResponse {
        let value = valueForAddressingMode(mode)

        registers.a ^= value
        registers.setSignFlag(calculateSign(UInt16(registers.a)))
        registers.setZeroFlag(calculateSign(UInt16(registers.a)))
        return defaultResponse()
    }

    func opINC(_ mode: AddressingMode) -> InstructionResponse {
        let value = valueForAddressingMode(mode)
        let result = value + 1
        registers.setZeroFlag(calculateZero(UInt16(result)))
        registers.setSignFlag(calculateSign(UInt16(result)))
        setValueForAddressingMode(UInt8(result & 0xFF), mode: mode)
        return defaultResponse()
    }

    func opINX(_ mode: AddressingMode) -> InstructionResponse {
        let result = UInt16(registers.x) + UInt16(1)
        registers.setZeroFlag(calculateZero(result))
        registers.setSignFlag(calculateSign(result))
        registers.x = UInt8(result & 0xFF)
        return defaultResponse()
    }

    func opINY(_ mode: AddressingMode) -> InstructionResponse {
        let result = UInt16(registers.y) + UInt16(1)
        registers.setZeroFlag(calculateZero(result))
        registers.setSignFlag(calculateSign(result))
        registers.y = UInt8(result & 0xFF)
        return defaultResponse()
    }

    func opJMP(_ mode: AddressingMode) -> InstructionResponse {
        let address = addressForAddressingMode(mode)
        setProgramCounter(address)
        return InstructionResponse(handlesPC: true)
    }

    func opJSR(_ mode: AddressingMode) -> InstructionResponse {
        let address = addressForAddressingMode(mode)
        push16(getProgramCounter() - 1)
        setProgramCounter(address)
        return InstructionResponse(handlesPC: true)
    }

    func opLDA(_ mode: AddressingMode) -> InstructionResponse {
        let value = valueForAddressingMode(mode)
        registers.setZeroFlag(calculateZero(UInt16(value)))
        registers.setSignFlag(calculateSign(UInt16(value)))
        registers.a = value
        return defaultResponse()
    }

    func opLDX(_ mode: AddressingMode) -> InstructionResponse {
        let value = valueForAddressingMode(mode)
        registers.setZeroFlag(calculateZero(UInt16(value)))
        registers.setSignFlag(calculateSign(UInt16(value)))
        registers.x = value
        return defaultResponse()
    }

    func opLDY(_ mode: AddressingMode) -> InstructionResponse {
        let value = valueForAddressingMode(mode)
        registers.setZeroFlag(calculateZero(UInt16(value)))
        registers.setSignFlag(calculateSign(UInt16(value)))
        registers.y = value
        return defaultResponse()
    }

    func opLSR(_ mode: AddressingMode) -> InstructionResponse {
        let result: UInt16 = UInt16(valueForAddressingMode(mode)) >> UInt16(1);

        registers.setCarryFlag(registers.a & 0x1 > 0)
        registers.setZeroFlag(calculateZero(result))
        registers.setSignFlag(calculateSign(result))

        setValueForAddressingMode(UInt8(result & 0xFF), mode: mode)
        return defaultResponse()
    }

    func opNOP(_ mode: AddressingMode) -> InstructionResponse {
        return defaultResponse()
    }

    func opORA(_ mode: AddressingMode) -> InstructionResponse {
        let value = valueForAddressingMode(mode)

        registers.a |= value
        registers.setSignFlag(calculateSign(UInt16(registers.a)))
        registers.setZeroFlag(calculateSign(UInt16(registers.a)))
        return defaultResponse()
    }

    func opPHA(_ mode: AddressingMode) -> InstructionResponse {
        push8(registers.a)
        return defaultResponse()
    }

    func opPHP(_ mode: AddressingMode) -> InstructionResponse {
        push8(registers.getStatusByte())
        return defaultResponse()
    }

    func opPLA(_ mode: AddressingMode) -> InstructionResponse {
        registers.a = pop8()
        registers.setSignFlag(calculateSign(UInt16(registers.a)))
        registers.setZeroFlag(calculateSign(UInt16(registers.a)))
        return defaultResponse()
    }

    func opPLP(_ mode: AddressingMode) -> InstructionResponse {
        registers.setStatusByte(pop8())
        return defaultResponse()
    }

    func opROL(_ mode: AddressingMode) -> InstructionResponse {
        let result = UInt16(valueForAddressingMode(mode)) << UInt16(1)

        registers.setCarryFlag(calculateCarry(result))
        registers.setZeroFlag(calculateZero(result))
        registers.setSignFlag(calculateSign(result))

        setValueForAddressingMode(UInt8(result & 0xFF), mode: mode)
        return defaultResponse()
    }

    func opROR(_ mode: AddressingMode) -> InstructionResponse {
        let value = valueForAddressingMode(mode)
        let bit    = value & 0x01
        let result = UInt16(value) >> UInt16(1)

        registers.setCarryFlag(bit > 0)
        registers.setZeroFlag((calculateZero(result)))
        registers.setSignFlag((calculateSign(result)))

        setValueForAddressingMode(UInt8(result & 0xFF), mode: mode)
        return defaultResponse()
    }

    func opRTI(_ mode: AddressingMode) -> InstructionResponse {
        registers.setStatusByte(pop8())
        setProgramCounter(pop16())
        return InstructionResponse(handlesPC: true)
    }

    func opRTS(_ mode: AddressingMode) -> InstructionResponse {
        let returnAddress = pop16()
        setProgramCounter(returnAddress + 1)
        return InstructionResponse(handlesPC: true)
    }

    func opSBC(_ mode: AddressingMode) -> InstructionResponse {
        return defaultResponse()
    }

    func opSEC(_ mode: AddressingMode) -> InstructionResponse {
        registers.setCarryFlag(true)
        return defaultResponse()
    }

    func opSED(_ mode: AddressingMode) -> InstructionResponse {
        registers.setDecimalFlag(true)
        return defaultResponse()
    }

    func opSEI(_ mode: AddressingMode) -> InstructionResponse {
        registers.setInterruptFlag(true)
        return defaultResponse()
    }

    func opSTA(_ mode: AddressingMode) -> InstructionResponse {
        let address = addressForAddressingMode(mode)
        setMem(address, value: registers.a)
        return defaultResponse()
    }

    func opSTX(_ mode: AddressingMode) -> InstructionResponse {
        let address = addressForAddressingMode(mode)
        setMem(address, value: registers.x)
        return defaultResponse()
    }

    func opSTY(_ mode: AddressingMode) -> InstructionResponse {
        let address = addressForAddressingMode(mode)
        setMem(address, value: registers.y)
        return defaultResponse()
    }

    func opTAX(_ mode: AddressingMode) -> InstructionResponse {
        registers.x = registers.a
        registers.setSignFlag(calculateSign(UInt16(registers.a)))
        registers.setZeroFlag(calculateSign(UInt16(registers.a)))
        return defaultResponse()
    }

    func opTAY(_ mode: AddressingMode) -> InstructionResponse {
        registers.y = registers.a
        registers.setSignFlag(calculateSign(UInt16(registers.a)))
        registers.setZeroFlag(calculateSign(UInt16(registers.a)))
        return defaultResponse()
    }

    func opTSX(_ mode: AddressingMode) -> InstructionResponse {
        registers.x = registers.s
        registers.setSignFlag(calculateSign(UInt16(registers.s)))
        registers.setZeroFlag(calculateSign(UInt16(registers.s)))
        return defaultResponse()
    }

    func opTXA(_ mode: AddressingMode) -> InstructionResponse {
        registers.a = registers.x
        registers.setSignFlag(calculateSign(UInt16(registers.a)))
        registers.setZeroFlag(calculateSign(UInt16(registers.a)))
        return defaultResponse()
    }

    func opTXS(_ mode: AddressingMode) -> InstructionResponse {
        registers.s = registers.x
        registers.setSignFlag(calculateSign(UInt16(registers.s)))
        registers.setZeroFlag(calculateSign(UInt16(registers.s)))
        return defaultResponse()
    }

    func opTYA(_ mode: AddressingMode) -> InstructionResponse {
        registers.a = registers.y
        registers.setSignFlag(calculateSign(UInt16(registers.a)))
        registers.setZeroFlag(calculateSign(UInt16(registers.a)))
        return defaultResponse()
    }
}
