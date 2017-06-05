//
//  LoginViewController.swift
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

class LoginViewController: UIViewController {
    
    static private var FeatherPadURL = URL(string: "https://featherpad.herokuapp.com")!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var loginButton: LoginButton!
    @IBOutlet weak var signUpButton: LoginButton!
    @IBOutlet weak var learnMoreButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // When the user has tapped logged-in.
    @IBAction func loginButtonTapped(_ sender: Any) {
        SVProgressHUD.show()
        User.loginUser(withUsername: self.usernameTextField.text, password: self.passwordTextField.text, success: { 
            // Move to logged-in VC.
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let mainVC = mainStoryboard.instantiateInitialViewController()
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.present(mainVC!, animated: true, completion: nil)
            }
        }) { (error: Error?) in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                SVProgressHUD.showError(withStatus: error?.localizedDescription)
            }
        }
    }
    
    @IBAction func learnMoreButtonTapped(_ sender: Any) {
        UIApplication.shared.open(LoginViewController.FeatherPadURL, options: [:], completionHandler: nil)
    }
}
