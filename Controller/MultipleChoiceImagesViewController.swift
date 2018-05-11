//
//  MultipleChoiceImagesViewController.swift
//  maths-app
//
//  Created by P Malone on 11/05/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import UIKit

class MultipleChoiceImagesViewController: UIViewController {

    
    @IBOutlet weak var counter: UILabel!
    
    @IBOutlet weak var imageToDisplay: UIImageView!
    
    var count = 0
    
    let image: String = DataService.instance.downloadedTopics[4].subTopics[0].questions[0].imageurl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imageToDisplay.downloadImageFromURL(imgURL: image)
        counter.text = String(count)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    @IBAction func plusButton(_ sender: UIButton) {
        count += 1
        counter.text = String(count)
        
        
        
        let url = DataService.instance.downloadedTopics[4].subTopics[0].questions[count].imageurl!
        
        print(url)
        
        imageToDisplay.downloadImageFromURL(imgURL: url)
        
//        
    
    }
    
    @IBAction func minusButton(_ sender: UIButton) {
        count -= 1
        counter.text = String(count)
        
        let url = DataService.instance.downloadedTopics[4].subTopics[0].questions[count].imageurl!
        
        print(url)
        
        imageToDisplay.downloadImageFromURL(imgURL: url)
        
    }
    
    
    @IBAction func closeBtn(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
 

}
