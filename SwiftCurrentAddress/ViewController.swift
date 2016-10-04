//
//  ViewController.swift
//  SwiftCurrentAddress
//
//  Created by John Mac on 10/4/16.
//  Copyright © 2016 John Wetters. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController,MKMapViewDelegate,
CLLocationManagerDelegate {
    
    /******Outlets**********/
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func getAddress(_ sender: AnyObject) {
    }
    
    /******Outlets**********/
    
    //variables
    var measurement=0
    var measurementSave = 0
    var i=0
    var latitude=0.0
    var longitude=0.0
    var dropPin=true
    var lastDropPin=false
    let annotation = MKPointAnnotation()
    let placemarks = MKPlacemark()//init for placemark data
    var data : [String] = []
    let geocoder = CLGeocoder()
    var localText : String = ""
    var postalCode : String = ""
    var title1 : [String] = [""]
    var subTitle1 : [String] = [""]
    
    
    // MARK: - Properties
    
    lazy var locationManager : CLLocationManager = {
        
        let locationManager = CLLocationManager()
        
        //Set up location manager with defaults
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.delegate = self
        
        //Optimisation of battery
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.activityType = CLActivityType.fitness
        locationManager.allowsBackgroundLocationUpdates = false
        
        return locationManager
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager.requestWhenInUseAuthorization()
        
        self.locationManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - CLLocation didUpdateLocations
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations
        locations: [CLLocation])
    {
        let location = locations.last
        
        print("update last location \(measurement)")
        measurement += 1
        
        
        latitude=location!.coordinate.latitude
        longitude=location!.coordinate.longitude
        
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mapView.setRegion(region, animated: true)
        
        //add annotation
        if dropPin==true && localText=="" {
            
            CLGeocoder().reverseGeocodeLocation(location!, completionHandler: {(placemarks, error) -> Void in
                print(location)
                
                if error != nil {
                    print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                    return
                }
                
                if (placemarks?.count)! > 0 {
                    let pm = placemarks![0]
                    
                    self.localText=pm.locality!
                    self.postalCode=pm.postalCode!
                    print("pm=\(pm)")
                    
                    print("\nthoroughfare=\(pm.thoroughfare!)\n")
                    print("\nsubThoroughfare=\(pm.subThoroughfare!)\n")
                     print("\n locality=\(pm.locality!)\n")
                     //print("\nsubLocality=\(pm.subLocality!)\n")
                    print("\nadministrativeArea=\(pm.administrativeArea!)\n")
                    print("\nsubAdministrativeArea=\(pm.subAdministrativeArea!)\n")
                    print("\npostalCode=\(pm.postalCode!)\n")
                    print("\ncountry=\(pm.country!)\n")
                    print("\nISOcountryCode=\(pm.isoCountryCode!)\n")
                    self.title1=[ (pm.subThoroughfare!) +  " " + (pm.thoroughfare!)]
                    self.subTitle1=[ (pm.locality!) +   " , " + (pm.administrativeArea!) + " " ]
                    self.subTitle1.append(pm.postalCode!)
                }
                else {
                    print("Problem with the data received from geocoder")
                }
            })

           
            
            
        }
        if dropPin==false && lastDropPin==true {
            mapView.removeAnnotations([annotation])
            print("\nremove annotations\n")
        }
        
        //get location data
        
        if localText != "" {
            print("place=",localText)
            annotation.title =  self.title1.joined(separator: " ")
            annotation.subtitle=self.subTitle1.joined(separator: " ")
            annotation.coordinate = center
            mapView.addAnnotation(annotation)
            measurementSave=measurement
            print("\nadd annotation\n")
            print("\nmeasurementSaved=\(measurementSave)\n")
            
        }
        

        
        //var location = CLLocation(latitude: latitude, longitude: longitude) //changed!!!
        //print(location)
        
        
        
//        func reverseGeocodeLocation(_ location: CLLocation, completionHandler: [placemarks])
//        {
//        
//        if (placemarks != nil) {
//            
//            data.append(placemarks.subThoroughfare!)
//            data.append(placemarks.locality!)
//            data.append(placemarks.subThoroughfare!)
//            data.append(placemarks.subLocality!)
//            data.append(placemarks.administrativeArea!)
//            data.append(placemarks.subAdministrativeArea!)
//            data.append(placemarks.postalCode!)
//            data.append(placemarks.country!)
//             data.append(placemarks.isoCountryCode!)
//            
//            print("your location = \(data)")
//        }
//        }
        
        
        lastDropPin=dropPin
        //self.locationManager.stopUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == CLAuthorizationStatus.authorizedAlways {
            mapView.showsUserLocation = true
            mapView.userTrackingMode = MKUserTrackingMode.follow
            
            print("\nPermission Allowed\n")
        } else {
            print("\nPermission Refused\n")
        }
    }
    
    // MARK: - LocationManagerError
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error:Error)
    {
        print("Error: " + error.localizedDescription)
    }
    



}

