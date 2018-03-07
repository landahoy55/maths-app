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
    var topics = [Topic]()
    
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
        
        //download topics and get user information
        dataService.getAllTopics()
        dataService.getUserInformation()
        
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
                
//                let subtopicresults = SubtopicResult(achieved: "true", score: "5", subtopic: "5a954a498956bf2b2d1a5ef0", id: "5a8c2933e9d05f0014df2b44")
//                dataService.postNewSubtopicResult(subtopicresults, completion: { (success) in
//                    print(success)
//                })
//
//                 let topicResult = TopicResult(achieved: "true", topic: "5a954a498956bf2b2d1a5ef0", id: "5a8c2933e9d05f0014df2b44", subTopicResults: ["5a8c2933e9d05f0014df2b44"])
//                  dataService.postNewTopicResult(topicResult, completion: { (success) in
//                     print(success)
//                   })
                
//                dataService.getSubTopicResults("5a8c2933e9d05f0014df2b44", completion: { (success) in
//                    print(success)
//                })
                
                dataService.getTopicResult("5a8c2933e9d05f0014df2b44", completion: { (success) in
                    print(success)
                })
        
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
    
    //Now using a button on screen - remove
    @IBAction func helpButton(_ sender: UIButton) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let helpPopUp = sb.instantiateViewController(withIdentifier: "Help")
        present(helpPopUp, animated: true, completion: nil)
    }
    

}

//data service delegate
extension HomeViewController: DataServiceDelegate {
    
    func topicsLoaded() {
        //subTopics = dataService.downloadedTopics[0].subTopics
        topics = dataService.downloadedTopics
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
        
        return topics.count
    }
    
    //Configure cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "menuCell", for: indexPath) as! menuCellCollectionViewCell
        
        cell.titleLabel.text = topics[indexPath.row].title
        cell.descriptionLabel.text = topics[indexPath.row].description
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("CELL TAPPED\(indexPath.row)")
        subTopics = topics[indexPath.row].subTopics
        performSegue(withIdentifier: "subTopicMenuSegue", sender: self)
    }
    
}
