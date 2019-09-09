//
//  ViewController.swift
//  TransliteratingKeyboard
//
//  Created by Alexei Baboulevitch on 6/9/14.
//  Copyright (c) 2014 Alexei Baboulevitch ("Archagon"). All rights reserved.
//

import UIKit

class HostingAppViewController: UIViewController {
    
    @IBOutlet var stats: UILabel?
    let kb = HopliteKB()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(HostingAppViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HostingAppViewController.keyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillChangeFrame:"), name: UIKeyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HostingAppViewController.keyboardDidChangeFrame(_:)), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
        
        kb.view.translatesAutoresizingMaskIntoConstraints = false
        for view in self.view.subviews {
            if let tf = view as? UITextField {
                //inputView.resignFirstResponder()
                tf.inputView = kb.inputView
            }
        }
    }
    
   //check whether keyboard extension is installed //https://stackoverflow.com/questions/25675628/how-to-detect-whether-custom-keyboard-is-activated-from-the-keyboards-container
    func isKeyboardExtensionEnabled() -> Bool {
        guard let appBundleIdentifier = Bundle.main.bundleIdentifier else {
            fatalError("isKeyboardExtensionEnabled(): Cannot retrieve bundle identifier.")
        }
        
        guard let keyboards = UserDefaults.standard.dictionaryRepresentation()["AppleKeyboards"] as? [String] else {
            // There is no key `AppleKeyboards` in NSUserDefaults. That happens sometimes.
            return false
        }
        
        let keyboardExtensionBundleIdentifierPrefix = appBundleIdentifier + "."
        for keyboard in keyboards {
            if keyboard.hasPrefix(keyboardExtensionBundleIdentifierPrefix) {
                return true
            }
        }
        
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func dismiss() {
        for view in self.view.subviews {
            if let inputView = view as? UITextField {
                inputView.resignFirstResponder()
            }
        }
    }
    
    var startTime: TimeInterval?
    var firstHeightTime: TimeInterval?
    var secondHeightTime: TimeInterval?
    var referenceHeight: CGFloat = 216
    
    @objc func keyboardWillShow() {
        if startTime == nil {
            startTime = CACurrentMediaTime()
        }
    }
    
    @objc func keyboardDidHide() {
        startTime = nil
        firstHeightTime = nil
        secondHeightTime = nil
        
        self.stats?.text = "(Waiting for keyboard...)"
    }
    
    @objc func keyboardDidChangeFrame(_ notification: Notification) {
        //let frameBegin: CGRect! = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue
        let frameEnd: CGRect! = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        
        if frameEnd.height == referenceHeight {
            if firstHeightTime == nil {
                firstHeightTime = CACurrentMediaTime()
                
                if let startTime = self.startTime {
                    if let firstHeightTime = self.firstHeightTime {
                        let formatString = NSString(format: "First: %.2f, Total: %.2f", (firstHeightTime - startTime), (firstHeightTime - startTime))
                        self.stats?.text = formatString as String
                    }
                }
            }
        }
        else if frameEnd.height != 0 {
            if secondHeightTime == nil {
                secondHeightTime = CACurrentMediaTime()

                if let startTime = self.startTime {
                    if let firstHeightTime = self.firstHeightTime {
                        if let secondHeightTime = self.secondHeightTime {
                            let formatString = NSString(format: "First: %.2f, Second: %.2f, Total: %.2f", (firstHeightTime - startTime), (secondHeightTime - firstHeightTime), (secondHeightTime - startTime))
                            self.stats?.text = formatString as String
                        }
                    }
                }
            }
        }
    }
}

