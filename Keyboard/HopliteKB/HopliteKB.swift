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

let kCatTypeEnabled = "kCatTypeEnabled"

class HopliteKB: KeyboardViewController {
    
    let takeDebugScreenshot: Bool = false
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        UserDefaults.standard.register(defaults: [kCatTypeEnabled: false])
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
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
    
    override func keyPressed(_ key: Key) {
        let textDocumentProxy = self.textDocumentProxy
        let keyOutput = key.outputForCase(self.shiftState.uppercase())
        
        if key.type == .diacritic
        {
            var whichAccent = "´"
            var accent = -1
            if whichAccent == "´" //acute
            {
                accent = 1
            }
            else if whichAccent == "˜" //circumflex
            {
                accent = 2
            }
            else if whichAccent == "`" //grave
            {
                accent = 3
            }
            else if whichAccent == "¯" //macron
            {
                accent = 4
            }
            else if whichAccent == "῾" //rough breathing
            {
                accent = 5
            }
            else if whichAccent == "᾿" //smooth breathing
            {
                accent = 6
            }
            else if whichAccent == "ͺ" //iota subscript
            {
                accent = 7
            }
            else if whichAccent == "()" //surrounding parentheses
            {
                accent = 8
            }
            else if whichAccent == "¨" //diaeresis
            {
                accent = 9
            }
            else if whichAccent == "˘" //breve
            {
                accent = 10
            }
            else
            {
                return
            }
            
            let context = self.textDocumentProxy.documentContextBeforeInput
            let len = context?.count
            if len == nil || len! < 1
            {
                return
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
            for a in (context!.unicodeScalars).reversed()
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
            let suf = context!.unicodeScalars.suffix(lenToSend)
            var j = 0
            for i in (1...lenToSend).reversed()
            {
                buffer16[j] = UInt16(suf[suf.index(suf.endIndex, offsetBy: -i)].value)
                j += 1
            }
            var len16:Int32 = Int32(lenToSend)
            let unicodeMode = 0
            print("len: \(len16), accent pressed, umode: \(unicodeMode)")
            
            accentSyllable(&buffer16, 0, &len16, Int32(accent), true, Int32(unicodeMode))
            
            let newLetter = String(utf16CodeUnits: buffer16, count: Int(len16))
            
            (textDocumentProxy as UIKeyInput).deleteBackward() //seems to include any combining chars, but not in MSWord!
            (textDocumentProxy as UIKeyInput).insertText("\(newLetter)")
        }
        else
        {
            textDocumentProxy.insertText(keyOutput)
        }
    }
    
    override func setupKeys() {
        super.setupKeys()
        
        if takeDebugScreenshot {
            if self.layout == nil {
                return
            }
            
            for page in keyboard.pages {
                for rowKeys in page.rows {
                    for key in rowKeys {
                        if let keyView = self.layout!.viewForKey(key) {
                            keyView.addTarget(self, action: #selector(Catboard.takeScreenshotDelay), for: .touchDown)
                        }
                    }
                }
            }
        }
    }
    
    override func createBanner() -> ExtraView? {
        return nil//CatboardBanner(globalColors: type(of: self).globalColors, darkMode: false, solidColorMode: self.solidColorMode())
    }
    
    @objc func takeScreenshotDelay() {
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(Catboard.takeScreenshot), userInfo: nil, repeats: false)
    }
    
    @objc func takeScreenshot() {
        if !self.view.bounds.isEmpty {
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
            
            let oldViewColor = self.view.backgroundColor
            self.view.backgroundColor = UIColor(hue: (216/360.0), saturation: 0.05, brightness: 0.86, alpha: 1)
            
            let rect = self.view.bounds
            UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
            self.view.drawHierarchy(in: self.view.bounds, afterScreenUpdates: true)
            let capturedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            // AB: consider re-enabling this when interfaceOrientation actually breaks
            //// HACK: Detecting orientation manually
            //let screenSize: CGSize = UIScreen.main.bounds.size
            //let orientation: UIInterfaceOrientation = screenSize.width < screenSize.height ? .portrait : .landscapeLeft
            //let name = (orientation.isPortrait ? "Screenshot-Portrait" : "Screenshot-Landscape")
            
            let name = (self.isPortrait() ? "Screenshot-Portrait" : "Screenshot-Landscape")
            let imagePath = "/Users/archagon/Documents/Programming/OSX/RussianPhoneticKeyboard/External/tasty-imitation-keyboard/\(name).png"
            
            if let pngRep = capturedImage!.pngData() {
                try? pngRep.write(to: URL(fileURLWithPath: imagePath), options: [.atomic])
            }
            
            self.view.backgroundColor = oldViewColor
        }
    }
}
/*
func randomCat() -> String {
    let cats = "🐱😺😸😹😽😻😿😾😼🙀"
    
    let numCats = cats.count
    let randomCat = arc4random() % UInt32(numCats)
    
    let index = cats.index(cats.startIndex, offsetBy: Int(randomCat))
    let character = cats[index]
 
 
    return String(character)
}
*/
