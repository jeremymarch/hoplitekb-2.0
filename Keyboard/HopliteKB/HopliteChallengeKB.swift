//
//  HopliteKB.swift
//  Keyboard
//
//  Created by Jeremy on 9/5/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

/*
 This is the demo keyboard. If you're implementing your own keyboard, simply follow the example here and then
 set the name of your KeyboardViewController subclass in the Info.plist file.
 NSExtensionPrincipalClass = ${PRODUCT_MODULE_NAME}.HopliteKB
 */
/*
public enum UnicodeMode:Int32 {
    case PreComposedNoPUA = 0
    case PreComposedPUA = 1
    case CombiningOnly = 2
}
*/

/*
class hcColors:GlobalColors
{
    override class var hcmfOrangeColor: UIColor { get { return UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0) }}
    
    override class func diacriticKey(_ darkMode: Bool, solidColorMode: Bool) -> UIColor {
        if darkMode {
            if solidColorMode {
                return self.darkModeSolidColorSpecialKey //self.darkModeSolidColorRegularKey
            }
            else {
                return self.darkModeSpecialKey//self.darkModeRegularKey
            }
        }
        else {
            //Hoplite Keyboard diacritic orange color
            //return UIColor.init(red: 255/255.0, green: 96/255.0, blue: 70/255.0, alpha: 1.0)
            return UIColor.green //init(red: 51/255.0, green: 88/255.0, blue: 137/255.0, alpha: 1.0)
        }
    }
}
*/
class HopliteChallengeKB: KeyboardViewController {
    let appSuiteName = "group.com.philolog.hoplitekeyboard"
    let unicodeModeKey = "UnicodeAccents"
    var forceLowercase = true
    var unicodeMode = 3 //hoplite challenge mode
    //https://www.paintcodeapp.com/news/ultimate-guide-to-iphone-resolutions
    var screenTypes = ["Less than 4s", "iPhone 4s", "iPhone 5s/SE", "iPhone 6/7/8", "iPhone 6/7/8 Plus", "iPhone X/XS", "iPhone XR/iPhone XS Max"]
    //var nativeHeightThresholds:[CGFloat] = [1136.0, 1334.0, 1792.0, 1920.0, 2436.0, 2688.0]
    var iPhoneHeightThresholds:[CGFloat] = [480.0, 568.0, 667.0, 736.0, 812.0, 896.0]
    var keyboardHeights:[CGFloat] = [200.0, 200.0, 200.0, 228.0, 250.0, 228.0, 250.0]
    
    //override class var globalColors: GlobalColors.Type { get { return hcColors.self }}
    
