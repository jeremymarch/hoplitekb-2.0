//
//  Shapes.swift
//  TastyImitationKeyboard
//
//  Created by Alexei Baboulevitch on 10/5/14.
//  Copyright (c) 2014 Alexei Baboulevitch ("Archagon"). All rights reserved.
//

import UIKit

// TODO: these shapes were traced and as such are erratic and inaccurate; should redo as SVG or PDF

///////////////////
// SHAPE OBJECTS //
///////////////////

class BackspaceShape: Shape {
    override func drawCall(_ color: UIColor) {
        drawBackspace(self.bounds, color: color)
    }
}

class ShiftShape: Shape {
    var withLock: Bool = false {
        didSet {
            self.overflowCanvas.setNeedsDisplay()
        }
    }
    
    override func drawCall(_ color: UIColor) {
        drawShift(self.bounds, color: color, withRect: self.withLock)
    }
}

class AcuteShape: Shape {
    override func drawCall(_ color: UIColor) {
        drawAcute(self.bounds, color: color)
    }
}

class GraveShape: Shape {
    override func drawCall(_ color: UIColor) {
        drawGrave(self.bounds, color: color)
    }
}

class SmoothShape: Shape {
    override func drawCall(_ color: UIColor) {
        drawSmooth(self.bounds, color: color)
    }
}

class RoughShape: Shape {
    override func drawCall(_ color: UIColor) {
        drawRough(self.bounds, color: color)
    }
}

class GlobeShape: Shape {
    override func drawCall(_ color: UIColor) {
        drawGlobe(self.bounds, color: color)
    }
}

class Shape: UIView {
    var color: UIColor? {
        didSet {
            if let _ = self.color {
                self.overflowCanvas.setNeedsDisplay()
            }
        }
    }
    
