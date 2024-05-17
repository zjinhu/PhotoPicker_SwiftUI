//
//  File.swift
//  
//
//  Created by HU on 2024/5/14.
//
import UIKit

extension CropViewController {
    
    @objc
    func didCancelButtonClick(button: UIButton) {
        backClick(true)
    }
    
    @objc
    func didFinishButtonClick(button: UIButton) {
        processing()
    }
    
    @objc
    func didResetButtonClick(button: UIButton) {

        if editorView.maskImage != nil {
            editorView.setMaskImage(nil, animated: true)
        }
        editorView.reset(true)
        lastScaleAngle = 0

        button.isEnabled = false
    }
    
    @objc
    func didLeftRotateButtonClick(button: UIButton) {
        editorView.rotateLeft(true)
    }
    
    @objc
    func didRightRotateButtonClick(button: UIButton) {
        editorView.rotateRight(true)
    }

    func checkFinishButtonState() {
        if editorView.state == .edit {
            finishButton.isEnabled = true
        }else {
            if config.isWhetherFinishButtonDisabledInUneditedState {
                finishButton.isEnabled = isEdited
            }else {
                finishButton.isEnabled = true
            }
        }
    }

}
