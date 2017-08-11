//
//  AppDelegate.swift
//  Track Keyboard
//
//  Created by Luke Stephens on 28/6/17.
//  Copyright © 2017 Luke Stephens. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBAction func doChangeSynthesizeVoice(_ sender: Any) {
        SynthesizeVoice = !SynthesizeVoice
    }
    
    @IBAction func doChangeMagicMode(_ sender: Any) {
        MagicMode = "KeyboardBasic"
    }
    @IBAction func doChangeMagicModeCounting(_ sender: Any) {
        MagicMode = "Counting"
    }
    
    @IBAction func doResetFingerLocations(_ sender: Any) {
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
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

