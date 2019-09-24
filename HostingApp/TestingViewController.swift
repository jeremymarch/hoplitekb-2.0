//
//  TestingViewController.swift
//  HCPolytonicGreekKBapp
//
//  Created by Jeremy March on 2/26/17.
//  Copyright © 2017 Jeremy March. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//


import UIKit

class TestingViewController: UIViewController, UITextViewDelegate {
    @IBOutlet var textView:UITextView?
    @IBOutlet var HexLabel:UILabel?
    @IBOutlet var modeLabel:UILabel?
    var kb:HopliteKB? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //override Dark Mode
        textView?.backgroundColor = .white
        textView?.textColor = .black
        
        kb = HopliteKB() //kb needs to be member variable, can't be local to just this function
        kb?.inputView?.translatesAutoresizingMaskIntoConstraints = false
        kb?.appExt = false
        kb?.topRowButtonDepressNotAppExt = false
        
        textView!.inputView = kb?.inputView
        textView!.delegate = self
        
        let defaults = UserDefaults(suiteName: "group.com.philolog.hoplitekeyboard")
        if defaults != nil
        {
            let m = defaults?.object(forKey: "UnicodeAccents")
            if m != nil
            {
                let n:Int32 = m as! Int32
                if n >= 0 && n <= 2
                {
                    if n == UnicodeMode.PreComposedNoPUA.rawValue
                    {
                        modeLabel?.text = "Mode: Precomposed"
                    }
                    else if n == UnicodeMode.PreComposedPUA.rawValue
                    {
                        modeLabel?.text = "Mode: Precomposed with PUA"
                    }
                    else if n == UnicodeMode.CombiningOnly.rawValue
                    {
                        modeLabel?.text = "Mode: Combining Only"
                    }
                }
            }
 
        }
        modeLabel?.sizeToFit()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        let s = textView.text
        HexLabel?.text = "Unicode Code Points:\n" + textToCodePoints(text: s!, separator: " - ")
        HexLabel?.sizeToFit()
        
        /*
        var topCorrect:CGFloat = (textView.bounds.size.height - textView.contentSize.height) / 2.0
        topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect )
        textView.contentOffset = CGPoint(x: 0, y: topCorrect)
        */
    }

    func textToCodePoints(text:String, separator:String) -> String
    {
        var ns:String = ""
        for a in (text.unicodeScalars)
        {
            //NSLog(String(a.value, radix:16))
            //ns = ns + String(a.value, radix:16) + " "
            ns = ns + String(format: "%04X", a.value) + separator
        }
        let endIndex = ns.index(ns.endIndex, offsetBy: -separator.count, limitedBy: ns.startIndex)
        if endIndex != nil
        {
            //return ns.substring(to: endIndex!)
            return String(ns[..<endIndex!])
        }
        else
        {
            return ns
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
