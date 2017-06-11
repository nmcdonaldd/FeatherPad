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
// Following are for the QRCodeReader.
import QRCodeReader
import AVFoundation

class SwitchDeviceViewController: UIViewController {
    
    /// QRReader.
    fileprivate lazy var reader: QRCodeReader = QRCodeReader()
    fileprivate lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode], captureDevicePosition: .back)
            $0.showTorchButton = true
        }
        return QRCodeReaderViewController(builder: builder)
    }()
    
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
        self.switchDevicesTableView.rowHeight = UITableViewAutomaticDimension
        self.switchDevicesTableView.estimatedRowHeight = 58
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addDeviceButtonTapped(_ sender: UIBarButtonItem) {
        self.readerVC.modalPresentationStyle = .overFullScreen
        self.readerVC.delegate = self
        self.present(self.readerVC, animated: true, completion: nil)
    }
}

extension SwitchDeviceViewController: QRCodeReaderViewControllerDelegate {
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        self.reader.stopScanning()
        self.dismiss(animated: true, completion: nil)
    }
    func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
        // Is this needed? Too bad there are no optional protocol methods in Swift natively :/
    }
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        self.reader.stopScanning()
        self.dismiss(animated: true) { [weak self] in
            guard let strongSelf = self else {
                return
            }
            let alert = UIAlertController(title: "Add New Device", message: "What's this device's name", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { (textField: UITextField) in
                textField.placeholder = "Ex: Timmy's Pad"
            })
            let okayAction = UIAlertAction(title: "Okay", style: .default, handler: { (action: UIAlertAction) in
                // Add the device to the user's account.
                let deviceName = alert.textFields?[0].text ?? "FeatherPad \(User.currentUser?.associatedDevices?.count ?? 1)"
                let deviceID = result.value
                SVProgressHUD.show()
                User.currentUser?.addDeviceWithID(deviceID, withName: deviceName, success: { (device: FeatherPadDevice?) in
                    SVProgressHUD.dismiss()
                    SVProgressHUD.showSuccess(withStatus: "New FeatherPad device added!")
                    strongSelf.devices = User.currentUser?.associatedDevices
                    strongSelf.switchDevicesTableView.reloadData()
                }, failure: { (error: Error?) in
                    SVProgressHUD.dismiss()
                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                })
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(okayAction)
            alert.addAction(cancelAction)
            strongSelf.present(alert, animated: true, completion: nil)
        }
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