    // in case shapes draw out of bounds, we still want them to show
    var overflowCanvas: OverflowCanvas!
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override required init(frame: CGRect) {
        super.init(frame: frame)
        
        self.isOpaque = false
        self.clipsToBounds = false
        
        self.overflowCanvas = OverflowCanvas(shape: self)
        self.addSubview(self.overflowCanvas)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var oldBounds: CGRect?
    override func layoutSubviews() {
        if self.bounds.width == 0 || self.bounds.height == 0 {
            return
        }
        if oldBounds != nil && self.bounds.equalTo(oldBounds!) {
            return
        }
        oldBounds = self.bounds
        
        super.layoutSubviews()
        
        let overflowCanvasSizeRatio = CGFloat(1.25)
        let overflowCanvasSize = CGSize(width: self.bounds.width * overflowCanvasSizeRatio, height: self.bounds.height * overflowCanvasSizeRatio)
        
        self.overflowCanvas.frame = CGRect(
            x: CGFloat((self.bounds.width - overflowCanvasSize.width) / 2.0),
            y: CGFloat((self.bounds.height - overflowCanvasSize.height) / 2.0),
            width: overflowCanvasSize.width,
            height: overflowCanvasSize.height)
        self.overflowCanvas.setNeedsDisplay()
    }
    
    func drawCall(_ color: UIColor) { /* override me! */ }
    
    class OverflowCanvas: UIView {
        unowned var shape: Shape
        
        init(shape: Shape) {
            self.shape = shape
            
            super.init(frame: CGRect.zero)
            
            self.isOpaque = false
        }

        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func draw(_ rect: CGRect) {
            let ctx = UIGraphicsGetCurrentContext()
            CGColorSpaceCreateDeviceRGB()
            
            ctx?.saveGState()
            
            let xOffset = (self.bounds.width - self.shape.bounds.width) / CGFloat(2)
            let yOffset = (self.bounds.height - self.shape.bounds.height) / CGFloat(2)
            ctx?.translateBy(x: xOffset, y: yOffset)
            
            self.shape.drawCall(shape.color != nil ? shape.color! : UIColor.black)
            
            ctx?.restoreGState()
        }
    }
}

/////////////////////
// SHAPE FUNCTIONS //
/////////////////////

func getFactors(_ fromSize: CGSize, toRect: CGRect) -> (xScalingFactor: CGFloat, yScalingFactor: CGFloat, lineWidthScalingFactor: CGFloat, fillIsHorizontal: Bool, offset: CGFloat) {
    
    let xSize = { () -> CGFloat in
        let scaledSize = (fromSize.width / CGFloat(2))
        if scaledSize > toRect.width {
            return (toRect.width / scaledSize) / CGFloat(2)
        }
        else {
            return CGFloat(0.5)
        }
    }()
    
    let ySize = { () -> CGFloat in
        let scaledSize = (fromSize.height / CGFloat(2))
        if scaledSize > toRect.height {
            return (toRect.height / scaledSize) / CGFloat(2)
        }
        else {
            return CGFloat(0.5)
        }
    }()
    
    let actualSize = min(xSize, ySize)
    
    return (actualSize, actualSize, actualSize, false, 0)
}

func centerShape(_ fromSize: CGSize, toRect: CGRect) {
    let xOffset = (toRect.width - fromSize.width) / CGFloat(2)
    let yOffset = (toRect.height - fromSize.height) / CGFloat(2)
    
    let ctx = UIGraphicsGetCurrentContext()
    ctx?.saveGState()
    ctx?.translateBy(x: xOffset, y: yOffset)
}

func endCenter() {
    let ctx = UIGraphicsGetCurrentContext()
    ctx?.restoreGState()
}

func drawBackspace(_ bounds: CGRect, color: UIColor) {
    let factors = getFactors(CGSize(width: 44, height: 32), toRect: bounds)
    let xScalingFactor = factors.xScalingFactor
    let yScalingFactor = factors.yScalingFactor
    let lineWidthScalingFactor = factors.lineWidthScalingFactor
    
    centerShape(CGSize(width: 44 * xScalingFactor, height: 32 * yScalingFactor), toRect: bounds)
    
    
    //// Color Declarations
    let color = color
    let color2 = UIColor.gray // TODO:
    
    //// Bezier Drawing
    let bezierPath = UIBezierPath()
    bezierPath.move(to: CGPoint(x: 16 * xScalingFactor, y: 32 * yScalingFactor))
    bezierPath.addLine(to: CGPoint(x: 38 * xScalingFactor, y: 32 * yScalingFactor))
    bezierPath.addCurve(to: CGPoint(x: 44 * xScalingFactor, y: 26 * yScalingFactor), controlPoint1: CGPoint(x: 38 * xScalingFactor, y: 32 * yScalingFactor), controlPoint2: CGPoint(x: 44 * xScalingFactor, y: 32 * yScalingFactor))
    bezierPath.addCurve(to: CGPoint(x: 44 * xScalingFactor, y: 6 * yScalingFactor), controlPoint1: CGPoint(x: 44 * xScalingFactor, y: 22 * yScalingFactor), controlPoint2: CGPoint(x: 44 * xScalingFactor, y: 6 * yScalingFactor))
    bezierPath.addCurve(to: CGPoint(x: 36 * xScalingFactor, y: 0 * yScalingFactor), controlPoint1: CGPoint(x: 44 * xScalingFactor, y: 6 * yScalingFactor), controlPoint2: CGPoint(x: 44 * xScalingFactor, y: 0 * yScalingFactor))
    bezierPath.addCurve(to: CGPoint(x: 16 * xScalingFactor, y: 0 * yScalingFactor), controlPoint1: CGPoint(x: 32 * xScalingFactor, y: 0 * yScalingFactor), controlPoint2: CGPoint(x: 16 * xScalingFactor, y: 0 * yScalingFactor))
    bezierPath.addLine(to: CGPoint(x: 0 * xScalingFactor, y: 18 * yScalingFactor))
    bezierPath.addLine(to: CGPoint(x: 16 * xScalingFactor, y: 32 * yScalingFactor))
    bezierPath.close()
    color.setFill()
    bezierPath.fill()
    
    
    //// Bezier 2 Drawing
    let bezier2Path = UIBezierPath()
    bezier2Path.move(to: CGPoint(x: 20 * xScalingFactor, y: 10 * yScalingFactor))
    bezier2Path.addLine(to: CGPoint(x: 34 * xScalingFactor, y: 22 * yScalingFactor))
    bezier2Path.addLine(to: CGPoint(x: 20 * xScalingFactor, y: 10 * yScalingFactor))
    bezier2Path.close()
    UIColor.gray.setFill()
    bezier2Path.fill()
    color2.setStroke()
    bezier2Path.lineWidth = 2.5 * lineWidthScalingFactor
    bezier2Path.stroke()
    
    
    //// Bezier 3 Drawing
    let bezier3Path = UIBezierPath()
    bezier3Path.move(to: CGPoint(x: 20 * xScalingFactor, y: 22 * yScalingFactor))
    bezier3Path.addLine(to: CGPoint(x: 34 * xScalingFactor, y: 10 * yScalingFactor))
    bezier3Path.addLine(to: CGPoint(x: 20 * xScalingFactor, y: 22 * yScalingFactor))
    bezier3Path.close()
    UIColor.red.setFill()
    bezier3Path.fill()
    color2.setStroke()
    bezier3Path.lineWidth = 2.5 * lineWidthScalingFactor
    bezier3Path.stroke()
    
    endCenter()
}

func drawShift(_ bounds: CGRect, color: UIColor, withRect: Bool) {
    let factors = getFactors(CGSize(width: 38, height: (withRect ? 34 + 4 : 32)), toRect: bounds)
    let xScalingFactor = factors.xScalingFactor
    let yScalingFactor = factors.yScalingFactor
    _ = factors.lineWidthScalingFactor
    
    centerShape(CGSize(width: 38 * xScalingFactor, height: (withRect ? 34 + 4 : 32) * yScalingFactor), toRect: bounds)
    
    
    //// Color Declarations
    let color2 = color
    
    //// Bezier Drawing
    let bezierPath = UIBezierPath()
    bezierPath.move(to: CGPoint(x: 28 * xScalingFactor, y: 18 * yScalingFactor))
    bezierPath.addLine(to: CGPoint(x: 38 * xScalingFactor, y: 18 * yScalingFactor))
    bezierPath.addLine(to: CGPoint(x: 38 * xScalingFactor, y: 18 * yScalingFactor))
    bezierPath.addLine(to: CGPoint(x: 19 * xScalingFactor, y: 0 * yScalingFactor))
    bezierPath.addLine(to: CGPoint(x: 0 * xScalingFactor, y: 18 * yScalingFactor))
    bezierPath.addLine(to: CGPoint(x: 0 * xScalingFactor, y: 18 * yScalingFactor))
    bezierPath.addLine(to: CGPoint(x: 10 * xScalingFactor, y: 18 * yScalingFactor))
    bezierPath.addLine(to: CGPoint(x: 10 * xScalingFactor, y: 28 * yScalingFactor))
    bezierPath.addCurve(to: CGPoint(x: 14 * xScalingFactor, y: 32 * yScalingFactor), controlPoint1: CGPoint(x: 10 * xScalingFactor, y: 28 * yScalingFactor), controlPoint2: CGPoint(x: 10 * xScalingFactor, y: 32 * yScalingFactor))
    bezierPath.addCurve(to: CGPoint(x: 24 * xScalingFactor, y: 32 * yScalingFactor), controlPoint1: CGPoint(x: 16 * xScalingFactor, y: 32 * yScalingFactor), controlPoint2: CGPoint(x: 24 * xScalingFactor, y: 32 * yScalingFactor))
    bezierPath.addCurve(to: CGPoint(x: 28 * xScalingFactor, y: 28 * yScalingFactor), controlPoint1: CGPoint(x: 24 * xScalingFactor, y: 32 * yScalingFactor), controlPoint2: CGPoint(x: 28 * xScalingFactor, y: 32 * yScalingFactor))
    bezierPath.addCurve(to: CGPoint(x: 28 * xScalingFactor, y: 18 * yScalingFactor), controlPoint1: CGPoint(x: 28 * xScalingFactor, y: 26 * yScalingFactor), controlPoint2: CGPoint(x: 28 * xScalingFactor, y: 18 * yScalingFactor))
    bezierPath.close()
    color2.setFill()
    bezierPath.fill()
    
    
    if withRect {
        //// Rectangle Drawing
        let rectanglePath = UIBezierPath(rect: CGRect(x: 10 * xScalingFactor, y: 34 * yScalingFactor, width: 18 * xScalingFactor, height: 4 * yScalingFactor))
        color2.setFill()
        rectanglePath.fill()
    }
    
    endCenter()
}

func drawGlobe(_ bounds: CGRect, color: UIColor) {
    let factors = getFactors(CGSize(width: 41, height: 40), toRect: bounds)
    let xScalingFactor = factors.xScalingFactor
    let yScalingFactor = factors.yScalingFactor
    let lineWidthScalingFactor = factors.lineWidthScalingFactor
    
    centerShape(CGSize(width: 41 * xScalingFactor, height: 40 * yScalingFactor), toRect: bounds)
    
    
    //// Color Declarations
    let color = color
    
    //// Oval Drawing
    let ovalPath = UIBezierPath(ovalIn: CGRect(x: 0 * xScalingFactor, y: 0 * yScalingFactor, width: 40 * xScalingFactor, height: 40 * yScalingFactor))
    color.setStroke()
    ovalPath.lineWidth = 1 * lineWidthScalingFactor
    ovalPath.stroke()
    
    
    //// Bezier Drawing
    let bezierPath = UIBezierPath()
    bezierPath.move(to: CGPoint(x: 20 * xScalingFactor, y: -0 * yScalingFactor))
    bezierPath.addLine(to: CGPoint(x: 20 * xScalingFactor, y: 40 * yScalingFactor))
    bezierPath.addLine(to: CGPoint(x: 20 * xScalingFactor, y: -0 * yScalingFactor))
    bezierPath.close()
    color.setStroke()
    bezierPath.lineWidth = 1 * lineWidthScalingFactor
    bezierPath.stroke()
    
    
    //// Bezier 2 Drawing
    let bezier2Path = UIBezierPath()
    bezier2Path.move(to: CGPoint(x: 0.5 * xScalingFactor, y: 19.5 * yScalingFactor))
    bezier2Path.addLine(to: CGPoint(x: 39.5 * xScalingFactor, y: 19.5 * yScalingFactor))
    bezier2Path.addLine(to: CGPoint(x: 0.5 * xScalingFactor, y: 19.5 * yScalingFactor))
    bezier2Path.close()
    color.setStroke()
    bezier2Path.lineWidth = 1 * lineWidthScalingFactor
    bezier2Path.stroke()
    
    
    //// Bezier 3 Drawing
    let bezier3Path = UIBezierPath()
    bezier3Path.move(to: CGPoint(x: 21.63 * xScalingFactor, y: 0.42 * yScalingFactor))
    bezier3Path.addCurve(to: CGPoint(x: 21.63 * xScalingFactor, y: 39.6 * yScalingFactor), controlPoint1: CGPoint(x: 21.63 * xScalingFactor, y: 0.42 * yScalingFactor), controlPoint2: CGPoint(x: 41 * xScalingFactor, y: 19 * yScalingFactor))
    bezier3Path.lineCapStyle = .round;
    
    color.setStroke()
    bezier3Path.lineWidth = 1 * lineWidthScalingFactor
    bezier3Path.stroke()
    
    
    //// Bezier 4 Drawing
    let bezier4Path = UIBezierPath()
    bezier4Path.move(to: CGPoint(x: 17.76 * xScalingFactor, y: 0.74 * yScalingFactor))
    bezier4Path.addCurve(to: CGPoint(x: 18.72 * xScalingFactor, y: 39.6 * yScalingFactor), controlPoint1: CGPoint(x: 17.76 * xScalingFactor, y: 0.74 * yScalingFactor), controlPoint2: CGPoint(x: -2.5 * xScalingFactor, y: 19.04 * yScalingFactor))
    bezier4Path.lineCapStyle = .round;
    
    color.setStroke()
    bezier4Path.lineWidth = 1 * lineWidthScalingFactor
    bezier4Path.stroke()
    
    
    //// Bezier 5 Drawing
    let bezier5Path = UIBezierPath()
    bezier5Path.move(to: CGPoint(x: 6 * xScalingFactor, y: 7 * yScalingFactor))
    bezier5Path.addCurve(to: CGPoint(x: 34 * xScalingFactor, y: 7 * yScalingFactor), controlPoint1: CGPoint(x: 6 * xScalingFactor, y: 7 * yScalingFactor), controlPoint2: CGPoint(x: 19 * xScalingFactor, y: 21 * yScalingFactor))
    bezier5Path.lineCapStyle = .round;
    
    color.setStroke()
    bezier5Path.lineWidth = 1 * lineWidthScalingFactor
    bezier5Path.stroke()
    
    
    //// Bezier 6 Drawing
    let bezier6Path = UIBezierPath()
    bezier6Path.move(to: CGPoint(x: 6 * xScalingFactor, y: 33 * yScalingFactor))
    bezier6Path.addCurve(to: CGPoint(x: 34 * xScalingFactor, y: 33 * yScalingFactor), controlPoint1: CGPoint(x: 6 * xScalingFactor, y: 33 * yScalingFactor), controlPoint2: CGPoint(x: 19 * xScalingFactor, y: 22 * yScalingFactor))
    bezier6Path.lineCapStyle = .round;
    
    color.setStroke()
    bezier6Path.lineWidth = 1 * lineWidthScalingFactor
    bezier6Path.stroke()
    
    endCenter()
}
/*
func getSlope(p1:CGPoint, p2:CGPoint) -> CGFloat
{
    print("rise: \(p2.y - p1.y), run: \(p2.x - p1.x)")
    return (p2.y - p1.y) / (p2.x - p1.x)
}
*/
func getPointOnLine(slope:CGFloat, point:CGPoint, distance:CGFloat) -> CGPoint
{
    var newPoint = CGPoint()
    newPoint.x = distance * cos(atan(slope)) + point.x
    newPoint.y = distance * sin(atan(slope)) + point.y
    
    //print("x: \(newPoint.x), y: \(newPoint.y)")
    return newPoint
}

func getAcuteGravePath(_ bounds: CGRect, startX:CGFloat) -> UIBezierPath {
    let factors = getFactors(CGSize(width: 38, height: 32), toRect: bounds)
    let xScalingFactor = factors.xScalingFactor
    let yScalingFactor = factors.yScalingFactor
    //_ = factors.lineWidthScalingFactor
    //print("b: \(bounds)")
    centerShape(CGSize(width: 38 * xScalingFactor, height: 32 * yScalingFactor), toRect: bounds)
    
    //let bottomTruncation = 0.0
    let height:CGFloat = 10.0
    let fullHeight:CGFloat = 20.0
    //let topPadding = 0.0
    let slope2:CGFloat = -1.9
    let slope3:CGFloat = slope2 + 0.6
    
    let startPoint = CGPoint(x: startX * xScalingFactor, y: 4 * yScalingFactor)
    let p2 = getPointOnLine(slope:slope2, point:startPoint, distance:height * -1.0)
    let f2 = getPointOnLine(slope:slope2, point:startPoint, distance:fullHeight * -1.0)
    let f3 = getPointOnLine(slope:slope3, point:f2, distance:fullHeight - height)
    let p3 = getPointOnLine(slope:slope3, point:f3, distance:height)
    
    //// Bezier Drawing
    let bezierPath = UIBezierPath()
    //starting point
    bezierPath.move(to: startPoint)
    //upper line down and to the left
    bezierPath.addLine(to: p2)
    //bezierPath.addLine(to: f3) //for testing: a line straight across to f3
    //bottom curve
    bezierPath.addCurve(to: f3, controlPoint1: getPointOnLine(slope:slope2, point:p2, distance:-4.0), controlPoint2: getPointOnLine(slope:slope3, point:f3, distance:-4.0))
    
    //lower line going up
    bezierPath.addLine(to: p3)
    //top curve around to the left
    bezierPath.addCurve(to: startPoint, controlPoint1: getPointOnLine(slope:slope3, point:p3, distance:4.0), controlPoint2: getPointOnLine(slope:slope2, point:startPoint, distance:4.0))

    bezierPath.close()
    
    return bezierPath
}

func drawAcute(_ bounds: CGRect, color: UIColor) {
    let bezierPath = getAcuteGravePath(bounds, startX: 20.0)
    
    //// Color Declarations
    let color2 = color
    color2.setFill()
    //color2.setStroke()
    bezierPath.fill()
    //bezierPath.stroke()
    endCenter()
}

func drawGrave(_ bounds: CGRect, color: UIColor) {
    let bezierPath = getAcuteGravePath(bounds, startX: 36.0)
    mirrorPath(path:bezierPath, bounds:bounds)
    
    //// Color Declarations
    let color2 = color
    color2.setFill()
    //color2.setStroke()
    bezierPath.fill()
    //bezierPath.stroke()
    endCenter()
}

func mirrorPath(path:UIBezierPath, bounds:CGRect) {
    path.apply(CGAffineTransform(translationX: -bounds.origin.x, y: 0))
    path.apply(CGAffineTransform(scaleX: -1.0, y: 1.0))
    path.apply(CGAffineTransform(translationX: bounds.origin.x + bounds.width, y: 0))
}

func getBreathingPath(_ bounds: CGRect, startX:CGFloat) -> UIBezierPath {
    let factors = getFactors(CGSize(width: 38, height: 32), toRect: bounds)
    let xScalingFactor = factors.xScalingFactor
    let yScalingFactor = factors.yScalingFactor
    //_ = factors.lineWidthScalingFactor
    //print("b: \(bounds)")
    centerShape(CGSize(width: 38 * xScalingFactor, height: 32 * yScalingFactor), toRect: bounds)
    
    //let bottomTruncation = 0.0
    let height:CGFloat = 10.0
    let fullHeight:CGFloat = 20.0
    //let topPadding = 0.0
    let slope2:CGFloat = -1.9
    let slope3:CGFloat = slope2 + 0.6
    
    // Bezier Drawing
    let bezierPath = UIBezierPath()
    //starting point
    var point = CGPoint(x: startX * xScalingFactor, y: 4 * yScalingFactor)
    bezierPath.move(to: point)

    //bottom curve
    point.y += 20
    //bezierPath.addCurve(to: point, controlPoint1: getPointOnLine(slope:slope2, point:p2, distance:-4.0), controlPoint2: getPointOnLine(slope:slope3, point:f3, distance:-4.0))
    

    //top curve around to the left
    //bezierPath.addCurve(to: point, controlPoint1: getPointOnLine(slope:slope3, point:p3, distance:4.0), controlPoint2: getPointOnLine(slope:slope2, point:startPoint, distance:4.0))

    bezierPath.close()
    
    return bezierPath
}

func drawSmooth(_ bounds: CGRect, color: UIColor) {
    let bezierPath = getBreathingPath(bounds, startX: 20.0)
    
    //// Color Declarations
    let color2 = color
    color2.setFill()
    //color2.setStroke()
    bezierPath.fill()
    //bezierPath.stroke()
    endCenter()
}

func drawRough(_ bounds: CGRect, color: UIColor) {
    let bezierPath = getBreathingPath(bounds, startX: 36.0)
    mirrorPath(path:bezierPath, bounds:bounds)
    
    //// Color Declarations
    let color2 = color
    color2.setFill()
    //color2.setStroke()
    bezierPath.fill()
    //bezierPath.stroke()
    endCenter()
}
