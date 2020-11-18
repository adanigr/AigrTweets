//
//  HomeViewController.swift
//  AigrTweets
//
//  Created by Adan Reséndiz on 25/06/20.
//  Copyright © 2020 Adan Reséndiz. All rights reserved.
//

import UIKit
import Simple_Networking // library to consume web services
import SVProgressHUD // library to show load to user
import NotificationBannerSwift
import FirebaseStorage
import Foundation
import AVFoundation
import AVKit

class HomeViewController: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Define properties
    private let cellId = "TweetTableViewCell"
    private var dataSource = [Post]()
    
    let avPlayerController = AVPlayerViewController()
    
    //MARK: - create empty view for tableView
    fileprivate(set)lazy var emptyStateView: UIView = {
        guard let emptyView = Bundle.main.loadNibNamed("EmptyState", owner: nil, options:[:])?.first as? UIView else{
            return UIView()
        }
        return emptyView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getPosts()
    }
    
    private func setupUI() {
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: cellId, bundle: nil), forCellReuseIdentifier: cellId)
    }
    
    private func getPosts(){
        // 1. Indicate user load
        SVProgressHUD.show()
        
        // 2. Consume the get method service
        SN.get(endpoint: Endpoints.getPosts) { (response: SNResultWithEntity<[Post], ErrorResponse>) in
            //Quit loading icon
            SVProgressHUD.dismiss()
            
            switch response{
            case .success(let posts):
                
                self.dataSource = posts
                self.tableView.reloadData()
                
            case .error(let error):
                print("todo lo malo")
                print(error)
                NotificationBanner(title: "Error", subtitle: error.localizedDescription, style: .danger).show()
            //return
            case .errorResult(let entity):
                print("error pero no tan malo :)")
                print(entity)
                NotificationBanner(title: "Error", subtitle: entity.error, style: .warning).show(queuePosition: .front, bannerPosition: .top, queue: .default)
                //return
            }
        }
    }
    
    @objc func didfinishPlaying(note : NSNotification)  {
        
        avPlayerController.dismiss(animated: true, completion: nil)
        let alertView = UIAlertController(title: "Finished", message: "Video finished", preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Okey", style: .default, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    }
    
    private func deletePostAt(indexPath: IndexPath){
        
        //get post info
        let postRow = dataSource[indexPath.row]
        
        // 1. Show loading icon
        SVProgressHUD.show()
        
        // 2. get post id
        let postId = postRow.id
        
        // 3. create url endpoint
        let endPoint = Endpoints.delete + postId
        
        // 2. Consume the get method service
        SN.delete(endpoint: endPoint) { (response: SNResultWithEntity<GeneralResponse, ErrorResponse>) in
            //Quit loading icon
            SVProgressHUD.dismiss()
            
            switch response{
            case .success:
                // 1.delete post in data source
                self.dataSource.remove(at: indexPath.row)
                
                // 2. delete cell in table view
                self.tableView.deleteRows(at:[indexPath], with: .fade)
                
                if postRow.hasImage || postRow.hasVideo {
                    // 3. delete image to storage firebase
                    // create storage reference
                    let storageReference = Storage.storage().reference()
                    //Get object URL
                    let storageUrl = postRow.hasImage == true ? postRow.imageUrl : postRow.videoUrl
                    
                    //Get file name
                    let fileNameString: String = (storageUrl as NSString).lastPathComponent
                    print(fileNameString)
                    let fileNameArray = fileNameString.split(separator: "?")
                    let fileName = fileNameArray[0]
                    print(fileName.replacingOccurrences(of: "%2F", with: "/"))
                    // Create a reference to the file to delete
                    let desertRef = storageReference.child(String(fileName.replacingOccurrences(of: "%2F", with: "/")))
                    
                    // Delete the file
                    desertRef.delete { error in
                        if let error = error {
                            // Uh-oh, an error occurred!
                            print("Uh-oh, an error occurred!")
                            print(error)
                            NotificationBanner(title: "Uh-oh, an error occurred!", subtitle: error.localizedDescription, style: .danger).show()
                        } else {
                            // File deleted successfully
                        }
                    }
                }
            case .error(let error):
                print("todo lo malo")
                print(error)
                NotificationBanner(title: "Error", subtitle: error.localizedDescription, style: .danger).show()
            //return
            case .errorResult(let entity):
                print("error pero no tan malo :)")
                print(entity)
                NotificationBanner(title: "Error", subtitle: entity.error, style: .warning).show(queuePosition: .front, bannerPosition: .top, queue: .default)
                //return
            }
        }
    }
}

//MARK: - Implement UITableViewDelegate
extension HomeViewController: UITableViewDelegate{
    /*func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
     
     // configure action
     let deleteAction = UITableViewRowAction(style: .destructive, title:"Borrar") { [weak self] /* [weak self] for memory management */(action, index) in
     
     let alert:UIAlertController = UIAlertController(title: "", message: "are you sure want to delete ?", preferredStyle: UIAlertController.Style.alert)
     
     alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
     // delete row
     self?.deletePostAt(indexPath: indexPath)
     }))
     
     alert.addAction(UIAlertAction(title: "CANCEL", style: UIAlertAction.Style.cancel, handler: { (action) in
     }))
     
     // Write self in direct view controller
     self?.present(alert, animated: true, completion: nil)
     }
     return [deleteAction]
     }*/
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        //falta agregar funcionalidad de user defaults
        return dataSource[indexPath.row].author.email == "adanigr@platzi.com"
    }
    
    //Swipe cell left -> rigth
    //@available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Borrar") { action, view, complete in
            print("Delete row!")
            let alert:UIAlertController = UIAlertController(title: "", message: "¿Seguro que desea eliminar el tweet?", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "ACEPTAR", style: UIAlertAction.Style.default, handler: { (action) in
                // delete row
                self.deletePostAt(indexPath: indexPath)
            }))
            
            alert.addAction(UIAlertAction(title: "CANCELAR", style: UIAlertAction.Style.cancel, handler: { (action) in
            }))
            
            // Write self in direct view controller
            self.present(alert, animated: true, completion: nil)
            complete(true)
        }
        
        // here set your image and background color
        deleteAction.image = UIImage(named: "Trash")
        //deleteAction.backgroundColor = .darkGray
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    //Swipe cell rigth <- left
    //@available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Borrar") { action, view, complete in
            print("Delete row!")
            let alert:UIAlertController = UIAlertController(title: "", message: "¿Seguro que desea eliminar el tweet?", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "ACEPTAR", style: UIAlertAction.Style.default, handler: { (action) in
                // delete row
                self.deletePostAt(indexPath: indexPath)
            }))
            
            alert.addAction(UIAlertAction(title: "CANCELAR", style: UIAlertAction.Style.cancel, handler: { (action) in
            }))
            
            // Write self in direct view controller
            self.present(alert, animated: true, completion: nil)
            complete(true)
        }
        
        // here set your image and background color
        deleteAction.image = UIImage(named: "Trash")
        //deleteAction.backgroundColor = .darkGray
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //cell.textLabel?.text = "row: \(indexPath.row)"
        
        // begin animate cells
        /*let tableHeight: CGFloat = (tableView.bounds.size.height)
         
         cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
         
         UIView.animate(withDuration: 1.5, delay: 0.05 * Double(indexPath.row), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .transitionFlipFromLeft, animations: {
         cell.transform = CGAffineTransform(translationX: 0, y: 0);
         }, completion: nil)*/
        // end animate cells
    }
}

