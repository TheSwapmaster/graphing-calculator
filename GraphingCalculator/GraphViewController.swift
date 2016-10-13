//
//  GraphViewController.swift
//  Calcmaster
//
//  Created by Swapnil Harsule on 10/6/16.
//  Copyright © 2016 Swapnil Harsule. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: #selector(graphView.changeScale(_:))))
            
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView, action: #selector(graphView.panGraph(_:))))
            
            let doubleTapGestureRecognizer = UITapGestureRecognizer(target: graphView, action: #selector(graphView.resetOrigin(_:)))
            doubleTapGestureRecognizer.numberOfTapsRequired = 2
            
            graphView.addGestureRecognizer(doubleTapGestureRecognizer)
            
        }
    }
    

}
