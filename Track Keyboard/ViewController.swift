//
//  ViewController.swift
//  Track Keyboard
//
//  Created by Luke Stephens on 28/6/17.
//  Copyright © 2017 Luke Stephens. All rights reserved.
//

// Next: Make sequenceing work with remembering finger positions
// [•] Where is the finger 1...5?
// [•] Did finger rise up, which one was it 1...5?
// [•] Did finger go back down, which one was it 1...5?
// [•] Calculate up to 5
// Bug: Sequence goes out of whack, Cause Dictionary -> Swap To Array

import Cocoa

class MacViewController: NSViewController {
    
    @IBOutlet weak var testing: NSTextField!
    var InitalTouches:Array<NSTouch> = []
    var CurrentStateAlive:Dictionary<String, Bool> = [:]
    
    func doMagic(){
        
        // Calculating Binary Finger
        var number:Int = 0
        let pwrInt:(Int,Int)->Int = { a,b in return Int(pow(Double(a),Double(b))) }
        self.CurrentStateAlive.enumerated().forEach { (arg) in
            let (index,active) = arg
            if(active.value){
                let addition = pwrInt(2,index)
                number += addition
            }
        }
        
        // No Fingers Used, Then Reset Finger Positions
//        CurrentStateAlive.removeAll()
        
        // User Interface Update
        self.testing.stringValue = String(number)
    }
    
    
    override func touchesMoved(with event: NSEvent) {
        doMagic()
    }
    
    override func touchesBegan(with event: NSEvent) {
        
        
        // Check, New Finger
        let allTouchesCount = event.allTouches().count
        if(InitalTouches.count < allTouchesCount){
            // New Finger Detected, Add To Tracker
            let touches = event.touches(matching: NSTouch.Phase.began, in: self.view)
            InitalTouches.insert(touches.first!, at: InitalTouches.endIndex)
            // CurrentStateAlive[String(describing: touches.first?.identity)] = true
            
        } else {
            // Check, What Fingers Are Still There Who Came Back?
            let touches = event.touches(matching: NSTouch.Phase.any, in: self.view)
            touches.forEach { (touch) in
                var closestTouch: NSTouch = NSTouch()
                var distanceBest:CGFloat = CGFloat(1000.00)
                
                // Who is the Closest to specify who just left
                InitalTouches.forEach({ (inital) in
                    let distance = hypot(touch.normalizedPosition.x - inital.normalizedPosition.x, touch.normalizedPosition.y - inital.normalizedPosition.y)
                    if(distance < distanceBest){
                        closestTouch = inital
                        distanceBest = distance
                    }
                })
                
                // Update Who Left
                CurrentStateAlive[String(describing: closestTouch.identity)] = true
            }
        }
        
        doMagic()
    }
    
    override func touchesEnded(with event: NSEvent) {
        let touches = event.touches(matching: NSTouch.Phase.ended, in: self.view)
        touches.forEach { (touch) in
            var closestTouch: NSTouch = NSTouch()
            var distanceBest:CGFloat = CGFloat(1000.00)
            
            // Who is the Closest to specify who just left
            InitalTouches.forEach({ (inital) in
                let distance = hypot(touch.normalizedPosition.x - inital.normalizedPosition.x, touch.normalizedPosition.y - inital.normalizedPosition.y)
                if(distance < distanceBest){
                    closestTouch = inital
                    distanceBest = distance
                }
            })
            
            // Update Who Left
            CurrentStateAlive[String(describing: closestTouch.identity)] = false
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

