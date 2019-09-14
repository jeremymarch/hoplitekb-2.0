//
//  kludge.swift
//  HCPolytonicGreekKBapp2
//
//  Created by Jeremy on 9/12/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

class KludgeView: UIInputView {
//https://stackoverflow.com/questions/42723179/ios-puts-a-required-height-constraint-on-custom-keyboard
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
    }
    
    
    override init(frame: CGRect, inputViewStyle: UIInputView.Style) {
        super.init(frame: frame, inputViewStyle: inputViewStyle)
        //self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
}
}
