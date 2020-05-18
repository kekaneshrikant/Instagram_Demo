//
//  ViewController.swift
//  Instagram
//
//  Created by shrikant kekane on 14.05.20.
//  Copyright © 2020 shrikant kekane. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {
    
    @IBOutlet weak var emailTextView: UITextField!
    @IBOutlet weak var signupOrLoginButton: UIButton!
    @IBOutlet weak var switchLoginModeButton: UIButton!
    @IBOutlet weak var passwordTextView: UITextField!
    
    var signUpModeActive = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if PFUser.current() != nil {
            performSegue(withIdentifier: "showUserTable", sender: self)
        }
        
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func switchLoginMode(_ sender: UIButton) {
        
        if signUpModeActive {
            signUpModeActive = false
            signupOrLoginButton.setTitle("Log In", for: [])
            switchLoginModeButton.setTitle("Sign Up", for: [])
        } else {
            signUpModeActive = true
            signupOrLoginButton.setTitle("Sign Up", for: [])
            switchLoginModeButton.setTitle("Log In", for: [])
        }
    }
    
    @IBAction func signupOrLoginPressed(_ sender: UIButton) {
        
        if emailTextView.text == "" || passwordTextView.text == "" {
           displayAlert(withTitle: "Error in Form", andMessage: "Please Enter an Email and Password")
        } else {
            
            let activitySpinner = displaySpinner()
            
            if signUpModeActive {
                
                let user = PFUser()
                user.username = emailTextView.text
                user.password = passwordTextView.text
                user.email = emailTextView.text
                
                user.signUpInBackground { (success, error) in
                    activitySpinner.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                     if let error = error {
                        self.displayAlert(withTitle: "Sign Up Error!", andMessage: error.localizedDescription)
                        print(error)
                       } else {
                         print("Signed Up!")
                        self.performSegue(withIdentifier: "showUserTable", sender: self)
                       }
                }
                
                
                
            } else {
                
                PFUser.logInWithUsername(inBackground: emailTextView.text!, password: passwordTextView.text!) { (user, errorLogin) in
                    activitySpinner.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    if user != nil {
                        print("Login Successful")
                        self.performSegue(withIdentifier: "showUserTable", sender: self)
                    } else {
                        var errorText = "Unknown Error: please try again"
                        if let error = errorLogin {
                            errorText = error.localizedDescription
                        }
                        self.displayAlert(withTitle: "Log In Error", andMessage: errorText)
                    }
                }
            }
        }
    }
    
    func displayAlert(withTitle: String, andMessage: String) {
        let alert = UIAlertController(title: withTitle, message: andMessage, preferredStyle: .alert)
                   alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                       self.dismiss(animated: true, completion: nil)
            }))

        self.present(alert, animated: true, completion: nil)
    }
    
    
    func displaySpinner() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.medium
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        return activityIndicator
    }
    
    
}

