//
//  ImagePickerViewController.swift
//  FormKit
//
//  Created by Takuya Yokoyama on 2019/03/11.
//  Copyright © 2019 chocoyama. All rights reserved.
//

import UIKit
import Photos

public protocol ImagePickerViewControllerDelegate: class {
    func imagePickerViewController(_ imagePickerViewController: ImagePickerViewController, didSelectedImages images: [UIImage])
}

public class ImagePickerViewController: UIViewController {
    
    enum Page: Int, CaseIterable {
        case album
        case camera
        
        var title: String {
            switch self {
            case .album: return "アルバム"
            case .camera: return "カメラ"
            }
        }
    }
    
    @IBOutlet weak var mainContainerView: UIView!
    @IBOutlet weak var subContainerView: UIView!
    @IBOutlet weak var selectedCollectionView: UICollectionView! {
        didSet {
            SelectedImageCollectionViewCell.register(for: selectedCollectionView, bundle: .current)
        }
    }
    @IBOutlet weak var menuStackView: UIStackView! {
        didSet {
            setUpMenuStackView()
        }
    }
    @IBOutlet weak var selectedIndicatorViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectedIndicatorViewLeftConstraint: NSLayoutConstraint!
    
    public weak var delegate: ImagePickerViewControllerDelegate?
    private let columnCount: Int
    private let maxSelectCount: Int
    
    private let mainPageVC: InfiniteLoopPageViewController
    private let subPageVC: InfiniteLoopPageViewController
    private let repository = PhotoRepository()
    
    private var selectedValues: [(indexPath: IndexPath, image: UIImage)] = []
    
    private var menuItemWidth: CGFloat {
        return menuStackView.frame.width / CGFloat(Page.allCases.count)
    }
    
