//
//  AppDelegate.swift
//  Bondzu
//
//  Created by Luis Mariano Arobes on 03/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//
//TODO versión 2. Manejar picture in picture y screens externas
import UIKit
import Parse
import Bolts
import Stripe
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        Parse.enableLocalDatastore();
        Parse.setApplicationId("7aGqZRDKBITfaIRAXq2oKoBkuWkhNqJZJWmf318I",
            clientKey: "lwOEFDvVC8SsM4Nl86YBzrkDOlOw8WHCyqu4UpBe");
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        Stripe.setDefaultPublishableKey(Constantes.STRIPE_PLUBISHABLE_KEY)
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication:  sourceApplication, annotation: annotation)
        
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }
    
    func applicationWillTerminate(application: UIApplication) {
        
    }
    
    
    
}

