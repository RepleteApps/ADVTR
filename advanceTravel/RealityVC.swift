//
//  RealityVC.swift
//  advanceTravel
//
//  Created by Ranjit Mahto on 25/10/17.
//

import UIKit
import SceneKit
import MapKit
import CocoaLumberjack
import ARCL
import EasyTipView
//import CoreLocation

//@available(iOS 11.0, *)
class RealityVC: UIViewController, MKMapViewDelegate, SceneLocationViewDelegate,EasyTipViewDelegate {
    
    let sceneLocationView = SceneLocationView()
    let arMapView = MKMapView()
    var userAnnotation: MKPointAnnotation?
    var locationEstimateAnnotation: MKPointAnnotation?
    var updateUserLocationTimer: Timer?
    var placeMark: CLPlacemark!
    
    ///Whether to show a map view
    ///The initial value is respected
    var showMapView: Bool = false
    var centerMapOnUserLocation: Bool = true
    var showTipView: Bool = false
    var tipView : EasyTipView!
    var tipTouchView = UIView()
    var timer: Timer!
    
    ///Whether to display some debugging data
    ///This currently displays the coordinate of the best location estimate
    ///The initial value is respected
    var displayDebugging = true
    var updateInfoLabelTimer: Timer?
    var adjustNorthByTappingSidesOfScreen = false
    var selLatitute = Double()
    var selLongitute = Double()
    
    @IBOutlet weak var infoLabel:UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
//        updateInfoLabelTimer = Timer.scheduledTimer(
//            timeInterval: 0.1,
//            target: self,
//            selector: #selector(self.updateInfoLabel),
//            userInfo: nil,
//            repeats: true)
        
        //Set to true to display an arrow which points north.
        //Checkout the comments in the property description and on the readme on this.
        sceneLocationView.orientToTrueNorth = true
        
        sceneLocationView.locationEstimateMethod = .mostRelevantEstimate
        
        //sceneLocationView.showAxesNode = true
        sceneLocationView.locationDelegate = self
        sceneLocationView.showFeaturePoints = true
        
//        if displayDebugging {
//            sceneLocationView.showFeaturePoints = true
//        }
        
