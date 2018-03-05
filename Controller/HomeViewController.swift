//
//  HomeViewController.swift
//  maths-app
//
//  Created by P Malone on 20/02/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {


    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nameLbl: UILabel!
    
    var dataService = DataService.instance
    var subTopics = [SubTopic]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        //Show name
        nameLbl.text = UserDefaults.standard.string(forKey: DEFAULTS_EMAIL)
        
        //set gradient
        //view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        
        //collectionview delegate conformance
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //Conform to data service to trigger reload
        dataService.delegate = self
        
        //download topics
        DataService.instance.getAllTopics()
        
        //set style of nav bar
        navigationController?.navigationBar.prefersLargeTitles = true
        //navigationController?.navigationBar.backgroundColor = .purple
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        //identifier added to storyboard segue
        if let identifier = segue.identifier {
            switch identifier {
            
            case "inputSegue":
              
                let inputQuizViewController = segue.destination as! InputAnswerViewController
                    inputQuizViewController.subTopic = DataService.instance.downloadedTopics[0].subTopics[0]
                
                
            case "multipleChoiceSegue":
                
                //is it safer to unwrap these?
                let multiChoiceViewController = segue.destination as! MultipleChoiceViewController
                multiChoiceViewController.subTopic = DataService.instance.downloadedTopics[0].subTopics[1]
            
            
            case "subTopicMenuSegue":
                let subTopicViewController = segue.destination as! SubTopicViewController
                subTopicViewController.subTopics = subTopics
            
            default:
                return
            }
        }
    }
    
    
    @IBAction func logOut(_ sender: UIButton) {
        AuthorisationService.instance.logOut()
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func getTopicsBtn(_ sender: UIButton) {
        topicsLoaded()
    }
    

}

//data service delegate
extension HomeViewController: DataServiceDelegate {
    func topicsLoaded() {
        subTopics = dataService.downloadedTopics[0].subTopics
        //back on main thread
        OperationQueue.main.addOperation {
            self.collectionView.reloadData()
        }
    }
}

//collection view delegates
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    //set number of sections
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //TODO: Replace with topics
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        print("TOPICS******** \(subTopics)")
        return subTopics.count
    }
    
    //Configure cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "menuCell", for: indexPath) as! menuCellCollectionViewCell
        
        cell.titleLabel.text = subTopics[indexPath.row].title
        cell.descriptionLabel.text = subTopics[indexPath.row].description
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("CELL TAPPED\(indexPath.row)")
        performSegue(withIdentifier: "subTopicMenuSegue", sender: self)
    }
    
}
