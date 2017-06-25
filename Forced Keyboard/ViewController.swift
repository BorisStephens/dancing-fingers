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
        
        let keyboardHands = ForcedKeyboardGestureRecognizer(target: self, action: #selector(reset), threshold: 0.5)
        self.view.addGestureRecognizer(keyboardHands)
        
    }
    
    @objc func reset(){
        
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
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.reset()
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

import UIKit.UIGestureRecognizerSubclass

// MARK: GestureRecognizer
class ForcedKeyboardGestureRecognizer: UIGestureRecognizer
{
    var vibrateOnDeepPress = false
    let threshold: CGFloat
    
    private var deepPressed: Bool = false
    private var Stroke1 = false
    private var Stroke2 = false
    private var Stroke3 = false
    private var Stroke4 = false
    
    required init(target: AnyObject?, action: Selector, threshold: CGFloat)
    {
        self.threshold = threshold
        super.init(target: target, action: action)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        do {
            print("Forced Key Touches Begun")
            handleTouch(touches:touches)
        }
    }
    
    override func touchesEstimatedPropertiesUpdated(_ touches: Set<UITouch>) {
        print("Forced Key Estimate Attempt")
        handleTouch(touches: touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        do {
            print("Forced Key Supposed Movement")
            handleTouch(touches:touches)
        }
    }
    
    override func pressesChanged(_ presses: Set<UIPress>, with event: UIPressesEvent) {
        print("Forced Key Supposed Movement")
        handlePress(touches: presses)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        
        state = deepPressed ? UIGestureRecognizerState.ended : UIGestureRecognizerState.failed
        
        deepPressed = false
    }
    
    private func handleTouch(touches: Set<UITouch>){
    }
    
    private func handlePress(touches: Set<UIPress>){
        state = UIGestureRecognizerState.began
        deepPressed = true
        
        // MARK: Exclusions, Reset Fingers Not There
        switch touches.count {
        case 1:
            Stroke2 = false
            Stroke3 = false
            Stroke4 = false
        case 2:
            Stroke3 = false
            Stroke4 = false
        case 3:
            Stroke4 = false
        default: break
        }
        
        // MARK: Fingers, Check Them All
        let threashold = self.threshold
        for(index, touch) in touches.enumerated() {
            let force = touch.force
            
            // First
            if force > threashold && index == 0 {Stroke1 = true}
            if force < threashold && index == 0 {Stroke1 = false}
            
            // Second
            if force > threashold && index == 1 {Stroke2 = true}
            if force < threashold && index == 1 {Stroke2 = false}
            
            // Third
            if force > threashold && index == 2 {Stroke3 = true}
            if force < threashold && index == 2 {Stroke3 = false}
            
            // Fourth
            if force > threashold && index == 3 {Stroke4 = true}
            if force < threashold && index == 3 {Stroke4 = false}
        }
        
        // MARK: Binary, Return
        var String = ""
        if(Stroke1){String += "1"} else {String += "0"}
        if(Stroke2){String += "1"} else {String += "0"}
        if(Stroke3){String += "1"} else {String += "0"}
        if(Stroke4){String += "1"} else {String += "0"}
        print("\(String) Touches: \(touches.count)")
        return
    }
}
