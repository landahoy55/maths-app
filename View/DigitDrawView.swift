//
//  CanvasView.swift
//  handwriting-recog
//
//  Created by P Malone on 02/02/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import UIKit

//Code extended from Brian Advent open source project series
//Additional smoothing added increasing matches
//Ref https://github.com/brianadvent/CoreMLHandwritingRecognition
//Ref https://www.raywenderlich.com/87899/make-simple-drawing-app-uikit-swift
//Touches began and move form part of gesture recongisers
//Spritekit game work from Year 2 OOP made use - .first is main property

class DigitDrawView: UIView {
    
    //basic properties
    var lineColour: UIColor!
    var lineWidth: CGFloat!
    var path: UIBezierPath!
    var touchPoint: CGPoint!
    
    
    //replacing the init
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.clipsToBounds = true
        self.isMultipleTouchEnabled = false
        
        lineColour = UIColor.black
        //lineColour = UIColor.white
        lineWidth = 13
    }
    
    var start: CGPoint!
    
    //take placement of first touch and assign to starting point
    //touchesBegan - see previous spritekit games for more.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        start = touch?.location(in: self)
        
    }
    
    //record when moved.
    //create bezier path from touches
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print(touches)
//        print(touches.first)
        let touch = touches.first
        //log teh next location
        touchPoint = touch?.location(in: self)
    
        //path = UIBezierPath
        path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: touchPoint)
        
        start = touchPoint
        
        drawLine()
        
    }
    
    //create a line from the bezier path
    //colour the stroke
    func drawLine() {
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = lineColour.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.fillColor = UIColor.clear.cgColor
        
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
