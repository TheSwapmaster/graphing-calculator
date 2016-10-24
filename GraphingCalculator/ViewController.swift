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
    
    private let memReg = "M"
    
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
        
        if let memVal = brain.GetVariableValue(memReg) {
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
    
    @IBAction func UseMemoryAsOperand() {
        brain.SetOperand(memReg)
    }
    
    func GetResultForValue(value: Double, equation: CalcBrain.PropertyList) -> Double {
        //isUserTyping = false
        
        let origMemVal  = brain.GetVariableValue(memReg) // save original
        let origProg    = brain.program   // get resut for new value
        
        brain.SetVariableValue(memReg, varValue: value) // update to new value
        brain.program = equation
        
        defer { // restore original
            brain.SetVariableValue(memReg, varValue: origMemVal ?? 0.0)
            brain.program = origProg
        }
        
        let result = brain.result
        return result
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
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        print ("Preparing for segue")
        
        var destinationVC = segue.destinationViewController
        
        if let navcon = destinationVC as? UINavigationController {
            destinationVC = navcon.visibleViewController ?? destinationVC
        }
        if let graphVC = destinationVC as? GraphViewController {
            
            if segue.identifier == "showGraph" {
                
                calcViewControllerDefaults.program = brain.program  // store program to defaults
                
                graphVC.graphInfo = GraphInfo(xyEquation: brain.program, getValFunc: self.GetResultForValue)
                graphVC.navigationItem.title = history.text!    // equation being graphed
            }
            
        }
    }
    
    
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        
        if identifier == "showGraph" && brain.isPartialResult {
            self.navigationItem.title = "Cannot graph incomplete equation..."
            return false
        }
        
        self.navigationItem.title = " "
        return true
    }
    
    private struct CalculatorViewControllerDefaults {
        
        private var defaults = NSUserDefaults.standardUserDefaults()
        private var programKey = "CalcViewController.Program"
        
        var program: AnyObject? {
            set{
                defaults.setObject(newValue, forKey: programKey)
                defaults.synchronize()
            }
            get {
                return defaults.objectForKey(programKey)
            }
        }
    }
    
    private var calcViewControllerDefaults = CalculatorViewControllerDefaults()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let defaultProgram = calcViewControllerDefaults.program {
            self.displayValue = 0.0
            self.SetMemory(UIButton())
            self.brain.program = defaultProgram
            performSegueWithIdentifier("showGraph", sender: nil)
        }
        
    }
    
    
    
}


