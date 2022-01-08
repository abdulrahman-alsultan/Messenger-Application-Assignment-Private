//
//  SignupViewController.swift
//  Messenger Application Assignment
//
//  Created by administrator on 03/01/2022.
//

import UIKit
import Firebase

class SignupViewController: UIViewController {
    
    
    @IBOutlet weak var nameField
        : UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPassordField: UITextField!
    @IBOutlet weak var upView: UIView!
    @IBOutlet weak var fieldsView: UIView!
    @IBOutlet weak var login: UIButton!
    
    @IBOutlet weak var emailPhrase: UILabel!
    @IBOutlet weak var mailState: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupview()
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func setupview(){
        emailPhrase.isHidden = true
        mailState.isHidden = true
        upView.layer.cornerRadius = 30
        upView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        upView.layer.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height / 2)
        
        fieldsView.layer.cornerRadius = 10
        fieldsView.layer.shadowColor = UIColor("5097EB").cgColor
        fieldsView.layer.shadowOffset = CGSize(width: 3, height: 3)
        fieldsView.layer.shadowOpacity = 0.7
        fieldsView.layer.shadowRadius = 4.0
//
        nameField.leftViewMode = .always
        let nameImageView = UIImageView()
        nameImageView.image = UIImage(systemName: "person")
        nameImageView.frame = CGRect(x: 5, y: 0, width: nameField.frame.height, height: nameField.frame.height)
        nameImageView.tintColor = .black
        nameField.leftView = nameImageView
//
        emailField.leftViewMode = .always
        let emailImageView = UIImageView()
        emailImageView.image = UIImage(named: "email")
        emailImageView.frame = CGRect(x: 5, y: 0, width: emailField.frame.height, height: emailField.frame.height)
        emailField.leftView = emailImageView
//
        passwordField.leftViewMode = .always
        let passwordImageView = UIImageView()
        passwordImageView.image = UIImage(named: "password")
        passwordImageView.frame = CGRect(x: 5, y: 0, width: passwordField.frame.height, height: passwordField.frame.height)
        passwordField.leftView = passwordImageView
//
        confirmPassordField.leftViewMode = .always
        let confirmPasswordImageView = UIImageView()
        confirmPasswordImageView.image = UIImage(named: "password")
        confirmPasswordImageView.frame = CGRect(x: 5, y: 0, width: confirmPassordField.frame.height, height: confirmPassordField.frame.height)
        confirmPassordField.leftView = confirmPasswordImageView
//
        let myMutableString = NSMutableAttributedString()
        myMutableString.append(NSAttributedString(string: "Already have an account? ", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black]))
        myMutableString.append(NSAttributedString(string: "Sign in", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "launch") ?? UIColor.blue]))
        login.setAttributedTitle(myMutableString, for: .normal)
    }
    
    @IBAction func navigateBackToLogin(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func createNewUser(_ sender: Any) {
        guard let name = nameField.text, let email = emailField.text, let password = passwordField.text, let confirmPassword = confirmPassordField.text else { return }
        
        if validateConfirmPassword(confirmPassword: confirmPassword, password: password) && name.isEmpty == false{
            self.view.endEditing(true)
            Auth.auth().createUser(withEmail: email, password: password){
                result, error in
                
                if let error = error{
                    self.handleError(error: error)
                    return
                }
                
//                guard let uid = result?.user.uid else { return }
                
                let user = ChatAppUser(name: name, emailAddress: email)
                
                DatabaseManger.shared.insertUser(with: user)
                
                self.SendVerificationMail(authUser: Auth.auth().currentUser)
            }
        }
    }
    
    func validateConfirmPassword(confirmPassword: String, password: String) -> Bool{
        if confirmPassword == password{
            return true
        }
        else{
            let alert = UIAlertController(title: "Password doesn't match", message: "Make sure your password and confirm password are equal.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
            return false
        }
    }
    
    
    func SendVerificationMail(authUser: User?){
        setViewsHidden()
        if authUser != nil{
            authUser?.sendEmailVerification(completion: { error in
                if let error = error {
                    let alert = UIAlertController(title: "Somthing went wrong", message: error.localizedDescription, preferredStyle: .alert)
                    let sendAgain = UIAlertAction(title: "Send again", style: .default){
                        action in
                        self.SendVerificationMail(authUser: authUser)
                    }
                    alert.addAction(sendAgain)
                    self.present(alert, animated: true, completion: nil)
                }
                self.emailPhrase.text = "Email send"
                self.mailState.image = UIImage(named: "mail_sent")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }
    }
    
    func setViewsHidden(){
        fieldsView.isHidden = true
        upView.isHidden = true
        emailPhrase.isHidden = false
        mailState.isHidden = false
        self.view.backgroundColor = UIColor("5097EB")
    }
    
    func createAlert(title: String, message: String?){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleError(error: Error){
        let errorAuthStatus = AuthErrorCode.init(rawValue: error._code)!
        switch(errorAuthStatus){
        case .weakPassword:
            createAlert(title: "Week password", message: error.localizedDescription)
        case .invalidEmail:
            createAlert(title: "Invalid email", message: nil)
        case .emailAlreadyInUse:
            createAlert(title: "Email already exists", message: nil)
        default: createAlert(title: "Something went wrong", message: nil)
        }
    }
    
}