    func getPortraitHeightForScreen() -> CGFloat
    {
        let actualScreenHeight = (UIScreen.main.nativeBounds.size.height / UIScreen.main.nativeScale)
        
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            return 270.0
            //landscapeHeight = 290.0
            
            //canonicalPortraitHeight = 264
            //canonicalLandscapeHeight = 352
        }
        else
        {
            return self.findThreshhold(self.keyboardHeights, threshholds: self.iPhoneHeightThresholds, measurement: actualScreenHeight)
        }
    }
    
    func getLandscapeHeightForScreen() -> CGFloat
    {
        //let actualScreenHeight = (UIScreen.main.nativeBounds.size.height / UIScreen.main.nativeScale)
        
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            return 280.0
            
        }
        else
        {
            return 157.0
        }
    }
    
    func setButtons(keys:[[String]]) { }
    
    func resetMFButton()
    {
        let mfkey = keyboard.pages[0].rows[0][0]
        
        if let keyview = self.layout?.viewForKey(mfkey)
        {
            mfkey.lowercaseKeyCap = "MF"
            mfkey.lowercaseOutput = "MF"
            self.layout?.updateKeyCap(keyview, model: mfkey, fullReset: false, uppercase: false, characterUppercase: false, shiftState: .disabled)
        }
    }
    
    override func loadView() {
        super.loadView()
        
        //self.inputView = KludgeView()
        //self.keyboard = defaultKeyboard()
        self.keyboard = hcKeyboard(needsInputModeSwitchKey:false)//needsInputSwitch)
        //self.preferredContentSize = CGSize(width: self.view.frame.size.width, height: 356)
        self.forwardingView = ForwardingView(frame: CGRect.zero)
        self.view.addSubview(self.forwardingView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardViewController.defaultsChanged(_:)), name: UserDefaults.didChangeNotification, object: nil)
        
        if let aBanner = self.createBanner() {
            aBanner.isHidden = true
            self.view.insertSubview(aBanner, belowSubview: self.forwardingView)
            self.bannerView = aBanner
        }
    }
    
    convenience init(isAppExtension:Bool) {
        self.init(nibName: nil, bundle: nil)
        self.appExt = isAppExtension
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.unicodeMode = 3
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.topRowButtonDepressNotAppExt = true
        self.needsInputSwitch = false //this should be true
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.portraitHeightOverride = self.getPortraitHeightForScreen()
        self.landscapeHeightOverride = self.getLandscapeHeightForScreen()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let COMBINING_GRAVE =            0x0300
    let COMBINING_ACUTE =            0x0301
    let COMBINING_CIRCUMFLEX =       0x0342//0x0302
    let COMBINING_MACRON =           0x0304
    let COMBINING_BREVE =            0x0306
    let COMBINING_DIAERESIS =        0x0308
    let COMBINING_SMOOTH_BREATHING = 0x0313
    let COMBINING_ROUGH_BREATHING =  0x0314
    let COMBINING_IOTA_SUBSCRIPT =   0x0345
    let EM_DASH =                    0x2014
    let LEFT_PARENTHESIS =           0x0028
    let RIGHT_PARENTHESIS =          0x0029
    let SPACE =                      0x0020
    let EN_DASH =                    0x2013
    let HYPHEN =                     0x2010
    let COMMA =                      0x002C
    
    
    override func viewWillAppear(_ animated: Bool) {
        if #available(iOS 11.0, *) {
            super.needsInputSwitch = true//self.needsInputModeSwitchKey //this one caused warning
        } else {
            super.needsInputSwitch = true
        }
        super.viewWillAppear(animated)
    }
    /*
    //would be nice if we could see the button press down
    func sendButton(button:Int)
    {
        if button > 0 && button < 10
        {
            let key = self.layout?.viewForKey(self.keyboard.pages[0].rows[0][button])
            key!.sendActions(for: .touchUpInside)
        }
    }
    */
    func diacriticPressed(accent:Int, context:String) -> String
    {
        assert(context.count > 0, "Cannot accent empty string")
        assert(unicodeMode == 3, "Invalid Unicode Mode for Hoplite Challenge")
        if context.count < 1
        {
            return ""
        }
        //accentSyllable(&context?.utf16, context.count, &context.count, 1, false);
        /*
         let bufferSize = 200
         var nameBuf = [Int8](repeating: 0, count: bufferSize) // Buffer for C string
         nameBuf[0] = Int8(context![context!.index(before: context!.endIndex)])
         accentSyllableUtf8(&nameBuf, 1, false)
         let name = String(cString: nameBuf)
         */
        
        let combiningChars = [COMBINING_BREVE,COMBINING_GRAVE,COMBINING_ACUTE,COMBINING_CIRCUMFLEX,COMBINING_MACRON,COMBINING_DIAERESIS,COMBINING_SMOOTH_BREATHING,COMBINING_ROUGH_BREATHING,COMBINING_IOTA_SUBSCRIPT]
        
        // 1. make a buffer for the C string
        let bufferSize16 = 12 //5 is max, for safety
        var buffer16 = [UInt16](repeating: 0, count: bufferSize16)
        
        // 2. figure out how many characters to send
        var lenToSend = 1
        let maxCombiningChars = 5
        for a in (context.unicodeScalars).reversed()
        {
            if lenToSend < maxCombiningChars && combiningChars.contains(Int(a.value))
            {
                lenToSend += 1
            }
            else
            {
                break
            }
        }
        
        // 3. fill the buffer
        let suf = context.unicodeScalars.suffix(lenToSend)
        var j = 0
        for i in (1...lenToSend).reversed()
        {
            buffer16[j] = UInt16(suf[suf.index(suf.endIndex, offsetBy: -i)].value)
            j += 1
        }
        var len16:Int32 = Int32(lenToSend)

        print("len: \(len16), accent pressed, umode: \(unicodeMode)")
        
        accentSyllable(&buffer16, 0, &len16, Int32(accent), true, Int32(unicodeMode))
        
        return String(utf16CodeUnits: buffer16, count: Int(len16))
    }
    
    override func keyPressed(_ key: Key) {
        
        if key.type == .diacritic
        {
            let whichAccent = (self.shiftState == .disabled) ? key.lowercaseOutput : key.uppercaseOutput

            let diacritics = ["acute", "circum", "grave", "macron", "rough", "smooth", "iotasub", "parens", "diaeresis", "breve"]
            
            guard let accent = diacritics.firstIndex(of: whichAccent!), accent > -1, accent < 10
                else {
                    assertionFailure("Invalid Accent")
                return
            }
            
            if let context = textDocumentProxy.documentContextBeforeInput, context.count > 0
            {
                //accents are 1-10, so add 1
                let newLetter = diacriticPressed(accent: accent + 1, context: context)
                
                (textDocumentProxy as UIKeyInput).deleteBackward() //seems to include any combining chars, but not in MSWord!
                (textDocumentProxy as UIKeyInput).insertText(newLetter)
            }
        }
        else if key.type == .multipleforms
        {
            print("multiple forms pressed")
            //get output before setting it to comma
            let keyOutput = key.outputForCase(self.shiftState.uppercase())
            if let keyView = self.layout?.viewForKey(key)
            {
                key.lowercaseKeyCap = ","
                key.lowercaseOutput = ", "
                self.layout?.updateKeyCap(keyView, model: key, fullReset: false, uppercase: false, characterUppercase: false, shiftState: .disabled)
            }
            textDocumentProxy.insertText(keyOutput)
        }
        else
        {
            let keyOutput = key.outputForCase(self.shiftState.uppercase())
            textDocumentProxy.insertText(keyOutput)
        }
    }
    
    @objc override func defaultsChanged(_ notification: Notification) {
        let defaults = UserDefaults(suiteName: appSuiteName)
        if let umode = defaults?.integer(forKey: unicodeModeKey)
        {
            unicodeMode = umode
        }
        else
        {
            unicodeMode = 0
        }
        self.updateKeyCaps(self.shiftState.uppercase())
    }
    
    // Not true: this only works if full access is enabled
    @objc override func canPlaySound() -> Bool {
        let defaults = UserDefaults(suiteName: appSuiteName)
        return defaults?.bool(forKey: kKeyboardClicks) ?? true
    }
}
