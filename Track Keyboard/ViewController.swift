//
//  ViewController.swift
//  Track Keyboard
//
//  Created by Luke Stephens on 28/6/17.
//  Copyright © 2017 Luke Stephens. All rights reserved.
//

// Make sequenceing work with remembering finger positions
// [•] Where is the finger 1...5?
// [•] Did finger rise up, which one was it 1...5?
// [•] Did finger go back down, which one was it 1...5?
// [•] Calculate up to 5
// Make sequenceing work with remembering positions
// [•] Bug: Sequence goes out of whack, Cause Dictionary -> Swap To Array
// –– Mile Stone: Word Typing --
// [ ] Where did my fingers go again? Draw dots
// [ ] (x points) Distance rendered above draw dots

import Cocoa
struct BinaryFinger {
    
    var alive: Bool = false
    let touch:NSTouch
    
    // println() should print just the unit name:
    var description: String { return touch.identity as! String }
}

var MagicMode = "Counting"

class MacViewController: NSViewController {
    
    @IBOutlet weak var settingMagicMode: NSSegmentedControl!
    @IBOutlet weak var testing: NSTextField!
    
    var CurrentTouchState:Array<BinaryFinger> = []
    //public var MagicMode = "Counting"
    
    func doMagicNumbers(){
        // User Interface Update
        let number = self.binaryFingerCalculation()
        self.testing.stringValue = String(number)
    }
    
    func doMagicWords(){
        
        // Calculating Binary Finger
        let number = self.binaryFingerCalculation()
        
        let anArray = ["Hello","My","Name","Is","Luke James Stephens","And","This","Me","Doing","A","Test","Of","How","Fast","I","Can","Type","On","Keyboard"]
        
        // User Interface Update
        self.testing.stringValue = anArray[number]
        
    }
    
    func doMagic(){
        
        if(CurrentTouchState.count < 4){
            self.testing.stringValue = "Please add a finger, need 4 we have \(CurrentTouchState.count)"
        } else {
            if(MagicMode == "Counting"){
                self.doMagicNumbers()
            }
            if(MagicMode == "Words"){
                self.doMagicWords()
            }
        }
    }
    
    func binaryFingerCalculation() -> Int{
        // Calculating Binary Finger
        var number:Int = 0
        let pwrInt:(Int,Int)->Int = { a,b in return Int(pow(Double(a),Double(b))) }
        self.CurrentTouchState.enumerated().forEach { (arg) in
            let (index,finger) = arg
            if(finger.alive){
                let addition = pwrInt(2,index)
                number += addition
            }
        }
        print("Current Binary Finger is \(number)")
        return number
    }
    
    
    override func touchesMoved(with event: NSEvent) {
        doMagic()
    }
    
    override func touchesBegan(with event: NSEvent) {
        
        // Check, New Finger
        let allTouchesCount = event.allTouches().count
        if(CurrentTouchState.count < allTouchesCount){
            // New Finger Detected, Add To Tracker
                let touches = event.touches(matching: NSTouch.Phase.began, in: self.view)
            touches.forEach({ (firstTouch) in
                CurrentTouchState.append(BinaryFinger(alive: true, touch: firstTouch))
            })
        } else {
            // Check, What Fingers Are Still There Who Came Back?
            let touches = event.touches(matching: NSTouch.Phase.any, in: self.view)
            touches.forEach { (touch) in
                var closestTouch: Int = -1
                var distanceBest:CGFloat = CGFloat(1000.00)
                
                // Who is the Closest to specify who just arrived
                CurrentTouchState.enumerated().forEach({ (arg) in
                    
                    let (index, tracking) = arg
                    let distance = hypot(
                        touch.normalizedPosition.x - tracking.touch.normalizedPosition.x,
                        touch.normalizedPosition.y - tracking.touch.normalizedPosition.y
                    )
                    if(distance < distanceBest){
                        closestTouch = index
                        distanceBest = distance
                    }
                })
                
                // Update Who Arrived Back
                if(closestTouch != -1){
                    CurrentTouchState[closestTouch].alive = true
                }
            }
        }
        doMagic()
    }
    
    override func touchesEnded(with event: NSEvent) {
        let touches = event.touches(matching: NSTouch.Phase.ended, in: self.view)
        touches.forEach { (touch) in
            var closestTouch: Int = -1
            var distanceBest:CGFloat = CGFloat(1000.00)
            
            // Who is the Closest to specify who just departed
            CurrentTouchState.enumerated().forEach({ (arg) in
                
                let (index, tracking) = arg
                let distance = hypot(
                    touch.normalizedPosition.x - tracking.touch.normalizedPosition.x,
                    touch.normalizedPosition.y - tracking.touch.normalizedPosition.y
                )
                if(distance < distanceBest){
                    closestTouch = index
                    distanceBest = distance
                }
            })
            
            // Update Who Arrived Back
            if(closestTouch != -1){
                CurrentTouchState[closestTouch].alive = false
            }
        }
        
        doMagic()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.acceptsTouchEvents = true
        // Do any additional setup after loading the view.
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}

//print("Finger Check:")
//touches.forEach { (touch) in
//    print("    Location, \(touch.normalizedPosition) \(touch.phase)")
//}

//func doMagicKeyboard(){ // Really need a bigger trackpad
//    // 78
//}
//
//func doMagicNavigation(){ // Agumented Reality, Swap out Frame 1, Frame 2
//
//}
//
//func doMagicDJ(){ // Map sounds... wow... that'll be quite a thing...
//
//}

