//
//  SwitchDeviceViewController.swift
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

class SwitchDeviceViewController: UIViewController {
    
    /// TableView holding all of the devices.
    @IBOutlet weak var switchDevicesTableView: UITableView!
    
    /// Devices registered to this user to allow them to switch.
    fileprivate var devices: [FeatherPadDevice]?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the views.
        self.devices = User.currentUser?.associatedDevices
        self.switchDevicesTableView.dataSource = self
        self.switchDevicesTableView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension SwitchDeviceViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.devices?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.switchDevicesTableView.dequeueReusableCell(withIdentifier: "devicesTableViewCell", for: indexPath) as! DevicesTableViewCell
        cell.deviceData = self.devices?[indexPath.row]
        return cell
    }
}

extension SwitchDeviceViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedDevice = self.devices?[indexPath.row]
        FeatherPadDevice.currentSelectedDevice = selectedDevice
        self.performSegue(withIdentifier: "unwindToHistory", sender: self)
    }
}
