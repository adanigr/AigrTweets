//
//  LoginViewController.swift
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

class LoginViewController: UIViewController , ValidationDelegate, UITextFieldDelegate {
    //MARK: - Outlets
    @IBOutlet weak var loginButton: TransitionButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    //@IBOutlet private var textFields: [TextFieldEffects]!
    
    // MARK: Error Labels
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    
    /**
     Set this value to true if you want to see all the "firstName"
     textFields prepopulated with the name "Raul" (for testing purposes)
     */
    //let prefillTextFields = false
    let validator = Validator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTextField.text = "test1@test.com"
        self.passwordTextField.text = "qwerty"
        self.emailTextField.text = "adanigr@platzi.com"
        self.passwordTextField.text = "platzi"
        
        //Looks for single or multiple taps.
        self.hideKeyboardWhenTappedAround()
        
        // Do any additional setup after loading the view.
        //guard prefillTextFields == true else { return }
        
        //_ = textFields.map { $0.text = "Raul" }
        
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
            } else if let textField = validationRule.field as? UITextView {
                textField.layer.borderColor = UIColor.green.cgColor
                textField.layer.borderWidth = 0.5
            }
        }, error:{ (validationError) -> Void in
            print("error")
            validationError.errorLabel?.isHidden = false
            validationError.errorLabel?.text = validationError.errorMessage
            if let textField = validationError.field as? UITextField {
                //textField.layer.borderColor = UIColor.red.cgColor
                //textField.layer.borderWidth = 1.0
                textField.underlined(color: UIColor.red)
            } else if let textField = validationError.field as? UITextView {
                textField.layer.borderColor = UIColor.red.cgColor
                textField.layer.borderWidth = 1.0
            }
        })
        
        validator.registerField(emailTextField, errorLabel: emailErrorLabel, rules: [RequiredRule(), EmailRule()])
        validator.registerField(passwordTextField, errorLabel: passwordErrorLabel, rules: [RequiredRule()])
    }
    
    //MARK: - IBACtions
    @IBAction func logonButtonTouchUpInside(_ button: TransitionButton) {
        //Hide Keyboard When Tapped Button
        view.endEditing(true)
        
        button.startAnimation() // 2: Then start the animation when the user tap the button
        //let qualityOfServiceClass = DispatchQoS.QoSClass.background
        //let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        
        validator.validate(self)
        
        /*if(self.performLogin()){
         button.stopAnimation(animationStyle: .expand, completion: {
         self.performSegue(withIdentifier: "showHome", sender: nil)
         })
         }else{
         button.stopAnimation(animationStyle: .shake, completion:nil)
         }*/
        /*
         backgroundQueue.async(execute: {
         
         //sleep(0) // 3: Do your networking task or background work here.
         //self.validator.validate(self)
         
         DispatchQueue.main.async(execute: { () -> Void in
         // 4: Stop the animation, here you have three options for the `animationStyle` property:
         // .expand: useful when the task has been compeletd successfully and you want to expand the button and transit to another view controller in the completion callback
         // .shake: when you want to reflect to the user that the task did not complete successfly
         // .normal
         
         
         button.stopAnimation(animationStyle: .expand, completion: {
         //let secondVC = SecondViewController()
         //self.present(secondVC, animated: true, completion: nil)
         //Show Home
         //self.performLogin()
         //self.performSegue(withIdentifier: "showHome", sender: nil)
         })
         })
         })
         */
    }
    
    // MARK: - Private Methods
    private func setupUI(){
        //loginButton.layer.cornerRadius = 25
    }
    
    private func performLogin() {
        //Get values from TextFields
        let email = self.emailTextField.text
        let password = self.passwordTextField.text
        
        //Create request
        let request = LoginRequest(email: email!, password: password!)
        
        // Call red library
        SN.post(endpoint: Endpoints.login, model: request) { (response: SNResultWithEntity<LoginResponse, ErrorResponse>) in
            
            //Quit loading icon
            //SVProgressHUD.dismiss()
            
            switch response{
            case .success(let user):
                
                self.loginButton.stopAnimation(animationStyle: .expand, completion: {
                    //Show Home
                    self.performSegue(withIdentifier: "showHome", sender: nil)
                    
                    //set authentication tokek
                    SimpleNetworking.setAuthenticationHeader(prefix: "", token: user.token)
                    NotificationBanner(subtitle: "Bienvenido \(user.user.names)", style: .success).show(queuePosition: .front, bannerPosition: .top, queue: .default)
                })
            case .error(let error):
                print("todo lo malo")
                print(error)
                self.loginButton.stopAnimation(animationStyle: .shake, completion:nil)
                NotificationBanner(title: "Error", subtitle: error.localizedDescription, style: .danger).show()
            //return
            case .errorResult(let entity):
                print("error pero no tan malo :)")
                print(entity)
                self.loginButton.stopAnimation(animationStyle: .shake, completion:nil)
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
        loginButton.stopAnimation(animationStyle: .shake, completion:nil)
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
