//
//  InfiniteLoopPageViewController.swift
//  UICatalog
//
//  Created by Takuya Yokoyama on 2018/10/14.
//  Copyright © 2018 Takuya Yokoyama. All rights reserved.
//

import UIKit

class InfiniteLoopPageViewController: UIPageViewController {
    weak var pageableDataSource: PageableViewControllerDataSource?
    private(set) var pages: [Page]
    
    let shouldInfiniteLoop: Bool
    let pageCache = PageCache()
    
    init(totalPage: Int,
         shouldInfiniteLoop: Bool,
         transitionStyle: UIPageViewController.TransitionStyle,
         navigationOrientation: UIPageViewController.NavigationOrientation,
         options: [UIPageViewController.OptionsKey : Any]?) {
        self.pages = (0..<totalPage).map { _ in Page() }
        self.pages.enumerated().forEach { $0.element.number = $0.offset }
        
        self.shouldInfiniteLoop = shouldInfiniteLoop
        
        super.init(transitionStyle: transitionStyle,
                   navigationOrientation: navigationOrientation,
                   options: options)
        dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp(at: 0)
    }
    
    func update(to pages: [Page], at page: Int = 0) {
        self.pages = pages
        setUp(at: page)
    }
    
    func setUp(at page: Int, direction: UIPageViewController.NavigationDirection = .forward) {
        let index = pages.indices ~= page ? page : 0
        if let controller = getViewController(at: index) {
            setViewControllers([controller], direction: direction, animated: false, completion: nil)
        }
    }
}

extension InfiniteLoopPageViewController {
    func getIndex(at viewController: UIViewController) -> Int? {
        guard let currentVC = viewController as? Pageable else { return nil }
        return pages.index { $0.number == currentVC.pageNumber }
    }
    
    func getViewController(at index: Int) -> UIViewController? {
        switch index {
        case -1 where shouldInfiniteLoop:
            if let lastIndex = pages.indices.last {
                return pageableDataSource?.viewController(at: lastIndex, cache: pageCache)
            } else {
                return nil
            }
        case -1:
            return nil
        case 0...(pages.count - 1):
            return pageableDataSource?.viewController(at: index, cache: pageCache)
        default:
            return shouldInfiniteLoop ? pageableDataSource?.viewController(at: 0, cache: pageCache) : nil
        }
    }
}

extension InfiniteLoopPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let currentIndex = getIndex(at: viewController) {
            return getViewController(at: pages.index(before: currentIndex))
        } else {
            return nil
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let currentIndex = getIndex(at: viewController) {
            return getViewController(at: pages.index(after: currentIndex))
        } else {
            return nil
        }
    }
}
