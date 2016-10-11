//
//  CalculatorViewController
//  GraphingCalculator
//
//  Created by Swapnil Harsule on 10/9/16.
//  Copyright © 2016 Swapnil Harsule. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


class CalculatorViewController: UIViewController {
    
    
    @IBOutlet fileprivate weak var display: UILabel!
    
    @IBOutlet weak var history: UILabel!
    
    @IBOutlet weak var memoryReg: UILabel!
    
    fileprivate var isUserTyping = false
    
    fileprivate var brain = CalcBrain() {
        didSet {
            brain.formatter.maximumFractionDigits = 4
            brain.formatter.minimumIntegerDigits = 1
        }
    }
    
    fileprivate var displayValue : Double {
        
        get{
            return Double(display.text!)!
        }
        set {
            display.text = brain.formatNumber(value: newValue)!
        }
    }
    
    @IBAction func touchDigit(_ sender: UIButton) {
        
        let digit = sender.currentTitle!
        
        // Avoid prepending zeroes to any number
        if digit == "0" && displayValue == 0 { return }
        
        // Return if a decimal point has already been typed
        if digit == "." {
            if display.text?.range(of: ".") != nil {return  // decimal already exists, return
            } else { isUserTyping = true } // else, append decimal point at the end
        }
        
        if !isUserTyping {
            display.text = digit
            isUserTyping = true
        }
        else {
            let textOnDisplay = display.text!
            display!.text = textOnDisplay + digit
        }
        
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        
        var memValToPrint: String
        
        if isUserTyping {
            
            brain.SetOperand(displayValue)
            isUserTyping = false
        }
        
        if let mathSymbol = sender.currentTitle {
            brain.PerformOperation(mathSymbol)
        }
        displayValue = brain.result
        history.text = brain.description
        
        if let memVal = brain.GetVariableValue("M") {
            memValToPrint = brain.formatNumber(value: memVal)!
        }
        else {
            memValToPrint = String(0)
        }
        memoryReg.text = "M=" + memValToPrint
        
        //
    }
    
    @IBAction func SetMemory(_ sender: UIButton) {
        isUserTyping = false
        brain.SetVariableValue("M", varValue: displayValue)
        
        let programToUpdate = brain.program
        brain.program = programToUpdate
        
        memoryReg.text = "M=" + brain.formatNumber(value: displayValue)!
        displayValue = brain.result
        history.text = brain.description
    }
    
    @IBAction func UpdateResultWithMemory(_ sender: UIButton) {
        brain.SetOperand("M")
    }
    
    
    @IBAction func Backspace() {
        if isUserTyping {
            if display.text?.characters.count>0 {
                display.text!.remove(at: display.text!.characters.index(before: display.text!.endIndex))
            }
        } else {
            brain.UndoLast()
            displayValue = brain.result
            history.text = brain.description
        }
        
        if display.text?.characters.count==0 {
            displayValue = brain.result
            isUserTyping = false
        }
    }
    
    
    
}


