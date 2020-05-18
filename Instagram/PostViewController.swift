//
//  PostViewController.swift
//  Instagram
//
//  Created by shrikant kekane on 16.05.20.
//  Copyright © 2020 shrikant kekane. All rights reserved.
//

import UIKit
import Parse

class PostViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var imageToPost: UIImageView!
    @IBOutlet weak var comment: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func postImage(_ sender: UIButton) {
        
        if let image = imageToPost.image {
            let spinner = self.displaySpinner()
            let post = PFObject(className: "Post")
            post["message"] = comment.text
            post["userid"] = PFUser.current()?.objectId
            
            if let imageData = image.pngData() {
                let imageFile = PFFileObject(name: "image.png", data: imageData)
                post["imageFile"] = imageFile
                post.saveInBackground { (success, error) in
                    spinner.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    if error != nil {
                        self.displayAlert(withTitle: "Upload Error", andMessage: error!.localizedDescription)
                    } else {
                        self.displayAlert(withTitle: "Post Complete", andMessage: "The post uploaded successfully!!")
                        self.comment.text = ""
                        self.imageToPost.image = nil
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
    
    @IBAction func chooseAnImage(_ sender: UIButton) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = false
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageToPost.image = image
        }
        self.dismiss(animated: true, completion: nil)
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
