//
//  HopliteKeyboard.swift
//  Keyboard
//
//  Created by Jeremy on 9/4/19.
//  Copyright © 2019 Apple. All rights reserved.
//
//
//  DefaultKeyboard.swift
//  TransliteratingKeyboard
//
//  Created by Alexei Baboulevitch on 7/10/14.
//  Copyright (c) 2014 Alexei Baboulevitch ("Archagon"). All rights reserved.
//

func minimalGKKeyboard(needsInputModeSwitchKey:Bool) -> Keyboard {
    let greekKeyboard = Keyboard()
    /*
    let l1 = Key(.character)
    l1.uppercaseKeyCap = "!"
    l1.lowercaseKeyCap = "ς"
    l1.uppercaseOutput = "!"
    l1.lowercaseOutput = "ς"
    greekKeyboard.add(key: l1, row: 0, page: 0)
    */
    for key in ["ε", "ρ", "τ", "υ", "θ", "ι", "ο", "π"] {
        let keyModel = Key(.character)
        keyModel.setLetter(key)
        greekKeyboard.add(key: keyModel, row: 0, page: 0)
    }
    
    for key in ["α", "σ", "δ", "φ", "γ", "η", "ξ", "κ", "λ"] {
        let keyModel = Key(.character)
        keyModel.setLetter(key)
        greekKeyboard.add(key: keyModel, row: 1, page: 0)
    }
    
    for key in ["ζ", "χ", "ψ", "ω", "β", "ν", "μ"] {
        let keyModel = Key(.character)
        keyModel.setLetter(key)
        greekKeyboard.add(key: keyModel, row: 2, page: 0)
    }
    
    let backspace = Key(.backspace)
    greekKeyboard.add(key: backspace, row: 2, page: 0)
 
    return greekKeyboard
}
