//
//  testAnimation.swift
//  maths-app
//
//  Created by P Malone on 14/03/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import UIKit

class testAnimation: UIView {

    let fillView = UIView()
    
    func setup() {
        self.backgroundColor = UIColor.black
        self.fillView.backgroundColor = UIColor.yellow
        self.addSubview(fillView)
        layoutIfNeeded()
        reset()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        fillView.frame = self.bounds
    }
    
    func reset() {
        fillView.frame.origin.y = bounds.height
    }
    
    func animate() {
        reset()
        UIView.animate(withDuration: 1) {
            self.fillView.frame.origin.y = 0
        }
    }
    
    var coeff:CGFloat = 0.7
    
    func drawCircleInView(){
        // Set up the shape of the circle
        let size:CGSize = self.bounds.size;
        
        let layerBackGround = CALayer();
        layerBackGround.frame = self.bounds;
        layerBackGround.backgroundColor = UIColor.blue.cgColor
        self.layer.addSublayer(layerBackGround)
        
        
        let initialRect:CGRect = CGRect.init(x: 0, y: size.height , width: size.width, height: 0)
        
        let finalRect:CGRect = CGRect.init(x: 0, y: 0, width: size.width, height:  size.height)
        
        let sublayer = CALayer()
        //sublayer.bounds = initialRect
        sublayer.frame = initialRect
        sublayer.anchorPoint = CGPoint(x: 0.5, y: 1)
        sublayer.backgroundColor = UIColor.orange.cgColor
        sublayer.opacity = 1
        
        
        let mask:CAShapeLayer = CAShapeLayer()
        mask.frame = self.bounds
        mask.path = UIBezierPath(ovalIn: self.bounds).cgPath
        
        mask.fillColor = UIColor.black.cgColor
        mask.strokeColor = UIColor.yellow.cgColor
        
        layerBackGround.addSublayer(sublayer)
        layerBackGround.mask = mask
        
        self.layer.addSublayer(layerBackGround)
        
        let boundsAnim:CABasicAnimation  = CABasicAnimation(keyPath: "bounds")
        boundsAnim.toValue = NSValue.init(cgRect:finalRect)
        
        let anim = CAAnimationGroup()
        anim.animations = [boundsAnim]
        anim.isRemovedOnCompletion = false
        anim.duration = 1
        anim.fillMode = kCAFillModeForwards
        sublayer.add(anim, forKey: nil)
    }

}
