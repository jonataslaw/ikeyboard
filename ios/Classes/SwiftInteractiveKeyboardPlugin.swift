import Flutter
import UIKit

public class SwiftInteractiveKeyboardPlugin: NSObject, FlutterPlugin {
  
    var active: Bool;
    var channel: FlutterMethodChannel;

    public static func register(with registrar: FlutterPluginRegistrar) {
      let channel = FlutterMethodChannel(name: "ikeyboard", binaryMessenger: registrar.messenger())
      let instance = SwiftInteractiveKeyboardPlugin(channel: channel, active:true)
      registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    init(channel: FlutterMethodChannel, active: Bool) {
       self.active = active;
       self.channel = channel;
       super.init()

       NotificationCenter.default.addObserver(self, selector: #selector(keyboardNotification(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
         if(call.method == "update"){
                 if(!self.active){
                    return
                 }
                if UIApplication.shared.windows.count > 2, let kbWindow = UIApplication.shared.windows.last {
                    DispatchQueue.main.async(execute: {
                        kbWindow.frame = CGRect.init(x: kbWindow.frame.minX, y: call.arguments as! CGFloat, width: kbWindow.frame.width, height: kbWindow.frame.height)
                    })
                }
                result(true)
            } else if(call.method == "active"){
                self.active = call.arguments as! Bool
                result(true)
            }
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if(!self.active){
            return
        }
        let info = notification.userInfo!
        let startFrameRaw = info[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue
        let endFrameRaw = info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let animationCurveRaw = info[UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber
        let durationRaw = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber
        let startFrame = startFrameRaw.cgRectValue
        let endFrame = endFrameRaw.cgRectValue
        let animationCurve = UIView.AnimationOptions(rawValue: UInt(animationCurveRaw.uintValue << 16))
        let duration =   durationRaw.doubleValue
        
        
        if(startFrame.minY - endFrame.minY == endFrame.height){
            
            let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber
            
            //  Getting UIKeyboardSize.
            if let kbFrame = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                
                let screenSize = UIScreen.main.bounds
                
                // This prevents the keyboard size from being miscalculated. 
                let intersectRect = kbFrame.intersection(screenSize)
                
                let _kbSize = intersectRect.isNull ? CGSize(width: screenSize.size.width, height: 0) : intersectRect.size
                
                self.channel.invokeMethod("show_keyboard", arguments: _kbSize.height)
                if UIApplication.shared.windows.count > 2, let kbWindow = UIApplication.shared.windows.last {
                    UIView.animate(withDuration: duration.doubleValue,
                                   delay: TimeInterval(0.0),
                                   options: animationCurve,
                                   animations: {
                        kbWindow.frame = CGRect.init(x: kbWindow.frame.minX, y: kbWindow.frame.minY + _kbSize.height, width: kbWindow.frame.width, height: kbWindow.frame.height)
                    })
                }
            }
            
            return
            /// Close keyboard
        } else if (endFrame.minY - startFrame.minY == endFrame.height) {
            self.channel.invokeMethod("hide_keyboard", arguments: 0.0)
            if UIApplication.shared.windows.count > 2, let kbWindow = UIApplication.shared.windows.last {
                UIView.animate(withDuration: duration,
                               delay: TimeInterval(0.0),
                               options: animationCurve,
                               animations: {
                    kbWindow.subviews[0].subviews[0].frame = CGRect.init(x: kbWindow.subviews[0].subviews[0].frame.minX+0.0, y: kbWindow.subviews[0].subviews[0].frame.minY - startFrame.size.height, width: kbWindow.subviews[0].subviews[0].frame.width, height: kbWindow.subviews[0].subviews[0].frame.height)
                })
            }
            
            /// back from emoji keyboard from alphanumeric keyboard
        }   else if (startFrame.height - endFrame.height > 0 && startFrame.height - endFrame.height == endFrame.minY - startFrame.minY) {        
            self.channel.invokeMethod("update_keyboard", arguments: endFrame.size.height)
            
            /// Go to emoji keyboard
        }   else if (endFrame.height - startFrame.height > 0 && endFrame.height - startFrame.height ==  startFrame.minY - endFrame.minY) { // user close the keyboard
            self.channel.invokeMethod("update_keyboard", arguments: endFrame.size.height)
        }
        
    }
}
