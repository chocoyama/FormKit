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
    }

    @IBOutlet weak var selectContainerView: UIView!
    @IBOutlet weak var selectedCollectionView: UICollectionView! {
        didSet {
            SelectedImageCollectionViewCell.register(for: selectedCollectionView, bundle: .current)
        }
    }
    
    public weak var delegate: ImagePickerViewControllerDelegate?
    
    private let columnCount: Int
    private let repository = PhotoRepository()
    
    private let maxSelectCount: Int = 10
    private var selectedValues: [(indexPath: IndexPath, image: UIImage)] = []
    
    init(columnCount: Int) {
        self.columnCount = columnCount
        super.init(nibName: String(describing: ImagePickerViewController.self), bundle: .current)
        modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let pageVC = InfiniteLoopPageViewController(
            totalPage: Page.allCases.count,
            shouldInfiniteLoop: false,
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
        pageVC.pageableDataSource = self
        addChild(pageVC)
        pageVC.view.overlay(on: selectContainerView)
        pageVC.didMove(toParent: self)
    }

    @IBAction func didTappedDoneBarButtonItem(_ sender: UIBarButtonItem) {
        let images = selectedValues.map { $0.image }
        delegate?.imagePickerViewController(self, didSelectedImages: images)
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
    
    @IBAction func didTappedCancelBarButtonItem(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
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

