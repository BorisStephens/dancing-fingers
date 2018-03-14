import UIKit.UIGestureRecognizerSubclass

// MARK: GestureRecognizer
class ForcedKeyboardGestureRecognizer: UIPanGestureRecognizer
{
    var vibrateOnDeepPress = false
    let threshold: CGFloat
    
    public var keyboardOutput = ""
    private var deepPressed: Bool = false
    private var Stroke1 = false
    private var Stroke2 = false
    private var Stroke3 = false
    private var Stroke4 = false
    
    required init(target: AnyObject?, action: Selector, threshold: CGFloat)
    {
        self.threshold = threshold
        super.init(target: target, action: action)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        do {
            // DEBUG: print("Forced Key Touches Begun \(String(describing: event.allTouches?.count))")
            handleTouch(touches:event.allTouches!)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        do {
            // print("Forced Key Supposed Movement")
            handleTouch(touches:event.allTouches!)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        
        state = deepPressed ? UIGestureRecognizerState.ended : UIGestureRecognizerState.failed
        
        deepPressed = false
        if event.allTouches!.count == 0 {
            self.keyboardOutput = "0000"
        }
        // DEBUG: print("Forced Key Touches Ended \(String(describing: event.allTouches?.count))")
    }
    
    private func handleTouch(touches: Set<UITouch>){
        state = UIGestureRecognizerState.began
        deepPressed = true
        
        // MARK: Exclusions, Reset Fingers Not There
        switch touches.count {
        case 1:
            Stroke2 = false
            Stroke3 = false
            Stroke4 = false
        case 2:
            Stroke3 = false
            Stroke4 = false
        case 3:
            Stroke4 = false
        default: break
        }
        
        // MARK: Fingers, Check Them All
        // TODO: Traitor, Index cannot be trusted. Use location to determine left to right sequence
        let threashold = self.threshold
        for(index, touch) in touches.enumerated() {
            let force = touch.force
            
            // First
            if force > threashold && index == 0 {Stroke1 = true}
            if force < threashold && index == 0 {Stroke1 = false}
            
            // Second
            if force > threashold && index == 1 {Stroke2 = true}
            if force < threashold && index == 1 {Stroke2 = false}
            
            // Third
            if force > threashold && index == 2 {Stroke3 = true}
            if force < threashold && index == 2 {Stroke3 = false}
            
            // Fourth
            if force > threashold && index == 3 {Stroke4 = true}
            if force < threashold && index == 3 {Stroke4 = false}
        }
        
        // MARK: Binary, Return
        var String = ""
        if(Stroke1){String += "1"} else {String += "0"}
        if(Stroke2){String += "1"} else {String += "0"}
        if(Stroke3){String += "1"} else {String += "0"}
        if(Stroke4){String += "1"} else {String += "0"}
        
        // DEBUG: print("\(String) Touches: \(touches.count)")
        
        self.keyboardOutput = String
        return
    }
}

