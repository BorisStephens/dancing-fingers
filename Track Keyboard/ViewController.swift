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

import Cocoa

struct BinaryFinger {
    
    var alive: Bool = false
    let touch:NSTouch
    var distance:CGFloat = 0.00
    // println() should print just the unit name:
    var description: String { return touch.identity as! String }
}

/* Core Varaibles */
var MagicMode = "KeyboardBasic"
var CurrentTouchState:Array<BinaryFinger> = []
var MagicNumber = 0
var doTrack = false

/* Timer Mode */
let timerMode = true
var startTime = NSDate()
var endTime = NSDate()

/* Keyboard Pattern Misfire Protection */
var BufferTimestamp:Date? = Date()
var BufferWaitTime:TimeInterval = TimeInterval(exactly: Float(0.28))!
var SynthesizeVoice:Bool = true
var MagicState: DancingKeyboardStates = .dormant

var UINumbersGame: Dictionary<Int, NSText> = [:]
var UILettersGame: Dictionary<Character, NSText> = [:]

struct DancingKeyboardStates: OptionSet {
    let rawValue: Int
    
    static let waiting      = DancingKeyboardStates(rawValue: 1 << 0)
    static let calculating  = DancingKeyboardStates(rawValue: 1 << 1)
    static let dormant      = DancingKeyboardStates(rawValue: 1 << 2)
    
    static let all: DancingKeyboardStates = [.waiting, .calculating, .dormant]
}
var MagicTrackingState: TrackingStates = .distanceXY//.vertical//.distanceXY
struct TrackingStates: OptionSet {
    let rawValue: Int
    
    static let normalized = TrackingStates(rawValue: 1 << 0)
    static let horizontal = TrackingStates(rawValue: 1 << 1)
    static let vertical   = TrackingStates(rawValue: 1 << 2)
    static let distanceXY = TrackingStates(rawValue: 1 << 3)
}

class MacViewController: NSViewController {
    
    @IBOutlet weak var testing: NSTextField!
    @IBOutlet weak var settingMagicMode: NSSegmentedControl!
    @IBOutlet weak var labelDurationAttempt: NSTextField!
    @IBOutlet weak var labelExpectedFingerPositions: NSTextField!
    
    // Result Number
    func binaryFingerCalculation(requestAutomated:Bool = false) -> Int{
        // Case: No Fingers Touching At All, Calculate
        if MagicState == .calculating{
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
            doMagicKeyboardBareMinimum(parameterNumber: number)
            print("Current Binary Finger is \(number)")
            
            // Reset Refactor V2 // Set em all to dead
            MagicState = .dormant
            CurrentTouchState.enumerated().forEach({ (arg) in
                let (index, _) = arg
                CurrentTouchState[index].alive = false
            })
            return 0
        }
        
        // Case: First Entry
        if MagicState.contains(.dormant) && !requestAutomated {
            MagicState = .waiting
            // Checkback in pre-defined amount of miliseconds
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + BufferWaitTime){
                _ = self.binaryFingerCalculation(requestAutomated: true)
            }
        }
        
        // Case: Waiting Over
        if MagicState == .waiting && BufferTimestamp! < Date() + BufferWaitTime && requestAutomated{
            MagicState = .calculating
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
            doMagicKeyboardBareMinimum(parameterNumber: number)
            print("Current Binary Finger is \(number)")
            
            // Reset Refactor V2 // Set em all to dead
            MagicState = .dormant
            CurrentTouchState.enumerated().forEach({ (arg) in
                let (index, _) = arg
                CurrentTouchState[index].alive = false
            })
        }
        
        // Case: Already waiting within predetermined buffer window user touched
        if MagicState == .waiting && BufferTimestamp! < Date() + BufferWaitTime && !requestAutomated {
            // Reset Timestamp as we now have a new finger state in the mix
            BufferTimestamp = Date()
        }
        
