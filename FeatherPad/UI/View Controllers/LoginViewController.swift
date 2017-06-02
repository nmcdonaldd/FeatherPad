//
//  LoginViewController.swift
//  FeatherPad
//
//  Created by Nick McDonald on 5/29/17.
//  Copyright © 2017 nickdonald. All rights reserved.
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
            SVProgressHUD.dismiss()
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let mainVC = mainStoryboard.instantiateInitialViewController()
            DispatchQueue.main.async {
                self.present(mainVC!, animated: true, completion: nil)
            }
        }) { (error: Error?) in
            SVProgressHUD.dismiss()
            SVProgressHUD.showError(withStatus: error?.localizedDescription)
        }
    }
    
    @IBAction func learnMoreButtonTapped(_ sender: Any) {
        UIApplication.shared.open(LoginViewController.FeatherPadURL, options: [:], completionHandler: nil)
    }
}
