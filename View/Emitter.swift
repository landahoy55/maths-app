//
//  Emitter.swift
//  emiiter
//
//  Created by P Malone on 15/03/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//


//CA Emitter
//Ref - https://developer.apple.com/documentation/quartzcore/caemitterlayer
import UIKit

class Emitter {
    
    //Emmiter layer and emitter cells.
    static func createEmitter() -> CAEmitterLayer {
        
        let emitter = CAEmitterLayer()
        //postition set in vc
        emitter.emitterShape = kCAEmitterLayerLine
        
        //cells - the thing to emit.
        emitter.emitterCells = createEmitterCells()
        
        return emitter
        
    }

    //some cells - three seems optimum
    static func createEmitterCells() -> [CAEmitterCell] {
        
        var cells = [CAEmitterCell]()
        
        cells.append(createCells())
        cells.append(createCells())
        cells.append(createCells())
        
        
        return cells
       
    }
    
    //configuring the cells
    //lots of properties available
    //Ref - https://developer.apple.com/documentation/quartzcore/caemitterlayer
    static func createCells() -> CAEmitterCell {
        let cell = CAEmitterCell()
        
        cell.contents = #imageLiteral(resourceName: "Icon-App-20x20@2x.png").cgImage
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
