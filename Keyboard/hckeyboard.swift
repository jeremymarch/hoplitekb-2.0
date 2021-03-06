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

func hcKeyboard(needsInputModeSwitchKey:Bool) -> Keyboard {
    let greekKeyboard = Keyboard()

    let mf = Key(.multipleforms)
    mf.uppercaseKeyCap = "MF"
    mf.lowercaseKeyCap = "MF"
    mf.uppercaseOutput = "MF"
    mf.lowercaseOutput = "MF"
    greekKeyboard.add(key: mf, row: 0, page: 0)
    
    //rough
    let d1 = Key(.diacritic)
    d1.uppercaseKeyCap = "῾" //῾
    d1.lowercaseKeyCap = "῾"
    d1.uppercaseOutput = "rough"
    d1.lowercaseOutput = "rough"
    greekKeyboard.add(key: d1, row: 0, page: 0)
    //smooth
    let d2 = Key(.diacritic)
    d2.uppercaseKeyCap = "᾿" //᾿
    d2.lowercaseKeyCap = "᾿"
    d2.uppercaseOutput = "smooth"
    d2.lowercaseOutput = "smooth"
    greekKeyboard.add(key: d2, row: 0, page: 0)
    //acute
    let d3 = Key(.diacritic)
    d3.uppercaseKeyCap = "´"
    d3.lowercaseKeyCap = "´"
    d3.uppercaseOutput = "acute"
    d3.lowercaseOutput = "acute"
    greekKeyboard.add(key: d3, row: 0, page: 0)
    //grave
    /*
    let d5 = Key(.diacritic)
    d5.uppercaseKeyCap = "`"
    d5.lowercaseKeyCap = "`"
    d5.uppercaseOutput = "grave"
    d5.lowercaseOutput = "grave"
    greekKeyboard.add(key: d5, row: 0, page: 0)
     */
    //circumflex, diaeresis
    let d4 = Key(.diacritic)
    d4.uppercaseKeyCap = "¨"
    d4.lowercaseKeyCap = "~"
    //d4.lowercaseKeyCap = "˘"//"˜" //a breve which we flip
    d4.uppercaseOutput = "diaeresis" //9
    d4.lowercaseOutput = "circum"
    greekKeyboard.add(key: d4, row: 0, page: 0)
    //macron, breve
    let d6 = Key(.diacritic)
    d6.uppercaseKeyCap = "˘"
    d6.lowercaseKeyCap = "¯"
    d6.uppercaseOutput = "breve"
    d6.lowercaseOutput = "macron"
    greekKeyboard.add(key: d6, row: 0, page: 0)
    //iota subscript
    let d7 = Key(.diacritic)
    d7.uppercaseKeyCap = "ͺ"
    d7.lowercaseKeyCap = "ͺ"
    d7.uppercaseOutput = "iotasub"
    d7.lowercaseOutput = "iotasub"
    greekKeyboard.add(key: d7, row: 0, page: 0)
    
    let returnKey = Key(.return)
    returnKey.uppercaseKeyCap = "enter"
    returnKey.uppercaseOutput = "\n"
    returnKey.lowercaseOutput = "\n"
    greekKeyboard.add(key: returnKey, row: 0, page: 0)
    /*
    //comma, apostrophe
    let d8 = Key(.punctuation)
    d8.uppercaseKeyCap = "’"
    d8.lowercaseKeyCap = ","
    d8.uppercaseOutput = "’"
    d8.lowercaseOutput = ","
    greekKeyboard.add(key: d8, row: 0, page: 0)
    //raised dot, em dash
    let d9 = Key(.punctuation)
    d9.uppercaseKeyCap = "—"
    d9.lowercaseKeyCap = "·"
    d9.uppercaseOutput = "—"
    d9.lowercaseOutput = "·"
    greekKeyboard.add(key: d9, row: 0, page: 0)
 */
    /*
    for key in [",", "."] {
        let keyModel = Key(.punctuation)
        keyModel.setLetter(key)
        greekKeyboard.add(key: keyModel, row: 0, page: 0)
    }*/
    
    let l1 = Key(.character)
    l1.uppercaseKeyCap = "!"
    l1.lowercaseKeyCap = "ς"
    l1.uppercaseOutput = "!"
    l1.lowercaseOutput = "ς"
    greekKeyboard.add(key: l1, row: 1, page: 0)
    
    for key in ["ε", "ρ", "τ", "υ", "θ", "ι", "ο", "π"] {
        let keyModel = Key(.character)
        keyModel.setLetter(key)
        greekKeyboard.add(key: keyModel, row: 1, page: 0)
    }
    
    for key in ["α", "σ", "δ", "φ", "γ", "η", "ξ", "κ", "λ"] {
        let keyModel = Key(.character)
        keyModel.setLetter(key)
        greekKeyboard.add(key: keyModel, row: 2, page: 0)
    }
    
    for key in ["ζ", "χ", "ψ", "ω", "β", "ν", "μ"] {
        let keyModel = Key(.character)
        keyModel.setLetter(key)
        greekKeyboard.add(key: keyModel, row: 3, page: 0)
    }
    
    let parens = Key(.diacritic)
    parens.uppercaseKeyCap = "( )"
    parens.lowercaseKeyCap = "( )"
    parens.uppercaseOutput = "parens"
    parens.lowercaseOutput = "parens"
    greekKeyboard.add(key: parens, row: 3, page: 0)
    
    let backspace = Key(.backspace)
    greekKeyboard.add(key: backspace, row: 3, page: 0)
    /*
    let keyModel = Key(.shift)
    greekKeyboard.add(key: keyModel, row: 4, page: 0)
    
    let keyModeChangeNumbers = Key(.modeChange)
    keyModeChangeNumbers.uppercaseKeyCap = "123"
    keyModeChangeNumbers.toMode = 1
    greekKeyboard.add(key: keyModeChangeNumbers, row: 4, page: 0)
    
    //globe key
    var keyboardChange:Key?
    if needsInputModeSwitchKey
    {
        keyboardChange = Key(.keyboardChange)
        greekKeyboard.add(key: keyboardChange!, row: 4, page: 0)
    }
    
    //let settings = Key(.settings)
    //greekKeyboard.add(key: Key(settings), row: 4, page: 0)
    
    let space = Key(.space)
    space.uppercaseKeyCap = "space"
    space.uppercaseOutput = " "
    space.lowercaseOutput = " "
    greekKeyboard.add(key: space, row: 4, page: 0)
    
    let periodquestion = Key(.punctuation)
    periodquestion.uppercaseKeyCap = ";"
    periodquestion.lowercaseKeyCap = "."
    periodquestion.uppercaseOutput = ";"
    periodquestion.lowercaseOutput = "."
    greekKeyboard.add(key: periodquestion, row: 4, page: 0)
 
    let returnKey = Key(.return)
    returnKey.uppercaseKeyCap = "return"
    returnKey.uppercaseOutput = "\n"
    returnKey.lowercaseOutput = "\n"
    greekKeyboard.add(key: returnKey, row: 4, page: 0)
    
    for key in ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"] {
        let keyModel = Key(.specialCharacter)
        keyModel.setLetter(key)
        greekKeyboard.add(key: keyModel, row: 0, page: 1)
    }
    
    for key in ["ϲ", "ϙ", "ϝ", "ϛ", "ϟ", "ϡ", "ϻ", "ͷ", "ͳ"] { //["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""] {
        let keyModel = Key(.specialCharacter)
        keyModel.setLetter(key)
        greekKeyboard.add(key: keyModel, row: 1, page: 1)
    }
    
    for key in ["ͱ", "ϸ", "ͻ", "ͼ", "ϵ", "ϐ", "Ϗ", "ʹ", "/"] { //[".", ",", "?", "!", "'"] {
        let keyModel = Key(.specialCharacter)
        keyModel.setLetter(key)
        greekKeyboard.add(key: keyModel, row: 2, page: 1)
    }
    
    for key in ["+", "*", "\"", "(", ")", "[", "]"] { //[".", ",", "?", "!", "'"] {
        let keyModel = Key(.specialCharacter)
        keyModel.setLetter(key)
        greekKeyboard.add(key: keyModel, row: 3, page: 1)
    }
    
    greekKeyboard.add(key: Key(backspace), row: 3, page: 1)
    
    let keyModeChangeSpecialCharacters = Key(.modeChange)
    keyModeChangeSpecialCharacters.uppercaseKeyCap = "#+="
    keyModeChangeSpecialCharacters.toMode = 2
    greekKeyboard.add(key: keyModeChangeSpecialCharacters, row: 4, page: 1)
    
    let keyModeChangeLetters = Key(.modeChange)
    keyModeChangeLetters.uppercaseKeyCap = "αβγ"
    keyModeChangeLetters.toMode = 0
    greekKeyboard.add(key: keyModeChangeLetters, row: 4, page: 1)
    
    if needsInputModeSwitchKey
    {
        greekKeyboard.add(key: Key(keyboardChange!), row: 4, page: 1)
    }
    //greekKeyboard.add(key: Key(settings), row: 3, page: 1)
    
    greekKeyboard.add(key: Key(space), row: 4, page: 1)
    
    let hyphen = Key(.punctuation)
    hyphen.uppercaseKeyCap = "-"
    hyphen.lowercaseKeyCap = "-"
    hyphen.uppercaseOutput = "-"
    hyphen.lowercaseOutput = "-"
    greekKeyboard.add(key: hyphen, row: 4, page: 1)
    
    greekKeyboard.add(key: Key(returnKey), row: 4, page: 1)
    
    for key in ["×", "‒", "⏑", "⏒", "⏓", "⏔", "⏕", "⏖","|", "‖"] {
        let keyModel = Key(.specialCharacter)
        keyModel.setLetter(key)
        greekKeyboard.add(key: keyModel, row: 0, page: 2)
    }
    
    
    for key in ["Ϲ", "Ϙ", "Ϝ", "Ϛ", "Ϟ", "Ϡ", "Ϻ", "Ͷ", "Ͳ"] {
        let keyModel = Key(.specialCharacter)
        keyModel.setLetter(key)
        greekKeyboard.add(key: keyModel, row: 1, page: 2)
    }
    
    for key in ["Ͱ", "Ϸ", "ͻ", "ͽ", "϶", "ϐ", "Ϗ", "͵", "\\"] {
        let keyModel = Key(.specialCharacter)
        keyModel.setLetter(key)
        greekKeyboard.add(key: keyModel, row: 2, page: 2)
    }
    
    for key in ["=", "#", "'", "<", ">", "{", "}"] {
        let keyModel = Key(.specialCharacter)
        keyModel.setLetter(key)
        greekKeyboard.add(key: keyModel, row: 3, page: 2)
    }
    
    greekKeyboard.add(key: Key(backspace), row: 3, page: 2)
    
    greekKeyboard.add(key: Key(keyModeChangeNumbers), row: 4, page: 2)
    greekKeyboard.add(key: Key(keyModeChangeLetters), row: 4, page: 2)
    
    if needsInputModeSwitchKey
    {
        greekKeyboard.add(key: Key(keyboardChange!), row: 4, page: 2)
    }
    
    //greekKeyboard.add(key: Key(settings), row: 3, page: 2)
    
    greekKeyboard.add(key: Key(space), row: 4, page: 2)
    
    let under = Key(.punctuation)
    under.uppercaseKeyCap = "_"
    under.lowercaseKeyCap = "_"
    under.uppercaseOutput = "_"
    under.lowercaseOutput = "_"
    greekKeyboard.add(key: under, row: 4, page: 2)
    
    greekKeyboard.add(key: Key(returnKey), row: 4, page: 2)
    */
    return greekKeyboard
}
