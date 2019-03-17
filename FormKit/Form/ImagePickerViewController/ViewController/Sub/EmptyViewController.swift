//
//  EmptyViewController.swift
//  FormKit
//
//  Created by Takuya Yokoyama on 2019/03/17.
//  Copyright © 2019 chocoyama. All rights reserved.
//

import UIKit

class EmptyViewController: UIViewController, Pageable {

    var pageNumber: Int = 0
    
    init() {
        super.init(nibName: String(describing: EmptyViewController.self), bundle: .current)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