        return 0 // Static for now
    }
    
    override func touchesBegan(with event: NSEvent) {
        
        
        
        // Bring alive
        print("Bring Alive These bad boys")
        let touches = event.allTouches()
        touches.forEach { (touch) in
            
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
            let phase = phases["\(touch.phase.rawValue)"]
            print(" 🖖+﹣ Finger\(closestTouch)  \(phase)")
        }
        
        // Check, New Finger
        let allTouchesCount = event.allTouches().count
        if(CurrentTouchState.count < allTouchesCount){
            // New Finger Detected, Add To Tracker
            let touches = event.touches(matching: NSTouch.Phase.began, in: self.view)
            touches.forEach({ (firstTouch) in
                CurrentTouchState.append(BinaryFinger(alive: true, touch: firstTouch, distance:0))
            })
        }
        doMagic()
    }
    
    override func touchesEnded(with event: NSEvent) {
        // No fingers touching at all, let us calculate
        let touches = event.allTouches()
        let phases = [
            "1":"Began",
            "2":"Moved",
            "4":"Stationary",
            "7":"Touching",
            "8":"Ending",
            "16":"Cancelled"
        ]
        
        for touch in touches {
            let phase = phases["\(touch.phase.rawValue)"]
            print(phase)
        }
        
        // Touches Ending and only one, you know what that means... calculating time
        if touches.count == 1 {
            MagicState = .calculating
            _ = self.binaryFingerCalculation(requestAutomated: false)
        }
    }
    
    func trackingDistance(tracking:BinaryFinger, touch:NSTouch) -> CGFloat{
        // Final Version
        var distance:CGFloat = 0
        switch MagicTrackingState {
        case .horizontal:
            distance =  tracking.touch.pos(self.view).x - touch.pos(self.view).x
            break
        case .vertical:
            distance = touch.pos(self.view).y - tracking.touch.pos(self.view).y
            break
        case .normalized:
            distance = touch.normalizedPosition.distanceToPoint(p: tracking.touch.normalizedPosition)
            break
        case .distanceXY:
            distance = touch.pos(self.view).distanceToPoint(p: tracking.touch.pos(self.view))
            break
        default:
            distance = touch.normalizedPosition.distanceToPoint(p: tracking.touch.normalizedPosition)
        }
        return abs(distance)
    }
    
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
            
            /* Behaviour with Counting */
            if(number == 31 && MagicMode == "Counting"){
                startTime = NSDate()
                self.labelDurationAttempt.stringValue = String(startTime.timeIntervalSinceNow * -1)
            }
            if(number == 15 && MagicMode == "Counting"){
                self.labelDurationAttempt.stringValue = String(startTime.timeIntervalSinceNow * -1)
            }
            
            /* Behaviour with Keyboard: Finish Counting when all the letters are done */
            if(allLettersAreDone() && MagicMode == "KeyboardBasic"){
                self.labelDurationAttempt.stringValue = String(startTime.timeIntervalSinceNow * -1)
                return
            }
            /* A was just pressed probably */
            if(letterIsDone(letter: "A") && !letterIsDone(letter: "B") && MagicMode == "KeyboardBasic" && number == 3){
                startTime = NSDate()
                self.labelDurationAttempt.stringValue = String(startTime.timeIntervalSinceNow * -1)
                return
            }
            self.labelDurationAttempt.stringValue = String(startTime.timeIntervalSinceNow * -1)
        }
    }
    
    func letterIsDone(letter:Character) -> Bool{
        var lettersAllDone = true
        if(UILettersGame[letter]?.backgroundColor !== NSColor.green){
            lettersAllDone = false
        }
        return lettersAllDone
    }
    
    func allLettersAreDone() -> Bool{
        let str = "abcdefghijklmnopqrstuvwxyz"
        let alphabets = Array(str)
        var lettersAllDone = true
        for letter in alphabets {
            if(UILettersGame[letter]?.backgroundColor !== NSColor.green){
                lettersAllDone = false
            }
        }
        return lettersAllDone
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
    
    func doMagicKeyboardBareMinimum(parameterNumber:Int){ // Really need a bigger trackpad
        //     A...Z, 26 (+2)
        // Backspace, 1
        // Spacebar , 2
        
        // Calculating Binary Finger
        let number = (parameterNumber - 1)
        doTimer(number:number)
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
            //print("Haptic Attempt, \(str)")
            self.labelExpectedFingerPositions.stringValue = "Haptic Attempt, \(str)" // Actual, not expeced... to be done
            self.doSequentialHaptics(input:str)
            
            /* Letter Game, Update User Interface */
            UILettersGame[letter]?.backgroundColor = NSColor.green
            
            /* Speak */
            if(SynthesizeVoice){
                let mySynth: NSSpeechSynthesizer = NSSpeechSynthesizer(voice: NSSpeechSynthesizer.defaultVoice)!
                // Verna talks once
                mySynth.startSpeaking("\(letter)")
            }
                
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
                self.binaryFingerCalculation()
            }
        }
        
        // Do Tracking?
        if(doTrack){
            doTrackingAssit()
        }
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
            print("  Finger \(index) in state of \(tracking.alive) tracking \(tracking.distance) \(tracking.touch.pos(self.view))")
            StringToDisplay = "\(StringToDisplay)\nFinger \(index) \(tracking.touch.pos(self.view)) "
        })
        
        self.testing.stringValue = "\(self.testing.stringValue) \n \(StringToDisplay)"
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.acceptsTouchEvents = true
        // Do any additional setup after loading the view.
        self.view.wantsRestingTouches = true
        
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
//
//func doMagicGesturePathWords(){ // Map sounds... wow... that'll be quite a thing...
//
//}

extension NSTouch {
    /**
     * Returns the relative position of the touch to the view
     * NOTE: the normalizedTouch is the relative location on the trackpad. values range from 0-1. And are y-flipped
     * TODO: debug if the touch area is working with a rect with a green stroke
     */
    func pos(_ view:NSView) -> CGPoint{
        let w = view.frame.size.width
        let h = view.frame.size.height
        let touchPos:CGPoint = CGPoint(x:self.normalizedPosition.x,y:1 + (self.normalizedPosition.y * -1))/*flip the touch coordinates*/
        let deviceSize:CGSize = self.deviceSize
        let deviceRatio:CGFloat = deviceSize.width/deviceSize.height/*find the ratio of the device*/
        let viewRatio:CGFloat = w/h
        var touchArea:CGSize = CGSize(width:w,height:h)
        /*Uniform-shrink the device to the view frame*/
        if(deviceRatio > viewRatio){/*device is wider than view*/
            touchArea.height = h/viewRatio
            touchArea.width = w
        }else if(deviceRatio < viewRatio){/*view is wider than device*/
            touchArea.height = h
            touchArea.width = w/deviceRatio
        }/*else ratios are the same*/
        let touchAreaPos:CGPoint = CGPoint(x:(w - touchArea.width)/2,y:(h - touchArea.height)/2)/*we center the touchArea to the View*/
        let touchArea2 = CGPoint(x:touchPos.x * touchArea.width,y:touchPos.y * touchArea.height)
        return CGPoint(x: touchAreaPos.x + touchArea2.x, y:touchAreaPos.y + touchArea2.y)
    }
}
// Reference: Position https://stackoverflow.com/questions/3573276/know-the-position-of-the-finger-in-the-trackpad-under-mac-os-x
