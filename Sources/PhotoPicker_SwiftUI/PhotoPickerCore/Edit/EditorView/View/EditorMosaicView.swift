//
//  EditorMosaicView.swift
//  Example
//
//  Created by Slience on 2022/11/8.
//

import UIKit
import CoreImage
import CoreGraphics

protocol EditorMosaicViewDelegate: AnyObject {
    func mosaicView(_  mosaicView: EditorMosaicView, splashColor atPoint: CGPoint) -> UIColor?
    func mosaicView(beginDraw mosaicView: EditorMosaicView)
    func mosaicView(endDraw mosaicView: EditorMosaicView)
}

class EditorMosaicView: UIView {
    weak var delegate: EditorMosaicViewDelegate?
    var originalImage: UIImage? {
        didSet {
            mosaicContentLayer.contents = originalImage?.cgImage
        }
    }
    var originalCGImage: CGImage? {
        didSet {
            mosaicContentLayer.contents = originalCGImage
        }
    }
    private var mosaicContentLayer: CALayer!
    private var mosaicPathLayer: CAShapeLayer!
    
    var isEnabled: Bool = false {
        didSet { isUserInteractionEnabled = isEnabled }
    }
    var isCanUndo: Bool { !mosaicPaths.isEmpty }
    var mosaicLineWidth: CGFloat = 25
    var imageWidth: CGFloat = 30
    var type: EditorMosaicType = .mosaic
    
    var scale: CGFloat = 1
    var isTouching: Bool = false
    var isBegan: Bool = false
    var count: Int { mosaicPaths.count }
    
