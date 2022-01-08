//
//  ChatViewController.swift
//  Messenger Application Assignment
//
//  Created by administrator on 07/01/2022.
//

import UIKit

class ChatViewController: UIViewController {
    
    var freind: ChatAppUser!
    @IBOutlet weak var friendname: UILabel!
    @IBOutlet weak var friendImage: UIImageView!
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var sendBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        friendname.text = freind.name
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }

}
