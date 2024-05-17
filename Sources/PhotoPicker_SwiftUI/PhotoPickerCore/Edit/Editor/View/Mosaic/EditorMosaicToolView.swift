//
//  EditorMosaicToolView.swift
//  HXPhotoPicker
//
//  Created by Silence on 2023/5/20.
//

import UIKit

protocol EditorMosaicToolViewDelegate: AnyObject {
    func mosaicToolView(
        _ mosaicToolView: EditorMosaicToolView,
        didChangedMosaicType type: EditorMosaicType
    )
    func mosaicToolView(
        didUndoClick mosaicToolView: EditorMosaicToolView
    )
}

class EditorMosaicToolView: UIView {
    weak var delegate: EditorMosaicToolViewDelegate?
    private var undoButton: UIButton!
    
    var canUndo: Bool = false {
        didSet {
            undoButton.isEnabled = canUndo
        }
    }
    var mosaicType: EditorMosaicType = .mosaic
    
    let selectedColor: UIColor
    init(selectedColor: UIColor) {
        self.selectedColor = selectedColor
        super.init(frame: .zero)
        initViews()
    }
    
    private func initViews() {

        undoButton = UIButton(type: .custom)
        undoButton.setImage(.imageResource.editor.mosaic.undo.image, for: .normal)
        undoButton.addTarget(self, action: #selector(didUndoClick(button:)), for: .touchUpInside)
        undoButton.tintColor = .white
        undoButton.isEnabled = false
        addSubview(undoButton)
    }
    
    @objc
    private func didUndoClick(button: UIButton) {
        delegate?.mosaicToolView(didUndoClick: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if UIDevice.isPortrait {
            if UIDevice.isPad {
                let buttonWidth = (width - height) * 0.5

                undoButton.frame = CGRect(x: width - height, y: 0, width: height, height: height)
            }else {
                let buttonWidth = (width - UIDevice.leftMargin - UIDevice.rightMargin - height) * 0.5
                undoButton.frame = CGRect(x: width - UIDevice.rightMargin - height, y: 0, width: height, height: height)
            }
            let buttonWidth = (width - UIDevice.leftMargin - UIDevice.rightMargin - height) * 0.5
            undoButton.frame = CGRect(x: width - UIDevice.rightMargin - height, y: 0, width: height, height: height)
        }else {
            undoButton.frame = CGRect(x: 0, y: UIDevice.topMargin, width: width, height: 44)
        }
    }
}
