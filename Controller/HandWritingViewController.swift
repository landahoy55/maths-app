//
//  HandWritingViewController.swift
//  maths-app
//
//  Created by P Malone on 22/03/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//

import UIKit
import Vision //Vision frame work combines CoreML, classificaion models and images/video
//https://developer.apple.com/documentation/vision/classifying_images_with_vision_and_core_ml

class HandWritingViewController: UIViewController {

    //Outlets
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var timerProgressView: UIProgressView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var canvas1: CanvasView!
    @IBOutlet weak var canvas2: CanvasView!
    @IBOutlet weak var recognisedLabel: UILabel!
    
    @IBOutlet weak var correctLabel: UILabel!
    @IBOutlet weak var helpLabel: UILabel!
    
    var subTopic: SubTopic?
    var currentQuestion: Question!
    var questionIndex = 0
    var timer = Timer()
    
    var canvases = [CanvasView]() //to loop over canvases
    var requests = [VNRequest]() //to store requests
    var possibleAnswer: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        canvases.append(canvas1)
        canvases.append(canvas2)
        
        startTimer()
        loadQuestions()
        visionModelSetUp()
        
        correctLabel.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //fade out label... using dispatchAfter. Could use a timer
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            
            UIView.animate(withDuration: 0.5, animations: {
                self.helpLabel.alpha = 0
            })
            
        }
    }
    
    func visionModelSetUp() {
        
        //load in model - MNIST is a pretrained model allowing for handwriting characters to be recongised
        guard let visionModel = try? VNCoreMLModel(for: MNIST().model) else { fatalError("Not able to load model") }
        
        //Request for image analysis - completion handler for request
        let classificationRequest = VNCoreMLRequest(model: visionModel, completionHandler: self.handleClassification)
        
        //tidying
        self.requests.removeAll()
        self.requests = [classificationRequest]
    }
    
    func handleClassification(request: VNRequest, error: Error?) {
        
        //request contains an array of results, type ANY - what has been observed
        guard let observations = request.results else { print("no results"); return }
        print("Observations ********", observations)
        
        //results are in order by confidence. Needs to be cast as an observation to get at properties.
        let classification = observations.first as! VNClassificationObservation
        let classificationIdentity = classification.identifier
        print("Classified", classificationIdentity)
    
        //push result var
        possibleAnswer += classificationIdentity
        
        //display - move back to main thread as per documentation
        DispatchQueue.main.async {
            //Configure label
            self.recognisedLabel.text = self.possibleAnswer
            //check answer
            self.checkAnswer(possibleAnswer: self.possibleAnswer)
        }
    
    }
    
    //Model requires a 28 x 28 monochrome images.
    //Convert canvas into 28 x 28 images.
    func performRequest(canvas: CanvasView) {
        
        print("PERFORMING REQUEST")
        
        //create image from view
        let image = UIImage(view: canvas)
        //scale to 28 x 28 as per model
        let scaledImage = scaleImage(image: image, toSize: CGSize(width: 28, height: 28))
        
        //Invert colour - model prefers black background
        //https://developer.apple.com/library/content/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html#//apple_ref/doc/filter/ci/CIColorMonochrome
        let imageToinvert = CIImage(image: scaledImage)
        guard let filter = CIFilter(name: "CIColorInvert") else { print("issue with filter"); return }
        filter.setValue(imageToinvert, forKey: kCIInputImageKey)
        let imageToRequest = convertCIImageToCGImage(inputImage: filter.outputImage!)
        //create
        
        //prepare request
        let imageRequestHandler = VNImageRequestHandler(cgImage: imageToRequest!, options: [:])
        
        //do it!
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
    
    func checkAnswer(possibleAnswer: String) {
        
        if possibleAnswer == currentQuestion.correctAnswer {
            questionIndex += 1
            loadQuestions()
            clear()
            
            //animate correct label
            UIView.animate(withDuration: 1, animations: {
                self.correctLabel.alpha = 1
            }, completion: { (success) in
                UIView.animate(withDuration: 1, animations: {
                    self.correctLabel.alpha = 0
                })
            })
           
        } else {

            //falling through here as two requests are being processed - for each canvas.
            //Use a flag, or process answer in a different way?
            
            //clear()
            
            //animate help label
//            UIView.animate(withDuration: 0.5, animations: {
//                self.helpLabel.alpha = 1
//                self.helpLabel.text = "Try exaggerating each character"
//            }, completion: { (success) in
//                UIView.animate(withDuration: 0.5, animations: {
//                    self.helpLabel.alpha = 0
//                })
//            })
            
        }
        
    }
    
    
    //MARK: Set up
    func loadQuestions() {
        if let subT = subTopic {
            print("**** SUBTOPIC AVAILABLE *****")
            questionIndex < subT.questions.count ? setQuestionLayout() : close()
        }
    }
    
    func setQuestionLayout() {
        currentQuestion = subTopic?.questions[questionIndex]
        questionLabel.text = currentQuestion.question
        scoreLabel.text = String(questionIndex)
    }
    
    func startTimer() {
        timerProgressView.tintColor = timerGreen
        timerProgressView.trackTintColor = UIColor.white
        timerProgressView.progress = 1.0
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTimerProgress), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimerProgress(){
        
        timerProgressView.progress -= 0.01/30
        
        //countdown timer - not 100% accurate
        let countdown = Int((timerProgressView.progress / 3.33) * 100)
        countdownLabel.text = String(countdown)
        
        if timerProgressView.progress <= 0 {
            print("Out of time")
            close()
        } else if timerProgressView.progress <= 0.2 {
            
            timerProgressView.progressTintColor = timerRed
        } else if timerProgressView.progress <= 0.5 {
            timerProgressView.progressTintColor = timerOrange
        }
    }
    
    func close() {
        timer.invalidate()
        dismiss(animated: true, completion: nil)
    }
    
    func clear() {
        //if content is in canvas clear
        for canvas in canvases {
            if canvas.path != nil {
                canvas.clearCanvas()
            }
        }
        
        //reset
        possibleAnswer = ""
        recognisedLabel.text = possibleAnswer
        
        //reset vision - may not be necessary.
        visionModelSetUp()
    }
    
    @IBAction func confirmButtonTapped(_ sender: UIButton) {
        
        
        
        for (index, canvas) in canvases.enumerated() {
            
            print("CANVAS :", index)

            //first time - blank canvas may be nil - no result captured.
            if canvas.path != nil {
                
                print("CANVAS IS EMPTY:", canvas.path.cgPath.isEmpty)
                
                //check to see if empty - canvas paths are nil if blank
                //allowing users to write in either canvas
                if canvas.path.cgPath.isEmpty == false {
                    performRequest(canvas: canvas)
                    //answer checked following request
                }
            }
        }
        
    }
    
    @IBAction func clearButtonTapped(_ sender: UIButton) {
    
        clear()
    
    }
    
    //Helper methods
    //models requires 28 x 28
    func scaleImage (image: UIImage, toSize size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        return newImage!
    }
    
    //No initaliser to create CGImage from CIImage - CIImages are data - not for presentation
    func convertCIImageToCGImage(inputImage: CIImage) -> CGImage? {
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(inputImage, from: inputImage.extent) {
            return cgImage
        }
        return nil
    }

}
