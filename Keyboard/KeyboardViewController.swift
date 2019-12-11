//
//  KeyboardViewController.swift
//  Keyboard
//
//  Created by Alexei Baboulevitch on 6/9/14.
//  Copyright (c) 2014 Alexei Baboulevitch ("Archagon"). All rights reserved.
//

import UIKit
import AudioToolbox

let metrics: [String:Double] = [
    "topBanner": 30
]
func metric(_ name: String) -> CGFloat { return CGFloat(metrics[name]!) }

// TODO: move this somewhere else and localize
let kAutoCapitalization = "kAutoCapitalization"
let kPeriodShortcut = "kPeriodShortcut"
let kKeyboardClicks = "kKeyboardClicks"
let kSmallLowercase = "kSmallLowercase"

class KeyboardViewController: UIInputViewController {
    var uiIsDarkMode:Bool = false
    var needsInputSwitch:Bool = true
    var appExt = true
    var topRowButtonDepressNotAppExt = false //false to prevent key popup in top row
    let backspaceDelay: TimeInterval = 0.5
    let backspaceRepeat: TimeInterval = 0.07
    var keyboard: Keyboard!
    var forwardingView: ForwardingView!
    var layout: KeyboardLayout?
    var heightConstraint: NSLayoutConstraint?
    var portraitHeightOverride:CGFloat = 0.0
    var landscapeHeightOverride:CGFloat = 0.0
    
    var bannerView: ExtraView?
    var settingsView: ExtraView?
    
    var currentMode: Int {
        didSet {
            if oldValue != currentMode {
                setMode(currentMode)
            }
        }
    }
    
    var backspaceActive: Bool {
        get {
            return (backspaceDelayTimer != nil) || (backspaceRepeatTimer != nil)
        }
    }
    var backspaceDelayTimer: Timer?
    var backspaceRepeatTimer: Timer?
    
    enum AutoPeriodState {
        case noSpace
        case firstSpace
    }
    
    var autoPeriodState: AutoPeriodState = .noSpace
    var lastCharCountInBeforeContext: Int = 0
    
    var shiftState: ShiftState {
        didSet {
            switch shiftState {
            case .disabled:
                self.updateKeyCaps(false)
            case .enabled:
                self.updateKeyCaps(true)
            case .locked:
                self.updateKeyCaps(true)
            }
        }
    }
    
    // state tracking during shift tap
    var shiftWasMultitapped: Bool = false
    var shiftStartingState: ShiftState?
    
    var keyboardHeight: CGFloat {
        get {
            if let constraint = self.heightConstraint {
                return constraint.constant
            }
            else {
                return 0
            }
        }
        set {
            self.setHeight(newValue)
        }
    }
    
    // TODO: why does the app crash if this isn't here?
    convenience init(isAppExtension:Bool) {
        self.init(nibName: nil, bundle: nil)
        self.appExt = isAppExtension
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        UserDefaults.standard.register(defaults: [
            kAutoCapitalization: false, //true will make it start on uppercase
            kPeriodShortcut: true,
            kKeyboardClicks: false,
            kSmallLowercase: true
        ])
        self.shiftState = .disabled
        self.currentMode = 0
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        //http://stackoverflow.com/questions/26120043/unable-to-change-uiinputview-height
        //for ios 9.0+, this is required when embedded, doesn't matter if run as app extension
        if #available(iOS 9.0, *) {
            self.inputView?.allowsSelfSizing = true
        }

    }
    
    //this is a hack, but solves a problem where isPortrait reported wrong
    //values and thus keyboard height was wrong when relaunching app
    @objc func keyboardWillShow(_ notification: Notification) {
        self.keyboardHeight = self.height(orientationIsPortrait: self.isPortrait(), withTopBanner: (self.bannerView != nil))
    }
