//
//  AppDelegate.swift
//  SVSJWSample
//
//  Created by Loïc GIRON DIT METAZ on 29/08/2019.
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
        // SDK - GDPR Compliance
        // OPTIONAL
        // By uncommenting the following code, you can set the GDPR consent string manually.
        // As per IAB specifications in Transparency And Consent Framework:
        // https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework
        // Smart Instream SDK will retrieve the consent string from the NSUserDefaults using the official IAB key "IABConsent_ConsentString"
        /////////////////////////////////////////
        
        // let myConsentString = "yourCMPComputedConsentStringBase64format"
        // UserDefaults.standard.set(myConsentString, forKey: "IABConsent_ConsentString")
        // UserDefaults.standard.synchronize()
        
        return true
    }

}
