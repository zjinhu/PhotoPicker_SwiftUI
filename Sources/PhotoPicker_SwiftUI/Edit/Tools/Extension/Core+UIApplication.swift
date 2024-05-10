//
//  Core+UIApplication.swift
//  HXPhotoPicker
//
//  Created by Slience on 2022/9/26.
//

import UIKit

private extension UIScene.ActivationState {
    var sortPriority: Int {
        switch self {
        case .foregroundActive: return 1
        case .foregroundInactive: return 2
        case .background: return 3
        case .unattached: return 4
        @unknown default: return 5
        }
    }
}

extension UIApplication {
    static var keyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .sorted { $0.activationState.sortPriority < $1.activationState.sortPriority }
            .compactMap { $0 as? UIWindowScene }
            .compactMap { $0.windows.first { $0.isKeyWindow } }
            .first
    }
    
    static var interfaceOrientation: UIInterfaceOrientation {
        let orientation = keyWindow?.windowScene?.interfaceOrientation ?? .portrait
        return orientation
    }
}

extension UIScreen {
    
    static var _scale: CGFloat {
        
        let scale = UIApplication.keyWindow?.windowScene?.screen.scale ?? 0
        return scale
        
    }
    
    static var _width: CGFloat {
        
        let width = UIApplication.keyWindow?.windowScene?.screen.bounds.width ?? 0
        return width
        
    }
    
    static var _height: CGFloat {
        
        let height = UIApplication.keyWindow?.windowScene?.screen.bounds.height ?? 0
        return height
        
    }
    
    static var _size: CGSize {
        
        let size = UIApplication.keyWindow?.windowScene?.screen.bounds.size ?? .zero
        return size
        
    }
    
}
