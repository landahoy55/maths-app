//
//  MenuViewController.swift
//  maths-app
//
//  Created by P Malone on 20/02/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var onboardingScrollView: UIScrollView!
    @IBOutlet weak var onboardingPageControl: UIPageControl!
    
    //TODO: replace with view model or pList - dict is working
    //image name matches asset folder
    let onboardingScreen1 = ["title":"Practice Maths","tagLine":"Sign up to personalise your experience","image":"icon"]
    let onboardingScreen3 = ["title":"Achieve Medals","tagLine":"Try to achieve gold, silver or bronze","image":"Medals"]
    let onboardingScreen4 = ["title":"Sign Up Now","tagLine":"Keep track of your progress over time","image":"Graph"]
    
    //dictionary of strings.
    var onboardingArray = [Dictionary<String,String>]()
    
    //once
    override func viewDidLoad() {
        super.viewDidLoad()

        onboardingArray = [onboardingScreen1, onboardingScreen3, onboardingScreen4]
        
        //scroll views have visible size, and content size.
        onboardingScrollView.isPagingEnabled = true
        onboardingScrollView.contentSize = CGSize(width: self.onboardingScrollView.frame.width * CGFloat(onboardingArray.count), height: self.onboardingScrollView.frame.height)
        onboardingScrollView.showsHorizontalScrollIndicator = false
        onboardingScrollView.showsVerticalScrollIndicator = false
        
        loadOnboarding()
        
        //set delegates
        onboardingScrollView.delegate = self
        
        //set gradient
        view.gradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
    }

    //each time screen is shown
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Move forward if authenticated
            //print(AuthorisationService.instance.isAuthenticated!)
        if AuthorisationService.instance.isAuthenticated == true {
            DataService.instance.getAllTopics()
            performSegue(withIdentifier: "toHomeVC", sender: nil)
            
        }
    }

    //loop over dict
    func loadOnboarding() {
        for (index, screen) in onboardingArray.enumerated() {
            //load nib - Cast to view.
            if let onboardingView = Bundle.main.loadNibNamed("onboarding", owner: self, options: nil)?.first as? onboardingView {
                onboardingView.imageView.image = UIImage(named: screen["image"]!)
                onboardingView.titleLbl.text = screen["title"]
                onboardingView.tagLineLbl.text = screen["tagLine"]
                
                onboardingScrollView.addSubview(onboardingView)
//                onboardingView.frame.size.width = 250
                onboardingView.frame.size.width = self.onboardingScrollView.bounds.size.width
                print("*******Frame width \(onboardingView.frame.size.width)")
//                onboardingView.frame.origin.x = CGFloat(index) * 250
                onboardingView.frame.origin.x = CGFloat(index) * self.onboardingScrollView.bounds.width
                print("*******Origin x \(onboardingView.frame.origin.x)")
                
            }
        }
    }
}

//scrollview delegate method
extension MenuViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / scrollView.frame.size.width
        onboardingPageControl.currentPage = Int(page)
    }
}
