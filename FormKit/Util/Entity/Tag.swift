//
//  Tag.swift
//  FormKit
//
//  Created by Takuya Yokoyama on 2019/03/07.
//  Copyright © 2019 chocoyama. All rights reserved.
//

import Foundation
import UIKit

public protocol Tag {
    var value: Int { get }
}

public extension UIView {
    public func setTag(_ tag: Tag) {
        self.tag = tag.value
    }
}
