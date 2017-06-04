//
//  HistoryViewController.swift
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

class HistoryViewController: UIViewController {
    
    @IBOutlet weak var historyTableView: UITableView!
    fileprivate var devices: [FeatherPadDevice]?
    
    /// Mapping of device readings to a list of their temp/hum readings.
    lazy fileprivate var deviceReadings: [FeatherPadDevice: [TempHumReading]] = {
        return [FeatherPadDevice: [TempHumReading]]()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "History"
        self.devices = User.currentUser!.associatedDevices
        self.historyTableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadReadings()
    }
    
    private func loadReadings() {
        DispatchQueue.main.async {
            SVProgressHUD.show()
        }
        /// Need to get the reading for every device.
        let group = DispatchGroup()     // Use a dispatch group so that we can update once all requests for all devices complete.
        for device in self.devices! {
            var readingsForDevice: [TempHumReading]?
            group.enter()
            device.updateDeviceReadings(success: { (tempHum: [TempHumReading]?, alerts: [ForcePadAlert]?) in
                if let _ = tempHum {
                    readingsForDevice = tempHum
                    self.deviceReadings.updateValue(readingsForDevice!, forKey: device)
                    group.leave()
                }
            }, failure: { (error: Error?) in
                // Do something with error.
                group.leave()
            })
        }
        group.notify(queue: .main) {
            // This executes when all devices have finished loading their readings.
            self.historyTableView.reloadData()
            SVProgressHUD.dismiss()
        }
    }
    
    @IBAction func logoutBarButtonItemTapped(_ sender: UIBarButtonItem) {
        User.logoutCurrentUser(completion: nil)
    }
}

extension HistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.historyTableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell") as! HistoryTableViewCell
        let device = self.devices?[0]
        let readings = self.deviceReadings[device!]
        cell.readingInfo = readings?[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let device = self.devices?[0]
        let readings = self.deviceReadings[device!]
        return readings?.count ?? 0
    }
}
