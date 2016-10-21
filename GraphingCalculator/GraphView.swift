//
//  GraphView.swift
//  Calcmaster
//
//  Created by Swapnil Harsule on 10/6/16.
//  Copyright © 2016 Swapnil Harsule. All rights reserved.
//

import UIKit

//@IBDesignable
class GraphView: UIView {
    
    private var axesDrawer = AxesDrawer(color: UIColor.blackColor())   // black axes
    private var color = UIColor.blueColor()
    
    private var isAnimationInProgress = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    
    var getNextValFunc: ((Double) -> Double)?
    
    var originOffset: CGPoint = CGPoint(x: 0, y: 0) { // offset relative to center of graphView
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable var scale: CGFloat = 100.0 {
        didSet {
            
            scale = max(0.1, min(200, scale))
            //            print("Scale is \(scale)")
            setNeedsDisplay()
        }
    }
    
    func changeScale(recognizer: UIPinchGestureRecognizer) {
        
        switch recognizer.state {
            
            //        case .Changed:
            //            isAnimationInProgress = true
            //
            //            scale = scale*recognizer.scale
            //            recognizer.scale = 1.0  // Reset scale to get relative scale next time we are in here
            //
            //        case .Ended:
            //            isAnimationInProgress = false
            
        case .Began:
            snapshot = snapshotViewAfterScreenUpdates(true)
            snapshot?.alpha = 0.8
            isAnimationInProgress = true
            self.addSubview(snapshot!)
            
        case .Changed:
            
            let oldScale = snapshot!.frame.size.width / self.frame.size.width

            snapshot?.frame.size.width  *= recognizer.scale
            snapshot?.frame.size.height *= recognizer.scale

            let newScale = snapshot!.frame.size.width / self.frame.size.width
            let scaleChange = newScale - oldScale
            
            let offsetFromOrigin = CGPoint(x: bounds.midX + originOffset.x, y: bounds.midY + originOffset.y)
            let newOffsetFromOrigin = CGPoint(x: -offsetFromOrigin.x * scaleChange, y: -offsetFromOrigin.y * scaleChange )
            
            snapshot!.center = CGPoint(x: snapshot!.center.x + newOffsetFromOrigin.x,
                                       y: snapshot!.center.y + newOffsetFromOrigin.y)
            
            recognizer.scale = 1.0  // Reset scale to get relative scale next time we are in here
            
        case .Ended:
            let changedScale = snapshot!.frame.size.width / self.frame.size.width
            
            scale *= changedScale
            snapshot!.removeFromSuperview()
            snapshot = nil
            isAnimationInProgress = false
            
        default:
            break
        }
    }
    
    private var snapshot: UIView?
    private var panSinceLastRefresh:CGPoint?
    
    func panGraph(recognizer: UIPanGestureRecognizer) {
        
        switch recognizer.state {
            //        case .Changed:
            //            isAnimationInProgress = true
            //
            //            originOffset = CGPoint(x: originOffset.x + recognizer.translationInView(self).x,
            //                                   y: originOffset.y + recognizer.translationInView(self).y)
            //
            //            recognizer.setTranslation(CGPoint(x: 0, y: 0), inView: self)// Reset translation to get relative translation next time we are in here
            //
            //        case .Ended:
            //            isAnimationInProgress = false
            
            
        case .Began:
            snapshot = snapshotViewAfterScreenUpdates(true)
            snapshot!.alpha = 0.8
            self.addSubview(snapshot!)
            panSinceLastRefresh = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
            isAnimationInProgress = true
            
        case .Changed:
            snapshot?.center.x += recognizer.translationInView(self).x
            snapshot?.center.y += recognizer.translationInView(self).y
            recognizer.setTranslation(CGPoint(x: 0, y: 0), inView: self)// Reset translation to get relative translation next time we are in here
            
        case .Ended, .Cancelled:
            originOffset =  CGPoint(x: snapshot!.center.x - bounds.midX + originOffset.x,
                                    y: snapshot!.center.y - bounds.midY + originOffset.y)
            snapshot?.removeFromSuperview()
            snapshot = nil
            isAnimationInProgress = false
            
        default:
            break
        }
    }
    
    func resetOrigin(recognizer: UITapGestureRecognizer) {
        
        switch recognizer.state {
        case .Ended:
            originOffset = CGPoint(x: recognizer.locationInView(self).x - bounds.midX, y: recognizer.locationInView(self).y - bounds.midY)
            
        default:
            break
        }
    }
    
    
    // Code to draw custom graph view
    override func drawRect(rect: CGRect) {
        // Drawing code
        //        print("bounds.height = \(bounds.height) bounds.width = \(bounds.width)")
        //        print("origin = \(CGPoint(x: bounds.midX + originOffset.x, y: bounds.midY + originOffset.y))")
        //        print("bounds.minX = \(bounds.minX) bounds.maxX = \(bounds.maxX)")
        
        if !isAnimationInProgress {
            
            
            axesDrawer.contentScaleFactor = self.contentScaleFactor
            
            let origin = CGPoint(x: bounds.midX + originOffset.x, y: bounds.midY + originOffset.y)
            
            axesDrawer.drawAxesInRect(bounds,
                                      origin: origin,
                                      pointsPerUnit: scale )
            
            drawGraphInRect(bounds, origin: origin, pointsPerUnit: scale)
        }
    }
    
    
    private func drawGraphInRect(bounds: CGRect, origin: CGPoint, pointsPerUnit: CGFloat) {
        
        var yValue: Double
        var xValue: Double
        var yPoint: CGFloat
        
        var previousPoint: CGPoint? = nil
        var currentPoint: CGPoint?
        
        let path = UIBezierPath()
        color.set()
        
        let stepSize: CGFloat = isAnimationInProgress == true ? 5.0 : 1.0 // Animation is expensive. Skip 5 points on x axis when animating.
        
        for xPoint in (bounds.minX).stride(to: bounds.maxX, by: stepSize) {
            //print(" X = \(getXValForPoint(x, bounds: bounds, origin: origin)) for point \(x)")
            
            xValue = getXValForPoint(xPoint, bounds: bounds, origin: origin)
            
            yValue = getNextValFunc!(xValue)
            
            // TODO: continue here.
            yPoint = getPointForYVal(yValue, bounds: bounds, origin: origin)
            
            currentPoint = CGPoint(x: xPoint, y: yPoint)
            
            if !CGRectContainsPoint(bounds, CGPoint(x: xPoint, y: yPoint)) {
                currentPoint = nil
            } else {
                if previousPoint != nil {
                    
                    path.moveToPoint(previousPoint!)
                    path.addLineToPoint(currentPoint!)
                }
            }
            
            previousPoint = currentPoint
            
            //            print("y = \(yValue) for x = \(xValue). yPoint = \(yPoint)")
        }
        path.stroke()
        
    }
    
    
    private func getXValForPoint(x: CGFloat, bounds: CGRect, origin: CGPoint) -> Double {
        
        return Double((x - origin.x)/scale)
    }
    
    private func getPointForYVal(y: Double, bounds: CGRect, origin: CGPoint) -> CGFloat {
        
        return origin.y - CGFloat(y)*scale
    }
    
    // we want the axes and hashmarks to be exactly on pixel boundaries so they look sharp
    // setting contentScaleFactor properly will enable us to put things on the closest pixel boundary
    // if contentScaleFactor is left to its default (1), then things will be on the nearest "point" boundary instead
    // the lines will still be sharp in that case, but might be a pixel (or more theoretically) off of where they should be
    
    private func alignedPoint(x x: CGFloat, y: CGFloat, insideBounds: CGRect? = nil) -> CGPoint?
    {
        let point = CGPoint(x: align(x), y: align(y))
        if let permissibleBounds = insideBounds where !CGRectContainsPoint(permissibleBounds, point) {
            return nil
        }
        return point
    }
    
    private func align(coordinate: CGFloat) -> CGFloat {
        return round(coordinate * contentScaleFactor) / contentScaleFactor
    }
    
    
}
