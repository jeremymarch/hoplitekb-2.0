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

func greekKeyboard() -> Keyboard {
    let greekKeyboard = Keyboard()
    
    for key in ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"] {
        let keyModel = Key(.character)
        keyModel.setLetter(key)
        greekKeyboard.add(key: keyModel, row: 0, page: 0)
    }
    
    for key in ["ξ", "S", "D", "F", "G", "H", "J", "K", "L"] {
        let keyModel = Key(.character)
        keyModel.setLetter(key)
        greekKeyboard.add(key: keyModel, row: 1, page: 0)
    }
    
    let keyModel = Key(.shift)
    greekKeyboard.add(key: keyModel, row: 2, page: 0)
    
    for key in ["Z", "X", "C", "V", "B", "N", "M"] {
        let keyModel = Key(.character)
        keyModel.setLetter(key)
        greekKeyboard.add(key: keyModel, row: 2, page: 0)
    }
    
    let backspace = Key(.backspace)
    greekKeyboard.add(key: backspace, row: 2, page: 0)
    
    let keyModeChangeNumbers = Key(.modeChange)
    keyModeChangeNumbers.uppercaseKeyCap = "123"
    keyModeChangeNumbers.toMode = 1
    greekKeyboard.add(key: keyModeChangeNumbers, row: 3, page: 0)
    
    let keyboardChange = Key(.keyboardChange)
    greekKeyboard.add(key: keyboardChange, row: 3, page: 0)
    
    let settings = Key(.settings)
    greekKeyboard.add(key: settings, row: 3, page: 0)
    
    let space = Key(.space)
    space.uppercaseKeyCap = "space"
    space.uppercaseOutput = " "
    space.lowercaseOutput = " "
    greekKeyboard.add(key: space, row: 3, page: 0)
    
    let returnKey = Key(.return)
    returnKey.uppercaseKeyCap = "return"
    returnKey.uppercaseOutput = "\n"
    returnKey.lowercaseOutput = "\n"
    greekKeyboard.add(key: returnKey, row: 3, page: 0)
    
    for key in ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"] {
        let keyModel = Key(.specialCharacter)
        keyModel.setLetter(key)
        greekKeyboard.add(key: keyModel, row: 0, page: 1)
    }
    
    for key in ["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""] {
        let keyModel = Key(.specialCharacter)
        keyModel.setLetter(key)
        greekKeyboard.add(key: keyModel, row: 1, page: 1)
    }
    
    let keyModeChangeSpecialCharacters = Key(.modeChange)
    keyModeChangeSpecialCharacters.uppercaseKeyCap = "#+="
    keyModeChangeSpecialCharacters.toMode = 2
    greekKeyboard.add(key: keyModeChangeSpecialCharacters, row: 2, page: 1)
    
    for key in [".", ",", "?", "!", "'"] {
        let keyModel = Key(.specialCharacter)
        keyModel.setLetter(key)
        greekKeyboard.add(key: keyModel, row: 2, page: 1)
    }
    
    greekKeyboard.add(key: Key(backspace), row: 2, page: 1)
    
    let keyModeChangeLetters = Key(.modeChange)
    keyModeChangeLetters.uppercaseKeyCap = "ABC"
    keyModeChangeLetters.toMode = 0
    greekKeyboard.add(key: keyModeChangeLetters, row: 3, page: 1)
    
    greekKeyboard.add(key: Key(keyboardChange), row: 3, page: 1)
    
    greekKeyboard.add(key: Key(settings), row: 3, page: 1)
    
    greekKeyboard.add(key: Key(space), row: 3, page: 1)
    
    greekKeyboard.add(key: Key(returnKey), row: 3, page: 1)
    
    for key in ["[", "]", "{", "}", "#", "%", "^", "*", "+", "="] {
        let keyModel = Key(.specialCharacter)
        keyModel.setLetter(key)
        greekKeyboard.add(key: keyModel, row: 0, page: 2)
    }
    
    for key in ["_", "\\", "|", "~", "<", ">", "€", "£", "¥", "•"] {
        let keyModel = Key(.specialCharacter)
        keyModel.setLetter(key)
        greekKeyboard.add(key: keyModel, row: 1, page: 2)
    }
    
    greekKeyboard.add(key: Key(keyModeChangeNumbers), row: 2, page: 2)
    
    for key in [".", ",", "?", "!", "'"] {
        let keyModel = Key(.specialCharacter)
        keyModel.setLetter(key)
        greekKeyboard.add(key: keyModel, row: 2, page: 2)
    }
    
    greekKeyboard.add(key: Key(backspace), row: 2, page: 2)
    
    greekKeyboard.add(key: Key(keyModeChangeLetters), row: 3, page: 2)
    
    greekKeyboard.add(key: Key(keyboardChange), row: 3, page: 2)
    
    greekKeyboard.add(key: Key(settings), row: 3, page: 2)
    
    greekKeyboard.add(key: Key(space), row: 3, page: 2)
    
    greekKeyboard.add(key: Key(returnKey), row: 3, page: 2)
    
    return greekKeyboard
}
