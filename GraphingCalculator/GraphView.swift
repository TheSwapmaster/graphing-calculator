//
//  GraphView.swift
//  Calcmaster
//
//  Created by Swapnil Harsule on 10/6/16.
//  Copyright © 2016 Swapnil Harsule. All rights reserved.
//

import UIKit

@IBDesignable class GraphView: UIView {

    fileprivate var axesDrawer = AxesDrawer(color: UIColor.black)   // black axes
    fileprivate var color = UIColor.blue
    
    var originOffset: CGPoint = CGPoint(x: 0, y: 0) {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable var scale: CGFloat = 1.0 {
        didSet {
            if scale < 0.1 { scale = 0.1 }
            setNeedsDisplay()
        }
    }
    
    func changeScale(_ recognizer: UIPinchGestureRecognizer) {
        
        switch recognizer.state {
        case .changed, .ended:
            scale = scale*recognizer.scale
            recognizer.scale = 1.0  // Reset scale to get relative scale next time we are in here
        default:
            break
        }
    }
    
    func moveGraph(_ recognizer: UIPanGestureRecognizer) {
        
        switch recognizer.state {
        case .changed, .ended:
            originOffset = CGPoint(x: originOffset.x + recognizer.translation(in: self).x,
                                   y: originOffset.y + recognizer.translation(in: self).y)
            
            recognizer.setTranslation(CGPoint(x: 0, y: 0), in: self)// Reset translation to get relative translation next time we are in here

        default:
            break
        }
    }
    
    // Code to draw custom graph view
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        axesDrawer.drawAxesInRect(bounds,
                                  origin: CGPoint(x: bounds.origin.x + originOffset.x, y: bounds.origin.y + originOffset.y),
                                  pointsPerUnit: scale )
    }
    

}
