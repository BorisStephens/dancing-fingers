//
//  ViewController.swift
//  Track Keyboard
//
//  Created by Luke Stephens on 28/6/17.
//  Copyright © 2017 Luke Stephens. All rights reserved.
//

// Next: Make sequenceing work with remembering finger positions
// [ ] Where is the finger 1...5?
// [ ] Did finger rise up, which one was it 1...5?
// [ ] Did finger go back down, which one was it 1...5?

import Cocoa

class MacViewController: NSViewController {
    
    @IBOutlet weak var testing: NSTextField!
    
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
    
    func doMagic( count:Int){
        
        /* Numbers */
        let finger1 = (count >= 1 ? 1 : 0)
        let finger2 = (count >= 2 ? 2 : 0)
        let finger3 = (count >= 3 ? 4 : 0)
        let finger4 = (count >= 4 ? 8 : 0)
        let number:Int = finger1+finger2+finger3+finger4
        self.testing.stringValue = String(number)
    }
    
    override func touchesBegan(with event: NSEvent) {
        let touches = event.touches(matching: NSTouch.Phase.any, in: self.view)
        doMagic(count:touches.count)
    }
    
    override func touchesEnded(with event: NSEvent) {
        let touches = event.touches(matching: NSTouch.Phase.any, in: self.view)
        doMagic(count:touches.count)
    }

}

