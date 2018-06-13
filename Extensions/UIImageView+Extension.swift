//
//  UIImageView+Extension.swift
//  maths-app
//
//  Created by P Malone on 11/05/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    
    //get url, if not use default image
    func downloadImageFromURL(imgURL: String?) {
        guard let imageURL = imgURL else {
            self.image = UIImage(named: "Silver.png")
            return
        }
        
        //put on background thread to work async - not lock up UI
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: URL(string: imageURL)!)
            
            //put back on main thread
            DispatchQueue.main.async {
                print("DATA...", data as Any)
                //show image defaul.
                self.image = data != nil ? UIImage(data: data!) : UIImage(named: "Silver.png")
            }
        }
    }
}
