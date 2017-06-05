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
    fileprivate var readings: [TempHumReading]?
    private var refreshControl: UIRefreshControl?
    
    @IBOutlet weak var navigationTitleContainerView: UIView!
    @IBOutlet weak var navigationTitleImageView: UIImageView!
    @IBOutlet weak var navigationTitleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "History"
        self.historyTableView.dataSource = self
        self.navigationTitleLabel.text = FeatherPadDevice.currentSelectedDevice?.name ?? "Nick"
        SVProgressHUD.show()
        self.loadReadings()
        self.setUpRefreshControl()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setUpRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.backgroundColor = UIColor.clear
        self.refreshControl!.addTarget(self, action: #selector(self.loadReadings), for: .valueChanged)
        self.historyTableView.refreshControl = self.refreshControl
    }
    
    @objc private func loadReadings() {
        // Load the currently-selected device's readings.
        guard let device = FeatherPadDevice.currentSelectedDevice else {
            print("No devices!")
            return
        }
        device.updateDeviceReadings(success: { (tempHum: [TempHumReading]?, alerts: [ForcePadAlert]?) in
            if let _ = tempHum {
                self.readings = tempHum
                self.historyTableView.reloadData()
            }
            SVProgressHUD.dismiss()
            self.refreshControl?.endRefreshing()
        }, failure: { (error: Error?) in
            SVProgressHUD.dismiss()
            self.refreshControl?.endRefreshing()
            // Do something with error.
        })
    }
    
    @IBAction func unwindFromSwitchDevices(sender: UIStoryboardSegue) {
        self.navigationTitleLabel.text = FeatherPadDevice.currentSelectedDevice?.name ?? "Sam"
        SVProgressHUD.show()
        self.loadReadings()
    }
    
    @IBAction func logoutBarButtonItemTapped(_ sender: UIBarButtonItem) {
        User.logoutCurrentUser(completion: nil)
    }
    
    @IBAction func userTappedTitleNavigationView(_ sender: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "toSwitchDevice", sender: self)
    }
}

extension HistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.historyTableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell") as! HistoryTableViewCell
        cell.readingInfo = self.readings?[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.readings?.count ?? 0
    }
}