        //self.setUpMapView()
        view.addSubview(sceneLocationView)
        self.setupLocationForSceneView()
    }
    
    func setupLocationForSceneView()
    {
        let coordinate = CLLocationCoordinate2D(latitude:self.selLatitute , longitude: self.selLongitute)
        let location = CLLocation(coordinate: coordinate, altitude: 200)
        let image = UIImage(named: "pin")!
        
        let annotationNode = LocationAnnotationNode(location: location, image: image)
        annotationNode.scaleRelativeToDistance = true
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
        
        updateUserLocationTimer = Timer.scheduledTimer(
            timeInterval: 0.5,
            target: self,
            selector: #selector(self.updateUserLocation),
            userInfo: nil,
            repeats: true)
    }
    
    func setUpMapView()
    {
        //Currently set to Canary Wharf
        let pinCoordinate = CLLocationCoordinate2D(latitude: self.selLatitute, longitude: self.selLongitute)
        let pinLocation = CLLocation(coordinate: pinCoordinate, altitude: 236)
        let pinImage = UIImage(named: "pin")!
        let pinLocationNode = LocationAnnotationNode(location: pinLocation, image: pinImage)
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: pinLocationNode)
        
       
        if showMapView
        {
            arMapView.delegate = self
            arMapView.showsUserLocation = true
            arMapView.alpha = 0.8
            view.addSubview(arMapView)
            
            updateUserLocationTimer = Timer.scheduledTimer(
                timeInterval: 0.5,
                target: self,
                selector: #selector(self.updateUserLocation),
                userInfo: nil,
                repeats: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DDLogDebug("run")
        sceneLocationView.run()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        DDLogDebug("pause")
        // Pause the view's session
        sceneLocationView.pause()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sceneLocationView.frame = CGRect(
            x: 0,
            y: 60,
            width: self.view.frame.size.width,
            height: self.view.frame.size.height - 60)
        
        infoLabel.frame = CGRect(x: 6, y: 0, width: self.view.frame.size.width - 12, height: 14 * 4)
        
        
        if showMapView
        {
            infoLabel.frame.origin.y = (self.view.frame.size.height / 2) - infoLabel.frame.size.height
        } else {
            infoLabel.frame.origin.y = self.view.frame.size.height - infoLabel.frame.size.height
        }
        
        arMapView.frame = CGRect(
            x: 0,
            y: self.view.frame.size.height / 2,
            width: self.view.frame.size.width,
            height: self.view.frame.size.height / 2)
        
    }
    
    @objc func updateUserLocation()
    {
        
        if let currentLocation = sceneLocationView.currentLocation() {
            DispatchQueue.main.async {
                
                /*
                if let bestEstimate = self.sceneLocationView.bestLocationEstimate(),
                    let position = self.sceneLocationView.currentScenePosition() {
                    DDLogDebug("")
                    DDLogDebug("Fetch current location")
                    DDLogDebug("best location estimate, position: \(bestEstimate.position), location: \(bestEstimate.location.coordinate), accuracy: \(bestEstimate.location.horizontalAccuracy), date: \(bestEstimate.location.timestamp)")
                    DDLogDebug("current position: \(position)")
                    
                    let translation = bestEstimate.translatedLocation(to: position)
                    
                    DDLogDebug("translation: \(translation)")
                    DDLogDebug("translated location: \(currentLocation)")
                    DDLogDebug("")
                }*/
                
                if self.userAnnotation == nil
                {
                    self.userAnnotation = MKPointAnnotation()
                    self.arMapView.addAnnotation(self.userAnnotation!)
                }
                
                UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
                    self.userAnnotation?.coordinate = currentLocation.coordinate
                }, completion: nil)
                
                if self.centerMapOnUserLocation {
                    UIView.animate(withDuration: 0.45, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
                        self.arMapView.setCenter(self.userAnnotation!.coordinate, animated: false)
                    }, completion: {
                        _ in
                        self.arMapView.region.span = MKCoordinateSpan(latitudeDelta: 0.0005, longitudeDelta: 0.0005)
                    })
                }
                
                /*
                if self.displayDebugging
                {
                    let bestLocationEstimate = self.sceneLocationView.bestLocationEstimate()
                    
                    if bestLocationEstimate != nil {
                        if self.locationEstimateAnnotation == nil {
                            self.locationEstimateAnnotation = MKPointAnnotation()
                            self.mapView.addAnnotation(self.locationEstimateAnnotation!)
                        }
                        
                        self.locationEstimateAnnotation!.coordinate = bestLocationEstimate!.location.coordinate
                    } else {
                        if self.locationEstimateAnnotation != nil {
                            self.mapView.removeAnnotation(self.locationEstimateAnnotation!)
                            self.locationEstimateAnnotation = nil
                        }
                    }
                }
                */
            }
        }
        
    }
    
    @objc func updateInfoLabel()
    {
        if let position = sceneLocationView.currentScenePosition() {
            infoLabel.text = "x: \(String(format: "%.2f", position.x)), y: \(String(format: "%.2f", position.y)), z: \(String(format: "%.2f", position.z))\n"
        }
        
        if let eulerAngles = sceneLocationView.currentEulerAngles() {
            infoLabel.text!.append("Euler x: \(String(format: "%.2f", eulerAngles.x)), y: \(String(format: "%.2f", eulerAngles.y)), z: \(String(format: "%.2f", eulerAngles.z))\n")
        }
        
//        if let heading = sceneLocationView.locationManager.heading,
//            let accuracy = sceneLocationView.locationManager.headingAccuracy {
//            infoLabel.text!.append("Heading: \(heading)º, accuracy: \(Int(round(accuracy)))º\n")
//        }
        
        let date = Date()
        let comp = Calendar.current.dateComponents([.hour, .minute, .second, .nanosecond], from: date)
        
        if let hour = comp.hour, let minute = comp.minute, let second = comp.second, let nanosecond = comp.nanosecond {
            infoLabel.text!.append("\(String(format: "%02d", hour)):\(String(format: "%02d", minute)):\(String(format: "%02d", second)):\(String(format: "%03d", nanosecond / 1000000))")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        super.touchesBegan(touches, with: event)
        
        if let touch = touches.first {
            if touch.view != nil
            {
                if (arMapView == touch.view! ||
                    arMapView.recursiveSubviews().contains(touch.view!)) {
                    centerMapOnUserLocation = false
                }
                else if (tipView == touch.view!)
                {
                    print("Tap on tip view")
                    self.showTipView = false
                }
                else
                {
                    let location = touch.location(in: self.view)
                    
                    if location.x <= 40 && adjustNorthByTappingSidesOfScreen
                    {
                        print("left side of the screen")
                        sceneLocationView.moveSceneHeadingAntiClockwise()
                    }
                    else if location.x >= view.frame.size.width - 40 && adjustNorthByTappingSidesOfScreen
                    {
                        print("right side of the screen")
                        sceneLocationView.moveSceneHeadingClockwise()
                    }
                    else
                    {
                        let image = UIImage(named: "pin")!
                        let annotationNode = LocationAnnotationNode(location: nil, image: image)
                        annotationNode.scaleRelativeToDistance = true
                    sceneLocationView.addLocationNodeForCurrentPosition(locationNode: annotationNode)
                    }
                    
                    self.showCurrentLocationPopUp( touthPoint:location)
                }
            }
        }
    }
    
    func showCurrentLocationPopUp(touthPoint:CGPoint)
    {
        if let currentLocation = sceneLocationView.currentLocation()
        {
            print(currentLocation.coordinate.latitude , currentLocation.coordinate.longitude)
            
            let geoCoder = CLGeocoder()
            
            geoCoder.reverseGeocodeLocation(currentLocation, completionHandler: { (placemarks, error) -> Void in
                
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                let pm = placemarks! as [CLPlacemark]
                
                if pm.count > 0
                {
                    let pm = placemarks![0]
                    print(pm.country ?? "No Country")
                    print(pm.locality ?? "No Locality")
                    print(pm.subLocality ?? "No SubLocality")
                    print(pm.thoroughfare ?? "No ThrouhgFare")
                    print(pm.postalCode ?? "No PostalCode")
                    print(pm.subThoroughfare ?? "No SubThroufare")
                    
                    var addressString : String = ""
                    if pm.subLocality != nil {
                        addressString = addressString + pm.subLocality! + ", "
                    }
                    
                    if pm.thoroughfare != nil {
                        addressString = addressString + pm.thoroughfare! + ", "
                    }
                    if pm.locality != nil {
                        addressString = addressString + pm.locality! + ", "
                    }
                    if pm.country != nil {
                        addressString = addressString + pm.country! + ", "
                    }
                    if pm.postalCode != nil {
                        addressString = addressString + pm.postalCode! + " "
                    }
                    
                    print(addressString)
                
                    if self.showTipView == false
                    {
                        self.createAndShowPopUp(address: addressString, touchPoint: touthPoint)
                    }
                    else
                    {
                        self.tipView.dismiss(withCompletion: {
                            
                            self.showTipView = false
                            self.createAndShowPopUp(address: addressString, touchPoint: touthPoint)
                           
                        })
                    }
                }
            })
        }
    }
    
    func createAndShowPopUp(address:String, touchPoint:CGPoint)
    {
        var preferences = EasyTipView.Preferences()
        preferences.drawing.font = UIFont(name: "Futura-Medium", size: 13)!
        preferences.drawing.foregroundColor = UIColor.white
        preferences.drawing.backgroundColor = UIColor(hue:0.46, saturation:0.99, brightness:0.6, alpha:1)
        preferences.drawing.arrowPosition = EasyTipView.ArrowPosition.top
        
        /*
         * Optionally you can make these preferences global for all future EasyTipViews
         */
        
//        EasyTipView.globalPreferences = preferences
//
//        EasyTipView.show(forView: self.view,
//                         withinSuperview: self.navigationController?.view,
//                         text: "Tip view inside the navigation controller's view. Tap to dismiss!",
//                         preferences: preferences,
//                         delegate: self)
        
        tipTouchView.frame = CGRect(x: touchPoint.x, y: touchPoint.y, width: 30, height: 30)
        tipTouchView.backgroundColor = UIColor.clear
        
        sceneLocationView.addSubview(tipTouchView)
        
        tipView = EasyTipView(text: address, preferences: preferences, delegate:self)
        tipView.show(forView: tipTouchView, withinSuperview: self.navigationController?.view)
        
         self.showTipView = true
         self.resetAndStartTimer()
    }

    func easyTipViewDidDismiss(_ tipView: EasyTipView) {
        self.stopTimer()
    }
    
    //MARK: MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        if let pointAnnotation = annotation as? MKPointAnnotation
        {
            let marker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)
            
            if pointAnnotation == self.userAnnotation {
                marker.displayPriority = .required
                marker.glyphImage = UIImage(named: "user")
            } else {
                marker.displayPriority = .required
                marker.markerTintColor = UIColor(hue: 0.267, saturation: 0.67, brightness: 0.77, alpha: 1.0)
                marker.glyphImage = UIImage(named: "compass")
            }
            
            return marker
        }
        
        return nil
    }
    
    //MARK: SceneLocationViewDelegate
    
    func sceneLocationViewDidAddSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
        DDLogDebug("add scene location estimate, position: \(position), location: \(location.coordinate), accuracy: \(location.horizontalAccuracy), date: \(location.timestamp)")
    }
    
    func sceneLocationViewDidRemoveSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
        DDLogDebug("remove scene location estimate, position: \(position), location: \(location.coordinate), accuracy: \(location.horizontalAccuracy), date: \(location.timestamp)")
    }
    
    func sceneLocationViewDidConfirmLocationOfNode(sceneLocationView: SceneLocationView, node: LocationNode) {
        
    }
    
    func sceneLocationViewDidSetupSceneNode(sceneLocationView: SceneLocationView, sceneNode: SCNNode) {
        
    }
    
    func sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: SceneLocationView, locationNode: LocationNode) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func btnDissmissTap(_ sender: Any) {
        
        if self.showTipView == true
        {
            self.tipView.dismiss()
            self.stopTimer()
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func resetAndStartTimer()
    {
        if timer == nil
        {
            timer = Timer.scheduledTimer(timeInterval:5, target: self, selector: #selector(self.autoHideTipView), userInfo: nil, repeats: false)
        }
    }
    
    // MARK: Stop Timer
    func stopTimer()
    {
        if timer != nil
        {
            timer.invalidate()
            timer = nil
        }
    }
    
    func autoHideTipView()
    {
        self.tipView.dismiss(withCompletion: {
            self.showTipView = false
        })
    }
    
} // class


extension DispatchQueue {
    func asyncAfter(timeInterval: TimeInterval, execute: @escaping () -> Void) {
        self.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(timeInterval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: execute)
    }
}

extension UIView {
    func recursiveSubviews() -> [UIView] {
        var recursiveSubviews = self.subviews
        
        for subview in subviews {
            recursiveSubviews.append(contentsOf: subview.recursiveSubviews())
        }
        
        return recursiveSubviews
    }
}

