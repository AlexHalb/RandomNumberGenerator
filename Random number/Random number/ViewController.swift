//
//  ViewController.swift
//  Random number
//
//  Created by Alex Halbesleben on 1/13/19.
//  Copyright © 2019 Alex Halbesleben. All rights reserved.
//

import UIKit
import CoreLocation
import CoreMotion

class ViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {
    @IBOutlet weak var num: UILabel!
    @IBOutlet weak var Digits: UITextField!
    @IBOutlet weak var generate: UIButton!
    var mm : CMMotionManager!
    var digitsWanted = 0
    var locx = 0
    var locy = 0
    var locationManager : CLLocationManager!
    var stringBase = ""
    var touchData = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        //setting up the location
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        //setting up motion
        mm = CMMotionManager()
        mm.startDeviceMotionUpdates()
        //Touching the generate button calls returnDigits()
        generate.addTarget(self, action: #selector(returnDigits), for: .touchUpInside)
    }
    @objc func returnDigits(){
        //Getting the value in the text field and converting it to an integer
        digitsWanted = Int(Digits.text ?? "5") ?? 5
        let result = generateNum(len: digitsWanted)
        num.text = result
    }
    fileprivate func extractedFunc() {
        stringBase = stringBase.filter("0123456789".contains)
    }
    
    func generateNum(len:Int)->String {
        //Getting date
        let date = Double(NSDate().timeIntervalSince1970)
        //Setting up battery monitoring
        let currentDevice = UIDevice.current
        currentDevice.isBatteryMonitoringEnabled = true
        //Getting the battery level
        let device = Double(currentDevice.batteryLevel) * 100
        //Getting the device motion
        let data = mm.deviceMotion
        //A number based on the combined pitch, roll, and yaw of the device
        let intData = Int(((data?.attitude.pitch)!+5)*((data?.attitude.roll)!+5)*((data?.attitude.yaw)!+5))
        //appending the date to the final result
        stringBase.append(String(Int(date)))
        //Storing the battery level as an int
        let batteryAsString = Int(device)
        let motionAsString = intData
        var hasher = Hasher()
        hasher.combine(String(motionAsString))
        hasher.combine(String(batteryAsString))
        hasher.finalize()
        while stringBase.count <= 600 {
            stringBase.append("\(motionAsString)")
            stringBase.append("\(batteryAsString)")
            stringBase.hash(into: &hasher)
            stringBase.append(String(Int(date))+String(locx)+String(locy))
            stringBase.hash(into: &hasher)
            stringBase.append(String(UIDevice.current.name.hashValue))
            stringBase.append(touchData)
            stringBase.hash(into: &hasher)
            stringBase.append("\(motionAsString)")
            stringBase.append("\(batteryAsString)")
            stringBase.hash(into: &hasher)
            stringBase.append(String(Int(date))+String(locx)+String(locy))
            stringBase.hash(into: &hasher)
            stringBase.append(String(UIDevice.current.name.hashValue))
            stringBase.append(touchData)
            stringBase.hash(into: &hasher)
            stringBase = stringBase.filter("0123456789".contains)
        }
        print(stringBase.count)
        //trimming to fit how many digits the user wants
        stringBase.removeFirst(stringBase.count-len)
        print(stringBase) //Prints the number to the console for future use
        //returning the number
        return stringBase
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let loc :CLLocation = locations[0] as CLLocation
        //Storing the location for future use
        locx = Int(loc.coordinate.latitude)
        locy = Int(loc.coordinate.longitude)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            touchData.append(String(Int(touch.location(in: view).x)))
            touchData.append(String(Int(touch.location(in: view).y)))
        }
    }
}

