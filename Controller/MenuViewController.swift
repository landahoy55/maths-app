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
    
    //TODO: replace with view model or pList.
    let onboardingScreen1 = ["title":"Practice Everyday Maths","tagLine":"Sign up to personalise your experience","image":"onboarding1"]
    let onboardingScreen2 = ["title":"Try Daily Activities","tagLine":"New challenges released daily","image":"onboarding1"]
    let onboardingScreen3 = ["title":"Across Many Topics","tagLine":"Cover the major maths subjects","image":"onboarding1"]
    let onboardingScreen4 = ["title":"Sign Up Now","tagLine":"Keep track of your progress over time","image":"onboarding1"]
    
    //dictionary of strings.
    var onboardingArray = [Dictionary<String,String>]()
    
    //once
    override func viewDidLoad() {
        super.viewDidLoad()

        onboardingArray = [onboardingScreen1, onboardingScreen3, onboardingScreen4]
        
        //scroll views have visible size, and content size.
        onboardingScrollView.isPagingEnabled = true
        onboardingScrollView.contentSize = CGSize(width: self.view.frame.width * CGFloat(onboardingArray.count), height: 250)
        print(onboardingScrollView.contentSize)
        onboardingScrollView.showsHorizontalScrollIndicator = false
        onboardingScrollView.showsVerticalScrollIndicator = false
        print(onboardingScrollView.frame.width)
        
        loadOnboarding()
        
        //set delegates
        onboardingScrollView.delegate = self
        
        //set gradient
        view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
    }

    //each time screen is shown
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Move forward if authenticated
            //print(AuthorisationService.instance.isAuthenticated!)
        if AuthorisationService.instance.isAuthenticated == true {
            performSegue(withIdentifier: "toHomeVC", sender: nil)
        }
    }

    
    func loadOnboarding() {
        for (index, screen) in onboardingArray.enumerated() {
            //load nib - Cast to view.
            if let onboardingView = Bundle.main.loadNibNamed("onboarding", owner: self, options: nil)?.first as? onboardingView {
                onboardingView.imageView.image = UIImage(named: screen["image"]!)
                onboardingView.titleLbl.text = screen["title"]
                onboardingView.tagLineLbl.text = screen["tagLine"]
                
                onboardingScrollView.addSubview(onboardingView)
                onboardingView.frame.size.width = 250
                print(onboardingView.frame.size.width)
                onboardingView.frame.origin.x = CGFloat(index) * 250
            }
        }
    }
}

//scrollview delegate
extension MenuViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = onboardingScrollView.contentOffset.x / onboardingScrollView.frame.size.width
        onboardingPageControl.currentPage = Int(page)
    }
}