//MARK: - Implement UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //let count = 0
        //Get number of rows for dataRows
        let count = dataSource.count
        tableView.backgroundView = count == 0 ? emptyStateView : nil
        tableView.separatorStyle = count == 0 ? .none : .singleLine
        return count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        if let cell = cell as? TweetTableViewCell{
            //Config cell
            cell.setupCellWith(post: dataSource[indexPath.row])
            
            cell.needsToShowVideo = { url in
                
                // Aquí SI deberíamos abrir un ViewController
                let avPlayer = AVPlayer(url: url)
                
                
                
                //let avPlayerController = AVPlayerViewController()
                self.avPlayerController.player = avPlayer
                
                 NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.didfinishPlaying(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem)
                 
                self.avPlayerController.player = avPlayer
                 
                self.avPlayerController.allowsPictureInPicturePlayback = true
                 
                self.avPlayerController.delegate = self
                 
                self.avPlayerController.player?.play()
                 
                self.present(self.avPlayerController, animated: true, completion : nil)
                
                /*
                self.present(avPlayerController, animated: true) {
                    //Reproduce video automaticamente
                    avPlayerController.player?.play()
                }*/
                
            }
        }
        return cell
    }
}

//MARK: - Implement AVPlayerViewControllerDelegate
extension HomeViewController: AVPlayerViewControllerDelegate {
    
    func playerViewController(_ playerViewController: AVPlayerViewController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        
        let currentviewController = navigationController?.visibleViewController
        
        if currentviewController != playerViewController{
            
            currentviewController?.present(playerViewController, animated: true, completion: nil)
            
        }
        
    }
}
