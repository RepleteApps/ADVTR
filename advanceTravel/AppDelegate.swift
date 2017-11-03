//
//  AppDelegate.swift
//  advanceTravel
//
//  Created by Ranjit Mahto on 27/09/17.
//
//

import UIKit
import Firebase
import FBSDKCoreKit
import IQKeyboardManagerSwift
import GoogleSignIn
import KVNProgress
import QuadratTouch

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Firebase
        FirebaseApp.configure()
        
        //Google
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        //Facebook
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        if let currentUser =  Auth.auth().currentUser
        {
            print(currentUser.displayName!)
        }
        
        // foursquare setup
        let client = Client(clientID: Constants.FSQ_CLIENT_ID, clientSecret:   Constants.FSQ_CLIENT_SECRET, redirectURL:"advtr://foursquare")
        var configuration = Configuration(client:client)
        configuration.mode = nil
        configuration.shouldControllNetworkActivityIndicator = true
        Session.setupSharedSessionWithConfiguration(configuration)
        
        // IQKeyboardManager
        IQKeyboardManager.sharedManager().enable = true
        
        // LocationManager
        LocationManager.sharedInstance.startUpdatingLocation()
        return true
    }

    func application(_ application: UIApplication, open url: URL,
                     sourceApplication: String?, annotation: Any) -> Bool {
        return Session.sharedSession().handleURL(url: url)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!)
    {
        if let err = error
        {
            print("Faile to login into Google", err)
            GlobalFunc.showFlashAlertWithTitle(message: Constants.GP_LOGIN_FAIL, alertType: Constants.errorAlert)
            return
        }
        
        KVNProgress.show(withStatus: "Veryfying user...")
        
        print("user login successfully with Google", user)
        
        guard let idToken = user.authentication.idToken else {return}
        guard let accessToken = user.authentication.accessToken else {return}
        
        let gpCredentails = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        Auth.auth().signIn(with: gpCredentails, completion: { (user, error) in
            
            if let err = error
            {
                print("Failed to create a Firbase User with Google account", err)
                GlobalFunc.showFlashAlertWithTitle(message: Constants.CREATE_FIR_USER_WITH_GP_FAIL, alertType: Constants.errorAlert)
                return
            }
            
            guard let uid = user?.uid else { return}
            print("Successfully logged into Firebase with Google", uid)
            GlobalFunc.showFlashAlertWithTitle(message: Constants.CREATE_FIR_USER_WITH_GP_SUCCESS,
                                               alertType: Constants.successAlert)
            
            NotificationCenter.default.post(name:NSNotification.Name(Constants.NOTIFY_USER_CREATED_BY_GOOGLE), object:nil , userInfo: nil)
        })
    }

    
    func applicationWillResignActive(_ application: UIApplication) {

    }

    func applicationDidEnterBackground(_ application: UIApplication) {

    }

    func applicationWillEnterForeground(_ application: UIApplication) {

    }

    func applicationDidBecomeActive(_ application: UIApplication) {

    }

    func applicationWillTerminate(_ application: UIApplication) {

    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool
    {
        
        let handle = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String , annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        GIDSignIn.sharedInstance().handle(url,
                                          sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                          annotation: [:])
        
        return handle
    }
    
//    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
//        
//        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
//    }

}

