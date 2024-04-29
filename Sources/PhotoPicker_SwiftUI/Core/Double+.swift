//
//  File.swift
//  
//
//  Created by FunWidget on 2024/4/29.
//

import Foundation
extension Double{
    func formatDuration() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        
        return formatter.string(from: TimeInterval(self)) ?? "00:00"
    }
}