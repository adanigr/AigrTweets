//
//  AddPostViewController.swift
//  AigrTweets
//
//  Created by Adan Reséndiz on 30/06/20.
//  Copyright © 2020 Adan Reséndiz. All rights reserved.
//

import UIKit
import TransitionButton  // 1: First import the TransitionButton library
import SwiftValidator
import Simple_Networking
import NotificationBannerSwift
import UITextView_Placeholder
import SVProgressHUD
import FirebaseStorage
import AVFoundation
import AVKit
import MobileCoreServices

class AddPostViewController: UIViewController {
    //MARK: - IBOutlets Controls
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var publishButton: TransitionButton!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var previewVideoButton: UIButton!
    
    // MARK: - IBOutlets Error Labels
    @IBOutlet weak var postErrorLabel: UILabel!
    
    // MARK: - Properties
    private var imagePicker: UIImagePickerController?
    private var currentVideoUrl: URL?
    
    //Create instance for validator object
    let validator = Validator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //hide video button preview
        previewVideoButton.isHidden = true
        
        //Looks for single or multiple taps.
        self.hideKeyboardWhenTappedAround()
        
        //Add place holder to text view
        postTextView.placeholder = "Escribe tu tweet aquí..."
        //postTextView.placeholderColor = UIColor.white // optional
        //postTextView.attributedPlaceholder = .init(string: "test")// NSAttributedString (optional)
        
        // Do any additional setup after loading the view.
        
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
        
