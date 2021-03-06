//
//  HistoryTableView.swift
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

class HistoryTableViewCell: UITableViewCell {
    
    private static let greenColor = UIColor(red: 67/255, green: 160/255, blue: 71/255, alpha: 1.0)
    private static let warningColor = UIColor(red: 229/255, green: 57/255, blue: 52/255, alpha: 1.0)
    private static let normalTempColor = UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1.0)

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var statusColorView: UIView!
    
    var readingInfo: TempHumReading? {
        didSet {
            guard let readingInfo = self.readingInfo else {
                return
            }
            self.temperatureLabel.text = readingInfo.formattedTemperature
            self.humidityLabel.text = "\(readingInfo.humidityValue!)%"
            self.timeLabel.text = self.readingInfo?.relativeTimeStamp
            
            if readingInfo.isAboveThreshold {
                self.timeLabel.textColor = HistoryTableViewCell.warningColor
                self.temperatureLabel.textColor = HistoryTableViewCell.warningColor
                self.statusColorView.backgroundColor = HistoryTableViewCell.warningColor
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.temperatureLabel.textColor = HistoryTableViewCell.normalTempColor
        self.timeLabel.textColor = HistoryTableViewCell.greenColor
        self.statusColorView.backgroundColor = HistoryTableViewCell.greenColor
    }

}
