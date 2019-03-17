//
//  Pageable.swift
//  UICatalog
//
//  Created by Takuya Yokoyama on 2018/10/14.
//  Copyright © 2018 Takuya Yokoyama. All rights reserved.
//

import Foundation

protocol Pageable: class {
    var pageNumber: Int { get set } // zero origin
}

protocol PageableViewControllerDataSource: class {
    func viewController(at index: Int, for pageViewController: UIPageViewController, cache: PageCache) -> (UIViewController & Pageable)?
}
