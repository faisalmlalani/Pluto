//
//  LoginController.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 6/26/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import UIKit
import Firebase
import Hue

class LoginController: UIViewController {

    // MARK: - UI Components
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        // Turn the status bar white.
        return .lightContent
    }
    
    let addProfilePicImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "add_profile_pic")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    lazy var loginRegisterSegmentedControl: UISegmentedControl = {
        
        let segmentedControl = UISegmentedControl(items: ["Login", "Register"])
        segmentedControl.tintColor = UIColor.white
        // Start the control with the "Register" item highlighted.
        segmentedControl.selectedSegmentIndex = 1
        segmentedControl.addTarget(self, action: #selector(handleLoginRegisterSegmentChange), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        return segmentedControl
    }()
    
    func handleLoginRegisterSegmentChange() {
        
        // Grab the title of the selected control index and capitalize it.
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)?.uppercased()
        // Set the title to the button text.
        loginRegisterButton.setTitle(title, for: .normal)
        
        // Change the height of inputsContainerView.
        inputsContainerViewHeightAnchor?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 : 150
        
        // Show/hide the usernameTextField by manipulating the height anchor's multiplier.
        usernameTextFieldHeightAnchor?.isActive = false
        usernameTextFieldHeightAnchor = usernameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/3)
        usernameTextFieldHeightAnchor?.isActive = true
        
        // We also need to show/hide the placeholder text and the usernameSeperatorView.
        usernameTextField.placeholder = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? "" : "@username"
        usernameSeperatorView.alpha = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1
        
        // Modify the email and password fields so they take up more or less space in inputsContainerView to adjust for the usernameTextField.
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
    }
    
    /// A view for the login and register text fields.
    let inputsContainerView: UIView = {
        
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        // The corner radius will not take effect if the following line is not added:
        view.layer.masksToBounds = true
        
        return view
    }()
    
    let usernameTextField: UITextField = {
        
        let textField = UITextField()
        textField.placeholder = "@username"
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
    }()
    
    let usernameSeperatorView: UIView = {
        
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let emailTextField: UITextField = {
        
        let textField = UITextField()
        textField.placeholder = "email@something.com"
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
    }()
    
    let emailSeperatorView: UIView = {
        
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let passwordTextField: UITextField = {
        
        let textField = UITextField()
        textField.placeholder = "password"
        textField.translatesAutoresizingMaskIntoConstraints = false
        // Hide the text in the field.
        textField.isSecureTextEntry = true
        
        return textField
    }()
    
    lazy var loginRegisterButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.white
        button.setTitle("REGISTER", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(UIColor.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(handleLoginOrRegister), for: .touchUpInside)
        
        return button
    }()
    
    func handleLoginOrRegister() {
        
        // Check the segmented control to decide whether to log in or register.
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            
            handleLogin()
            
        } else {
            
            handleRegister()
        }
    }
    
    func handleLogin() {
        
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            
            print("ERROR: the text fields are invalid.")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if error != nil {
                
                print("ERROR: there was an error logging in. Details: \(error.debugDescription)")
                return
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func handleRegister() {
        
        guard let email = emailTextField.text, let password = passwordTextField.text, let username = usernameTextField.text else {
            
            print("ERROR: the text fields are invalid.")
            return
        }
        
        // Authenticate the new user using Firebase.
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            
            if error != nil {
                
                print("ERROR: something went wrong while creating the account. Details: \(error.debugDescription)")
                return
            }
            
            guard let uid = user?.uid else {
                
                print("ERROR: could not get user ID.")
                return
            }
            
            // Create a dictionary of values to add to the database.
            let values = ["username": username,
                          "email": email]
            
            DataService.ds.REF_USERS.child(uid).updateChildValues(values, withCompletionBlock: { (error, reference) in
                
                if error != nil {
                    
                    print("ERROR: could not authenticate the user with Firebase. Details: \(error.debugDescription)")
                }
                
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    // MARK: - View Configuration
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change the background color of the view using the Hue library.
        let gradient = [UIColor(red: 255, green: 89, blue: 49), UIColor(red: 240, green: 49, blue: 126)].gradient()
        gradient.bounds = view.bounds
        gradient.frame = view.frame
        view.layer.insertSublayer(gradient, at: 0)
        
        // view.backgroundColor = UIColor.black
        
        // Add the UI components.
        view.addSubview(addProfilePicImageView)
        view.addSubview(loginRegisterSegmentedControl)
        view.addSubview(inputsContainerView)
        view.addSubview(loginRegisterButton)
        
        // Set up the constraints.
        setUpProfileImageView()
        setUpLoginRegisterSegmentedControl()
        setUpInputsContainerView()
        setUpLoginRegisterButton()
    }
    
    /**
        Adds constaints to the inputsContainerView.
     */
    func setUpProfileImageView() {
        
        // Add X, Y, width, and height constraints to the profileImageView.
        addProfilePicImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        addProfilePicImageView.bottomAnchor.constraint(equalTo: loginRegisterSegmentedControl.topAnchor, constant: -12).isActive = true
        addProfilePicImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        addProfilePicImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    /**
        Adds constaints to the loginRegisterSegmentedControl.
     */
    func setUpLoginRegisterSegmentedControl() {
        
        // Add X, Y, width, and height constraints to the loginRegisterSegmentedControl.
        loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
        loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 25).isActive = true
    }
    
    // These needs to be declared here so we can change them with the segmented control.
    var inputsContainerViewHeightAnchor: NSLayoutConstraint?
    var usernameTextFieldHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    
    /**
        Adds constaints to the inputsContainerView.
    */
    func setUpInputsContainerView() {
    
        // Add X, Y, width, and height constraints to the inputsContainerView.
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputsContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputsContainerViewHeightAnchor?.isActive = true
        
        // Add the username, email, and password fields, along with their seperators, to the view.
        inputsContainerView.addSubview(usernameTextField)
        inputsContainerView.addSubview(usernameSeperatorView)
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailSeperatorView)
        inputsContainerView.addSubview(passwordTextField)
        
        // Add X, Y, width, and height constraints to the usernameTextField.
        usernameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        usernameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        usernameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        usernameTextFieldHeightAnchor = usernameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        usernameTextFieldHeightAnchor?.isActive = true
        
        // Add X, Y, width, and height constraints to the usernameSeperatorView.
        usernameSeperatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        usernameSeperatorView.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor).isActive = true
        usernameSeperatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        usernameSeperatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // Add X, Y, width, and height constraints to the emailTextField.
        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        // Add X, Y, width, and height constraints to the emailSeperatorView.
        emailSeperatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailSeperatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeperatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailSeperatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // Add X, Y, width, and height constraints to the passwordTextField.
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
        
        // Set the delegates of the text fields.
        usernameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    /**
     Adds constaints to the loginRegisterButton.
     */
    func setUpLoginRegisterButton() {
        
        // Add X, Y, width, and height constraints to the loginRegisterButton.
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
}

extension LoginController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == usernameTextField {
            
            // Add an @ to the beginning of the username.
            textField.text = "@"
        }
    }
}

extension UIColor {
    
    convenience init(red: CGFloat, green: CGFloat, blue: CGFloat) {
        
        self.init(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}
