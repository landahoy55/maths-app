//
//  GoldEmitter.swift
//  maths-app
//
//  Created by P Malone on 09/05/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import Foundation

import UIKit

//CA Emitter
//Ref - https://developer.apple.com/documentation/quartzcore/caemitterlayer

class GoldEmitter {
    
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
        
        //adding several cells
        cells.append(createCells())
        cells.append(createCells())
        cells.append(createCells())
        

        return cells
        
    }
    
    //configuring the cells
    //lots of properties available
    //https://developer.apple.com/documentation/quartzcore/caemitterlayer
    static func createCells() -> CAEmitterCell {
        let cell = CAEmitterCell()
        
        cell.contents = #imageLiteral(resourceName: "gold-emitter.png").cgImage
        cell.birthRate = 15
        cell.lifetime = 20
        
        cell.lifetimeRange = 0
        cell.velocity = CGFloat(350.0)
        cell.velocityRange = CGFloat(80.0)
        
        //sends cells down - pi used in docs
        cell.emissionLongitude = CGFloat(Double.pi)
        cell.emissionRange = CGFloat(Double.pi)
        cell.spin = CGFloat(3.5)
        
        //adjust size
        cell.spinRange = CGFloat(4.0)
        cell.scaleRange = CGFloat(1)
        cell.scaleSpeed = CGFloat(-0.1)
        
        
        return cell
    }
    
}
