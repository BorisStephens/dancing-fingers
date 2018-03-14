//
//  ViewController.swift
//  Forced Keyboard
//
//  Created by Luke Stephens on 25/6/17.
//  Copyright © 2017 Luke Stephens. All rights reserved.
//

import UIKit

class iPhoneViewController: UIViewController {
    
    var dancingFingers = DancingFingers() // Eventually this should be a controller that is implemented into the main iPhoneVierwController or alongside the UIViewController.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isMultipleTouchEnabled = true
        print(self.view.isMultipleTouchEnabled)
        // Do any additional setup after loading the view, typically from a nib.
        
        //        let keyboardHands = ForcedKeyboardGestureRecognizer(target: self, action: #selector(reset), threshold: 0.5)
//        self.view.addGestureRecognizer(keyboardHands)
        
        // Version iPhone Build that USES FORCE (NOT GREAT EXPERIENCE, IN FACT AWEFUL)
        //let keyboardHandPans = ForcedKeyboardGestureRecognizer(target: self, action: #selector(test2), threshold: 0.65)
        ///self.view.addGestureRecognizer(keyboardHandPans)
        //self.doSequentialHaptics(input: "10000") // 1
        //self.doSequentialHaptics(input: "01000") // 2
        //self.doSequentialHaptics(input: "11000") // 3
        
        // Add on top
        //let touch = UITapGestureRecognizer(target: self, action: #selector(tapRequestDoSequentialHaptics))
        //touch.numberOfTapsRequired = 1
        //self.view.addGestureRecognizer(touch)
    }
    
    func trackingDistance(tracking:BinaryFinger, touch:UITouch) -> CGFloat{
        // Final Version
        var distance:CGFloat = 0
        switch MagicTrackingState {
        case .horizontal:
            distance = tracking.touch.preciseLocation(in: self.view).x - touch.preciseLocation(in: self.view).x
            break
        case .vertical:
            distance = tracking.touch.preciseLocation(in: self.view).y - touch.preciseLocation(in: self.view).y
            break
        case .normalized:
            //distance = touch.normalizedPosition.distanceToPoint(p: tracking.touch.normalizedPosition)
            break
        case .distanceXY:
            //distance = touch.pos(self.view).distanceToPoint(p: tracking.touch.pos(self.view))
            break
        default:
            distance = 0//touch.normalizedPosition.distanceToPoint(p: tracking.touch.normalizedPosition)
        }
        return abs(distance)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Bring alive
        print("Bring Alive These bad boys")
        let touches = event?.allTouches
        touches?.forEach { (touch) in
            
            var closestTouch: Int = -1
            var distanceBest:CGFloat = CGFloat(1000.00)
            
            // Who is the Closest to specify who just arrived
            CurrentTouchState.enumerated().forEach({ (arg) in
                let (index, tracking) = arg
                let distance = trackingDistance(tracking:tracking, touch:touch)
                if(distance < distanceBest){
                    closestTouch = index
                    distanceBest = distance
                }
            })
            if closestTouch != -1 {
                CurrentTouchState[closestTouch].alive = true
            }
            let phases = [
                "1":"Began",
                "2":"Moved",
                "4":"Stationary",
                "7":"Touching",
                "8":"Ending",
                "16":"Cancelled"
            ]
            let phase = phases["\(touch.phase.rawValue)"]!
            print(" 🖖+﹣ Finger\(closestTouch)  \(phase)")
        }
        
        // Check, New Finger
        let allTouchesCount = event?.allTouches?.count
        // Instant Five Finger Detection
        if(allTouchesCount == 5 && CurrentTouchState.count < 5){
            //startTime = NSDate()
            CurrentTouchState.removeAll()
            
            // Load All
            event?.allTouches?.forEach({ (firstTouch) in
                CurrentTouchState.append(BinaryFinger(alive: true, distance:0, touch: firstTouch))
            })
            
            // Sort Horizontally
            CurrentTouchState = CurrentTouchState.sorted {_,_ in
                //$0.touch.normalizedPosition.x < $1.touch.normalizedPosition.x
            }
        }
        
        // More than five or doing it progressivly
        if(CurrentTouchState.count < allTouchesCount!){
            // New Finger Detected, Add To Tracker
            let touches = event?.allTouches
            
            //let touches = event.touches(matching: UIPressPhase.began, in: self.view)
            touches?.forEach({ (firstTouch) in
                CurrentTouchState.append(BinaryFinger(alive: true, distance:0, touch: firstTouch))
            })
        }
        //doMagic()
    }
    
    //override func touchesEnded(with event: UIEvent) {
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // No fingers touching at all, let us calculate
        let touches = event?.allTouches
        let phases = [
            "1":"Began",
            "2":"Moved",
            "4":"Stationary",
            "7":"Touching",
            "8":"Ending",
            "16":"Cancelled"
        ]
        
        for touch in touches! {
            let phase = phases["\(touch.phase.rawValue)"]
            print(phase ?? "default touch phase apparently")
        }
        
        // Touches All Ending Then We Should probably calcualte
        var touchesEndingAll = true
        for touch in touches! {
            if touch.phase.rawValue != 8 {
                touchesEndingAll = false
            }
        }
        if touchesEndingAll {
            MagicState = .calculating
            let number = self.dancingFingers.binaryFingerCalculation()
        }
        
        // Touches Ending and only one, you know what that means... calculating time
        if touches?.count == 1 && CurrentTouchState.count > 4 {
            MagicState = .calculating
            let number = self.dancingFingers.binaryFingerCalculation()
        }
        
        // Touches Ending and in the bottom left corner of Magic Trackpad
        if touches?.count == 1 {
            
//            if touches?.first!.pos(self.view).x < 40 {
//                //self.resetTimer()
//                //self.testing.stringValue = ""
//                if(SynthesizeVoice){
//                    //let mySynth: NSSpeechSynthesizer = NSSpeechSynthesizer(voice: NSSpeechSynthesizer.defaultVoice)!
//                    // Verna talks once
//                    //mySynth.startSpeaking("reset")
//                    print "This is where we would noramlly speak but siri is spoken to differently on iOS than it is on Mac OS"
//                }
//            }
        }
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
    
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.reset()
//    }
    
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


