//
//  XibInitializable.swift
//  FormKit
//
//  Created by Takuya Yokoyama on 2019/02/25.
//  Copyright © 2019 chocoyama. All rights reserved.
//

import Foundation
import UIKit

/**
 1. 以下のイニシャライザを実装
 ```
 required init?(coder aDecoder: NSCoder) {
 super.init(coder: aDecoder)
 setXibView()
 }
 
 override init(frame: CGRect) {
 super.init(frame: frame)
 setXibView()
 }
 ```
 
 2. コードで生成する場合は、以下の呼び出しを行う。
 ```
 let view = SomeInitializableView.create()
 ```
 */
public protocol XibInitializable: class {}
extension XibInitializable where Self: UIView {
    func setXibView() {
        let nib = UINib(nibName: String(describing: Self.self), bundle: Bundle(for: type(of: self)))
        let xibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        xibView.backgroundColor = .clear
        self.insertSubview(xibView, at: 0)
        xibView.overlay(on: self)
    }
    
    init() {
        self.init(frame: .zero)
    }
    
}

private extension UIView {
    func overlay(on view: UIView) {
        view.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        self.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        self.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}
