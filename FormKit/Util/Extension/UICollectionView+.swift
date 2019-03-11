//
//  UICollectionView+.swift
//  FormKit
//
//  Created by Takuya Yokoyama on 2019/03/11.
//  Copyright © 2019 chocoyama. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionView {
    func scrollToRight(animated: Bool) {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let x = layout.collectionViewContentSize.width - self.frame.width
        if x > 0 {
            setContentOffset(CGPoint(x: x, y: 0), animated: animated)
        }
    }
    
    func scrollToBottom(animated: Bool) {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let y = layout.collectionViewContentSize.height - self.frame.height
        if y > 0 {
            setContentOffset(CGPoint(x: 0, y: y), animated: animated)
        }
    }
}
