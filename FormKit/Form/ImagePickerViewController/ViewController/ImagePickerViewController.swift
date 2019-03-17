//
//  ImagePickerViewController.swift
//  FormKit
//
//  Created by Takuya Yokoyama on 2019/03/11.
//  Copyright © 2019 chocoyama. All rights reserved.
//

import UIKit
import Photos

public class ImagePickerViewController: UIViewController {

    @IBOutlet weak var selectContainerView: UIView!
    @IBOutlet weak var selectedCollectionView: UICollectionView! {
        didSet {
            SelectedImageCollectionViewCell.register(for: selectedCollectionView, bundle: .current)
        }
    }
    
    private let columnCount: Int
    private let repository = PhotoRepository()
    
    private let maxSelectCount: Int = 10
    private var selectedValues: [(selectCollectionViewIndexPath: IndexPath, image: UIImage)] = []
    
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
        
        let albumViewController = AlbumViewController(columnCount: columnCount)
        albumViewController.delegate = self
        addChild(albumViewController)
        albumViewController.view.overlay(on: selectContainerView)
        albumViewController.didMove(toParent: self)
    }

    @IBAction func didTappedDoneBarButtonItem(_ sender: UIBarButtonItem) {
//        let images = selectedValues.map { $0.image }
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
    func albumViewController(_ albumViewController: AlbumViewController,
                             didSelectedItemAt indexPath: IndexPath,
                             cell: SelectImageCollectionViewCell,
                             image: UIImage) {
        if selectedValues.count >= maxSelectCount && !cell.isSelectedState {
            return
        }
        
        let isSelected = cell.toggleState()
        if isSelected {
            let insertedIndexPath = append(image: image, at: indexPath)
            
            selectedCollectionView.selectItem(at: insertedIndexPath,
                                              animated: true,
                                              scrollPosition: .centeredHorizontally)
        } else {
            let removedIndexPath = remove(image: image, at: indexPath)
            
            if let indexPath = removedIndexPath {
                selectedCollectionView.selectItem(at: indexPath,
                                                  animated: true,
                                                  scrollPosition: .right)
            }
        }
    }
    
    private func append(image: UIImage, at selectCollectionViewIndexPath: IndexPath) -> IndexPath? {
        let insertIndex = selectedValues.count
        selectedValues.insert((selectCollectionViewIndexPath: selectCollectionViewIndexPath, image: image), at: insertIndex)
        
        let insertIndexPath = IndexPath(item: insertIndex, section: 0)
        
        let cell = getCell(at: insertIndexPath)
        UIView.transition(
            with: cell.imageView,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: {
                cell.configure(with: image)
        },
            completion: { (finished) in
        }
        )
        
        return insertIndexPath
    }
    
    private func remove(image: UIImage, at selectCollectionViewIndexPath: IndexPath) -> IndexPath? {
        let removeIndexPaths = selectedValues
            .enumerated()
            .filter { $0.element.selectCollectionViewIndexPath == selectCollectionViewIndexPath }
            .map { IndexPath(item: $0.offset, section: 0) }
        
        guard let removeIndexPath = removeIndexPaths.first else { return nil }
        
        selectedValues.removeAll { $0.selectCollectionViewIndexPath == selectCollectionViewIndexPath }
        
        let cell = getCell(at: removeIndexPath)
        UIView.transition(
            with: cell.imageView,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: {
                cell.configureEmpty()
        },
            completion: { (finished) in
                self.selectedCollectionView.performBatchUpdates({
                    let reloadRange = (removeIndexPath.item..<(self.selectedValues.count + 1))
                    let reloadIndexPaths = reloadRange.map { IndexPath(item: $0, section: 0) }
                    self.selectedCollectionView.reloadItems(at: reloadIndexPaths)
                }, completion: { (finished) in
                })
        }
        )
        
        return removeIndexPath
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

