//
//  ViewController.swift
//  Forced Keyboard
//
//  Created by Luke Stephens on 25/6/17.
//  Copyright © 2017 Luke Stephens. All rights reserved.
//

import UIKit

class Drawing {
    
    /* DRAWING */
    func drawCircle(x:Int,color: CGColor, stroke: Bool){
        /* Draw Circle */
        let shapeLayer = CAShapeLayer()
        
        // Sequence
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x:x,y: 25),
            radius: CGFloat(8),
            startAngle: CGFloat(0),
            endAngle:CGFloat(Double.pi * 2),
            clockwise: true)
        shapeLayer.path = circlePath.cgPath
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = 3.0
        shapeLayer.fillColor = UIColor.white.cgColor
        if(stroke == true){
            shapeLayer.fillColor = color
        }
        
        // Add the cirlces
        self.view.layer.addSublayer(shapeLayer)
    }
    
}


