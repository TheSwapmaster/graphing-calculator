//
//  GraphView.swift
//  Calcmaster
//
//  Created by Swapnil Harsule on 10/6/16.
//  Copyright © 2016 Swapnil Harsule. All rights reserved.
//

import UIKit

@IBDesignable class GraphView: UIView {

    private var axesDrawer = AxesDrawer(color: UIColor.blackColor())   // black axes
    private var color = UIColor.blueColor()
    
    var originOffset: CGPoint = CGPoint(x: 0, y: 0) {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable var scale: CGFloat = 1.0 {
        didSet {
            if scale < 0.1 { scale = 0.1 }
            setNeedsDisplay()
        }
    }
    
    func changeScale(recognizer: UIPinchGestureRecognizer) {
        
        switch recognizer.state {
        case .Changed, .Ended:
            scale = scale*recognizer.scale
            recognizer.scale = 1.0  // Reset scale to get relative scale next time we are in here
        default:
            break
        }
    }
    
    func panGraph(recognizer: UIPanGestureRecognizer) {
        
        switch recognizer.state {
        case .Changed, .Ended:
            originOffset = CGPoint(x: originOffset.x + recognizer.translationInView(self).x,
                                   y: originOffset.y + recognizer.translationInView(self).y)
            
            recognizer.setTranslation(CGPoint(x: 0, y: 0), inView: self)// Reset translation to get relative translation next time we are in here

        default:
            break
        }
    }
    
    func resetOrigin(recognizer: UITapGestureRecognizer) {
        
        switch recognizer.state {
        case .Ended:
            
            //let currentOrigin = CGPoint(x: bounds.midX + originOffset.x, y: bounds.midY + originOffset.y)

            originOffset = CGPoint(x: recognizer.locationInView(self).x - bounds.midX, y: recognizer.locationInView(self).y - bounds.midY)
//            originOffset = recognizer.locationOfTouch(1, inView: self)
            
        default:
            break
        }
    }
    
    // Code to draw custom graph view
    override func drawRect(rect: CGRect) {
        // Drawing code
        
        axesDrawer.drawAxesInRect(bounds,
                                  origin: CGPoint(x: bounds.midX + originOffset.x, y: bounds.midY + originOffset.y),
                                  pointsPerUnit: scale )
    }
    

}
