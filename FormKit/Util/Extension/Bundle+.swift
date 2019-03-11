//
//  Bundle+.swift
//  FormKit
//
//  Created by Takuya Yokoyama on 2019/03/08.
//  Copyright © 2019 chocoyama. All rights reserved.
//

import Foundation

extension Bundle {
    static var current: Bundle {
        class DummyClass {}
        return Bundle(for: type(of: DummyClass()))
    }
}
