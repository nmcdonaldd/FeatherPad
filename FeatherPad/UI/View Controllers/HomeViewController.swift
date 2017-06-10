//
//  HomeViewController.swift
//
//  Copyright © 2017 Team Exponent (https://featherpad.herokuapp.com)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit
import SVProgressHUD

class HomeViewController: UIViewController {

    @IBOutlet weak var titleNavigationLabel: UILabel!
    @IBOutlet weak var featherPadLeftSideWarningImageView: UIImageView!
    @IBOutlet weak var featherPadRightSideWarningImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: TemperatureHumidityLabel!
    @IBOutlet weak var humidityLabel: TemperatureHumidityLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.titleNavigationLabel.text = FeatherPadDevice.currentSelectedDevice?.name
        NotificationCenter.default.addObserver(forName: DeviceNotificationCenterOps.currentlySelectedDeviceDidChange.notification, object: nil, queue: .main) { (notification: Notification) in
            let selectedDevice = notification.object as! FeatherPadDevice
            self.titleNavigationLabel.text = selectedDevice.name
        }
        
        self.featherPadLeftSideWarningImageView.image = UIImage(cgImage: (self.featherPadRightSideWarningImageView.image?.cgImage)!, scale: (self.featherPadRightSideWarningImageView.image?.scale)!, orientation: UIImageOrientation.upMirrored)
        self.featherPadLeftSideWarningImageView.isHidden = true
        self.featherPadRightSideWarningImageView.isHidden = false
        
        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.getUpdatedReadings), userInfo: nil, repeats: true)
        
        SVProgressHUD.show()
        self.getUpdatedReadings()
    }
    
    @objc private func getUpdatedReadings() {
        guard let device = FeatherPadDevice.currentSelectedDevice else {
            return
        }
        
        device.updateDeviceReadings(success: { (newTempsHums: [TempHumReading]?, newAlerts: [ForcePadAlert]?) in
            // Update temp/hum labels.
            let newest = newTempsHums?.last
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.temperatureLabel.text = newest?.formattedTemperature
                self.humidityLabel.text = "\((newest?.humidityValue) ?? 18)%"
            }
        }) { (error: Error?) in
            // Nothing for now.
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func userTappedDeviceName(_ sender: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "toDeviceSelector", sender: self)
    }
    
    @IBAction func unwindFromSwitchDevices(sender: UIStoryboardSegue) {
        SVProgressHUD.show()
        self.getUpdatedReadings()
    }

}
