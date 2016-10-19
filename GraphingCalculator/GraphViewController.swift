//
//  GraphViewController.swift
//  Calcmaster
//
//  Created by Swapnil Harsule on 10/6/16.
//  Copyright © 2016 Swapnil Harsule. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {

    var graphInfo = GraphInfo(xyEquation: nil, getValFunc: nil) {
        
        didSet {
            updateGraph()
        }
    }
    
    
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.getNextValFunc = self.getResultForValue
            
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: #selector(graphView.changeScale(_:))))
            
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView, action: #selector(graphView.panGraph(_:))))
            
            let doubleTapGestureRecognizer = UITapGestureRecognizer(target: graphView, action: #selector(graphView.resetOrigin(_:)))
            doubleTapGestureRecognizer.numberOfTapsRequired = 2
            
            graphView.addGestureRecognizer(doubleTapGestureRecognizer)
            
            updateGraph()
            
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
            
            graphView.originOffset = CGPoint(x: 0, y: 0) // Setting this variable in graphView calls SetNeedsDisplay
        }
        
    }
    

}
