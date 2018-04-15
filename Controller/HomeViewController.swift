//
//  HomeViewController.swift
//  maths-app
//
//  Created by P Malone on 20/02/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import UIKit
import AVFoundation

var correctSoundPlayer: AVAudioPlayer = AVAudioPlayer()
var wrongSoundPlayer: AVAudioPlayer = AVAudioPlayer()

class HomeViewController: UIViewController {

    @IBOutlet weak var activityBackgroundView: UIView!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    var dataService = DataService.instance
    var subTopics = [SubTopic]()
    var topics = [Topic]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()

        //set gradient
        //view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        
        //collectionview delegate conformance
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //Conform to data service to trigger reload
        dataService.delegate = self
        
        //download topics and get user information
        dataService.getAllTopics()
        
        //set up AV players
        let wrongURL = Bundle.main.url(forResource: "wrong", withExtension: "aiff")
        wrongSoundPlayer = try! AVAudioPlayer(contentsOf: wrongURL!)
        wrongSoundPlayer.prepareToPlay()
        
        let correctURL = Bundle.main.url(forResource: "correct", withExtension: "mp3")
        correctSoundPlayer = try! AVAudioPlayer(contentsOf: correctURL!)
        correctSoundPlayer.prepareToPlay()
        
        
        dataService.getUserId { (success) in
            if (success) {
                
                guard let id = UserDefaults.standard.string(forKey: DEFAULTS_USERID) else { return }
                
                self.dataService.getSubTopicResults(id, completion: { (success) in })
                self.dataService.getTopicResult(id, completion: { (success) in
                    self.dataService.getUserAccount(userId: id, completion: { (success) in
                        if let name = self.dataService.accountDetails?.name {
                            OperationQueue.main.addOperation {
                                self.nameLabel.text = "Welcome back \(name)"
                                self.activityIndicator.stopAnimating()
                                self.activityBackgroundView.removeFromSuperview()
                            }
                        }
                    })
                })
            }
        }
        
        //download challenge
        dataService.getDailyChallenge { (success) in }
        
        //set style of nav bar
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    //    override func viewDidAppear(_ animated: Bool) {
    //        print("*********** /nView did appear - Home screen")
    //        collectionView.reloadData()
    //    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("*********** /nView did appear - Home screen")
        collectionView.reloadData()
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
                //subTopicViewController.subTopicResults = dataService.downloadedSubTopicResults
                
            case "voiceSegue":
                let voiceInputViewController = segue.destination as! VoiceInputViewController
                voiceInputViewController.subTopic = DataService.instance.downloadedTopics[0].subTopics[0]
            
            
            case "handWritingSegue":
                let handWritingViewController = segue.destination as! HandWritingViewController
                handWritingViewController.subTopic = DataService.instance.downloadedTopics[0].subTopics[0]
            default:
                return
            }
        }
    }
    
    func topicStatus(topicTitle: String) -> Int {
        
        //loop over subtopic result for topic
        //return a string with number of achieved subtopics
        print("******** TOPIC TITLE \(topicTitle)")
        let results = dataService.downloadedTopicResults
        
        //find results related to topic - using funcional programming
        let specificResult = results.first(where: {$0.topic.title == topicTitle})
        
        print("****** FIND TOPIC RESULTS ***********")
        
        //optional
        print("****** \(String(describing: specificResult))")
        //loop over subtopic for count of achieved?
        
        var counter = 0
        if let specificResult = specificResult {
            for result in specificResult.subTopicResults {
                if result.achieved == true {
                    counter += 1
                }
            }
        }
        
        return counter
    }
    
    
    @IBAction func logOut(_ sender: UIButton) {
        AuthorisationService.instance.logOut()
        dismiss(animated: true, completion: nil)
    }
    
    
//    @IBAction func getTopicsBtn(_ sender: UIButton) {
//        topicsLoaded()
//    }
    
    
    @IBAction func handWritingButton(_ sender: UIButton) {
        performSegue(withIdentifier: "handWritingSegue", sender: self)
    }
    
    
    @IBAction func voiceButton(_ sender: UIButton) {
        
        performSegue(withIdentifier: "voiceSegue", sender: self)
    }
    
}

//Custom dataservice delegate - utilse elsewhere to force UI refresh, or retreive data.
extension HomeViewController: DataServiceDelegate {
    func topicResultsLoaded() {
        //quicker to run in completion block?
        OperationQueue.main.addOperation {
            self.collectionView.reloadData()
        }
    }
    
    
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
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "menuCell", for: indexPath) as! menuCollectionViewCell
        
        //could further reduce by creating a cell model.
        let title = topics[indexPath.row].title
        let description = topics[indexPath.row].description
        let numberAchieved = topicStatus(topicTitle: topics[indexPath.row].title)
        
        cell.configureCell(title: title, description: description, numberAchieved: numberAchieved)
        
        return cell
    }
    
    //tap to perform segue
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("CELL TAPPED\(indexPath.row)")
        subTopics = topics[indexPath.row].subTopics
        performSegue(withIdentifier: "subTopicMenuSegue", sender: self)
    }
    
}
