//
//  AppDelegate.swift
//  SVSAVPlayerSample
//
//  Created by Loïc GIRON DIT METAZ on 28/08/2019.
//  Copyright © 2019 Smart AdServer. All rights reserved.
//

import UIKit
import SVSVideoKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    var window: UIWindow?
    
    private let locationManager = CLLocationManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        /////////////////////////////////////////
        // TRACKING AUTHORIZATION
        /////////////////////////////////////////
        
        // Starting with iOS 14, the SDK need the user's consent before being able to access the IDFA.
        // Check the MasterViewController class to check how to request this consent…
        
        ////////////////////////////////////////////
        // SDK - Configuration
        // MANDATORY
        // You will not be able to start the AdManager without doing this.
        ////////////////////////////////////////////
        
        // Configure Smart Instream SDK with your SiteID
        SVSConfiguration.shared.configure(withSiteID: Constants.siteID)
        
        
        ////////////////////////////////////////////
        // SDK - Debugging
        // OPTIONAL
        // To help you trouble shooting the SDK
        ////////////////////////////////////////////
        
        // Set logging enabled for console logging of SDK events.
        // Note that you should disable the logging when pushing your application on the AppStore.
        SVSConfiguration.shared.loggingEnabled = true
        
        
        /////////////////////////////////////////////
        // SDK - Localization
        // OPTIONAL
        // You can set custom strings to be used by the SDK while displaying ads.
        // Please refer to the documentation for the complete HOW-TO.
        /////////////////////////////////////////////
        
        // Set the main bundle of the app as the source for localized strings.
        // SVSConfiguration.shared.stringsBundle = Bundle.main
        
        
        ////////////////////////////////////////////
        // SDK - User Location
        // OPTIONAL - Highly recommanded for monetization purposes.
        // It is recommanded that you request authorization for location detection if your app does not already request it
        // before integration of the Instream SDK.
        // If the user grants you the right to detect his location, the SDK will find it automatically and pass it to the ad server when making ad calls,
        // this will allow a better targeting and increase your RTB revenues.
        // Don't forget to setup the NSLocationWhenInUseUsageDescription key in your Info.plist.
        ////////////////////////////////////////////
        
        // Requesting the location when the app is in use.
        if (CLLocationManager.authorizationStatus() == .notDetermined
            || CLLocationManager.authorizationStatus() == .restricted
            || CLLocationManager.authorizationStatus() == .denied) {
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
        }

        // If you don't want the SDK to use the user's location automatically, you can disable the detection.
        // SVSConfiguration.shared.allowAutomaticLocationDetection = false
        
        // You can also set the location manually by passing a CLLocationCoordinate2D to the SDK.
        // SVSConfiguration.shared.manualLocation = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    
        
        /////////////////////////////////////////
        // SDK - TCF Compliance
        // OPTIONAL
        // By uncommenting the following code, you can set the TCF consent string manually.
        // As per IAB specifications in Transparency And Consent Framework.
        // Smart Instream SDK will retrieve the TCF consent string from the NSUserDefaults using the official IAB key "IABTCF_TCString"
        /////////////////////////////////////////
        // If you are using a CMP that is not validated by the IAB or not using the official key:
        // you will have to manually store the computed consent string into the NSUserDefaults for Smart Instream SDK to retrieve it and forward it to its partners.
        /////////////////////////////////////////
        // let myTCFConsentString = "yourTCFConsentStringBase64format"
        // UserDefaults.standard.set(myTCFConsentString, forKey: "IABTCF_TCString")
        // UserDefaults.standard.synchronize()
        
        /////////////////////////////////////////
        // SDK - CCPA Compliance
        // OPTIONAL
        // By uncommenting the following code, you can set the CCPA consent string manually.
        // As per IAB specifications in CCPA Compliance Framework.
        // Smart Instream SDK will retrieve the CCPA consent string from the NSUserDefaults using the official IAB key "IABUSPrivacy_String"
        /////////////////////////////////////////
        // If you are using a CMP that is not validated by the IAB or not using the official key:
        // you will have to manually store the computed consent string into the NSUserDefaults for Smart Instream SDK to retrieve it and forward it to its partners.
        /////////////////////////////////////////
        // let myCCPAConsentString = "yourCCPAConsentString";
        // UserDefaults.standard.set(myCCPAConsentString, forKey: "IABUSPrivacy_String")
        // UserDefaults.standard.synchronize()
        
        return true
    }
    
}

