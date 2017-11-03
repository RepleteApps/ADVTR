

import Foundation
import UIKit
//import SwiftValidator
//import Alamofire
import KVNProgress
//import SwiftyDrop
import ReachabilitySwift

typealias responseHandler = (Any , Bool) -> Void
typealias alertResposeHandler = (String) -> Void

class GlobalFunc {
    
    class var sharedInstance: GlobalFunc {
        struct Singleton {
            static let instance = GlobalFunc()
        }
        return Singleton.instance
    }
    
    var deviceToken: String = String(Date().timeIntervalSince1970)
    var accessToken : String = ""
    var versionname : String = ""
    var UserAuthToken : String = ""
    var userName:String = ""
    var AuthExpiredMessage:String = ""
    var isAuthExpired:Bool = false
    var NeedToReloadHomePage:Bool = false
    var NeedToSyncContact:Bool = false
    var NeedMoreSync:Bool = false
    
    var NeedToReloadContacts:Bool = false
    var NeedToReloadGroups:Bool = false
    
    var CountryDailingCode:String = ""
    var arrASCTitle:[String] = []
    

    class func checkInternet() -> Bool
    {
        let reachability: Reachability
        reachability = Reachability()!
        let networkStatus: Int = reachability.currentReachabilityStatus.hashValue
        return networkStatus != 0
    }

    class func getDeviceId() -> String
    {
        let deviceID:String = UIDevice.current.identifierForVendor!.uuidString
        return deviceID
    }
    
    class func currentTimeStamp() -> Int64
    {
        let date = Date.init()
        let timeStamp = Int64(UInt64((date.timeIntervalSince1970 + 62_135_596_800) * 10_000_000))
        return timeStamp
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func convertDateFormat(dateStr:String)-> String
    {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC+0:00")
        let date = dateFormatter.date(from: dateStr)
        print(date ?? "") //Convert String to Date
        
        if let recievedDate = date
        {
            dateFormatter.dateFormat = "EEE,MMMM dd,YYYY 'at' hh:mm a"
            let newDate = dateFormatter.string(from: recievedDate)
            print(newDate)
            return newDate
        }
        return dateStr
    }

    func getAppDelegate() -> AppDelegate
    {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func saveObject(with key:String, value:Any)
    {
        if (value as AnyObject).isKind(of: Bool.self as! AnyClass )
        {
            if UserDefaults.standard.value(forKey: key) == nil
            {
                UserDefaults.standard.set(value, forKey: key)
            }
        }
        else if (value as AnyObject).isKind(of: String.self as! AnyClass )
        {
            UserDefaults.standard.set(value, forKey: key)
        }
        
        UserDefaults.standard.synchronize()
    }
    
    func getObject(with key:String) -> Any
    {
        guard let savedValue = UserDefaults.standard.object(forKey: key) else { return ""}
        
        if (savedValue as AnyObject).isKind(of: Bool.self as! AnyClass )
        {
            return savedValue as! Bool
        }
        
        return ""
    }
    
    func removeObjec(with key:String)
    {
        UserDefaults.standard.removeObject(forKey:key)
    }
    
    //MARK: AlertMessage Methods
    class func AlertMessage(alertTitle:String, alertMessage:String, controller : UIViewController){
        
        var Title = ""
        
        if alertTitle == ""
        {
            Title = Constants.APP_NAME
        }
        else
        {
            Title = alertTitle
        }
        
        let alertview : UIAlertController = UIAlertController(title: Title, message:  alertMessage ,preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertview.addAction(defaultAction)
        controller.present(alertview, animated: true) {

        }
    }
    
    class func AlertMessageWithOkResponse(alertTitle:String, alertMessage:String, controller : UIViewController, alertResposeHandler: @escaping alertResposeHandler){
        
        var Title = ""
        
        if alertTitle == ""
        {
            Title = Constants.APP_NAME
        }
        else
        {
            Title = alertTitle
        }
        
        let alertview : UIAlertController = UIAlertController(title: Title, message:  alertMessage ,preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: Constants.AlertOK, style: .default) { (defaultOK) in
            alertResposeHandler(Constants.AlertOK)
        }
        
        alertview.addAction(defaultAction)
        controller.present(alertview, animated: true) {
            
        }
    }
    
    class func AlertMessageWithOkCancelResponse(alertTitle:String, alertMessage:String, controller : UIViewController, alertResposeHandler: @escaping alertResposeHandler){
        
        var Title = ""
        
        if alertTitle == ""
        {
            Title = Constants.APP_NAME
        }
        else
        {
            Title = alertTitle
        }
        
        let alertview : UIAlertController = UIAlertController(title: Title, message:  alertMessage ,preferredStyle: .alert)
        
        let actionOk = UIAlertAction(title: Constants.AlertOK, style: .default) { (defaultOK) in
            alertResposeHandler(Constants.AlertOK)
        }
        
        let actionCancel = UIAlertAction(title: Constants.AlertCancel, style: .default) { (defaultOK) in
            alertResposeHandler(Constants.AlertCancel)
        }
        
        alertview.addAction(actionOk)
        alertview.addAction(actionCancel)
        
        controller.present(alertview, animated: true) {
            
        }
    }
        
    class func showFlashAlertWithTitle(message: String, alertType:String) {
        
        if alertType == "Success"
        {
            KVNProgress.showSuccess(withStatus: message)
        }
        else if alertType == "Error"
        {
            KVNProgress.showSuccess(withStatus: message)
        }
    }

    //MARK- Internet error
    class func showInternetConnectionError() {
        //GlobalData.showAlert(ALERT.DefaultTitle, message: INTERNET_ERROR)
    }
    
}

