//
//  ViewController.swift
//  safeDistance
//
//  Created by Pawan Sharma on 25/05/2020.
//  Copyright © 2020 Pawan Sharma. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth
import AudioToolbox

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var uuid = UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")
    var locationManager:CLLocationManager = CLLocationManager()
    var peripheralManager:CBPeripheralManager = CBPeripheralManager()
    var previousProximity:CLProximity? = .unknown
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }

    @IBAction func startButtonPress(_ sender: UIButton) {
        advertiseDevice()
        // Vibrate only if the status has changed - DONE
        // Run App in background, see why minimizing to maximizing not working
        // Disappear the button and write text called Monitoring, on clicking START
        // Put Google Ad
        // Create App Icon
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    scanBeakons()
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        print(beacons.count)
        for beacon:CLBeacon in beacons {
            print(beacon.proximity.rawValue)
        }
        
        let filteredBeacon = beacons.filter({$0.proximity != .unknown})
        let firstBeacon = filteredBeacon.first
        
        let currentProximity = firstBeacon?.proximity
        
        if(currentProximity != previousProximity) {
            if(currentProximity == .immediate) {
                self.view.backgroundColor = UIColor.red
                vibrate(count:3)
            } else if(currentProximity == .near) {
                self.view.backgroundColor = UIColor.orange
                vibrate(count:2)
            } else {
               self.view.backgroundColor = UIColor.white
                vibrate(count:1)
            }
        }
        
        previousProximity = currentProximity
    }

    func scanBeakons() {
        let constraint = CLBeaconIdentityConstraint(uuid: uuid!)
        let region = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: "Covid Region")
        locationManager.startMonitoring(for: region)
        locationManager.startRangingBeacons(satisfying: constraint)
    }
    
    func advertiseDevice() {
        print("Advertising device")
        if peripheralManager.state == .poweredOn {
            let constraint = CLBeaconIdentityConstraint(uuid: uuid!)
            let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: "Covid Region")
            let peripheralData = beaconRegion.peripheralData(withMeasuredPower: nil)
            peripheralManager.startAdvertising(((peripheralData as NSDictionary) as! [String : Any]))
        } else {
            let button = UIButton(type: .custom)
            button.setTitle("Please turn on bluetooth", for: .normal)
            button.addTarget(self, action: #selector(didClick), for: .touchUpInside)
        }
    }

    @objc func didClick(){
        _ = CBCentralManager(delegate: nil, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey:true])
    }
    
    func vibrate(count: Int) {
        if count == 0 {
            return
        }
        AudioServicesPlaySystemSoundWithCompletion(kSystemSoundID_Vibrate) { [weak self] in
            self?.vibrate(count: count - 1)
        }
    }
}

