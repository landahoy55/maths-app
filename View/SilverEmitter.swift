//
//  SilverEmitter.swift
//  maths-app
//
//  Created by P Malone on 09/05/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import UIKit

class SilverEmitter {
    
    //static funcs are type func - don't need to create an object to use
    static func createEmitter() -> CAEmitterLayer {
        
        let emitter = CAEmitterLayer()
        //postition set in vc
        emitter.emitterShape = kCAEmitterLayerLine
        
        //cells - the thing to emit.
        emitter.emitterCells = generateEmitterCells()
        
        return emitter
        
    }
    
    static func generateEmitterCells() -> [CAEmitterCell] {
        
        var cells = [CAEmitterCell]()
        
        //array of colours - now using icon image so no longer accurate, but effect is correct
        let colours = [UIColor(red:0.95, green:0.40, blue:0.27, alpha:1.0),
                       UIColor(red:1.00, green:0.78, blue:0.36, alpha:1.0),
                       UIColor(red:0.48, green:0.78, blue:0.64, alpha:1.0),
                       UIColor(red:0.30, green:0.76, blue:0.85, alpha:1.0),
                       UIColor(red:0.58, green:0.39, blue:0.55, alpha:1.0)]
        
        for colour in colours {
            cells.append(createCells())
        }
        
        return cells
        
    }
    
    //configuring the cells
    //lots of properties available
    //https://developer.apple.com/documentation/quartzcore/caemitterlayer
    static func createCells() -> CAEmitterCell {
        let cell = CAEmitterCell()
        
        let intensity = Float(0.8)
        
        cell.contents = #imageLiteral(resourceName: "silver-emitter.png").cgImage
        cell.birthRate = 15 * intensity
        cell.lifetime = 20 * intensity
        
        cell.lifetimeRange = 0
        cell.velocity = CGFloat(350.0 * intensity)
        cell.velocityRange = CGFloat(80.0 * intensity)
        
        //sends cells down
        //cell.emissionLongitude = (180 * (.pi/180))
        cell.emissionLongitude = CGFloat(Double.pi)
        //creates more dynamic feel
        cell.emissionRange = CGFloat(Double.pi)
        cell.spin = CGFloat(3.5 * intensity)
        
        //adjust size
        cell.spinRange = CGFloat(4.0 * intensity)
        cell.scaleRange = CGFloat(intensity)
        cell.scaleSpeed = CGFloat(-0.1 * intensity)
        
//        cell.color = colour.cgColor
        
        return cell
    }
    
}

