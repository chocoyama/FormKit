//
//  CellRegisterable.swift
//  FormKit
//
//  Created by Takuya Yokoyama on 2019/03/08.
//  Copyright © 2019 chocoyama. All rights reserved.
//

import UIKit

public protocol CellRegisterable {}
extension CellRegisterable {
    static public var cellIdentifier: String {
        return String(describing: Self.self)
    }
}

extension UITableViewCell: CellRegisterable {}
extension CellRegisterable where Self: UITableViewCell {
    static public func register(for tableView: UITableView, bundle: Bundle? = nil) {
        let nib = UINib(nibName: cellIdentifier, bundle: bundle)
        tableView.register(nib, forCellReuseIdentifier: cellIdentifier)
    }
    
    static public func dequeue(from tableView: UITableView, indexPath: IndexPath) -> Self {
        
        return tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! Self
    }
}

extension UICollectionViewCell: CellRegisterable {}
extension CellRegisterable where Self: UICollectionViewCell {
    static public func register(for collectionView: UICollectionView, bundle: Bundle? = nil) {
        let nib = UINib(nibName: cellIdentifier, bundle: bundle)
        collectionView.register(nib, forCellWithReuseIdentifier: cellIdentifier)
    }
    
    static public func dequeue(from collectionView: UICollectionView, indexPath: IndexPath) -> Self {
        return collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! Self
    }
}
