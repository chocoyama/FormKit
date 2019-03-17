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
    
    @IBOutlet weak var selectContainerView: UIView!
    @IBOutlet weak var selectedCollectionView: UICollectionView! {
        didSet {
            SelectedImageCollectionViewCell.register(for: selectedCollectionView, bundle: .current)
        }
    }
    @IBOutlet weak var menuStackView: UIStackView! {
        didSet {
            Page.allCases
                .map {
                    let button = UIButton(type: .custom)
                    button.setTitle($0.title, for: .normal)
                    button.setTitleColor(.black, for: .normal)
                    button.tag = $0.rawValue
                    button.addTarget(self, action: #selector(self.didTappedMenuButton(sender:)), for: .touchUpInside)
                    return button
                }
                .forEach {
                    menuStackView.addArrangedSubview($0)
                }
        }
    }
    @IBOutlet weak var selectedIndicatorViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectedIndicatorViewLeftConstraint: NSLayoutConstraint!
    private var menuItemWidth: CGFloat {
        return menuStackView.frame.width / CGFloat(Page.allCases.count)
    }
    
    public weak var delegate: ImagePickerViewControllerDelegate?
    
    private let pageVC: InfiniteLoopPageViewController
    
    private let columnCount: Int
    private let repository = PhotoRepository()
    
    private let maxSelectCount: Int = 10
    private var selectedValues: [(indexPath: IndexPath, image: UIImage)] = []
    
    init(columnCount: Int) {
        self.columnCount = columnCount
        pageVC = InfiniteLoopPageViewController(
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
        pageVC.pageableDataSource = self
        pageVC.loopPageDelegate = self
        addChild(pageVC)
        pageVC.view.overlay(on: selectContainerView)
        pageVC.didMove(toParent: self)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        selectedIndicatorViewWidthConstraint.constant = menuItemWidth
    }
    
    @objc func didTappedMenuButton(sender: UIButton) {
        pageVC.moveTo(page: sender.tag, animated: true)
        moveSelectedIndicator(to: sender.tag)
    }
    
    private func moveSelectedIndicator(to index: Int) {
        selectedIndicatorViewLeftConstraint.constant = menuItemWidth * CGFloat(index)
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
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

extension ImagePickerViewController: InfiniteLoopPageViewControllerDelegate {
    func infiniteLoopPageViewController(_ infiniteLoopPageViewController: InfiniteLoopPageViewController, didChangePageAt index: Int) {
        moveSelectedIndicator(to: index)
    }
}

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

extension ImagePickerViewController: PageableViewControllerDataSource {
    func viewController(at index: Int, cache: PageCache) -> (UIViewController & Pageable)? {
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
}

