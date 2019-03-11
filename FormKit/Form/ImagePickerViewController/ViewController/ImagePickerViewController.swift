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

    @IBOutlet weak var selectCollectionView: UICollectionView! {
        didSet {
            SelectImageCollectionViewCell.register(for: selectCollectionView, bundle: .current)
            selectCollectionView.dataSource = selectCollectionViewDataSource
        }
    }
    @IBOutlet weak var selectedCollectionView: UICollectionView! {
        didSet {
            SelectedImageCollectionViewCell.register(for: selectedCollectionView, bundle: .current)
            selectedCollectionView.dataSource = selectedCollectionViewDataSource
        }
    }
    
    private let columnCount: Int
    
    private let repository = PhotoRepository()
    private let selectCollectionViewDataSource = SelectCollectionViewDataSource()
    private let selectedCollectionViewDataSource = SelectedCollectionViewDataSource()
    
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
        selectCollectionViewDataSource.allAssets = repository.fetchAllPhotos()
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

extension ImagePickerViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView == selectCollectionView,
            let cell = selectCollectionView.cellForItem(at: indexPath) as? SelectImageCollectionViewCell,
            let image = cell.imageView.image else { return }
        
        if selectedCollectionViewDataSource.selectedValues.count >= selectedCollectionViewDataSource.maxSelectCount && !cell.isSelectedState {
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
        let insertIndex = selectedCollectionViewDataSource.selectedValues.count
        selectedCollectionViewDataSource.selectedValues.insert((selectCollectionViewIndexPath: selectCollectionViewIndexPath, image: image), at: insertIndex)
        
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
        let removeIndexPaths = selectedCollectionViewDataSource.selectedValues
            .enumerated()
            .filter { $0.element.selectCollectionViewIndexPath == selectCollectionViewIndexPath }
            .map { IndexPath(item: $0.offset, section: 0) }
        
        guard let removeIndexPath = removeIndexPaths.first else { return nil }
        
        selectedCollectionViewDataSource.selectedValues.removeAll { $0.selectCollectionViewIndexPath == selectCollectionViewIndexPath }

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
                    let reloadRange = (removeIndexPath.item..<(self.selectedCollectionViewDataSource.selectedValues.count + 1))
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

extension ImagePickerViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == selectCollectionView {
            let screenWidth = UIScreen.main.bounds.width
            let columnCount = CGFloat(self.columnCount)
            
            var totalMargin: CGFloat = 0.0
            if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
                totalMargin += flowLayout.minimumInteritemSpacing * (columnCount - 1)
                totalMargin += flowLayout.sectionInset.left + flowLayout.sectionInset.right
            }
            
            let itemWidth = (screenWidth - totalMargin) / columnCount
            return CGSize(width: itemWidth, height: itemWidth)
        } else {
            return CGSize(width: 80, height: 80)
        }
    }
}

// MARK:- SelectCollectionViewDataSource

class SelectCollectionViewDataSource: NSObject {
    var allAssets: PHFetchResult<PHAsset>?
}

extension SelectCollectionViewDataSource: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allAssets?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let asset = allAssets?.object(at: indexPath.item) else { fatalError() }
        return SelectImageCollectionViewCell
            .dequeue(from: collectionView, indexPath: indexPath)
            .configure(with: asset)
    }
}

// MARK:- SelectedCollectionViewDataSource

class SelectedCollectionViewDataSource: NSObject {
    var maxSelectCount: Int = 10
    var selectedValues: [(selectCollectionViewIndexPath: IndexPath, image: UIImage)] = []
}

extension SelectedCollectionViewDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return maxSelectCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
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
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return indexPath.item < selectedValues.count
    }
}
