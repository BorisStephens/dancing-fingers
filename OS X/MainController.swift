//
//  ViewController.swift
//  Forced Keyboard
//
//  Created by Luke Stephens on 25/6/17.
//  Copyright © 2017 Luke Stephens. All rights reserved.
//

import UIKit

class iPhoneViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isMultipleTouchEnabled = true
        print(self.view.isMultipleTouchEnabled)
        // Do any additional setup after loading the view, typically from a nib.
        
        //        let keyboardHands = ForcedKeyboardGestureRecognizer(target: self, action: #selector(reset), threshold: 0.5)
//        self.view.addGestureRecognizer(keyboardHands)
        
        let keyboardHandPans = ForcedKeyboardGestureRecognizer(target: self, action: #selector(test2), threshold: 0.65)
        self.view.addGestureRecognizer(keyboardHandPans)
        self.doSequentialHaptics(input: "10000") // 1
        //self.doSequentialHaptics(input: "01000") // 2
        //self.doSequentialHaptics(input: "11000") // 3
        
        // Add on top
        let touch = UITapGestureRecognizer(target: self, action: #selector(tapRequestDoSequentialHaptics))
        touch.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(touch)
    }
    
    @objc func tapRequestDoSequentialHaptics(){
        doSequentialHaptics(input:"11000")
    }
    
    @objc func doSequentialHaptics(input:String = "10000"){
        
        // Prep the hardware
        var generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
//        var feedbackGenerator = UISelectionFeedbackGenerator()
//        feedbackGenerator.prepare()
//        feedbackGenerator.selectionChanged()
        
        /* Loop All Characters And Send Feedback */
        var lag = 0.100 // Miliseconds
        for character in input.characters {
            if(character == "0"){
                DispatchQueue.main.asyncAfter(deadline: .now() + lag) {
                    generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + lag) {
                    generator = UIImpactFeedbackGenerator(style: .heavy)
                    generator.impactOccurred()
                }
            }
            
            // Add to lag
            lag += 0.200
        }
    }
    
    var feedbackGenerator : UISelectionFeedbackGenerator? = nil
    
    @objc func test(sender: UIPanGestureRecognizer! = nil){
        
        switch(sender.state) {
        case .began:
            
            print("We are now panning")
            
            // Instantiate a new generator.
            feedbackGenerator = UISelectionFeedbackGenerator()
            
            // Prepare the generator when the gesture begins.
            feedbackGenerator?.prepare()
            
        case .changed:
            
            // Check to see if the selection has changed...
            //if  myCustomHasSelectionChangedMethod(translationPoint: sender.translation(in: view)) {
            
            // Trigger selection feedback.
            feedbackGenerator?.selectionChanged()
            
            // Keep the generator in a prepared state.
            feedbackGenerator?.prepare()
            //            }
            
        case .cancelled, .ended, .failed:
            
            // Release the current generator.
            feedbackGenerator = nil
            
        default:
            // Do Nothing.
            break
        }
    }
    var previousNumber = 0
    @objc func test2(sender: ForcedKeyboardGestureRecognizer? = nil){
        
        let keyboardOutput = Array(sender!.keyboardOutput)
        
        /* Graphics */
        self.drawCircle(x: 20, color: UIColor.red.cgColor,     stroke: (keyboardOutput[0] == "0" ? true : false))
        self.drawCircle(x: 140, color: UIColor.green.cgColor,  stroke: (keyboardOutput[1] == "0" ? true : false))
        self.drawCircle(x: 260, color: UIColor.blue.cgColor,   stroke: (keyboardOutput[2] == "0" ? true : false))
        self.drawCircle(x: 380, color: UIColor.orange.cgColor, stroke: (keyboardOutput[3] == "0" ? true : false))
        
        /* Numbers */
        let finger1 = (keyboardOutput[0] == "0" ? 1 : 0)
        let finger2 = (keyboardOutput[1] == "0" ? 2 : 0)
        let finger3 = (keyboardOutput[2] == "0" ? 4 : 0)
        let finger4 = (keyboardOutput[3] == "0" ? 8 : 0)
        let number:Int = finger1+finger2+finger3+finger4
        // print("State is now \(String(describing: sender?.keyboardOutput)) producing \(number)")
        self.labelLetter.text = "\(number)"
        
        if(previousNumber != number){
            doSequentialHaptics(input: sender!.keyboardOutput)
            previousNumber = number
        }
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
class ForcedKeyboardGestureRecognizer: UIPanGestureRecognizer
{
    var vibrateOnDeepPress = false
    let threshold: CGFloat
    
    public var keyboardOutput = ""
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
            // DEBUG: print("Forced Key Touches Begun \(String(describing: event.allTouches?.count))")
            handleTouch(touches:event.allTouches!)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        do {
           // print("Forced Key Supposed Movement")
            handleTouch(touches:event.allTouches!)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        
        state = deepPressed ? UIGestureRecognizerState.ended : UIGestureRecognizerState.failed
        
        deepPressed = false
        if event.allTouches!.count == 0 {
            self.keyboardOutput = "0000"
        }
        // DEBUG: print("Forced Key Touches Ended \(String(describing: event.allTouches?.count))")
    }
    
    private func handleTouch(touches: Set<UITouch>){
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
        // TODO: Traitor, Index cannot be trusted. Use location to determine left to right sequence
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
        
        // DEBUG: print("\(String) Touches: \(touches.count)")
        
        self.keyboardOutput = String
        return
    }
}
