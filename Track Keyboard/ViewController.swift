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
// [•] Training Mode, Record from start point of 1 till user reaches 15
// –– Mile Stone: Number Counting to 15 -- Try beat 25 seconds
// [•] Where did my fingers go again?
// [•] (x points) Distance rendered above draw dots « Not very accurate ... not sure why

// Learnings / Open Loops
// [ ] Draw dots « Apparently this is really hard in OS X... sad panda
//

import Cocoa

struct BinaryFinger {
    
    var alive: Bool = false
    let touch:NSTouch
    var distance:CGFloat = 0.00
    // println() should print just the unit name:
    var description: String { return touch.identity as! String }
}

var MagicMode = "Letters"
var CurrentTouchState:Array<BinaryFinger> = []

class MacViewController: NSViewController {
    
    @IBOutlet weak var settingMagicMode: NSSegmentedControl!
    @IBOutlet weak var testing: NSTextField!
    @IBOutlet weak var labelDurationAttempt: NSTextField!
    
    /* Timer Mode */
    let timerMode = true
    var startTime = NSDate()
    var endTime = NSDate()
    
    
    //public var MagicMode = "Counting"
    
    func doMagicNumbers(){
        // User Interface Update
        let number = self.binaryFingerCalculation()
        doTimer(number:number)
        self.testing.stringValue = String(number)
    }
    
    func doTimer(number:Int){
        if(timerMode){
            if(number == 31){
                startTime = NSDate()
                self.labelDurationAttempt.stringValue = String(startTime.timeIntervalSinceNow * -1)
            }
            if(number == 15){
                self.labelDurationAttempt.stringValue = String(startTime.timeIntervalSinceNow * -1)
            }
            self.labelDurationAttempt.stringValue = String(startTime.timeIntervalSinceNow * -1)
        }
    }
    
    func doMagicWords(){
        
        // Calculating Binary Finger
        let number = self.binaryFingerCalculation()
        
        let anArray = ["Hello","My","Name","Is","Luke James Stephens","And","This","Me","Doing","A","Test","Of","How","Fast","I","Can","Type","On","Keyboard"]
        
        // Try Numbers In Array That Exist
        if(number <= anArray.count){
            // User Interface Refelct the outcome
            self.testing.stringValue = anArray[number]
        }
    }
    
    func doMagicLetters(){
        // Calculating Binary Finger
        let number = self.binaryFingerCalculation() - 1
        let str = "abcdefghijklmnopqrstuvwxyz"
        
        let alphabets = Array(str)
        if(number <= alphabets.count && number >= 0){
            // User Interface Refelct the outcome
            self.testing.stringValue = "\(alphabets[number])"
        }
    }
    
    func doMagic(){
        
        let doTrack = false
        // Do Tracking?
        if(doTrack){
            doTrackingAssit()
        }
        
        // Getting Started Bro
        if(CurrentTouchState.count < 4){
            self.testing.stringValue = "Please add a finger, need 4 we have \(CurrentTouchState.count)"
        } else {
            if(MagicMode == "Counting"){
                self.doMagicNumbers()
            }
            if(MagicMode == "Words"){
                self.doMagicWords()
            }
            if(MagicMode == "Letters"){
                self.doMagicLetters()
            }
        }
    }
    
    func binaryFingerCalculation() -> Int{
        // Calculating Binary Finger
        var number:Int = 0
        let pwrInt:(Int,Int)->Int = { a,b in return Int(pow(Double(a),Double(b))) }
        CurrentTouchState.enumerated().forEach { (arg) in
            let (index,finger) = arg
            if(finger.alive){
                let addition = pwrInt(2,index)
                number += addition
            }
        }
        //print("Current Binary Finger is \(number)")
        return number
    }
    
    
    override func touchesMoved(with event: NSEvent) {
        
        /*
        let touches = event.touches(matching: NSTouch.Phase.any, in: self.view)
        touches.forEach { (touch) in
            var closestTouch: Int = -1
            var distanceBest:CGFloat = CGFloat(1000.00)
            
            // Where is everyone
            CurrentTouchState.enumerated().forEach({ (arg) in
                
                let (index, tracking) = arg
                // Version 2
                let xDist = (tracking.touch.normalizedPosition.x - touch.normalizedPosition.x)
                let yDist = (tracking.touch.normalizedPosition.y - touch.normalizedPosition.y)
                let distance = sqrt((xDist * xDist) + (yDist * yDist))
                if(distance < distanceBest){
                    closestTouch = index
                    distanceBest = distance
                }
            })
            
            // Update Distance
            if(closestTouch != -1){
                CurrentTouchState[closestTouch].distance = (distanceBest)
            }
        }
        */
        doMagic()
    }
    
    func doTrackingAssit(){
        print("–– Finger Postions -–")
        CurrentTouchState.enumerated().forEach({ (arg) in
            
            let (index, tracking) = arg
            print("  Finger \(index) in state of \(tracking.alive) tracking \(tracking.distance)")
        })
    }
    
    override func touchesBegan(with event: NSEvent) {
        
        // Reset
        CurrentTouchState.enumerated().forEach({ (arg) in
            var (index, tracking) = arg
            CurrentTouchState[index].alive = false
            //tracking.alive = false
        })
        
        // Check, New Finger
        let allTouchesCount = event.allTouches().count
        if(CurrentTouchState.count < allTouchesCount){
            // New Finger Detected, Add To Tracker
            let touches = event.touches(matching: NSTouch.Phase.began, in: self.view)
            touches.forEach({ (firstTouch) in
                CurrentTouchState.append(BinaryFinger(alive: true, touch: firstTouch, distance:0))
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
                    // Version 3
                    let distance = touch.normalizedPosition.distanceToPoint(p: tracking.touch.normalizedPosition)
                    if(distance < distanceBest){
                        closestTouch = index
                        distanceBest = distance
                    }
                })
                
                // Update Who Arrived Back
                if(closestTouch != -1){
                    CurrentTouchState[closestTouch].alive = true
                    CurrentTouchState[closestTouch].distance = (distanceBest)
                }
            }
        }
        doMagic()
    }
    
    override func touchesEnded(with event: NSEvent) {
        let touches = event.touches(matching: NSTouch.Phase.ended, in: self.view)
        touches.forEach { (touch) in
            
            //print("End for finger unknwon which is in a state of \(touch.phase)")
            
            var closestTouch: Int = -1
            var distanceBest:CGFloat = CGFloat(1000.00)
            
            // Who is the Closest to specify who just departed
            CurrentTouchState.enumerated().forEach({ (arg) in
                
                let (index, tracking) = arg
                // Version 3
                let distance = touch.normalizedPosition.distanceToPoint(p: tracking.touch.normalizedPosition)
                if(distance < distanceBest){
                    closestTouch = index
                    distanceBest = distance
                }
            })
            
            // Update Who Arrived Back + Check To See If Resting Or Dead
            if(closestTouch != -1){
                //CurrentTouchState[closestTouch].alive = false
                CurrentTouchState[closestTouch].distance = (distanceBest)
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

extension CGPoint {
    func distanceToPoint(p:CGPoint) -> CGFloat {
        return sqrt(pow((p.x - x), 2) + pow((p.y - y), 2))
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