    init() {
        super.init(frame: .zero)
        initViews()
        layer.addSublayer(mosaicContentLayer)
        layer.addSublayer(mosaicPathLayer)
        mosaicPathLayer.lineWidth = mosaicLineWidth / scale
        mosaicContentLayer.mask = mosaicPathLayer
        clipsToBounds = true
        isUserInteractionEnabled = false
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(panGesureRecognizerClick(panGR:)))
        pan.delegate = self
        addGestureRecognizer(pan)
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinchGesureRecognizerClick(pinchGR:)))
        pinch.delegate = self
        addGestureRecognizer(pinch)
    }
    
    func initViews() {
        mosaicContentLayer = CALayer()
        mosaicPathLayer = CAShapeLayer()
        mosaicPathLayer.strokeColor = UIColor.white.cgColor
        mosaicPathLayer.fillColor = nil
        mosaicPathLayer.lineCap = .round
        mosaicPathLayer.lineJoin = .round
    }
    
    var mosaicPaths: [MosaicPath] = []
    var mosaicPoints: [CGPoint] = []

    @objc
    func pinchGesureRecognizerClick(pinchGR: UIPanGestureRecognizer) {
        
    }
    
    @objc func panGesureRecognizerClick(panGR: UIPanGestureRecognizer) {
        switch panGR.state {
        case .began:
            let point = panGR.location(in: self)
            isTouching = false
            isBegan = true
            if type == .mosaic {
                let lineWidth = mosaicLineWidth / scale
                let path = MosaicPath(type: .mosaic, width: lineWidth)
                path.move(to: point)
                if let mosaicPath = mosaicPathLayer.path {
                    let bezierPath = MosaicPath(cgPath: mosaicPath, type: .mosaic)
                    bezierPath.move(to: point)
                    mosaicPathLayer.path = bezierPath.cgPath
                }else {
                    mosaicPathLayer.path = path.cgPath
                }
                mosaicPaths.append(path)
                mosaicPoints.append(CGPoint(x: point.x / width, y: point.y / height))
            }
        case .changed:
            let point = panGR.location(in: self)
            var didChanged = false
            if type == .mosaic {
                if let cgPath = mosaicPathLayer.path,
                   let mosaicPath = mosaicPaths.last,
                   !mosaicPath.currentPoint.equalTo(point) {
                    didChanged = true
                    mosaicPath.addLine(to: point)
                    let path = MosaicPath(cgPath: cgPath, type: .mosaic)
                    path.addLine(to: point)
                    mosaicPoints.append(CGPoint(x: point.x / width, y: point.y / height))
                    mosaicPathLayer.path = path.cgPath
                }
            }
            if didChanged {
                if isBegan {
                    delegate?.mosaicView(beginDraw: self)
                }
                isTouching = true
                isBegan = false
            }
        case .failed, .cancelled, .ended:
            if isTouching {
                delegate?.mosaicView(endDraw: self)
                let path = mosaicPaths.last
                path?.points = mosaicPoints
 
            }else {
                undo()
            }
            mosaicPoints.removeAll()
            isTouching = false
        default:
            break
        }
    }

    func getAngleBetweenPoint(startPoint: CGPoint, endPoint: CGPoint) -> CGFloat {
        let p2 = startPoint
        let p3 = endPoint
        let p1 = CGPoint(x: p3.x, y: p2.y)
        if (p1.x == p2.x && p2.x == p3.x) || (p1.y == p2.x && p2.x == p3.x) {
            return 0
        }
        let a = abs(p1.x - p2.x)
        let b = abs(p1.y - p2.y)
        let c = abs(p3.x - p2.x)
        let d = abs(p3.y - p2.y)
        
        if (a < 1.0 && b < 1.0) || (c < 1.0 && d < 1.0) {
            return 0
        }
        let e = a * c + b * d
        let f = sqrt(a * a + b * b)
        let g = sqrt(c * c + d * d)
        let r = CGFloat(acos(e / (f * g)))
        let angle = (180 * r / CGFloat.pi)
        if p3.x < p2.x {
            if p3.y < p2.y {
                return 270 + angle
            }else {
                return 270 - angle
            }
        }else {
            if p3.y < p2.y {
                return 90 - angle
            }else {
                return 90 + angle
            }
        }
    }
    func undo() {
        if let lastPath = mosaicPaths.last {
            mosaicPaths.removeLast()
            if lastPath.type == .mosaic {
                let mosaicPath = UIBezierPath()
                for path in mosaicPaths {
                    mosaicPath.append(path)
                }
                if mosaicPath.isEmpty {
                    mosaicPathLayer.path = nil
                }else {
                    mosaicPathLayer.path = mosaicPath.cgPath
                }
            }
        }
    }
    func undoAll() {

        mosaicPaths.removeAll()
        mosaicPathLayer.path = nil
    }
    func getMosaicData() -> [MosaicData] {
        var mosaicDatas: [MosaicData] = []
        for path in mosaicPaths {
            let lineWidth = path.type == .mosaic ? path.lineWidth : path.width
            let  mosaicData = MosaicData(
                type: path.type,
                points: path.points,
                lineWidth: lineWidth / width,
                angles: path.angles
            )
            mosaicDatas.append(mosaicData)
        }
        return mosaicDatas
    }
    func setMosaicData(mosaicDatas: [MosaicData], viewSize: CGSize) {
        let mosaicPath = UIBezierPath()
        for mosaicData in mosaicDatas {
            if mosaicData.type == .mosaic {
                let path = MosaicPath(
                    type: .mosaic,
                    width: mosaicData.lineWidth * viewSize.width
                )
                for (index, point) in mosaicData.points.enumerated() {
                    let newPoint = CGPoint(x: point.x * viewSize.width, y: point.y * viewSize.height)
                    if index == 0 {
                        path.move(to: newPoint)
                    }else {
                        path.addLine(to: newPoint)
                    }
                }
                path.points = mosaicData.points
                mosaicPath.append(path)
                mosaicPaths.append(path)
            }
        }
        if mosaicPath.isEmpty {
            mosaicPathLayer.path = nil
        }else {
            mosaicPathLayer.path = mosaicPath.cgPath
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        mosaicContentLayer.frame = bounds
        mosaicPathLayer.frame = bounds
        CATransaction.commit()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EditorMosaicView {
    
    class MosaicPath: EditorDrawView.BrushPath {
        let type: EditorMosaicType
        let width: CGFloat

        var angles: [CGFloat] = []
        
        init(type: EditorMosaicType, width: CGFloat) {
            self.type = type
            self.width = width
            super.init()
        }
        
        convenience init(cgPath: CGPath, type: EditorMosaicType) {
            self.init(type: type, width: 0)
            self.cgPath = cgPath
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    struct MosaicData {
        let type: EditorMosaicType
        let points: [CGPoint]
        let lineWidth: CGFloat
        let angles: [CGFloat]
    }
}
extension EditorMosaicView.MosaicData: Codable {
    enum CodingKeys: String, CodingKey {
        case type
        case points
        case colors
        case lineWidth
        case angles
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(EditorMosaicType.self, forKey: .type)
        points = try container.decode([CGPoint].self, forKey: .points)
        lineWidth = try container.decode(CGFloat.self, forKey: .lineWidth)
        angles = try container.decode([CGFloat].self, forKey: .angles)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(points, forKey: .points)
 
        try container.encode(lineWidth, forKey: .lineWidth)
        try container.encode(angles, forKey: .angles)
    }
}
extension EditorMosaicView: UIGestureRecognizerDelegate {
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        isEnabled
    }
    
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        if gestureRecognizer is UIPinchGestureRecognizer && otherGestureRecognizer is UIPanGestureRecognizer {
            return false
        }
        if gestureRecognizer is UIPanGestureRecognizer {
            return false
        }
        return true
    }
}
