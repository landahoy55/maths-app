//
//  CanvasView.swift
//  handwriting-recog
//
//  Created by P Malone on 02/02/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import UIKit

class CanvasView: UIView {
    
    //basic properties required to create a canvas
    var lineColour: UIColor!
    var lineWidth: CGFloat!
    var path: UIBezierPath!
    var touchPoint: CGPoint!
    var startingPoint: CGPoint!
    
    //replacing the init
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.clipsToBounds = true
        self.isMultipleTouchEnabled = false
        
        lineColour = UIColor.black
        //lineColour = UIColor.white
        lineWidth = 10
    }
    
    //take placement of first touch and assign to starting point
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        startingPoint = touch?.location(in: self)
        
    }
    
    //create bezier path from touches
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        touchPoint = touch?.location(in: self)
    
        path = UIBezierPath()
        path.move(to: startingPoint)
        path.addLine(to: touchPoint)
        
        startingPoint = touchPoint
        
        drawShapeLayer()
        
    }
    
    //create a shape from the bezier path and colour the stroke
    func drawShapeLayer() {
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = lineColour.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.fillColor = UIColor.clear.cgColor
        
        //smooth line :)
        shapeLayer.lineCap = kCALineCapRound
        
        self.layer.addSublayer(shapeLayer)
        self.setNeedsDisplay()
        
    }
    
    func clearCanvas() {
        path.removeAllPoints()
        self.layer.sublayers = nil
        self.setNeedsDisplay()
    }

}
