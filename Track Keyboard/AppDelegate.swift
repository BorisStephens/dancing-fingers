//
//  AppDelegate.swift
//  Track Keyboard
//
//  Created by Luke Stephens on 28/6/17.
//  Copyright © 2017 Luke Stephens. All rights reserved.
//

import Cocoa


class DancingFingers{
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
        DancingFingers.doRestart()
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

