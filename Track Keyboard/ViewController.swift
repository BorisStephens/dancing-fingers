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

/* Core Varaibles */
var MagicMode = "Counting"
var CurrentTouchState:Array<BinaryFinger> = []
var MagicNumber = 0

class MacViewController: NSViewController {
    
    @IBOutlet weak var settingMagicMode: NSSegmentedControl!
    @IBOutlet weak var testing: NSTextField!
    @IBOutlet weak var labelDurationAttempt: NSTextField!
    
    /* Timer Mode */
    let timerMode = true
    var startTime = NSDate()
    var endTime = NSDate()
    
    @objc func doSequentialHaptics(input:String = "10000"){
        
        /* Loop All Characters And Send Feedback */
        var lag = 0.020 // Miliseconds
        for character in input.characters {
            if(character == "0"){
                DispatchQueue.main.asyncAfter(deadline: .now() + lag) {
                    NSHapticFeedbackManager.defaultPerformer.perform(NSHapticFeedbackManager.FeedbackPattern.generic, performanceTime: NSHapticFeedbackManager.PerformanceTime.now)
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + lag) {
                    NSHapticFeedbackManager.defaultPerformer.perform(NSHapticFeedbackManager.FeedbackPattern.levelChange, performanceTime: NSHapticFeedbackManager.PerformanceTime.now)
                }
            }
            
            // Add to lag
            lag += lag
        }
    }
    
    
    func doMagicNumbers(){
        // User Interface Update
        let number = self.binaryFingerCalculation()
        doTimer(number:number)
        self.testing.stringValue = String(number)
        
        /* Numbers Game, User Interface Update */
        UINumbersGame[number]?.backgroundColor = NSColor.green
        
        /* Numbers Game, User Interface Reset Number UI */
        if(number == 31){
            for (_, numberGame) in UINumbersGame {
                numberGame.backgroundColor = NSColor.red
            }
        }
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
    
    func doMagicKeyboardBareMinimum(){ // Really need a bigger trackpad
        //     A...Z, 26 (+2)
        // Backspace, 1
        // Spacebar , 2
        
        // Calculating Binary Finger
        let number = (self.binaryFingerCalculation() - 1)
        MagicNumber = number
        
        
        if(number == 1){ // Space
            self.testing.stringValue = "\(self.testing.stringValue) "
            return
        }
        if(number == 0){ // Backspace
            var outcome = self.testing.stringValue
            
            // String has something to remove?
            if(outcome.count > 0){
                outcome = outcome.substring(to: outcome.index(before: outcome.endIndex))
                self.testing.stringValue = "\(outcome)"
                return
            }
        }
        
        // Letters
        let str = "abcdefghijklmnopqrstuvwxyz"
        let alphabets = Array(str)
        if(number <= (alphabets.count + 1) && number >= 2){
            // User Interface Append Letter
            let alphabetNumber = number - 2
            print(" Hello \(alphabetNumber)")
            let letter = alphabets[alphabetNumber]
            if(self.testing.stringValue == "Please add a finger, need 4 we have 3"){
                self.testing.stringValue = ""
            }
            self.testing.stringValue = "\(self.testing.stringValue)\(alphabets[alphabetNumber])"
            
            // Haptic, Only On Change
            let str = self.binaryFingerCalculationString()
            print("Haptic Attempt, \(str)")
            self.doSequentialHaptics(input:str)
            
            /* Letter Game, Update User Interface */
            UILettersGame[letter]?.backgroundColor = NSColor.green
            return
        }
    }
    
    func doMagicLetters(){
        // Calculating Binary Finger
        let number = self.binaryFingerCalculation() - 1
        let str = "abcdefghijklmnopqrstuvwxyz"
        
        let alphabets = Array(str)
        if(number <= (alphabets.count-1) && number >= 0){
            let mySynth: NSSpeechSynthesizer = NSSpeechSynthesizer(voice: NSSpeechSynthesizer.defaultVoice)!
            // Verna talks once
            if("\(alphabets[number])" != self.testing.stringValue){
                mySynth.startSpeaking("\(alphabets[number])")
            }
            
            // User Interface Refelct the outcome
            self.testing.stringValue = "\(alphabets[number])"
        }
    }
    
    func doMagic(){
        
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
            if(MagicMode == "KeyboardBasic"){
                self.doMagicKeyboardBareMinimum()
            }
        }
        
        let doTrack = true
        // Do Tracking?
        if(doTrack){
            doTrackingAssit()
        }
    }
    
    // Result Number
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
    
    // Binary Representation String
    func binaryFingerCalculationString() -> String{
        // Calculating Binary Finger
        var number:String = ""
        CurrentTouchState.enumerated().forEach { (arg) in
            let (_,finger) = arg
            if(finger.alive){
                number = "\(number)1"
            } else {
                number = "\(number)0"
            }
        }
        //print("Current Binary Finger is \(number)")
        return number
    }
    
    
    override func touchesMoved(with event: NSEvent) {}
    
    func doTrackingAssit(){
        print("–– Finger Postions -–")
        
        var StringToDisplay = ""
        CurrentTouchState.enumerated().forEach({ (arg) in
            
            let (index, tracking) = arg
            print("  Finger \(index) in state of \(tracking.alive) tracking \(tracking.distance)")
            StringToDisplay = "\(StringToDisplay)\nFinger \(index) \(tracking.touch.normalizedPosition)"
        })
        
        self.testing.stringValue = "\(self.testing.stringValue) \n \(StringToDisplay)"
    }
    
    override func touchesBegan(with event: NSEvent) {
        
        // Reset
        CurrentTouchState.enumerated().forEach({ (arg) in
            let (index, _) = arg
            CurrentTouchState[index].alive = false
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
//        doMagic()
    }
    
    var UINumbersGame: Dictionary<Int, NSText> = [:]
    var UILettersGame: Dictionary<Character, NSText> = [:]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.acceptsTouchEvents = true
        // Do any additional setup after loading the view.
        
        /* Numbers Game, User Interface */
        for number in 1...15 {
            let text = NSText(frame: NSMakeRect(CGFloat(27*number),20,25,20))
                text.string = "\(number)"
                text.backgroundColor = NSColor.red
                text.isEditable = false
            UINumbersGame[number] = text
            self.view.addSubview(text)
        }
        
        /* Letters Game, User Interface */
        let str = "abcdefghijklmnopqrstuvwxyz"
        let alphabets = Array(str)
        for letter in alphabets {
            let number = str.index(of: letter)
            let text = NSText(frame: NSMakeRect(CGFloat(20*number!),20,25,0))
                text.string = "\(letter)"
                text.backgroundColor = NSColor.red
                text.isEditable = false
            self.view.addSubview(text)
            UILettersGame[letter] = text
        }
        
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}

extension String {
    public func index(of char: Character) -> Int? {
        if let idx = characters.index(of: char) {
            return characters.distance(from: startIndex, to: idx)
        }
        return nil
    }
}

extension CGPoint {
    func distanceToPoint(p:CGPoint) -> CGFloat {
        //return sqrt(pow((p.x - x), 2))
        //Version 2 more specific return (pow((p.x - x), 2) + pow((p.y - y), 2))
        // Version 3 return (pow((p.x - x), 2))
        return sqrt(pow((p.x - x), 2) + pow((p.y - y), 2))
    }
}

//print("Finger Check:")
//touches.forEach { (touch) in
//    print("    Location, \(touch.normalizedPosition) \(touch.phase)")
//}

//func doMagicKeyboardFull(){ // Really need a bigger trackpad
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
