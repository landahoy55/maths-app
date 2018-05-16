//
//  UNService.swift
//  maths-app
//
//  Created by P Malone on 12/03/2018.
//  Copyright © 2018 landahoy55. All rights reserved.
//


//User notification service - to add local notifications

import UIKit
import UserNotifications

class NotificationService: NSObject {
    
    //Create singleton - we only need instance
    //Requires override as NSObject
    private override init(){}
    static let instance = NotificationService()
    
    let userNotificationsCentre = UNUserNotificationCenter.current()
    
    //request user permissions
    func authorise() {
        
        //Set up authorisation options
        let options: UNAuthorizationOptions = [.alert, .sound]
        userNotificationsCentre.requestAuthorization(options: options) { (granted, error) in
            
            //If error is not nil use it, or use string
            print (error ?? "No UserNotification Error")
            
            guard granted else {
                //handle user denied.
                print("User denied access")
                return
            }
            
            //get back on main thread
            DispatchQueue.main.async {
                //configure
                self.configure()
            }
        }
    }
    
    
    func configure() {
       
        //conform to delegate
        userNotificationsCentre.delegate = self
        
        //register for remote notifications
        let app = UIApplication.shared //might need to case as delegate
        app.registerForRemoteNotifications()
    }
    
    //create notification based on timer
    func timerRequest(with interval: TimeInterval) {
        
        //Notifications need:
            //Content
            //Trigger
            //Request
        
        let content = UNMutableNotificationContent()
        content.title = "It's been a day!"
        content.body = "Time to test your maths skills 🤙"
        
        content.sound = .default()
        
        //repeat only works if over 60 seconds
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        
        let request = UNNotificationRequest(identifier: "userNotification.oneDay", content: content, trigger: trigger)
    
        userNotificationsCentre.add(request)
        
    }


}

//conform to delegate - will allow interactions with notifications
extension NotificationService: UNUserNotificationCenterDelegate {
    
    //Triggered when app is NOT in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("User Notif didRecieveResponse delegate method")
        
        completionHandler()
    }
    
    //Triggered when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("UserNotif will present delegate method")
        
        let options: UNNotificationPresentationOptions = [.alert, .sound]
        completionHandler(options)
    }
}