/*
     override func viewDidLoad() {
     super.viewDidLoad()
        //self.inputView = KludgeView()
        //self.keyboard = defaultKeyboard()
        self.keyboard = greekKeyboard(needsInputModeSwitchKey:self.needsInputSwitch)
        //self.preferredContentSize = CGSize(width: self.view.frame.size.width, height: 356)
        self.forwardingView = ForwardingView(frame: CGRect.zero)
        self.view.addSubview(self.forwardingView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardViewController.defaultsChanged(_:)), name: UserDefaults.didChangeNotification, object: nil)
     }
*/
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    deinit {
        backspaceDelayTimer?.invalidate()
        backspaceRepeatTimer?.invalidate()
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func defaultsChanged(_ notification: Notification) {
        //let defaults = notification.object as? NSUserDefaults
        self.updateKeyCaps(self.shiftState.uppercase())
    }
    
    // without this here kludge, the height constraint for the keyboard does not work for some reason
    var kludge: UIView?
    func setupKludge() {
        if self.kludge == nil {
            let kludge = UIView()
            //kludge.intrinsicContentSize = CGSize(width: UIViewNoIntrinsicMetric, height: 0)
            self.view.addSubview(kludge)
            kludge.translatesAutoresizingMaskIntoConstraints = false
            kludge.isHidden = true
            
            let a = NSLayoutConstraint(item: kludge, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: 0)
            let b = NSLayoutConstraint(item: kludge, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: 0)
            let c = NSLayoutConstraint(item: kludge, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
            let d = NSLayoutConstraint(item: kludge, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
            self.view.addConstraints([a, b, c, d])
            
            self.kludge = kludge
        }
    }
    
    //https://stackoverflow.com/questions/52652956/how-to-detect-if-the-device-iphone-has-physical-home-button
    func needExtraBottomPadding() -> Bool
    {
        if #available(iOS 11.0, *), let keyWindow = UIApplication.shared.keyWindow, keyWindow.safeAreaInsets.bottom > 0 { return true }
        return false
    }
    
    /*
    BUG NOTE

    For some strange reason, a layout pass of the entire keyboard is triggered 
    whenever a popup shows up, if one of the following is done:

    a) The forwarding view uses an autoresizing mask.
    b) The forwarding view has constraints set anywhere other than init.

    On the other hand, setting (non-autoresizing) constraints or just setting the
    frame in layoutSubviews works perfectly fine.

    I don't really know what to make of this. Am I doing Autolayout wrong, is it
    a bug, or is it expected behavior? Perhaps this has to do with the fact that
    the view's frame is only ever explicitly modified when set directly in layoutSubviews,
    and not implicitly modified by various Autolayout constraints
    (even though it should really not be changing).
    */
    
    var constraintsAdded: Bool = false
    func setupLayout() {
        if !constraintsAdded {
            /*
             var extraP = false
            if !appExt && !needsInputSwitch
            {
                extraP = true
            }*/
        
            let extraBottomPadding = needExtraBottomPadding()
            //print("EEEEEEEEEEEE \(extraP) \(appExt) \(needsInputSwitch)")
            self.layout = type(of: self).layoutClass.init(model: self.keyboard, superview: self.forwardingView, layoutConstants: type(of: self).layoutConstants, globalColors: type(of: self).globalColors, darkMode: self.darkMode(), solidColorMode: self.solidColorMode(), needsExtraBottomPadding: extraBottomPadding, constrainPopupToKeyboardBounds: appExt)
            
            self.layout?.initialize()
            self.setMode(0)
            
            self.setupKludge()
            
            self.updateKeyCaps(self.shiftState.uppercase())
            self.updateCapsIfNeeded()
            
            self.updateAppearances(self.darkMode())
            self.addInputTraitsObservers()
            
            self.constraintsAdded = true
        }
    }
    
    // only available after frame becomes non-zero
    func darkMode() -> Bool {
        let darkMode = { () -> Bool in
            let proxy = self.textDocumentProxy
            return proxy.keyboardAppearance == UIKeyboardAppearance.dark
        }()
        
        return darkMode
    }
    
    func solidColorMode() -> Bool {
        //setting this to true fixes odd issue when transitioning from
        //dark mode to light mode
        return UIAccessibility.isReduceTransparencyEnabled
    }
    
    /*
     
     problem seems to be that before view disappears it switches to portrait,
     when it reappears it renders at portrait height even when landscape.
     this can be tested because problem disappears when portrait height override in HopliteChallenge.swift is set to be the same as landscape.
     */
    func isPortrait() -> Bool
    {
        //let size = UIScreen.main.bounds.size
        //let size = UIScreen.main.nativeBounds.size
        if UIApplication.shared.statusBarOrientation.isLandscape {
            //print("Landscape: \(size.width) X \(size.height)")
            return false
        } else {
            //print("Portrait: \(size.width) X \(size.height)")
            return true
        }
    }
    /*
    override func viewDidAppear(_ animated: Bool) {
        if self.needsInputModeSwitchKey
        {
            self.forwardingView.backgroundColor = UIColor.brown
        }
    }
    */

    var lastLayoutBounds: CGRect?
    override func viewDidLayoutSubviews() {
        if view.bounds == CGRect.zero {
            return
        }
        getUIDarkMode()
        self.setupLayout()
        
        let orientationSavvyBounds = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.height(orientationIsPortrait: self.isPortrait(), withTopBanner: false))
        
        if (lastLayoutBounds != nil && lastLayoutBounds == orientationSavvyBounds) {
            // do nothing
        }
        else {
            let uppercase = self.shiftState.uppercase()
            let characterUppercase = (UserDefaults.standard.bool(forKey: kSmallLowercase) ? uppercase : true)
            
            self.forwardingView.frame = orientationSavvyBounds
            self.layout?.layoutKeys(self.currentMode, uppercase: uppercase, characterUppercase: characterUppercase, shiftState: self.shiftState)
            self.lastLayoutBounds = orientationSavvyBounds
            self.setupKeys()
        }
        
        self.bannerView?.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: metric("topBanner"))
        
        let newOrigin = CGPoint(x: 0, y: self.view.bounds.height - self.forwardingView.bounds.height)
        self.forwardingView.frame.origin = newOrigin
    }
    
    override func loadView() {
        super.loadView()
        
        //self.inputView = KludgeView()
        //self.keyboard = defaultKeyboard()
        self.keyboard = greekKeyboard(needsInputModeSwitchKey:self.needsInputSwitch)
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
    /*
    override func viewDidAppear(_ animated: Bool) {
        if #available(iOS 11.0, *) {
            print("input2: \(self.needsInputModeSwitchKey)")
        }
    }
    */
    override func viewWillDisappear(_ animated: Bool)
    {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification , object: nil)
    }
    
    var alreadyInit = false
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        //adapted from setMode
        if !needsInputSwitch
        {
            /*
            if keyboard.pages[0].rows[4][1].type == .keyboardChange
            {
                keyboard.pages[0].rows[4].remove(at: 1)
            }
            */
            
            //remove all .keyboardChange keys
            for (p, page) in keyboard.pages.enumerated() {
                for (r, rowKeys) in page.rows.enumerated() {
                    for (k, key) in rowKeys.enumerated() {
                        if key.type == .keyboardChange {
                            keyboard.pages[p].rows[r].remove(at: k)
                        }
                    }
                }
            }
            
            self.setMode(0)
        }

        self.bannerView?.isHidden = false
        self.keyboardHeight = self.height(orientationIsPortrait: self.isPortrait(), withTopBanner: (self.bannerView != nil))
        //self.updateAppearances(self.uiIsDarkMode)
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        self.forwardingView.resetTrackedViews()
        self.shiftStartingState = nil
        self.shiftWasMultitapped = false
        
        // optimization: ensures smooth animation
        if let keyPool = self.layout?.keyPool {
            for view in keyPool {
                view.shouldRasterize = true
            }
        }
        
        self.keyboardHeight = self.height(orientationIsPortrait: self.isPortrait(), withTopBanner: (self.bannerView != nil))
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        // optimization: ensures quick mode and shift transitions
        if let keyPool = self.layout?.keyPool {
            for view in keyPool {
                view.shouldRasterize = false
            }
        }
    }
    
    func height(orientationIsPortrait isPortrait: Bool, withTopBanner: Bool) -> CGFloat {
        let isPad = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
        
        // AB: consider re-enabling this when interfaceOrientation actually breaks
        //// HACK: Detecting orientation manually
        //let screenSize: CGSize = UIScreen.main.bounds.size
        //let orientation: UIInterfaceOrientation = screenSize.width < screenSize.height ? .portrait : .landscapeLeft
        
        //TODO: hardcoded stuff
        let actualScreenWidth = (UIScreen.main.nativeBounds.size.width / UIScreen.main.nativeScale)
        var canonicalPortraitHeight: CGFloat
        var canonicalLandscapeHeight: CGFloat
        if isPad {
            canonicalPortraitHeight = 264
            canonicalLandscapeHeight = 352
            
            if portraitHeightOverride > 0
            {
                canonicalPortraitHeight = portraitHeightOverride
            }
            if landscapeHeightOverride > 0
            {
                canonicalLandscapeHeight = landscapeHeightOverride
            }
        }
        else {
            canonicalPortraitHeight = isPortrait && actualScreenWidth >= 400 ? 266 : 256
            canonicalLandscapeHeight = 162
            
            if portraitHeightOverride > 0
            {
                canonicalPortraitHeight = portraitHeightOverride
            }
            if landscapeHeightOverride > 0
            {
                canonicalLandscapeHeight = landscapeHeightOverride
            }
            /*
            //we get this from needsextrabottompadding now
            if !appExt && !needsInputSwitch
            {
                canonicalPortraitHeight += 50
                canonicalLandscapeHeight += 30
            }
            */
            print("app \(appExt) nee \(needsInputSwitch)")
            
        }
        
        let topBannerHeight = (withTopBanner ? metric("topBanner") : 0)
        
        let a = CGFloat(isPortrait ? canonicalPortraitHeight + topBannerHeight : canonicalLandscapeHeight + topBannerHeight)
        //print("heightaa: \(a)")
        return a
    }
    
    func isInTopRow(key:Key) -> Bool
    {
        for p in self.keyboard.pages //look in each page
        {
            for k in p.rows[0] //just look in top row
            {
                if k == key
                {
                    return true
                }
            }
        }
        return false
    }
    
    /*
    BUG NOTE

    None of the UIContentContainer methods are called for this controller.
    */
    
    //override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    //    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    //}
    
    func setupKeys() {
        if self.layout == nil {
            return
        }
        
        for page in keyboard.pages {
            for rowKeys in page.rows { // TODO: quick hack
                for key in rowKeys {
                    if let keyView = self.layout?.viewForKey(key) {
                        keyView.removeTarget(nil, action: nil, for: UIControl.Event.allEvents)
                        
                        switch key.type {
                        case Key.KeyType.keyboardChange:
                            keyView.addTarget(self,
                                              action: #selector(KeyboardViewController.advanceTapped(_:)),
                                              for: .touchUpInside)
                        case Key.KeyType.backspace:
                            let cancelEvents: UIControl.Event = [UIControl.Event.touchUpInside, UIControl.Event.touchUpInside, UIControl.Event.touchDragExit, UIControl.Event.touchUpOutside, UIControl.Event.touchCancel, UIControl.Event.touchDragOutside]
                            
                            keyView.addTarget(self,
                                              action: #selector(KeyboardViewController.backspaceDown(_:)),
                                              for: .touchDown)
                            keyView.addTarget(self,
                                              action: #selector(KeyboardViewController.backspaceUp(_:)),
                                              for: cancelEvents)
                        case Key.KeyType.shift:
                            keyView.addTarget(self,
                                              action: #selector(KeyboardViewController.shiftDown(_:)),
                                              for: .touchDown)
                            keyView.addTarget(self,
                                              action: #selector(KeyboardViewController.shiftUp(_:)),
                                              for: .touchUpInside)
                            keyView.addTarget(self,
                                              action: #selector(KeyboardViewController.shiftDoubleTapped(_:)),
                                              for: .touchDownRepeat)
                        case Key.KeyType.modeChange:
                            keyView.addTarget(self,
                                              action: #selector(KeyboardViewController.modeChangeTapped(_:)),
                                              for: .touchDown)
                        case Key.KeyType.settings:
                            keyView.addTarget(self,
                                              action: #selector(KeyboardViewController.toggleSettings),
                                              for: .touchUpInside)
                        default:
                            break
                        }
                        
                        if key.isCharacter /*&& key.type != .diacritic && key.type != .punctuation*/ {

                            if topRowButtonDepressNotAppExt || !isInTopRow(key: key)
                            {
                                if UIDevice.current.userInterfaceIdiom != UIUserInterfaceIdiom.pad {
                                    keyView.addTarget(self,
                                                      action: #selector(KeyboardViewController.showPopup(_:)),
                                                      for: [.touchDown, .touchDragInside, .touchDragEnter])
                                    keyView.addTarget(keyView,
                                                      action: #selector(KeyboardKey.hidePopup),
                                                      for: [.touchDragExit, .touchCancel])
                                    keyView.addTarget(self,
                                                      action: #selector(KeyboardViewController.hidePopupDelay(_:)),
                                                      for: [.touchUpInside, .touchUpOutside, .touchDragOutside])
                                }
                            }
                        }
                        
                        if key.hasOutput {
                            keyView.addTarget(self,
                                              action: #selector(KeyboardViewController.keyPressedHelper(_:)),
                                              for: .touchUpInside)
                        }
                        
                        if key.type != Key.KeyType.shift && key.type != Key.KeyType.modeChange {
                            keyView.addTarget(self,
                                              action: #selector(KeyboardViewController.highlightKey(_:)),
                                              for: [.touchDown, .touchDragInside, .touchDragEnter])
                            keyView.addTarget(self,
                                              action: #selector(KeyboardViewController.unHighlightKey(_:)),
                                              for: [.touchUpInside, .touchUpOutside, .touchDragOutside, .touchDragExit, .touchCancel])
                        }
                        
                        keyView.addTarget(self,
                                          action: #selector(KeyboardViewController.playKeySound),
                                          for: .touchDown)
                    }
                }
            }
        }
    }
    
    /////////////////
    // POPUP DELAY //
    /////////////////
    
    var keyWithDelayedPopup: KeyboardKey?
    var popupDelayTimer: Timer?
    
    @objc func showPopup(_ sender: KeyboardKey) {
        if sender == self.keyWithDelayedPopup {
            self.popupDelayTimer?.invalidate()
        }
        sender.showPopup()
    }
    
    @objc func hidePopupDelay(_ sender: KeyboardKey) {
        self.popupDelayTimer?.invalidate()
        
        if sender != self.keyWithDelayedPopup {
            self.keyWithDelayedPopup?.hidePopup()
            self.keyWithDelayedPopup = sender
        }
        
        if sender.popup != nil {
            self.popupDelayTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(KeyboardViewController.hidePopupCallback), userInfo: nil, repeats: false)
        }
    }
    
    @objc func hidePopupCallback() {
        self.keyWithDelayedPopup?.hidePopup()
        self.keyWithDelayedPopup = nil
        self.popupDelayTimer = nil
    }
    
    /////////////////////
    // POPUP DELAY END //
    /////////////////////
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }

    // TODO: this is currently not working as intended; only called when selection changed -- iOS bug
    override func textDidChange(_ textInput: UITextInput?) {
        self.contextChanged()
        pollTraits()
    }
    
    func contextChanged() {
        self.updateCapsIfNeeded()
        self.autoPeriodState = .noSpace
    }
    
    func setHeight(_ height: CGFloat) {
        
        if self.heightConstraint == nil {
            //this fixes constraint conflict, but now touches aren't seen
            //self.inputView!.translatesAutoresizingMaskIntoConstraints = false
            self.heightConstraint = NSLayoutConstraint(
                item:self.view!,
                attribute:.height,
                relatedBy:.equal,
                toItem:nil,
                attribute:.notAnAttribute,
                multiplier:1.0,
                constant:height)
            self.heightConstraint!.priority = UILayoutPriority(rawValue: 999.0)
            self.heightConstraint!.isActive = true
            self.view.addConstraint(self.heightConstraint!) // TODO: what if view already has constraint added?
        }
        else {
            //problem is wrong # being passed in here when relaunching in landscape
            self.heightConstraint?.constant = height
        }
    }
    
    func updateAppearances(_ appearanceIsDark: Bool) {
        self.layout?.solidColorMode = self.solidColorMode()
        self.layout?.darkMode = appearanceIsDark
        self.layout?.updateKeyAppearance()
        
        self.bannerView?.darkMode = appearanceIsDark
        self.settingsView?.darkMode = appearanceIsDark
        
    //https://github.com/archagon/tasty-imitation-keyboard/pull/130/commits/e15486c8f00c10af849dd29739f4b4ce1a2420aa
        //Fix for iOS12 update bugs where touches on the forwarding view are not being handled properly
        //Fix just updates the background color of the forwarding view to blend in with the keyboard background view,
        //so that it can respond to touches
        /*
        if #available(iOSApplicationExtension 10.0, *){
            if(!appearanceIsDark){
                self.forwardingView?.backgroundColor = UIColor(red: (203/255), green: (206/255), blue: (226/255), alpha: 0.1)
            }else{
                self.forwardingView?.backgroundColor = UIColor(red: (42/255), green: (43/255), blue: (53/255), alpha: 0.1)
            }

        } else {
            // Fallback on earlier versions
        }*/
    }
    
    @objc func highlightKey(_ sender: KeyboardKey) {
        sender.isHighlighted = true
    }
    
    @objc func unHighlightKey(_ sender: KeyboardKey) {
        sender.isHighlighted = false
    }
    
    @objc func keyPressedHelper(_ sender: KeyboardKey) {
        if let model = self.layout?.keyForView(sender) {
            self.keyPressed(model)

            // auto exit from special char subkeyboard
            if model.type == Key.KeyType.space || model.type == Key.KeyType.return {
                self.currentMode = 0
            }
            else if model.lowercaseOutput == "'" {
                self.currentMode = 0
            }
            else if model.type == Key.KeyType.character {
                self.currentMode = 0
            }
            
            // auto period on double space
            // TODO: timeout
            
            self.handleAutoPeriod(model)
            // TODO: reset context
        }
        
        self.updateCapsIfNeeded()
    }
    
    func handleAutoPeriod(_ key: Key) {
        if !UserDefaults.standard.bool(forKey: kPeriodShortcut) {
            return
        }
        
        if self.autoPeriodState == .firstSpace {
            if key.type != Key.KeyType.space {
                self.autoPeriodState = .noSpace
                return
            }
            
            let charactersAreInCorrectState = { () -> Bool in
                let previousContext = self.textDocumentProxy.documentContextBeforeInput
                
                if previousContext == nil || (previousContext!).count < 3 {
                    return false
                }
                
                var index = previousContext!.endIndex
                
                index = previousContext!.index(before: index)
                if previousContext![index] != " " {
                    return false
                }
                
                index = previousContext!.index(before: index)
                if previousContext![index] != " " {
                    return false
                }
                
                index = previousContext!.index(before: index)
                let char = previousContext![index]
                if self.characterIsWhitespace(char) || self.characterIsPunctuation(char) || char == "," {
                    return false
                }
                
                return true
            }()
            
            if charactersAreInCorrectState {
                self.textDocumentProxy.deleteBackward()
                self.textDocumentProxy.deleteBackward()
                self.textDocumentProxy.insertText(".")
                self.textDocumentProxy.insertText(" ")
            }
            
            self.autoPeriodState = .noSpace
        }
        else {
            if key.type == Key.KeyType.space {
                self.autoPeriodState = .firstSpace
            }
        }
    }
    
    func cancelBackspaceTimers() {
        self.backspaceDelayTimer?.invalidate()
        self.backspaceRepeatTimer?.invalidate()
        self.backspaceDelayTimer = nil
        self.backspaceRepeatTimer = nil
    }
    
    @objc func backspaceDown(_ sender: KeyboardKey) {
        self.cancelBackspaceTimers()
        
        self.textDocumentProxy.deleteBackward()
        self.updateCapsIfNeeded()
        
        // trigger for subsequent deletes
        self.backspaceDelayTimer = Timer.scheduledTimer(timeInterval: backspaceDelay - backspaceRepeat, target: self, selector: #selector(KeyboardViewController.backspaceDelayCallback), userInfo: nil, repeats: false)
    }
    
    @objc func backspaceUp(_ sender: KeyboardKey) {
        self.cancelBackspaceTimers()
    }
    
    @objc func backspaceDelayCallback() {
        self.backspaceDelayTimer = nil
        self.backspaceRepeatTimer = Timer.scheduledTimer(timeInterval: backspaceRepeat, target: self, selector: #selector(KeyboardViewController.backspaceRepeatCallback), userInfo: nil, repeats: true)
    }
    
    @objc func backspaceRepeatCallback() {
        self.playKeySound()
        
        self.textDocumentProxy.deleteBackward()
        self.updateCapsIfNeeded()
    }
    
    @objc func shiftDown(_ sender: KeyboardKey) {
        self.shiftStartingState = self.shiftState
        
        if let shiftStartingState = self.shiftStartingState {
            if shiftStartingState.uppercase() {
                // handled by shiftUp
                return
            }
            else {
                switch self.shiftState {
                case .disabled:
                    self.shiftState = .enabled
                case .enabled:
                    self.shiftState = .disabled
                case .locked:
                    self.shiftState = .disabled
                }
                
                (sender.shape as? ShiftShape)?.withLock = false
            }
        }
    }
    
    @objc func shiftUp(_ sender: KeyboardKey) {
        if self.shiftWasMultitapped {
            // do nothing
        }
        else {
            if let shiftStartingState = self.shiftStartingState {
                if !shiftStartingState.uppercase() {
                    // handled by shiftDown
                }
                else {
                    switch self.shiftState {
                    case .disabled:
                        self.shiftState = .enabled
                    case .enabled:
                        self.shiftState = .disabled
                    case .locked:
                        self.shiftState = .disabled
                    }
                    
                    (sender.shape as? ShiftShape)?.withLock = false
                }
            }
        }

        self.shiftStartingState = nil
        self.shiftWasMultitapped = false
    }
    
    @objc func shiftDoubleTapped(_ sender: KeyboardKey) {
        self.shiftWasMultitapped = true
        
        switch self.shiftState {
        case .disabled:
            self.shiftState = .locked
        case .enabled:
            self.shiftState = .locked
        case .locked:
            self.shiftState = .disabled
        }
    }
    
    func updateKeyCaps(_ uppercase: Bool) {
        let characterUppercase = (UserDefaults.standard.bool(forKey: kSmallLowercase) ? uppercase : true)
        self.layout?.updateKeyCaps(false, uppercase: uppercase, characterUppercase: characterUppercase, shiftState: self.shiftState)
    }
    
    @objc func modeChangeTapped(_ sender: KeyboardKey) {
        if let toMode = self.layout?.viewToModel[sender]?.toMode {
            self.currentMode = toMode
        }
    }
    
    func setMode(_ mode: Int) {
        self.forwardingView.resetTrackedViews()
        self.shiftStartingState = nil
        self.shiftWasMultitapped = false
        
        let uppercase = self.shiftState.uppercase()
        let characterUppercase = (UserDefaults.standard.bool(forKey: kSmallLowercase) ? uppercase : true)
        self.layout?.layoutKeys(mode, uppercase: uppercase, characterUppercase: characterUppercase, shiftState: self.shiftState)
        
        self.setupKeys()
    }
    
    @objc func advanceTapped(_ sender: KeyboardKey) {
        self.forwardingView.resetTrackedViews()
        self.shiftStartingState = nil
        self.shiftWasMultitapped = false
        
        self.advanceToNextInputMode()
    }
    
    @IBAction func toggleSettings() {
        // lazy load settings
        if self.settingsView == nil {
            if let aSettings = self.createSettings() {
                aSettings.darkMode = self.darkMode()
                
                aSettings.isHidden = true
                self.view.addSubview(aSettings)
                self.settingsView = aSettings
                
                aSettings.translatesAutoresizingMaskIntoConstraints = false
                
                let widthConstraint = NSLayoutConstraint(item: aSettings, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1, constant: 0)
                let heightConstraint = NSLayoutConstraint(item: aSettings, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1, constant: 0)
                let centerXConstraint = NSLayoutConstraint(item: aSettings, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
                let centerYConstraint = NSLayoutConstraint(item: aSettings, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
                
                self.view.addConstraint(widthConstraint)
                self.view.addConstraint(heightConstraint)
                self.view.addConstraint(centerXConstraint)
                self.view.addConstraint(centerYConstraint)
            }
        }
        
        if let settings = self.settingsView {
            let hidden = settings.isHidden
            settings.isHidden = !hidden
            self.forwardingView.isHidden = hidden
            self.forwardingView.isUserInteractionEnabled = !hidden
            self.bannerView?.isHidden = hidden
        }
    }
    
    func updateCapsIfNeeded() {
        if self.shouldAutoCapitalize() {
            switch self.shiftState {
            case .disabled:
                self.shiftState = .enabled
            case .enabled:
                self.shiftState = .enabled
            case .locked:
                self.shiftState = .locked
            }
        }
        else {
            switch self.shiftState {
            case .disabled:
                self.shiftState = .disabled
            case .enabled:
                self.shiftState = .disabled
            case .locked:
                self.shiftState = .locked
            }
        }
    }
    
    func characterIsPunctuation(_ character: Character) -> Bool {
        return (character == ".") || (character == "!") || (character == "?")
    }
    
    func characterIsNewline(_ character: Character) -> Bool {
        return (character == "\n") || (character == "\r")
    }
    
    func characterIsWhitespace(_ character: Character) -> Bool {
        // there are others, but who cares
        return (character == " ") || (character == "\n") || (character == "\r") || (character == "\t")
    }
    
    func stringIsWhitespace(_ string: String?) -> Bool {
        if string != nil {
            for char in (string!) {
                if !characterIsWhitespace(char) {
                    return false
                }
            }
        }
        return true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        getUIDarkMode()
        self.updateAppearances(uiIsDarkMode)
    }
    
    func getUIDarkMode()
    {
        if #available(iOS 12.0, *) {
            uiIsDarkMode = (traitCollection.userInterfaceStyle == .dark)
        } else {
            uiIsDarkMode = false
        }
    }
    
    func shouldAutoCapitalize() -> Bool {
        if !UserDefaults.standard.bool(forKey: kAutoCapitalization) {
            return false
        }
        
        let traits = self.textDocumentProxy
        if let autocapitalization = traits.autocapitalizationType {
            let documentProxy = self.textDocumentProxy
            //var beforeContext = documentProxy.documentContextBeforeInput
            
            switch autocapitalization {
            case .none:
                return false
            case .words:
                if let beforeContext = documentProxy.documentContextBeforeInput {
                    let previousCharacter = beforeContext[beforeContext.index(before: beforeContext.endIndex)]
                    return self.characterIsWhitespace(previousCharacter)
                }
                else {
                    return true
                }
            
            case .sentences:
                if let beforeContext = documentProxy.documentContextBeforeInput {
                    let offset = min(3, beforeContext.count)
                    var index = beforeContext.endIndex
                    
                    for i in 0 ..< offset {
                        index = beforeContext.index(before: index)
                        let char = beforeContext[index]
                        
                        if characterIsPunctuation(char) {
                            if i == 0 {
                                return false //not enough spaces after punctuation
                            }
                            else {
                                return true //punctuation with at least one space after it
                            }
                        }
                        else {
                            if !characterIsWhitespace(char) {
                                return false //hit a foreign character before getting to 3 spaces
                            }
                            else if characterIsNewline(char) {
                                return true //hit start of line
                            }
                        }
                    }
                    
                    return true //either got 3 spaces or hit start of line
                }
                else {
                    return true
                }
            case .allCharacters:
                return true
            @unknown default:
                return false
            }
        }
        else {
            return false
        }
    }
    
    func canPlaySound() -> Bool
    {
        return UserDefaults.standard.bool(forKey: kKeyboardClicks)
    }
    
    // this only works if full access is enabled
    @objc func playKeySound() {
        if !canPlaySound()
        {
            return
        }
        
        DispatchQueue.global(qos: .default).async(execute: {
            AudioServicesPlaySystemSound(1104)
        })
    }
    
    //////////////////////////////////////
    // MOST COMMONLY EXTENDABLE METHODS //
    //////////////////////////////////////
    
    class var layoutClass: KeyboardLayout.Type { get { return KeyboardLayout.self }}
    class var layoutConstants: LayoutConstants.Type { get { return LayoutConstants.self }}
    class var globalColors: GlobalColors.Type { get { return GlobalColors.self }}
    
    func keyPressed(_ key: Key) {
        self.textDocumentProxy.insertText(key.outputForCase(self.shiftState.uppercase()))
    }
    
    // a banner that sits in the empty space on top of the keyboard
    func createBanner() -> ExtraView? {
        // note that dark mode is not yet valid here, so we just put false for clarity
        //return ExtraView(globalColors: self.dynamicType.globalColors, darkMode: false, solidColorMode: self.solidColorMode())
        return nil
    }
    
    // a settings view that replaces the keyboard when the settings button is pressed
    func createSettings() -> ExtraView? {
        // note that dark mode is not yet valid here, so we just put false for clarity
        let settingsView = DefaultSettings(globalColors: type(of: self).globalColors, darkMode: false, solidColorMode: self.solidColorMode())
        settingsView.backButton?.addTarget(self, action: #selector(KeyboardViewController.toggleSettings), for: UIControl.Event.touchUpInside)
        return settingsView
    }
}
