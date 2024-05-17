//
//  HXBaseViewController.swift
//  HXPhotoPicker
//
//  Created by Slience on 2021/1/9.
//

import UIKit

open class HXBaseViewController: UIViewController {
    open override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    open func deviceOrientationDidChanged() {
        
    }
    
    open func deviceOrientationWillChanged() {
        
    }
    
    open override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)

        deviceOrientationWillChanged()
        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            self?.deviceOrientationDidChanged()
        }
    }
    
    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        PhotoTools.removeCache()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
