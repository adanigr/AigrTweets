//
//  TweetTableViewCell.swift
//  AigrTweets
//
//  Created by Adan Reséndiz on 25/06/20.
//  Copyright © 2020 Adan Reséndiz. All rights reserved.
//

import UIKit
import Kingfisher
import AVKit

class TweetTableViewCell: UITableViewCell {
    //MARK; - IBOutlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var teweetImageView: UIImageView!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    //MARK: - Properties
    private var videoUrl: URL?
    var needsToShowVideo: ((_ url: URL) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        if #available(iOS 13.0, *) {
            let startImage = AVPictureInPictureController.pictureInPictureButtonStartImage
            videoButton.setImage(startImage, for: .normal)
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 13.0, *) {
            let stopImage = AVPictureInPictureController.pictureInPictureButtonStopImage
            videoButton.setImage(stopImage, for: .selected)
        } else {
            // Fallback on earlier versions
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //NOTA IMPORTANTE
    //Las celdas nunca deben invocar ViewControllers!
    //MARK: - IBActions
    @IBAction func openVideoButtonTouchUpInside(){
        guard let videoUrl = videoUrl else {
            return
        }
        
        needsToShowVideo?(videoUrl)
    }
    
    func setupCellWith(post: Post){
        videoButton.isHidden = !post.hasVideo
        nameLabel.text = post.author.names
        nickNameLabel.text = post.author.nickname
        messageLabel.text = post.text
        
        dateLabel.text = post.createdAt
        
        if post.hasImage {
            // config image
            teweetImageView.isHidden = false
            teweetImageView.kf.setImage(with: URL(string: post.imageUrl))
        } else {
            teweetImageView.isHidden = true
        }
        
        videoUrl = URL(string: post.videoUrl)
    }
}
