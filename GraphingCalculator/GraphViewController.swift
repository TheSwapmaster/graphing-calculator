//
//  GraphViewController.swift
//  Calcmaster
//
//  Created by Swapnil Harsule on 10/6/16.
//  Copyright © 2016 Swapnil Harsule. All rights reserved.
//

import UIKit


class GraphViewController: UIViewController {
    
    private struct GraphViewInfo {
        
        private var scaleKey = "GraphViewController.Scale"
        private var originOffsetKey = "GraphViewController.OriginOffset"
        
        private var defaults = NSUserDefaults.standardUserDefaults()
        
        var scale: CGFloat {
            set {
                defaults.setObject(newValue, forKey: scaleKey)
                defaults.synchronize()
            }
            get {
                return defaults.objectForKey(scaleKey) as? CGFloat ?? 100.0
            }
        }
        
        var originOffset: CGPoint { // offset relative to center of graphView
            set{
                defaults.setObject([newValue.x, newValue.y] , forKey: originOffsetKey)
                defaults.synchronize()
            }
            get {
                if let originOffsetArray = defaults.objectForKey(originOffsetKey) as? [CGFloat] {
                    return CGPoint(x: originOffsetArray.first! , y: originOffsetArray.last!)
                }
                return CGPoint(x: 0.0, y: 0.0)
            }
        }
        
    }
    
    private var graphViewInfo = GraphViewInfo()
    
    var graphInfo = GraphInfo(xyEquation: nil, getValFunc: nil) {
        
        didSet {
            updateGraph()
        }
    }
    
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.getNextValFunc = self.getResultForValue
            
            // Restore defaults
            graphView.originOffset = self.graphViewInfo.originOffset
            graphView.scale = self.graphViewInfo.scale
            
            // Add gestures
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(GraphViewController.changeScale(_:))))
            
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(GraphViewController.panGraph(_:))))
            
            let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(GraphViewController.resetOrigin(_:)))
            doubleTapGestureRecognizer.numberOfTapsRequired = 2
            
            graphView.addGestureRecognizer(doubleTapGestureRecognizer)
            
            updateGraph()
            
        }
    }
    
    @objc private func panGraph(recognizer: UIPanGestureRecognizer) {
        graphView.panGraph(recognizer)
        
        if recognizer.state == .Ended {
            graphViewInfo.originOffset = graphView.originOffset
        }
    }
    
    
    @objc private func changeScale(recognizer: UIPinchGestureRecognizer) {
        graphView.changeScale(recognizer)
        
        if recognizer.state == .Ended {
            graphViewInfo.scale = graphView.scale
        }
    }
    
    
    @objc private func resetOrigin(recognizer: UITapGestureRecognizer) {
        graphView.resetOrigin(recognizer)
        
        if recognizer.state == .Ended {
            graphViewInfo.originOffset = graphView.originOffset
        }
    }
    
    
    
    
    
    func getResultForValue(value: Double) -> Double {
        
        guard (graphInfo.getValFunc != nil && graphInfo.xyEquation != nil) else {
            return 0.0
        }
        return graphInfo.getValFunc!(value, graphInfo.xyEquation!)
        
    }
    
    
    // Function to udate Graph View
    func updateGraph() {
        
        if graphView != nil {
            
            graphView.setNeedsDisplay()
        }
        
    }
    
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        let sizeBeforeRotation = graphView.bounds.size
        
        coordinator.animateAlongsideTransition(nil) { context in
            
            self.graphView.originOffset.x *= self.graphView.bounds.size.width / sizeBeforeRotation.width
            self.graphView.originOffset.y *= self.graphView.bounds.size.height / sizeBeforeRotation.height
            
        }
    }
}
