//
//  PhotoManager.swift
//  照片选择器-Swift
//
//  Created by Silence on 2019/6/29.
//  Copyright © 2019年 Silence. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

public final class PhotoManager: NSObject {
    
    public static let shared = PhotoManager()

    /// 当前是否处于暗黑模式
    public static var isDark: Bool {
        if shared.appearanceStyle == .normal {
            return false
        }
        if shared.appearanceStyle == .dark {
            return true
        }
            if UITraitCollection.current.userInterfaceStyle == .dark {
                return true
            }
        
        return false
    }
    public static var HUDView: PhotoHUDProtocol.Type = ProgressHUD.self
    
    public var isDebugLogsEnabled: Bool = false

    /// 当前外观样式，每次创建PhotoPickerController时赋值
    var appearanceStyle: AppearanceStyle = .varied

    /// 加载指示器类型
    var indicatorType: IndicatorType = .system
    
    var downloadSession: URLSession!
    var downloadTasks: [String: URLSessionDownloadTask] = [:]
    var downloadCompletions: [String: (URL?, Error?, Any?) -> Void] = [:]
    var downloadProgresss: [String: (Double, URLSessionDownloadTask) -> Void] = [:]
    var downloadFileURLs: [String: URL] = [:]
    var downloadExts: [String: Any] = [:]

    let uuid: String = UUID().uuidString
    
    private override init() {
        super.init()
        

        downloadSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)

    }

}
