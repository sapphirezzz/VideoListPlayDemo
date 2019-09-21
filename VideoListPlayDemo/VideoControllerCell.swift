//
//  VideoControllerCell.swift
//  VideoListPlayDemo
//
//  Created by zackzheng on 2019/9/18.
//  Copyright © 2019 zackzheng. All rights reserved.
//

import UIKit

protocol VideoControllerCellDelegate: class {
    func videoControllerCell(_ cell: VideoControllerCell, didClickToPlay videoURL: URL)
}

class VideoControllerCell: UITableViewCell {
    @IBOutlet var videoView: UIView!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var coverImageView: UIImageView!
    
    weak var delegate: VideoControllerCellDelegate?
    var url: URL?
    var cover: UIImage? {
        didSet {
            coverImageView.image = cover
        }
    }
    
    @IBAction func onClickPlayButton() {
        guard let url = url else {return}
        delegate?.videoControllerCell(self, didClickToPlay: url)
    }
}

extension VideoControllerCell: VideoPlayable {
    var viewToContainVideo: UIView {
        return videoView
    }
    var urlToPlay: URL? {
        return url
    }
    func videoStatusChanged(changeTo isPlaying: Bool) {
        playButton.isHidden = isPlaying
    }
}