    init(columnCount: Int, maxSelectCount: Int) {
        self.columnCount = columnCount
        self.maxSelectCount = maxSelectCount
        
        mainPageVC = InfiniteLoopPageViewController(
            totalPage: Page.allCases.count,
            shouldInfiniteLoop: false,
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
        
        subPageVC = InfiniteLoopPageViewController(
            totalPage: Page.allCases.count,
            shouldInfiniteLoop: false,
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
        
        super.init(nibName: String(describing: ImagePickerViewController.self), bundle: .current)
        modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setUpPageViewController()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpSelectedIndicatorView()
    }
    
    private func setUpPageViewController() {
        mainPageVC.pageableDataSource = self
        mainPageVC.loopPageDelegate = self
        addChild(mainPageVC)
        mainPageVC.view.overlay(on: mainContainerView)
        mainPageVC.didMove(toParent: self)
        
        subPageVC.pageableDataSource = self
        subPageVC.loopPageDelegate = self
        addChild(subPageVC)
        subPageVC.view.overlay(on: subContainerView)
        subPageVC.didMove(toParent: self)
    }
    
    private func setUpMenuStackView() {
        Page.allCases
            .map {
                let button = UIButton(type: .custom)
                button.setTitle($0.title, for: .normal)
                button.setTitleColor(.black, for: .normal)
                button.backgroundColor = .clear
                button.tag = $0.rawValue
                button.addTarget(self, action: #selector(self.didTappedMenuButton(sender:)), for: .touchUpInside)
                return button
            }
            .forEach {
                menuStackView.addArrangedSubview($0)
            }
    }
    
    private func setUpSelectedIndicatorView() {
        selectedIndicatorViewWidthConstraint.constant = menuItemWidth
    }
    
    private func moveMainPageView(to index: Int) {
        mainPageVC.moveTo(page: index, animated: true)
    }
    
    private func moveSubPageView(to index: Int) {
        subPageVC.moveTo(page: index, animated: true)
    }
    
    private func moveSelectedIndicator(to index: Int) {
        selectedIndicatorViewLeftConstraint.constant = menuItemWidth * CGFloat(index)
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK:- User Action
extension ImagePickerViewController {
    @objc func didTappedMenuButton(sender: UIButton) {
        moveMainPageView(to: sender.tag)
        moveSubPageView(to: sender.tag)
        moveSelectedIndicator(to: sender.tag)
    }
    
    @IBAction func didTappedDoneBarButtonItem(_ sender: UIBarButtonItem) {
        let images = selectedValues.map { $0.image }
        delegate?.imagePickerViewController(self, didSelectedImages: images)
    }
    
    @IBAction func didTappedCancelBarButtonItem(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didRecognizedLongPressGesture(_ sender: UILongPressGestureRecognizer) {
        let pressedPoint = sender.location(in: selectedCollectionView)
        
        switch sender.state {
        case .possible:
            break
        case .began:
            if let indexPath = selectedCollectionView.indexPathForItem(at: pressedPoint) {
                selectedCollectionView.beginInteractiveMovementForItem(at: indexPath)
            }
        case .changed:
            selectedCollectionView.updateInteractiveMovementTargetPosition(pressedPoint)
        case .ended, .cancelled:
            selectedCollectionView.endInteractiveMovement()
        case .failed:
            break
        }
    }
}

// MARK:- UICollectionView

extension ImagePickerViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return maxSelectCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item <= selectedValues.count - 1 {
            let selectedValue = selectedValues[indexPath.item]
            return SelectedImageCollectionViewCell
                .dequeue(from: collectionView, indexPath: indexPath)
                .configure(with: selectedValue.image)
        } else {
            return SelectedImageCollectionViewCell
                .dequeue(from: collectionView, indexPath: indexPath)
                .configureEmpty()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard destinationIndexPath.item < selectedValues.count else {
            collectionView.performBatchUpdates({
                collectionView.reloadSections(IndexSet(integer: 0))
            }, completion: { (finished) in
            })
            return
        }
        let removedItem = selectedValues.remove(at: sourceIndexPath.item)
        selectedValues.insert(removedItem, at: destinationIndexPath.item)
    }
    
    public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return indexPath.item < selectedValues.count
    }
}

extension ImagePickerViewController: UICollectionViewDelegate {
}

extension ImagePickerViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
}

// MARK: InfiniteLoopPageViewController

extension ImagePickerViewController: PageableViewControllerDataSource {
    func viewController(at index: Int, for pageViewController: UIPageViewController, cache: PageCache) -> (UIViewController & Pageable)? {
        if pageViewController == mainPageVC {
            return mainViewController(at: index, for: pageViewController, cache: cache)
        } else {
            return subViewController(at: index, for: pageViewController, cache: cache)
        }
    }
    
    private func mainViewController(at index: Int, for pageViewController: UIPageViewController, cache: PageCache) -> (UIViewController & Pageable)? {
        if let cachedVC = cache.get(from: "\(index)") { return cachedVC }
        
        let page = Page.allCases[index]
        let pageableVC: (UIViewController & Pageable)
        switch page {
        case .album:
            let vc = AlbumViewController(columnCount: columnCount,
                                         maxSelectCount: maxSelectCount)
            vc.delegate = self
            vc.pageNumber = page.rawValue
            pageableVC = vc
        case .camera:
            let vc = CameraViewController()
            vc.pageNumber = page.rawValue
            pageableVC = vc
        }
        
        cache.save(pageableVC, with: "\(index)")
        return pageableVC
    }
    
    private func subViewController(at index: Int, for pageViewController: UIPageViewController, cache: PageCache) -> (UIViewController & Pageable)? {
        if let cachedVC = cache.get(from: "\(index)") { return cachedVC }
        
        let page = Page.allCases[index]
        let pageableVC: (UIViewController & Pageable)
        switch page {
        case .album:
            let vc = EmptyViewController()
            vc.pageNumber = page.rawValue
            pageableVC = vc
        case .camera:
            let vc = CameraActionViewController()
            vc.delegate = self as! CameraActionViewControllerDelegate
            vc.pageNumber = page.rawValue
            pageableVC = vc
        }
        
        cache.save(pageableVC, with: "\(index)")
        return pageableVC
    }
}

extension ImagePickerViewController: InfiniteLoopPageViewControllerDelegate {
    func infiniteLoopPageViewController(_ infiniteLoopPageViewController: InfiniteLoopPageViewController, didChangePageAt index: Int) {
        if infiniteLoopPageViewController == mainPageVC {
            mainInfiniteLoopPageViewController(infiniteLoopPageViewController, didChangePageAt: index)
        } else {
            subInfiniteLoopPageViewController(infiniteLoopPageViewController, didChangePageAt: index)
        }
    }
    
    private func mainInfiniteLoopPageViewController(_ infiniteLoopPageViewController: InfiniteLoopPageViewController, didChangePageAt index: Int) {
        moveSubPageView(to: index)
        moveSelectedIndicator(to: index)
    }
    
    private func subInfiniteLoopPageViewController(_ infiniteLoopPageViewController: InfiniteLoopPageViewController, didChangePageAt index: Int) {
        moveMainPageView(to: index)
        moveSelectedIndicator(to: index)
    }
}

// MARK: AlbumViewController

extension ImagePickerViewController: AlbumViewControllerDelegate {
    func albumViewController(_ albumViewController: AlbumViewController, didInsertedItemAt indexPath: IndexPath, selectedValues: [(indexPath: IndexPath, image: UIImage)]) {
        self.selectedValues = selectedValues
        
        let cell = getCell(at: indexPath)
        UIView.transition(
            with: cell.imageView,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: {
                let image = selectedValues[indexPath.item].image
                cell.configure(with: image)
            },
            completion: { (finished) in
                self.selectedCollectionView.selectItem(at: indexPath,
                                                       animated: true,
                                                       scrollPosition: .centeredHorizontally)
            }
        )
    }
    
    func albumViewController(_ albumViewController: AlbumViewController, didRemovedItemAt indexPath: IndexPath, selectedValues: [(indexPath: IndexPath, image: UIImage)]) {
        self.selectedValues = selectedValues
        
        let cell = getCell(at: indexPath)
        UIView.transition(
            with: cell.imageView,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: {
                cell.configureEmpty()
            },
            completion: { (finished) in
                self.selectedCollectionView.performBatchUpdates({
                    let reloadRange = (indexPath.item..<(self.selectedValues.count + 1))
                    let reloadIndexPaths = reloadRange.map { IndexPath(item: $0, section: 0) }
                    self.selectedCollectionView.reloadItems(at: reloadIndexPaths)
                }, completion: { (finished) in
                    self.selectedCollectionView.selectItem(at: indexPath,
                                                           animated: true,
                                                           scrollPosition: .right)
                })
            }
        )
    }
    
    private func getCell(at indexPath: IndexPath) -> SelectedImageCollectionViewCell {
        if let visibleCell = selectedCollectionView.cellForItem(at: indexPath) as? SelectedImageCollectionViewCell {
            return visibleCell
        } else {
            let dequeueCell = SelectedImageCollectionViewCell
                .dequeue(from: selectedCollectionView, indexPath: indexPath)
            return dequeueCell
        }
    }
    
}

extension ImagePickerViewController: CameraActionViewControllerDelegate {
    public func cameraActionViewController(_ cameraActionViewController: CameraActionViewController, didTappedCameraView tapGesture: UITapGestureRecognizer) {
        print("Fire!!")
    }
}
