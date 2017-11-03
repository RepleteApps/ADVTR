//
//  HomeVC.swift
//  advanceTravel
//
//  Created by Ranjit Mahto on 29/09/17.
//
//

import UIKit
import MapKit
import QuadratTouch
import Firebase

class HomeVC: UIViewController, UISearchBarDelegate,CLLocationManagerDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource
{
    
    @IBOutlet weak var lblLoginStatus: UILabel!
    @IBOutlet weak var navSearchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!

    var loginByCredntial = ""
    var locationManager  = CLLocationManager ()
    var str_latitude:String = String()
    var str_Logitude:String = String()
    var Arr_VenueResult:[Dictionary<String,Any>] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.showLoginByStatus(isShowStatus: false)
        tableView.isHidden = true
    }
    
    func logOut() -> Bool {
        
        if Auth.auth().currentUser != nil {
            
            do {
                
                try Auth.auth().signOut()
                return true
            }catch {
                return false
            }
        }
        
        return true
    }
    
    func showLoginByStatus(isShowStatus:Bool)
    {
        if isShowStatus {
            if loginByCredntial == UserLoginPageFlow.LoginByFB.rawValue
            {
                lblLoginStatus.text = "Login By Facebook"
            }
            else
            {
                lblLoginStatus.text = "Login By Google"
            }
        }
        else
        {
           lblLoginStatus.text = ""
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.navSearchBar.text = ""
        self.setUpLocationManager()
    }
    
    func setUpLocationManager()
    {
        self.locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    // MARK: Location manager Delegate Method
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        if status == .authorizedWhenInUse
        {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations.last
        
        let myLocation:CLLocationCoordinate2D = location!.coordinate
        print("locations = \(myLocation.latitude) \(myLocation.longitude)")
        str_latitude = "\(myLocation.latitude)"
        str_Logitude = "\(myLocation.longitude)"
        
        
        let span : MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let region : MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
        
        self.configNavigationSearchBar()
        //self.searchVenuesForKeyword(venue: "Cali")
        self.tableView.isHidden = true
        self.locationManager.startUpdatingLocation()
    }
    // MARK: - Private Methods -
    
    func searchVenuesForKeyword(venue:String)
    {
        if GlobalFunc.checkInternet() == false
        {
            GlobalFunc.showFlashAlertWithTitle(message: Constants.MsgInternetNotAvailable, alertType: Constants.errorAlert)
            return
        }
        else
        {
            self.locationManager.stopUpdatingLocation()
            
            let session = Session.sharedSession()
            let parameters = [Parameter.query:"\(venue)","ll": "\(str_latitude),\(str_Logitude)","limit": "50"]
            let searchTask = session.venues.search(parameters)
            {
                (result) -> Void in
                if result.response != nil
                {
                    print(result)
                    
                    var mainPlace:[String:AnyObject] = result.response!
                    if mainPlace["venues"] != nil {
                        print(mainPlace["venues"]!)
                        self.Arr_VenueResult = mainPlace["venues"] as! [Dictionary<String, Any>]
                        
                        if self.Arr_VenueResult.count > 0
                        {
                            self.tableView.delegate = self
                            self.tableView.dataSource = self
                            self.tableView.reloadData()
                            self.tableView.isHidden = false
                            self.locationManager.stopUpdatingLocation()
                        }
                        else
                        {
                            self.tableView.isHidden = true
                            self.locationManager.startUpdatingLocation()
                        }
                    }
                }
            }
            searchTask.start()
        }
        //searchController.searchBar.becomeFirstResponder()
    }
    
    @IBAction func navigationCancelButtonClicked()
    {
        self.dismiss(animated: true, completion: {
            self.locationManager.startUpdatingLocation()
        })
    }
    
    func configNavigationSearchBar()
    {
        //navSearchBar.sizeToFit()
        
        configPlaceholder(searchBar: navSearchBar)
        navSearchBar.delegate = self
        navSearchBar.showsCancelButton = false
        
        // Add the search bar to the navigationBar
        navigationItem.titleView = navSearchBar
        definesPresentationContext = true
    }
    
    func configPlaceholder(searchBar: UISearchBar)
    {
        let placeholder = "Search your location"
        let keyword = ""
        let range = (placeholder as NSString).range(of: keyword)
        
        let attributedString = NSMutableAttributedString(string: placeholder)
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blue, range: range)
        
        let searchTextField = searchBar.value(forKey: "searchField") as? UITextField
        searchTextField?.attributedPlaceholder = attributedString
    }
    
    // MARK: - UISearchResultsUpdating, UISearchBarDelegate
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        navSearchBar.placeholder = "Search your location"
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar)
    {
        configPlaceholder(searchBar: navSearchBar)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        print(searchBar.text!)
        
        if (searchBar.text?.characters.count)! == 0
        {
            //self.searchVenuesForKeyword(venue: "Cali")
            self.tableView.isHidden = true
            self.locationManager.startUpdatingLocation()
        }
        else if (searchBar.text?.characters.count)! > 2
        {
            self.searchVenuesForKeyword(venue: searchBar.text!)
            self.locationManager.stopUpdatingLocation()
        }
        else
        {
            if searchBar.text != ""
            {
                let firstChar = searchBar.text?.characters.first
                print(firstChar!)
                if firstChar! == " "
                {
                    searchBar.text = ""
                }
            }
        }
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        //self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
     func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.Arr_VenueResult.count
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        if !(cell != nil)
        {
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "Cell")
        }
        
        let dict:Dictionary<String,Any> = self.Arr_VenueResult[indexPath.row]
        
        cell?.textLabel?.text = (dict["name"] as! String)
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 15)
        cell?.textLabel?.textColor = UIColor(red: 92/255, green: 92/255, blue: 92/255, alpha: 1.0)
        
        if (dict["location"] as! Dictionary<String,Any>).index(forKey: "address") != nil
        {
            cell?.detailTextLabel?.text = ((dict["location"] as! Dictionary<String,Any>)["address"]! as! String)
            cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
            cell?.detailTextLabel?.textColor = UIColor(red: 135/255, green: 135/255, blue: 135/255, alpha: 1.0)
        }
        return cell!
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        var VenueDict:[String:Any] = [:]
        
        let dict:Dictionary<String,Any> = self.Arr_VenueResult[indexPath.row]
        
        print(dict)
        
        VenueDict["name"] = dict["name"]!
        VenueDict["latitude"] = (dict["location"] as! Dictionary<String,Any>)["lat"]!
        VenueDict["longitude"] = (dict["location"] as! Dictionary<String,Any>)["lng"]!
        VenueDict["fulladdress"] = (dict["location"] as! Dictionary<String,Any>)
        
        print(VenueDict)
        
        self.tableView.isHidden = true
        self.locationManager.startUpdatingLocation()
        
        let mainSB = UIStoryboard(name:"Main", bundle: nil)
        let realityvc:RealityVC = mainSB.instantiateViewController(withIdentifier: "RealityVC") as! RealityVC
       
        if let lat = VenueDict["latitude"] as? Double , let long = VenueDict["longitude"] as? Double
        {
            print("Selected Lat :\(lat) Long : \(long)")
            realityvc.selLatitute = lat
            realityvc.selLongitute = long
        }
        
         self.present(realityvc, animated: true, completion:nil)
//       self.navigationController?.dismiss(animated: true, completion: nil)
    }

    @IBAction func Action_DissmissVC(_ sender: Any) {
        
        GlobalFunc.AlertMessageWithOkCancelResponse(alertTitle: Constants.APP_NAME, alertMessage: "Are you sure you want to logout from application?", controller: self, alertResposeHandler: { (selectedTitle:String) in
            
            if selectedTitle == Constants.AlertOK{
                
                let isLogout:Bool = self.logOut()
                
                if isLogout == true {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            else if selectedTitle == Constants.AlertCancel{
                
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
