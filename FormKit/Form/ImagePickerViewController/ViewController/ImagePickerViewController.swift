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
        didSet { SelectedImageCollectionViewCell.register(for: selectedCollectionView, bundle: .current) }
    }
    @IBOutlet weak var menuStackView: UIStackView! {
        didSet { setUpMenuStackView() }
    }
    @IBOutlet weak var previewImageView: UIImageView! {
        didSet { updatePreviewImageView(isHidden: true, animated: false) }
    }
    @IBOutlet weak var selectedIndicatorViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectedIndicatorViewLeftConstraint: NSLayoutConstraint!
    
    public weak var delegate: ImagePickerViewControllerDelegate?
    private let columnCount: Int
    private let maxSelectCount: Int
    private let repository = PhotoRepository()
    
    private let mainPageVC: InfiniteLoopPageViewController
    private let subPageVC: InfiniteLoopPageViewController
    private let albumVC: AlbumViewController
    private let cameraVC = CameraViewController()
    private let emptyVC = EmptyViewController()
    private let cameraActionVC = CameraActionViewController()
    
    private var pickedImages = [UIImage]()
    private var timer: Timer?
    private var canDelete = false {
        didSet {
            timer?.invalidate()
            timer = nil
            selectedCollectionView.reloadData()
        }
    }
    
    private var menuItemWidth: CGFloat {
        return menuStackView.frame.width / CGFloat(Page.allCases.count)
    }
    
    init(columnCount: Int, maxSelectCount: Int, pickedImages: [UIImage]) {
        self.columnCount = columnCount
        self.maxSelectCount = maxSelectCount
        self.pickedImages = pickedImages
        
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
        
        albumVC = AlbumViewController(columnCount: columnCount,
                                      maxSelectCount: maxSelectCount,
                                      pickedImages: pickedImages)
        
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
        delegate?.imagePickerViewController(self, didSelectedImages: pickedImages)
        dismiss(animated: true, completion: nil)
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
                canDelete = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.selectedCollectionView.beginInteractiveMovementForItem(at: indexPath)
                }
            }
        case .changed:
            selectedCollectionView.updateInteractiveMovementTargetPosition(pressedPoint)
        case .ended, .cancelled:
            selectedCollectionView.endInteractiveMovement()
            if canDelete {
                timer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { [weak self] (timer) in
                    self?.canDelete = false
                }
            }
        case .failed:
            break
        @unknown default:
            fatalError()
        }
    }
}

// MARK:- UICollectionView

extension ImagePickerViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return maxSelectCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item <= pickedImages.count - 1 {
            let image = pickedImages[indexPath.item]
            return SelectedImageCollectionViewCell
                .dequeue(from: collectionView, indexPath: indexPath)
                .configure(with: image, canDelete: canDelete, delegate: self)
        } else {
            return SelectedImageCollectionViewCell
                .dequeue(from: collectionView, indexPath: indexPath)
                .configureEmpty()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard destinationIndexPath.item < pickedImages.count else {
            collectionView.performBatchUpdates({
                collectionView.reloadSections(IndexSet(integer: 0))
            }, completion: { (finished) in
            })
            return
        }
        let removedItem = pickedImages.remove(at: sourceIndexPath.item)
        pickedImages.insert(removedItem, at: destinationIndexPath.item)
    }
    
    public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return indexPath.item < pickedImages.count
    }
}

extension ImagePickerViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let tappedSelectedItem = collectionView.indexPathsForSelectedItems?.contains(indexPath) == true
        if tappedSelectedItem {
            collectionView.deselectItem(at: indexPath, animated: true)
            updatePreviewImageView(isHidden: true, animated: true)
            return false
        }
        return true
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        previewImageView.image = pickedImages[indexPath.item]
        updatePreviewImageView(isHidden: false, animated: true)
    }
    
    private func updatePreviewImageView(isHidden: Bool, animated: Bool) {
        let duration = animated ? 0.3 : 0.0
        let alpha: CGFloat = isHidden ? 0.0 : 1.0
        UIView.animate(withDuration: duration) {
            self.previewImageView.alpha = alpha
        }
    }
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
            albumVC.delegate = self
            albumVC.pageNumber = page.rawValue
            pageableVC = albumVC
        case .camera:
            cameraVC.delegate = self
            cameraVC.pageNumber = page.rawValue
            pageableVC = cameraVC
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
            emptyVC.pageNumber = page.rawValue
            pageableVC = emptyVC
        case .camera:
            cameraActionVC.delegate = self
            cameraActionVC.pageNumber = page.rawValue
            pageableVC = cameraActionVC
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

extension ImagePickerViewController: SelectedImageCollectionViewCellDelegate {
    func selectedImageCollectionViewCell(_ cell: SelectedImageCollectionViewCell,
                                         didTappedDeleteButton button: UIButton,
                                         with image: UIImage?) {
        guard let image = image,
            let pickedImage = pickedImages.first(where: { $0 == image }) else { return }
        albumVC.remove(pickedImage: pickedImage)
    }
}

// MARK: AlbumViewController

extension ImagePickerViewController: AlbumViewControllerDelegate {
    func albumViewController(_ albumViewController: AlbumViewController, didInsertedItemAt indexPath: IndexPath, selectedImages: [UIImage]) {
        self.pickedImages = selectedImages
        insertImage(at: indexPath)
    }
    
    func albumViewController(_ albumViewController: AlbumViewController, didRemovedItemAt indexPath: IndexPath, selectedImages: [UIImage]) {
        self.pickedImages = selectedImages
        deleteImage(at: indexPath)
    }
    
    private func insertImage(at indexPath: IndexPath) {
        let cell = getCell(at: indexPath)
        UIView.transition(
            with: cell.imageView,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: {
                let image = self.pickedImages[indexPath.item]
                cell.configure(with: image, canDelete: self.canDelete, delegate: self)
            },
            completion: { (finished) in
                self.reload(withSelectItemAt: indexPath)
            }
        )
    }
    
    private func deleteImage(at indexPath: IndexPath) {
        let cell = getCell(at: indexPath)
        UIView.transition(
            with: cell.imageView,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: {
                cell.configureEmpty()
            },
            completion: { (finished) in
                self.reload(withSelectItemAt: indexPath)
            }
        )
    }
    
    private func reload(withSelectItemAt indexPath: IndexPath) {
        self.selectedCollectionView.performBatchUpdates({
            let reloadIndexPaths = (0..<self.maxSelectCount).map { IndexPath(item: $0, section: 0) }
            self.selectedCollectionView.reloadItems(at: reloadIndexPaths)
        }, completion: { (finished) in
            self.selectedCollectionView.scrollToItem(at: indexPath,
                                                     at: .centeredHorizontally,
                                                     animated: true)
        })
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

extension ImagePickerViewController: CameraViewControllerDelegate {
    func cameraViewController(_ cameraViewController: CameraViewController, didCapturedImage image: UIImage) {
        albumVC.append(pickedImage: image)
    }
}

extension ImagePickerViewController: CameraActionViewControllerDelegate {
    public func cameraActionViewController(_ cameraActionViewController: CameraActionViewController, didTappedCameraView tapGesture: UITapGestureRecognizer) {
        guard pickedImages.count < maxSelectCount else {
            let alert = UIAlertController(title: "設定可能枚数の上限です", message: "設定している画像を減らしてください", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        cameraVC.capturePhoto()
    }
    
    public func cameraActionViewController(_ cameraActionViewController: CameraActionViewController, didTappedReverseButton button: UIButton) {
        cameraVC.reverseCamera()
    }
}
