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
    
    @IBAction func didTappedCancelBarButtonItem(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

extension ImagePickerViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView == selectCollectionView,
            let cell = selectCollectionView.cellForItem(at: indexPath) as? SelectImageCollectionViewCell,
            let image = cell.imageView.image else { return }
        
        let isSelected = cell.toggleState()
        if isSelected {
            append(image: image, at: indexPath)
            selectedCollectionView.scrollToRight(animated: true)
        } else {
            remove(image: image, at: indexPath)
        }
    }
    
    private func append(image: UIImage, at selectCollectionViewIndexPath: IndexPath) {
        let insertIndex = selectedCollectionViewDataSource.selectedValues.count
        selectedCollectionViewDataSource.selectedValues.insert((selectCollectionViewIndexPath: selectCollectionViewIndexPath, image: image), at: insertIndex)
        selectedCollectionView.insertItems(at: [IndexPath(item: insertIndex, section: 0)])
    }
    
    private func remove(image: UIImage, at selectCollectionViewIndexPath: IndexPath) {
        let removeIndices = selectedCollectionViewDataSource.selectedValues
            .enumerated()
            .filter { $0.element.selectCollectionViewIndexPath == selectCollectionViewIndexPath }
            .map { IndexPath(item: $0.offset, section: 0) }
        selectedCollectionViewDataSource.selectedValues.removeAll { $0.selectCollectionViewIndexPath == selectCollectionViewIndexPath }
        selectedCollectionView.deleteItems(at: removeIndices)
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
    var selectedValues: [(selectCollectionViewIndexPath: IndexPath, image: UIImage)] = []
}

extension SelectedCollectionViewDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedValues.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let selectedValue = selectedValues[indexPath.item]
        return SelectedImageCollectionViewCell
            .dequeue(from: collectionView, indexPath: indexPath)
            .configure(with: selectedValue.image)
    }
}
