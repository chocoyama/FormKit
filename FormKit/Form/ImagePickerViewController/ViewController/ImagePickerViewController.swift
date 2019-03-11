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
        }
    }
    @IBOutlet weak var selectedCollectionView: UICollectionView! {
        didSet {
            SelectedImageCollectionViewCell.register(for: selectedCollectionView, bundle: .current)
        }
    }
    
    private let columnCount: Int
    
    private let repository = PhotoRepository()
    private var allAssets: PHFetchResult<PHAsset>?
    private var selectedValues: [(selectCollectionViewIndexPath: IndexPath, image: UIImage)] = []
    
    init(columnCount: Int) {
        self.columnCount = columnCount
        super.init(nibName: String(describing: ImagePickerViewController.self), bundle: .current)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        allAssets = repository.fetchAllPhotos()
    }

    @IBAction func didTappedDoneBarButtonItem(_ sender: UIBarButtonItem) {
//        let images = selectedValues.map { $0.image }
    }
    
    @IBAction func didTappedCancelBarButtonItem(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

extension ImagePickerViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == selectCollectionView {
            return selectCollectionView(collectionView, numberOfItemsInSection: section)
        } else {
            return selectedCollectionView(collectionView, numberOfItemsInSection: section)
        }
    }
    
    private func selectCollectionView(_ selectCollectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allAssets?.count ?? 0
    }
    
    private func selectedCollectionView(_ selectedCollectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedValues.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == selectCollectionView {
            return selectCollectionView(collectionView, cellForItemAt: indexPath)
        } else {
            return selectedCollectionView(collectionView, cellForItemAt: indexPath)
        }
    }
    
    private func selectCollectionView(_ selectCollectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let asset = allAssets?.object(at: indexPath.item) else { fatalError() }
        return SelectImageCollectionViewCell
            .dequeue(from: selectCollectionView, indexPath: indexPath)
            .configure(with: asset)
    }
    
    private func selectedCollectionView(_ selectedCollectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let selectedValue = selectedValues[indexPath.item]
        return SelectedImageCollectionViewCell
            .dequeue(from: selectedCollectionView, indexPath: indexPath)
            .configure(with: selectedValue.image)
    }
}

extension ImagePickerViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == selectCollectionView {
            selectCollectionView(collectionView, didSelectItemAt: indexPath)
        } else {
            selectedCollectionView(collectionView, didSelectItemAt: indexPath)
        }
    }
    
    private func selectCollectionView(_ selectCollectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = selectCollectionView.cellForItem(at: indexPath) as? SelectImageCollectionViewCell,
            let image = cell.imageView.image else { return }
        
        let isSelected = cell.toggleState()
        if isSelected {
            append(image: image, at: indexPath)
            scrollToTail()
        } else {
            removeImage(at: indexPath)
        }
    }
    
    private func selectedCollectionView(_ selectedCollectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    private func append(image: UIImage, at selectCollectionViewIndexPath: IndexPath) {
        let insertIndex = selectedValues.count
        selectedValues.insert((selectCollectionViewIndexPath: selectCollectionViewIndexPath, image: image), at: insertIndex)
        selectedCollectionView.insertItems(at: [IndexPath(item: insertIndex, section: 0)])
    }
    
    private func removeImage(at selectCollectionViewIndexPath: IndexPath) {
        let removeIndices = selectedValues
            .enumerated()
            .filter { $0.element.selectCollectionViewIndexPath == selectCollectionViewIndexPath }
            .map { IndexPath(item: $0.offset, section: 0) }
        selectedValues.removeAll { $0.selectCollectionViewIndexPath == selectCollectionViewIndexPath }
        selectedCollectionView.deleteItems(at: removeIndices)
    }
    
    private func scrollToTail() {
        selectedCollectionView.scrollToRight(animated: true)
    }
}

extension ImagePickerViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == selectCollectionView {
            return selectCollectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
        } else {
            return selectedCollectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
        }
    }
    
    private func selectCollectionView(_ selectCollectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let columnCount = CGFloat(self.columnCount)
        
        var totalMargin: CGFloat = 0.0
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            totalMargin += flowLayout.minimumInteritemSpacing * (columnCount - 1)
            totalMargin += flowLayout.sectionInset.left + flowLayout.sectionInset.right
        }
        
        let itemWidth = (screenWidth - totalMargin) / columnCount
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    private func selectedCollectionView(_ selectedCollectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
}

//class SelectedCollectionViewDataSource: NSObject {
//    
//}
//
//extension SelectedCollectionViewDataSource: UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        
//    }
//}
