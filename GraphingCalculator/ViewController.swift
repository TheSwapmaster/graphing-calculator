//
//  CalculatorViewController
//  GraphingCalculator
//
//  Created by Swapnil Harsule on 10/9/16.
//  Copyright © 2016 Swapnil Harsule. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    
    
    @IBOutlet private weak var display: UILabel!
    
    @IBOutlet weak var history: UILabel!
    
    @IBOutlet weak var memoryReg: UILabel!
    
    private var isUserTyping = false
    
    private var brain = CalcBrain()
    
    private var displayValue : Double {
        
        get{
            return Double(display.text!)!
        }
        set {
            display.text = brain.formatNumber(newValue)!
        }
    }
    
    @IBAction func touchDigit(sender: UIButton) {
        
        let digit = sender.currentTitle!
        
        // Avoid prepending zeroes to any number
        if digit == "0" && displayValue == 0 { return }
        
        // Return if a decimal point has already been typed
        if digit == "." {
            if display.text?.rangeOfString(".") != nil {return  // decimal already exists, return
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
    
    @IBAction func performOperation(sender: UIButton) {
        
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
            memValToPrint = brain.formatNumber(memVal)!
        }
        else {
            memValToPrint = String(0)
        }
        memoryReg.text = "M=" + memValToPrint
        
        //
    }
    
    @IBAction func SetMemory(sender: UIButton) {
        isUserTyping = false
        brain.SetVariableValue("M", varValue: displayValue)
        
        let programToUpdate = brain.program
        brain.program = programToUpdate
        
        memoryReg.text = "M=" + brain.formatNumber(displayValue)!
        displayValue = brain.result
        history.text = brain.description
    }
    
    @IBAction func UpdateResultWithMemory(sender: UIButton) {
        brain.SetOperand("M")
    }
    
    
    @IBAction func Backspace() {
        if isUserTyping {
            if display.text?.characters.count>0 {
                display.text!.removeAtIndex(display.text!.endIndex.predecessor())
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


