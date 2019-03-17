//
//  PageViewControllerCache.swift
//  UICatalog
//
//  Created by Takuya Yokoyama on 2018/11/10.
//  Copyright © 2018 Takuya Yokoyama. All rights reserved.
//

import UIKit

class PageCache {
    private var viewControllers: [String: (UIViewController & Pageable)] = [:]
    
    init() {}
    
    func save(_ viewController: (UIViewController & Pageable), with id: String) {
        viewControllers[id] = viewController
    }
    
    func get(from id: String) -> (UIViewController & Pageable)? {
        if viewControllers.keys.contains(id) {
            return viewControllers[id]
        } else {
            return nil
        }
    }
    
    func clear() {
        viewControllers = [:]
    }
}

