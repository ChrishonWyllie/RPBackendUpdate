//
//  AppDelegate.swift
//  RedPlanetTest
//
//  Created by Chrishon Wyllie on 6/8/17.
//  Copyright © 2017 Chrishon Wyllie. All rights reserved.
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        // Enable LocalDataStore()
        Parse.enableLocalDatastore()
        
        /*
         MARK: - Parse; Client Configuration
         • AWS EC2 Instance Server
         • Database hosted on MLAB
         */
        let configuration = ParseClientConfiguration {
            $0.applicationId = "mvFumzoAGYENJ0vOKjKB4icwSCiRiXqbYeFs29zk"
            $0.clientKey = "f3YjXEEzQYU8jJq7ZQIASlqxSgDr0ZmpfYUMFPuS"
            $0.server = "http://parseserver-48bde-env.us-east-1.elasticbeanstalk.com/parse/"
        }
        Parse.initialize(with: configuration)
        
        loginWithParse()
        
        return true
    }
    
    private func loginWithParse() {
        PFUser.logInWithUsername(inBackground: "chrisw",
                                 password: "password") {
                                    (user: PFUser?, error: Error?) in
                                    if user != nil {
                                        
                                        //print("logged in successfully")
                                        //print("user object: \(String(describing: user))")
                                        
                                    } else {
                                        print(error?.localizedDescription as Any)
                                        // Show error
                                        //self.showError()
                                    }
        }
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

