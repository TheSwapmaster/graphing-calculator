//
//  AppBrain.swift
//  Calcmaster
//
//  Created by Swapnil Harsule on 7/18/16.
//  Copyright © 2016 Swapnil Harsule. All rights reserved.
//

import Foundation

class CalcBrain {
    
    fileprivate var accumulator = 0.0
    fileprivate var isConstant = false
    
    typealias PropertyList = AnyObject
    fileprivate var internalProgram = [PropertyList]()
    
    fileprivate var operations: Dictionary<String, Operation> = [
        
        "eˣ"    :Operation.unaryOperation( { pow(M_E, $0) }, "e^", false),
        "10ˣ"   :Operation.unaryOperation( { pow(10, $0) }, "10^", false),
        "logₑ"  :Operation.unaryOperation( { log($0) }, "logₑ", false),
        "log₁₀" :Operation.unaryOperation( { log10($0) }, "log₁₀", false),
        "x²"    :Operation.unaryOperation( { pow($0,2) }, "²", true),
        "√"     :Operation.unaryOperation(sqrt, "√", false),
        "x³"    :Operation.unaryOperation( { pow($0,3) }, "³", true ),
        "³√"    :Operation.unaryOperation( { pow($0,1/3) }, "³√", false ),
        "cos"   :Operation.unaryOperation(cos, "cos", false),
        "sin"   :Operation.unaryOperation(sin, "sin", false),
        "tan"   :Operation.unaryOperation(tan, "tan", false),
        "π"     :Operation.constant(M_PI),
        "AC"    :Operation.clear,
        "1/x"   :Operation.unaryOperation( { 1/$0 } ,"⁻¹", true),
        "⁺⁄₋"   :Operation.unaryOperation( { -$0 } ,"-", false),
        "%"     :Operation.binaryOperation( { $0.truncatingRemainder(dividingBy: $1) } ),
        "×"     :Operation.binaryOperation( { $0 * $1 } ),
        "+"     :Operation.binaryOperation( { $0 + $1 } ),
        "-"     :Operation.binaryOperation( { $0 - $1 } ),
        "÷"     :Operation.binaryOperation( { $0 / $1 } ),
        "="     :Operation.equals
    ]
    
    fileprivate var variableValues: Dictionary<String, Double> = [:]
    fileprivate var isOperandVar = false
    
    func SetVariableValue(_ varName: String, varValue: Double) {
        variableValues[varName] = varValue
    }
    
    func GetVariableValue(_ varName: String) -> Double? {
        return variableValues[varName]
    }
    
    fileprivate enum Operation {
        
        case constant(Double)
        case unaryOperation((Double)->Double, String, Bool) // TRUE mean symbol suffixed, FALSE means prefixed
        case binaryOperation((Double, Double)->Double)
        case equals
        case clear
    }
    
    var program : PropertyList {
        get{
            return internalProgram as CalcBrain.PropertyList
        }
        set{
            ResetCalculator()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps{
                    
                    if let operand = op as? Double {
                        SetOperand(operand)
                    }
                    else if let operation = op as? String{
                        
                        if variableValues[operation] != nil {
                            SetOperand(operation)
                        }
                        else {
                            PerformOperation(operation)
                        }
                    }
                }
            }
            
        }
    }
    
    var result : Double {
        
        get {
            return accumulator
        }
    }
    
    var description: String {
        get{
            if isPartialResult { return operationsTyped + "..." }
            else if operationsTyped == " " { return operationsTyped }
            else { return operationsTyped + "=" }
        }
    }
    
    fileprivate var operationsTyped:String = " "
    
    fileprivate struct PendingBinaryOperation {
        
        var binaryFunc: (Double, Double)->Double
        var firstOperand: Double
    }
    
    var formatter = NumberFormatter()
    
    public func formatNumber(value: Double) -> String? {

        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 4
        formatter.minimumIntegerDigits = 1
        
        if let retString = formatter.string(from: NSNumber(value: value )) {
            return retString
        }
        return nil
    }
    
    fileprivate var isPending: PendingBinaryOperation?
    
    fileprivate var isPartialResult: Bool {
        get{
            return isPending != nil
        }
    }
    
    fileprivate func ClearDescription() {
        operationsTyped = " "
    }
    
    func SetOperand(_ varName: String) {
        
        if variableValues[varName] == nil {
            SetVariableValue(varName, varValue: 0.0)
        }
        internalProgram.append(varName as CalcBrain.PropertyList)
        accumulator = variableValues[varName]!
        if(!isPartialResult) {
            operationsTyped = varName
        }
        else {
            operationsTyped += varName
            isOperandVar = true
        }
    }
    
    func SetOperand(_ operand: Double) {
        
        accumulator = operand
        internalProgram.append(operand as CalcBrain.PropertyList)
        if(!isPartialResult) {
            operationsTyped = formatter.string(from: NSNumber(value: accumulator))!
        }

    }
    
    func PerformOperation (_ symbol: String) {
        
        var textToAppend:String
        
        if let operation = operations[symbol] {
            internalProgram.append(symbol as CalcBrain.PropertyList)
            
            switch operation {
            
            case .constant(let value):
                if(isPartialResult) {
                    operationsTyped += String(symbol)
                }
                else {
                    ClearDescription()
                    operationsTyped = String(symbol)
                }
                accumulator = value
                isConstant = true
                
            case .unaryOperation(let function, let symbolToPrint, let suffix):
                if(isPartialResult) {
                    if isConstant == true {
                        textToAppend = String(operationsTyped.remove(at: operationsTyped.characters.index(before: operationsTyped.endIndex)))
                    }
                    else {
                        textToAppend = formatter.string(from: NSNumber(value: accumulator))!
                    }
                    isConstant = true
                    if suffix{
                        operationsTyped += "(" + textToAppend + ")" + String(symbolToPrint)
                    }
                    else {
                        operationsTyped += String(symbolToPrint) + "(" + textToAppend + ")"
                    }
                }
                else {
                    if operationsTyped != " "{
                        textToAppend = operationsTyped
                    } else {
                        textToAppend = formatter.string(from: NSNumber(value: accumulator))!
                    }
                    if suffix{
                        operationsTyped = "(" + textToAppend + ")" + String(symbolToPrint)
                    }
                    else {
                        operationsTyped = String(symbolToPrint) + "(" + textToAppend + ")"
                    }
                }
                
                accumulator = function(accumulator)
                
            case .binaryOperation(let function):
                execPendingBinaryOperation()
                operationsTyped +=  String(symbol)
                isPending = PendingBinaryOperation(binaryFunc:  function, firstOperand:   accumulator)
            
            case .equals:
                execPendingBinaryOperation()
                
            case .clear:
                variableValues["M"] = nil
                ResetCalculator()
            }
        }
    }
    
    func UndoLast() {
        if internalProgram.count > 0 {
            internalProgram.removeLast()
            program = internalProgram as CalcBrain.PropertyList
        }
        
    }
    
    fileprivate func execPendingBinaryOperation() {
        if isPending != nil {
            if(!isConstant && !isOperandVar) {
                operationsTyped += formatter.string( from: NSNumber(value: accumulator))!
            }
            else {
                isConstant = false
                isOperandVar = false
            }
            
            accumulator = (isPending!.binaryFunc(isPending!.firstOperand, accumulator))
            isPending = nil
        }
    }
    
    fileprivate func ResetCalculator() {
        isPending = nil
        accumulator = 0
        ClearDescription()
        internalProgram.removeAll()
    }
    
}
