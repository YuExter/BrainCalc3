//
//  GraphicView.swift
//  CalculatorBrain_3
//
//  Created by Юля Пономарева on 24.12.2017.
//  Copyright © 2017 Юля Пономарева. All rights reserved.
//

import UIKit

class GraphicView: UIView {
    
    var isOriginPointSet: Bool = false
    
    @IBInspectable var origin: CGPoint = CGPoint() {
        didSet {
            if self.origin.x == 0 && self.origin.y == 0 {
                self.isOriginPointSet = false
            } else {
                self.isOriginPointSet = true
            }
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var lineWidth: CGFloat = 1.0
    
    @IBInspectable var color = UIColor.black
    
    @IBInspectable var scale: CGFloat = 50.0 {
        didSet
        {
            self.setNeedsDisplay()
        }
    }
    
    var getCoordinate: ((CGFloat) -> CGFloat)?
    
    fileprivate func drawPathForFunction() -> UIBezierPath {
        let path = UIBezierPath()
        
        let width: Int = Int(self.bounds.size.width)
        var point: CGPoint = CGPoint()
        
        var noPathPoint = true
        self.origin = self.isOriginPointSet ? self.origin : CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
        
        for pixel in 0...width {
            point.x = CGFloat(pixel)
            guard let function = self.getCoordinate else { return UIBezierPath() }
            let y = function((point.x - self.origin.x) / self.scale)
            
            if !y.isNormal && !y.isZero {
                noPathPoint = true
                continue
            }
            
            point.y = self.origin.y - CGFloat(y * self.scale)
            
            if (noPathPoint) {
                path.move(to: point)
                noPathPoint = false
            } else {
                path.addLine(to: point)
            }
        }
        
        path.lineWidth = lineWidth
        return path
    }
    
    @objc func changeScale(byReactingTo pinchRecognizer: UIPinchGestureRecognizer) {
        switch pinchRecognizer.state {
        case .changed, .ended:
            self.scale *= pinchRecognizer.scale
            pinchRecognizer.scale = 1
        default:
            break
        }
    }
    
    @objc func move(byReactingTo panRecognizer: UIPanGestureRecognizer) {
        switch panRecognizer.state {
        case .changed:
            let translation = panRecognizer.translation(in: self)
            self.origin.x += translation.x
            self.origin.y += translation.y
            
            panRecognizer.setTranslation(CGPoint(), in: self)
        default:
            break
        }
    }
    
    @objc func doubleTap(byReactingTo tapRecognizer: UITapGestureRecognizer) {
        switch tapRecognizer.state {
        case .ended:
            self.origin = tapRecognizer.location(in: self)
        default:
            break
        }
    }
    
    override func draw(_ rect: CGRect) {
        let graphBoundaries = CGRect(
            x: self.bounds.minX,
            y: self.bounds.minY,
            width: self.bounds.size.width,
            height: self.bounds.size.height
        )
        
        self.color.set()
        self.drawPathForFunction().stroke()
        
        let drawer = AxesDrawer()
        drawer.drawAxes(
            in: graphBoundaries,
            origin: self.origin,
            pointsPerUnit: CGFloat(self.scale)
        )
    }
}


