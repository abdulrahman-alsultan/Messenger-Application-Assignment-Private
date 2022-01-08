//
//  ViewController.swift
//  Messenger Application Assignment
//
//  Created by administrator on 03/01/2022.
//

import UIKit
import Firebase
import FirebaseDatabase

class LoginViewController: UIViewController {
    
    let defaults = UserDefaults.standard

    @IBOutlet weak var upView: UIView!
    @IBOutlet weak var fieldView: UIView!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var registerBtn: UIButton!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginWith: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setViews()
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func login(_ sender: Any) {
        self.view.endEditing(true)
        if let email = emailField.text, let password = passwordField.text{
            if email.isEmpty == true && password.isEmpty == true{
                createAlert(title: "Empty fields", message: nil)
                return
            }
            
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    self.handleError(error: error)
                    return
                }
                
                if let user = Auth.auth().currentUser{
                    if user.isEmailVerified{
                        self.defaults.set(true, forKey: "IsUserLoggedIn")
                        Database.database().reference(withPath: "users").observeSingleEvent(of: .value) { snapshot in
                            let snap = snapshot.value as! [String:AnyObject]
                            for s in snap{
                                if s.key == self.safeEmail(email: user.email!){
                                    self.defaults.set(s.value["name"] as! String, forKey: "MyName")
                                    break
                                }
                            }
                            
                            
                        }
//                        self.performSegue(withIdentifier: "MyApp", sender: self)
                        self.dismiss(animated: true, completion: nil)
                    }
                    else{
                        let alert = UIAlertController(title: "Email not verified", message: nil, preferredStyle: .alert)
                        let sendMailAgain = UIAlertAction(title: "Send the mail again", style: .default) { action in
                            user.sendEmailVerification { error in
                                if let error = error{
                                    self.createAlert(title: "Something went wrong", message: error.localizedDescription)
                                }
                            }
                        }
                        let cancel = UIAlertAction(title: "cancel", style: .default, handler: nil)
                        alert.addAction(cancel)
                        alert.addAction(sendMailAgain)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
            }
        }
        
    }
    
    func safeEmail(email: String) -> String{
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
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
        case .wrongPassword:
            createAlert(title: "Wrong password", message: nil)
        case .invalidEmail:
            print("invalidEmail")
            createAlert(title: "Invalid email", message: nil)
        case .userDisabled:
            print("userDisabled")
            createAlert(title: "User disable", message: nil)
        case .userNotFound:
            print("userNotFound")
            createAlert(title: "User not found", message: nil)
        case .tooManyRequests:
            print("tooManyRequests, oooops")
            createAlert(title: "Too many requst", message: nil)
        default: createAlert(title: "Something went wrong", message: nil)
        }
    }
    
    
    
    @IBAction func navigateToRegisterScreen(_ sender: Any) {
        //performSegue(withIdentifier: "CreateAcount", sender: self)
        let vc = storyboard?.instantiateViewController(identifier: "Register") as! SignupViewController
        present(vc, animated: true, completion: nil)
    
    }
    

    
    func setViews(){
        upView.layer.cornerRadius = 30
        upView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        upView.layer.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height / 2)
        
        fieldView.layer.cornerRadius = 10
        fieldView.layer.shadowColor = UIColor("5097EB").cgColor
        fieldView.layer.shadowOffset = CGSize(width: 3, height: 3)
        fieldView.layer.shadowOpacity = 0.7
        fieldView.layer.shadowRadius = 4.0
        
        emailField.leftViewMode = .always
        let emailImageView = UIImageView()
        emailImageView.image = UIImage(named: "email")
        emailImageView.frame = CGRect(x: 5, y: 0, width: emailField.frame.height, height: emailField.frame.height)
        emailField.leftView = emailImageView
        
        
        passwordField.leftViewMode = .always
        let passwordImageView = UIImageView()
        passwordImageView.image = UIImage(named: "password")
        passwordImageView.frame = CGRect(x: 5, y: 0, width: passwordField.frame.height, height: passwordField.frame.height)
        passwordField.leftView = passwordImageView
        
        let myMutableString = NSMutableAttributedString()
        myMutableString.append(NSAttributedString(string: "Don't have an account? ", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black]));
        myMutableString.append(NSAttributedString(string: "Register now", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "launch")!]))
        registerBtn.setAttributedTitle(myMutableString, for: .normal)
        
        

    }
}
extension UIColor {
  
  convenience init(_ hex: String, alpha: CGFloat = 1.0) {
    let cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    var rgbValue: UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)
    
    self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
              green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
              blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
              alpha: alpha)
  }

}


//extension LoginViewController: LoginButtonDelegate{
//    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
//
//    }
//
//    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
//        guard let token = result?.token?.tokenString else {
//            return
//        }
//        print(error ?? "")
//
//        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields": "email, name"], tokenString: token, version: nil, httpMethod: .get)
//
//        facebookRequest.start { _, result, error in
//            guard let result = result as? [String: Any], error == nil else { return }
//
//            guard let userName = result["name"] as? String, let email = result["email"] as? String else { return }
//
//            DatabaseManger.shared.userExists(with: email) { exists in
//                if !exists {
//                    DatabaseManger.shared.insertUser(with: ChatAppUser(name: userName, emailAddress: email))
//                }
//            }
//
//        }
//
//        let credential = FacebookAuthProvider.credential(withAccessToken: token)
//
//        Auth.auth().signIn(with: credential) { result, error in
//            guard result != nil, error == nil else{
//                self.createAlert(title: "Something went wrong", message: error?.localizedDescription)
//                return
//            }
//
//            self.defaults.set(true, forKey: "IsUserLoggedIn")
////          self.performSegue(withIdentifier: "MyApp", sender: self)
//            self.dismiss(animated: true, completion: nil)
//
//        }
//    }
//
//
//}