        validator.registerField(postTextView, errorLabel: postErrorLabel, rules: [RequiredRule()])
    }
    
    //MARK: - IBActions
    @IBAction func addPostAction(_ button: TransitionButton){
        //Hide Keyboard When Tapped Button
        view.endEditing(true)
        
        button.startAnimation() // 2: Then start the animation when the user tap the button
        
        validator.validate(self)
    }
    
    @IBAction func dismissAction(){
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openCameraButtonTouchUpInside(){
        
        let alert = UIAlertController(title: "Cámara", message: "Selecciona una opción", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Foto", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Video", style: .default, handler: { _ in
            self.openVideoCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .destructive, handler: nil))
        
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func openPreviewVideoButtonTouchUpInside(){
        
        guard let currentVideoUrl = currentVideoUrl else {
            return
        }
        
        let avPlayer = AVPlayer(url: currentVideoUrl)
        
        let avPlayerController = AVPlayerViewController()
        avPlayerController.player = avPlayer
        
        present(avPlayerController, animated: true) {
            //Reproduce video automaticamente
            avPlayerController.player?.play()
        }
    }
    
    //MARK: - Private functions
    private func openVideoCamera(){
        imagePicker = UIImagePickerController()
        imagePicker?.sourceType = .camera
        imagePicker?.mediaTypes = [kUTTypeMovie as String]
        imagePicker?.cameraFlashMode = .off
        imagePicker?.cameraCaptureMode = .video
        imagePicker?.videoQuality = .typeMedium
        imagePicker?.videoMaximumDuration = TimeInterval(5)
        imagePicker?.allowsEditing = true
        imagePicker?.delegate = self
        
        guard let imagePicker = imagePicker else{
            return
        }
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func openCamera(){
        imagePicker = UIImagePickerController()
        imagePicker?.sourceType = .camera
        imagePicker?.cameraFlashMode = .off
        imagePicker?.cameraCaptureMode = .photo
        imagePicker?.allowsEditing = true
        imagePicker?.delegate = self
        
        guard let imagePicker = imagePicker else{
            return
        }
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func uploadPhotoToFirebase() {
        // 1. Ensure the photo exists
        // 2. Compress the image and convert it into data
        guard let imageSaved = previewImageView.image, let imageSavedData: Data = imageSaved.jpegData(compressionQuality: 0.1) else {
            return
        }
        
        //SVProgressHUD.show()
        
        // 3. Settings to save the photo to firebase
        let metaDataConfig = StorageMetadata()
        metaDataConfig.contentType = "image/jpg"
        
        // 4. create storage reference
        let storage = Storage.storage()
        
        // 5. Create image name
        let imageName = Int.random(in: 100...1000)
        
        // 6. Reference of where the photo is saved
        let folderReference = storage.reference(withPath: "tweet-photos/\(imageName).jpg")
        
        //Creating thread in background and uploading photo to firebase
        DispatchQueue.global(qos: .background).async {
            folderReference.putData(imageSavedData, metadata: metaDataConfig) { (metadata: StorageMetadata?, error: Error?) in
                
                //Going back to the main thread
                DispatchQueue.main.async {
                    //Remove loading icon
                    //SVProgressHUD.dismiss()
                    
                    if let error = error {
                        print("Error al guardar la foto en firebase")
                        print(error)
                        NotificationBanner(title: "Error", subtitle: error.localizedDescription, style: .danger).show()
                        
                        return
                    }
                    
                    //Get download url
                    folderReference.downloadURL { (url: URL?, error: Error?) in
                        print(url?.absoluteString ?? "" )
                        let downloadUrl = url?.absoluteString
                        self.savePost(imageUrl: downloadUrl!, videoUrl: nil)
                    }
                }
            }
        }
    }
    
    func uploadVideoToFirebase() {
        // 1. Ensure the video exists
        // 2. convert video in data
        guard let currentVideoSavedUrl = currentVideoUrl,
            let videoData: Data = try? Data(contentsOf: currentVideoSavedUrl) else {
            return
        }
        
        //SVProgressHUD.show()
        
        // 3. Settings to save the video to firebase
        let metaDataConfig = StorageMetadata()
        metaDataConfig.contentType = "video/MP4"
        
        // 4. create storage reference
        let storage = Storage.storage()
        
        // 5. Create video name
        let videoName = Int.random(in: 100...1000)
        
        // 6. Reference of where the photo is saved
        let folderReference = storage.reference(withPath: "tweet-videos/\(videoName).mp4")
        
        // 7. Creating thread in background and uploading video to firebase
        DispatchQueue.global(qos: .background).async {
            folderReference.putData(videoData, metadata: metaDataConfig) { (metadata: StorageMetadata?, error: Error?) in
                
                //Going back to the main thread
                DispatchQueue.main.async {
                    //Remove loading icon
                    //SVProgressHUD.dismiss()
                    
                    if let error = error {
                        print("Error al guardar la foto en firebase")
                        print(error)
                        NotificationBanner(title: "Error", subtitle: error.localizedDescription, style: .danger).show()
                        
                        return
                    }
                    
                    //Get download url
                    folderReference.downloadURL { (url: URL?, error: Error?) in
                        print(url?.absoluteString ?? "" )
                        let downloadUrl = url?.absoluteString
                        self.savePost(imageUrl: nil, videoUrl: downloadUrl!)
                    }
                }
            }
        }
    }
    
    private func savePost(imageUrl: String?, videoUrl: String?){
        //Create Request
        let request = PostRequest(text: postTextView.text, imageUrl: imageUrl, videoUrl: videoUrl, location: nil)
        
        // Call network library
        SN.post(endpoint: Endpoints.post, model: request) { (response: SNResultWithEntity<Post, ErrorResponse>) in
            
            //Quit loading icon
            //SVProgressHUD.dismiss()
            
            switch response{
            case .success(let post):
                
                self.publishButton.stopAnimation(animationStyle: .expand, completion: {
                    //return
                    self.dismiss(animated: true, completion: nil)
                    
                    NotificationBanner(subtitle: "Ya hay un nuevo Tweet :)", style: .success).show(queuePosition: .front, bannerPosition: .top, queue: .default)
                })
            case .error(let error):
                print("todo lo malo")
                print(error)
                self.publishButton.stopAnimation(animationStyle: .shake, completion:nil)
                NotificationBanner(title: "Error", subtitle: error.localizedDescription, style: .danger).show()
            //return
            case .errorResult(let entity):
                print("error pero no tan malo :)")
                print(entity)
                self.publishButton.stopAnimation(animationStyle: .shake, completion:nil)
                NotificationBanner(title: "Error", subtitle: entity.error, style: .warning).show(queuePosition: .front, bannerPosition: .top, queue: .default)
                //return
            }
        }
    }
}

//MARK: - Implement extensions
extension AddPostViewController: ValidationDelegate, UITextFieldDelegate{
    func validationSuccessful() {
        print("Validation SUCCESSFUL!")
        //uploadPhotoToFirebase()
        uploadVideoToFirebase()
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        print("Validation FAILED!")
        publishButton.stopAnimation(animationStyle: .shake, completion:nil)
    }
}

//MARK: - Implement UIImagePickerControllerDelegate
extension AddPostViewController: UIImagePickerControllerDelegate,  UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //Close camera
        imagePicker?.dismiss(animated: true, completion: nil)
        
        //Capture image
        if info.keys.contains(.originalImage) {
            previewImageView.isHidden = false
            //Get taket image
            previewImageView.image = info[.originalImage] as? UIImage
        }
        
        //Capture video url
        if info.keys.contains(.mediaURL), let recordedVideoUrl = (info[.mediaURL] as? URL)?.absoluteURL {
            self.previewVideoButton.isHidden = false
            currentVideoUrl = recordedVideoUrl
        }
    }
}
