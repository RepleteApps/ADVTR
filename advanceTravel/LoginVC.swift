//
//  LoginVC.swift
//  advanceTravel
//
//  Created by Ranjit Mahto on 27/09/17.
//
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import KVNProgress
import Firebase
import GoogleSignIn


class LoginVC: UIViewController, GIDSignInUIDelegate {
    
    @IBOutlet weak var btnFacebook: UIButton!
    @IBOutlet weak var btnGoogle: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.checkUserLogin()
    }
    
    func checkUserLogin()
    {
        if Auth.auth().currentUser != nil {
             KVNProgress.show(withStatus:"Veryfying User...")
            
            if let currentUser =  Auth.auth().currentUser
            {
                KVNProgress.dismiss(completion: {
                    
                    print(currentUser.displayName!)
                    
                    let mainSB = UIStoryboard(name:"Main", bundle: nil)
                    let homevc:HomeVC = mainSB.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                    homevc.loginByCredntial = UserLoginPageFlow.LoginByGP.rawValue
                    self.present(homevc, animated: true, completion:nil)
                })
            }
 
        }
        
    }
    
    @IBAction func Action_SignInWithFacebook(_ sender: Any) {
        
        if GlobalFunc.checkInternet() == false
        {
            KVNProgress.showError(withStatus:"Internt Conection Interrupted")
            return
        }
        else
        {
             self.loginWithFacebook()
        }
       
    }
    
    func loginWithFacebook()
    {
        
        let login: FBSDKLoginManager = FBSDKLoginManager()
        //        login.logOut()
        login.loginBehavior = FBSDKLoginBehavior.native
        
        let permissonCriteria:[Any] = ["public_profile","email"]
        
        login.logIn(withReadPermissions:permissonCriteria, from: self, handler: { (result: FBSDKLoginManagerLoginResult!, error) in
            
            if ((error) != nil)
            {
                let errorMessage = error?.localizedDescription
                print("Faile to login into Facebook", errorMessage!)
                GlobalFunc.showFlashAlertWithTitle(message: Constants.FB_LOGIN_FAIL, alertType: Constants.errorAlert)
                return
            }
            else if result.isCancelled
            {
                // Handle cancellations
                print("cancel by user")
                GlobalFunc.showFlashAlertWithTitle(message: Constants.FB_LOGIN_CANCEL_BY_USER, alertType: Constants.errorAlert)
                return
            }
            else
            {
                KVNProgress.show(withStatus: "Wait creating user...")
                
                print("user login successfully with Facebook with Token", result.token.tokenString)
                
                let fbCredential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                
                Auth.auth().signIn(with: fbCredential, completion: { (user, error) in
                    
                    KVNProgress.dismiss()
                    
                    if let err = error
                    {
                        print("Failed to create a Firbase User with Facebook account", err)
                        
                        KVNProgress.showError(withStatus: Constants.CREATE_FIR_USER_WITH_FB_FAIL + err.localizedDescription)
                        return
                    }
                    
                    guard let uid = user?.uid else { return}
                    print("Successfully logged into Firebase with Facebook", uid)
                    
                    KVNProgress.showSuccess(withStatus:Constants.FB_LOGIN_SUCCESS, completion: {
                        
                         self.showHomeScreen(loginBy: "FACEBOOK")
                    })

                })
            }
        })
    }
    
    @IBAction func Action_SignInWithGoogle(_ sender: Any) {
        
        if GlobalFunc.checkInternet() == false
        {
            KVNProgress.showError(withStatus:"Internt Conection Interrupted")
            return
        }
        else
        {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.goToHomeView),
                name: NSNotification.Name(Constants.NOTIFY_USER_CREATED_BY_GOOGLE),
                object: nil)
            
            GIDSignIn.sharedInstance().uiDelegate = self
            GIDSignIn.sharedInstance().signIn()
        }
    }
    
    func goToHomeView(notification:Notification)
    {
        KVNProgress.showSuccess(withStatus:Constants.GP_LOGIN_SUCCESS, completion: {
            self.showHomeScreen(loginBy: "GOOGLE")
        })
    }
    
    func showHomeScreen(loginBy:String)
    {
        let mainSB = UIStoryboard(name:"Main", bundle: nil)
        let homevc:HomeVC = mainSB.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        
        if loginBy == "GOOGLE" {
            homevc.loginByCredntial = UserLoginPageFlow.LoginByGP.rawValue
        }
        else{
            homevc.loginByCredntial = UserLoginPageFlow.LoginByFB.rawValue
        }
        self.present(homevc, animated: true, completion:nil)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
} // class
