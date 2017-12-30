//
//  GraphicViewController.swift
//  CalculatorBrain_3
//
//  Created by Юля Пономарева on 24.12.2017.
//  Copyright © 2017 Юля Пономарева. All rights reserved.
//

import UIKit

class GraphicViewController: UIViewController {
    
    @IBOutlet fileprivate var graphicView: GraphicView! {
        didSet {
            self.graphicView.getCoordinate = { (x) -> CGFloat in
                if let f = self.function {
                    return CGFloat(f(x))
                }
                return CGFloat()
            }

            let pinchRegonizer = UIPinchGestureRecognizer(
                target: self.graphicView,
                action: #selector(GraphicView.changeScale(byReactingTo: ))
            )
            self.graphicView.addGestureRecognizer(pinchRegonizer)
            
            let panRecognizer = UIPanGestureRecognizer(
                target: self.graphicView,
                action: #selector(GraphicView.move(byReactingTo: ))
            )
            self.graphicView.addGestureRecognizer(panRecognizer)
            
            let tapRecognizer = UITapGestureRecognizer(
                target: self.graphicView,
                action: #selector(GraphicView.doubleTap)
            )
            tapRecognizer.numberOfTapsRequired = 2
            self.graphicView.addGestureRecognizer(tapRecognizer)
        }
    }
    
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.graphicView.setNeedsDisplay()
    }
    
    var function: ((CGFloat) -> CGFloat)?
}

