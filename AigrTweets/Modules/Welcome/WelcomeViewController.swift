//
//  WelcomeViewController.swift
//  AigrTweets
//
//  Created by Adan Reséndiz on 15/06/20.
//  Copyright © 2020 Adan Reséndiz. All rights reserved.
//

import UIKit
import PMSuperButton
import AVFoundation
import AVKit

class WelcomeViewController: UIViewController {
    
    //MARK: - IBOutlet
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var loginButton: PMSuperButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Private Methods
    private func setupUI(){
        loginButton.layer.cornerRadius = 25
    }
    
    private func setupView() {
        let path = URL(fileURLWithPath: Bundle.main.path(forResource: "Octagon", ofType: "mp4")!)
        let player = AVPlayer(url: path)
        
        let newLayer = AVPlayerLayer(player: player)
        newLayer.frame = self.videoView.frame
        self.videoView.layer.addSublayer(newLayer)
        newLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        player.play()
        player.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none
        NotificationCenter.default.addObserver(self, selector: #selector(self.videoDidPlayToEnd(_:)), name: NSNotification.Name(rawValue: "AVPlayerItemDidPlayToEndTimeNotification"), object: player.currentItem)
    }
    
    // MARK: - Selector Methods
    @objc func videoDidPlayToEnd(_ notification: Notification) {
        let player: AVPlayerItem = notification.object as! AVPlayerItem
        player.seek(to: CMTime.zero, completionHandler: nil)
    }
}
