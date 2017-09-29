//
//  DancingFingers.swift
//  Forced Keyboard
//
//  Created by Luke Stephens on 8/9/17.
//  Copyright © 2017 Luke Stephens. All rights reserved.
//

import Foundation
import Cocoa



/* Binary Finger, Used to track the finger toches */
struct BinaryFinger {
    
    var alive: Bool = false
    var distance:CGFloat = 0.00
    
    #if os(iOS) || os(watchOS) || os(tvOS)
    let touch:UITouch
    var description: String { return touch.identity as! String }
    #elseif os(OSX)
    let touch:NSTouch
    var description: String { return touch.identity as! String }
    #endif
}

class DancingFingers{
    
    // Result Letter
    func letter() {
        // Letters
//        let str = "abcdefghijklmnopqrstuvwxyz"
//        let alphabets = Array(str)
//        if(number <= (alphabets.count + 1) && number >= 2){
//
//            // User Interface Append Letter
//            let alphabetNumber = number - 2
//            let letter = alphabets[alphabetNumber]
//            if(self.testing.stringValue == "Please add a finger, need 4 we have 3"){
//                self.testing.stringValue = ""
//            }
//            self.testing.stringValue = "\(self.testing.stringValue)\(alphabets[alphabetNumber])"
//
//            return letter
//        }
    }
    
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
            // doMagicKeyboardBareMinimum(parameterNumber: number)
            // print("Current Binary Finger is \(number)")
            // return number;
            
            
            // Reset Refactor V2 // Set em all to dead
            MagicState = .dormant
            CurrentTouchState.enumerated().forEach({ (arg) in
                let (index, _) = arg
                CurrentTouchState[index].alive = false
            })
            
            // Save Time
            // TEMP DISABLED: self.saveTime(textToSave:"\(number)\t\(self.labelDurationAttempt.stringValue)")
            return number
        }
        
        // Case: First Entry
        if MagicState.contains(.dormant) && !requestAutomated {
            MagicState = .waiting
            // Checkback in pre-defined amount of miliseconds
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + BufferWaitTime){
                if KeyboardFiresWithinTimer {
                    _ = self.binaryFingerCalculation(requestAutomated: true)
                }
            }
            return 0
        }
        
        // Case: Waiting Over
        if MagicState == .waiting && BufferTimestamp! < Date() + BufferWaitTime && requestAutomated && KeyboardFiresWithinTimer{
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
            // doMagicKeyboardBareMinimum(parameterNumber: number)
            return number;
            print("Current Binary Finger is \(number)")
            
            // Reset Refactor V2 // Set em all to dead
            MagicState = .dormant
            CurrentTouchState.enumerated().forEach({ (arg) in
                let (index, _) = arg
                CurrentTouchState[index].alive = false
            })
            
            // Save Time
            // TEMP DISABLE: self.saveTime(textToSave:"\(number)\t\(self.labelDurationAttempt.stringValue)")
        }
        
        // Case: Already waiting within predetermined buffer window user touched
        if MagicState == .waiting && BufferTimestamp! < Date() + BufferWaitTime && !requestAutomated {
            // Reset Timestamp as we now have a new finger state in the mix
            BufferTimestamp = Date()
        }
        
        return 0 // Static for now
    }
    
    static func doRestart(){
        // Finger Tracking
        CurrentTouchState.removeAll()
        // Timer
        startTime = NSDate()
        // Numbers Game
        for (_, numberGame) in UINumbersGame {
            numberGame.backgroundColor = NSColor.red
        }
        // Letters Game
        for (_, interface) in UILettersGame {
            interface.backgroundColor = NSColor.red
        }
        // Waiting on 5 Fingers
        Waiting = true
        
        // Save Session New State
        DispatchQueue.main.asyncAfter(deadline: .now() + 40) {
            // create the destination url for the text file to be saved
            let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileURL = documentDirectory.appendingPathComponent("file.txt")
            
            var text = "--- New Session Started --- \(Date().description)"
            do {
                // reading from disk
                do {
                    let mytext = try String(contentsOf: fileURL)
                    text = "\(text)\n\(mytext)"
                    print(mytext)   // "some text\n"
                } catch {
                    print("error loading contents of:", fileURL, error)
                }
                
                // writing to disk
                try text.write(to: fileURL, atomically: false, encoding: .utf8)
                
                // saving was successful.
            } catch {
                print("error writing to url:", fileURL, error)
            }
        }
    }
}

/* Core Varaibles */
var MagicMode = "KeyboardBasic"
var CurrentTouchState:Array<BinaryFinger> = []
var MagicNumber = 0
var doTrack = false
var Waiting = true // Waiting for 5 fingers

/* Timer Mode */
let timerMode = true
var startTime = NSDate()
var endTime = NSDate()

/* Keyboard Pattern Misfire Protection */
var BufferTimestamp:Date? = Date()
var BufferWaitTime:TimeInterval = TimeInterval(exactly: Float(0.18))!
var SynthesizeVoice:Bool = true
var MagicState: DancingKeyboardStates = .dormant
var KeyboardFiresWithinTimer = false

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
