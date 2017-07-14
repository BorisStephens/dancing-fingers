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


    @IBAction func doChangeMagicMode(_ sender: Any) {
        MagicMode = "KeyboardBasic"
    }
    @IBAction func doChangeMagicModeCounting(_ sender: Any) {
        MagicMode = "Counting"
    }
    
    @IBAction func doResetFingerLocations(_ sender: Any) {
        CurrentTouchState.removeAll()
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

