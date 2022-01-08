//
//  ProfileViewController.swift
//  Messenger Application Assignment
//
//  Created by administrator on 04/01/2022.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    
    let auth = Auth.auth()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupViews()
        let tap = UITapGestureRecognizer(target: self, action: #selector(pickImage))
        userImage.addGestureRecognizer(tap)
        userImage.isUserInteractionEnabled = true
    }
    
    func setupViews(){
        userEmail.text = Auth.auth().currentUser?.email
        userName.text = defaults.value(forKey: "MyName") as? String
        
        userImage.layer.borderWidth = 1
        userImage.layer.borderColor = UIColor("5097EB").cgColor
        userImage.layer.cornerRadius = userImage.frame.height / 2
        userImage.clipsToBounds = true
        userImage.contentMode = .scaleToFill
    }
    
    @objc func pickImage(){
        let actionSheet = UIAlertController(title: "Profile Picture", message: "How would you like to select a picture?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        present(actionSheet, animated: true, completion: nil)
    }
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    
    @IBAction func logout(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Log out", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Log out", style: .destructive, handler: { _ in
            do{
                try Auth.auth().signOut()
                self.defaults.set(false, forKey: "IsUserLoggedIn")
                self.dismiss(animated: true, completion: nil)
            }catch{
                let alert = UIAlertController(title: "Something went wrong", message: error.localizedDescription, preferredStyle: .alert)
                let ok = UIAlertAction(title: "Okay", style: .default, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }
        })
        )
        
        actionSheet.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    
    
}


extension ProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            userImage.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
