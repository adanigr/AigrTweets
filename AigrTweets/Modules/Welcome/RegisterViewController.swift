//
//  RegisterViewController.swift
//  AigrTweets
//
//  Created by Adan Reséndiz on 15/06/20.
//  Copyright © 2020 Adan Reséndiz. All rights reserved.
//

import UIKit
import NotificationBannerSwift
import TextFieldEffects
import TransitionButton  // 1: First import the TransitionButton library
import SwiftValidator
import Simple_Networking
import SVProgressHUD

class RegisterViewController: UIViewController , ValidationDelegate, UITextFieldDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var registerButton: TransitionButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var namesTextField: UITextField!
    
    // MARK: Labels
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var namesErrorLabel: UILabel!
    
    
    let validator = Validator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Looks for single or multiple taps.
        self.hideKeyboardWhenTappedAround()
        
        // Do any additional setup after loading the view.
        setupUI()
        
        validator.styleTransformers(success:{ (validationRule) -> Void in
            print("here")
            // clear error label
            validationRule.errorLabel?.isHidden = true
            validationRule.errorLabel?.text = ""
            
            if let textField = validationRule.field as? UITextField {
                //textField.layer.borderColor = UIColor.green.cgColor
                //textField.layer.borderWidth = 0.5
                textField.underlined(color: UIColor.green)
            } else if validationRule.field is UITextView {
                //textField.layer.borderColor = UIColor.green.cgColor
                //textField.layer.borderWidth = 0.5
                //textField.underlined()
            }
        }, error:{ (validationError) -> Void in
            print("error")
            validationError.errorLabel?.isHidden = false
            validationError.errorLabel?.text = validationError.errorMessage
            if let textField = validationError.field as? UITextField {
                //textField.layer.borderColor = UIColor.red.cgColor
                //textField.layer.borderWidth = 1.0
                textField.underlined(color: UIColor.red)
            } else if validationError.field is UITextView {
                //textField.layer.borderColor = UIColor.red.cgColor
                //textField.layer.borderWidth = 1.0
            }
        })
        
        validator.registerField(emailTextField, errorLabel: emailErrorLabel, rules: [RequiredRule(), EmailRule()])
        
        validator.registerField(passwordTextField, errorLabel: passwordErrorLabel, rules: [RequiredRule()])
        
        validator.registerField(namesTextField, errorLabel: namesErrorLabel, rules: [RequiredRule()])
    }
    
    //MARK: - IBACtions
    @IBAction func registerButtonTouchUpInside(_ button: TransitionButton){
        //Hide Keyboard When Tapped Button
        view.endEditing(true)
        
        button.startAnimation() // 2: Then start the animation when the user tap the button
        
        validator.validate(self)
    }
    
    private func setupUI(){
        //registerButton.layer.cornerRadius = 25
    }
    
    private func performLogin(){
        //Get values from TextFields
        guard let email = self.emailTextField.text else { return }
        guard let password = self.passwordTextField.text else { return }
        guard let names = self.namesTextField.text else { return }
        
        //Create request
        let request = RegisterRequest(email: email, password: password, names: names)
        
        // Call network library
        SN.post(endpoint: Endpoints.register, model: request) { (response: SNResultWithEntity<LoginResponse, ErrorResponse>) in
            
            //Quit loading icon
            //SVProgressHUD.dismiss()
            
            switch response{
            case .success(let user):
                
                self.registerButton.stopAnimation(animationStyle: .expand, completion: {
                    //Show Home
                    self.performSegue(withIdentifier: "showHome", sender: nil)
                    
                    //set authentication tokek
                    SimpleNetworking.setAuthenticationHeader(prefix: "", token: user.token)
                    
                    NotificationBanner(subtitle: "Bienvenido \(user.user.names)", style: .success).show(queuePosition: .front, bannerPosition: .top, queue: .default)
                })
            case .error(let error):
                print("todo lo malo")
                print(error)
                self.registerButton.stopAnimation(animationStyle: .shake, completion:nil)
                NotificationBanner(title: "Error", subtitle: error.localizedDescription, style: .danger).show()
            //return
            case .errorResult(let entity):
                print("error pero no tan malo :)")
                print(entity)
                self.registerButton.stopAnimation(animationStyle: .shake, completion:nil)
                NotificationBanner(title: "Error", subtitle: entity.error, style: .warning).show(queuePosition: .front, bannerPosition: .top, queue: .default)
                //return
            }
        }
    }
    
    func validationSuccessful() {
        print("Validation SUCCESSFUL!")
        performLogin()
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        print("Validation FAILED!")
        registerButton.stopAnimation(animationStyle: .shake, completion:nil)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
