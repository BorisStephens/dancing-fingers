//
//  ViewController.swift
//  Forced Keyboard
//
//  Created by Luke Stephens on 25/6/17.
//  Copyright © 2017 Luke Stephens. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isMultipleTouchEnabled = true
        print(self.view.isMultipleTouchEnabled)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func reset(){
        Stroke1 = false
        Stroke2 = false
        Stroke3 = false
        Stroke4 = false
        
        self.drawCircle(x: 20, color: UIColor.red.cgColor,    stroke: false)
        self.drawCircle(x: 140, color: UIColor.green.cgColor,  stroke: false)
        self.drawCircle(x: 260, color: UIColor.blue.cgColor,   stroke: false)
        self.drawCircle(x: 380, color: UIColor.orange.cgColor, stroke: false)
    }
    
    @IBOutlet weak var labelLetter: UILabel!
    @IBOutlet weak var labelSentance: UITextView!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var Stroke1 = false,
        Stroke2 = false,
        Stroke3 = false,
        Stroke4 = false
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let threashold:CGFloat = 1.0
        for(index, touch) in touches.enumerated() {
            
            if #available(iOS 9.0, *) {
                if traitCollection.forceTouchCapability == UIForceTouchCapability.available {
                    
                    // 3D Touch capable
                    let force = touch.force///touch.maximumPossibleForce
                    
                    // First
                    if force > threashold && index == 0 {
                        Stroke1 = true
                    }
                    if force < threashold && index == 0 {
                        Stroke1 = false
                    }
                    
                    // Second
                    if force > threashold && index == 1 {
                        Stroke2 = true
                    }
                    if force < threashold && index == 1 {
                        Stroke2 = false
                    }
                    
                    // Third
                    if force > threashold && index == 2 {
                        Stroke3 = true
                    }
                    if force < threashold && index == 2 {
                        Stroke3 = false
                    }
                    
                    // Fourth
                    if force > threashold && index == 3 {
                        Stroke4 = true
                    }
                    if force < threashold && index == 2 {
                        Stroke4 = false
                    }
                }
            }
            
            self.drawCircle(x: 20, color: UIColor.red.cgColor,    stroke: Stroke1)
            self.drawCircle(x: 40, color: UIColor.green.cgColor,  stroke: Stroke2)
            self.drawCircle(x: 60, color: UIColor.blue.cgColor,   stroke: Stroke3)
            self.drawCircle(x: 80, color: UIColor.orange.cgColor, stroke: Stroke4)
        }
        
        
        self.detectNumber()
        
    }
    
    func detectLetter(){
        var String = ""
        if(Stroke1){
            String += "1"
        } else {
            String += "0"
        }
        
        if(Stroke2){
            String += "1"
        } else {
            String += "0"
        }
        
        if(Stroke3){
            String += "1"
        } else {
            String += "0"
        }
        
        if(Stroke4){
            String += "1"
        } else {
            String += "0"
        }
        
        /* Alphabet */
        self.labelLetter.text = "\(String)"
        
        if(self.labelLetter.text == "1000"){
           self.labelLetter.text = "A"
        }
        if(self.labelLetter.text == "1100"){
            self.labelLetter.text = "B"
        }
        if(self.labelLetter.text == "1110"){
            self.labelLetter.text = "C"
        }
        if(self.labelLetter.text == "1111"){
            self.labelLetter.text = "D"
        }
    }
    
    func detectNumber(){
        
        var String = 0
        if(Stroke1){
            String += 1
        }
        
        if(Stroke2){
            String += 2
        }
        
        if(Stroke3){
            String += 4
        }
        
        if(Stroke4){
            String += 8
        }
        
        /* Numbers */
        self.labelLetter.text = "\(String)"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //print("Count is up to \(touches.count)")
        
        for obj in touches {
            let touch = obj as UITouch
            let location = touch.location(in: self.view)
            //print(location)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.reset()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("A cancel event happened")
    }
    
    
    
    
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

