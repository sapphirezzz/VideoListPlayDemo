//
//  VideoListAutoPlayManager.swift
//  VideoListPlayDemo
//
//  Created by zackzheng on 2019/9/18.
//  Copyright © 2019 zackzheng. All rights reserved.
//

import UIKit
import AVKit

protocol VideoPlayable: UIView {
    var viewToContainVideo: UIView {get}
    var urlToPlay: URL? {get}
    func videoStatusChanged(changeTo isPlaying: Bool)
}

protocol VideoListPlayable: UIScrollView {
    var visibleViews: [VideoPlayable] {get}
}

extension UITableView: VideoListPlayable {
    var visibleViews: [VideoPlayable] {
        let views: [VideoPlayable] = visibleCells.compactMap({ $0 as? VideoPlayable })
        return views
    }
}
extension UICollectionView: VideoListPlayable {
    var visibleViews: [VideoPlayable] {
        let views: [VideoPlayable] = visibleCells.compactMap({ $0 as? VideoPlayable })
        return views
    }
}

class VideoListAutoPlayManager {
    
    private init() {
        playerVC.player = AVPlayer()
        playerVC.showsPlaybackControls = false
        playerVC.view.backgroundColor = UIColor.clear
    }
    static let shared = VideoListAutoPlayManager()
    
    private var playerVC: AVPlayerViewController = AVPlayerViewController()
    private var preOffsetY: CGFloat = 0
    private var currentPlayingView: VideoPlayable?
    
    func scrollViewDidScroll(_ scrollView: VideoListPlayable) {

        let currentOffsetY = scrollView.contentOffset.y
        let minY = scrollView.frame.height / 3
        let maxY = minY * 2
        // 获取在 scrollView 自动播放区域内的视频
        let autoPlayableViews = scrollView.visibleViews.filter { view in
            guard let relativeRect = relativeRect(view: view.viewToContainVideo, relativeTo: scrollView), view.urlToPlay != nil else {return false}
            let containerCenterY = relativeRect.minY + relativeRect.height / 2
            return (containerCenterY > minY && containerCenterY < maxY)
        }
        
        guard let first = autoPlayableViews.first else {
            // 没有需要自动播放的视频
            // 移除当前正在离开/已经离开屏幕的视频
            removeCurrentVideoIfLeavingScreen(scrollView: scrollView)
            preOffsetY = currentOffsetY
            return
        }

        // 取出需要自动播放的视频
        let viewToPlay: VideoPlayable = autoPlayableViews.reduce(first) { (result, view) in
            let isScrollToUpper = currentOffsetY < preOffsetY
            return result.frame.maxY > view.frame.maxY ? (isScrollToUpper ? view : result) : (isScrollToUpper ? result : view)
        }
        if let currentPlayingView = currentPlayingView, viewToPlay as UIView == currentPlayingView {
            // 满足条件的视频正在播放中
            preOffsetY = currentOffsetY
            return
        }
        removeCurrentVideo(on: scrollView)

        addPlayerView(to: viewToPlay, on: scrollView)
        preOffsetY = currentOffsetY
    }
    
    func play(at videoView: VideoPlayable, on scrollView: VideoListPlayable) {
        removeCurrentVideo(on: scrollView)
        addPlayerView(to: videoView, on: scrollView)
    }
}

private extension VideoListAutoPlayManager {

    func relativeRect(view: UIView, relativeTo scrollView: VideoListPlayable) -> CGRect? {
        // 计算 view 相对于 scrollView 的位置
        guard let scrollViewSuperView = scrollView.superview, let containerSuperview = view.superview else {return nil}
        let containerViewRect = containerSuperview.convert(view.frame, to: scrollViewSuperView)
        let relativeRect = CGRect(origin: CGPoint(x: containerViewRect.minX - scrollView.frame.minX, y: containerViewRect.minY - scrollView.frame.minY), size: containerViewRect.size)
        return relativeRect
    }
    
    func addPlayerView(to view: VideoPlayable, on scrollView: VideoListPlayable) {

        guard let url = view.urlToPlay else {
            return
        }

        let avItem = AVPlayerItem(url: url)
        let avPlayer = AVPlayer(playerItem: avItem)
        playerVC.player = avPlayer
        avPlayer.isMuted = true
        avPlayer.play()

        view.videoStatusChanged(changeTo: true)

        let containerView = view.viewToContainVideo
        containerView.addSubview(playerVC.view)

        playerVC.view.translatesAutoresizingMaskIntoConstraints = false
        playerVC.view.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        playerVC.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        playerVC.view.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        playerVC.view.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true

        currentPlayingView = view
    }
    
    func removeCurrentVideoIfLeavingScreen(scrollView: VideoListPlayable) {
        guard let view = currentPlayingView, let relativeRect = relativeRect(view: view, relativeTo: scrollView) else {
            return
        }
        let currentOffsetY = scrollView.contentOffset.y
        let containerCenterY = relativeRect.minY + relativeRect.height / 2
        if (currentOffsetY > preOffsetY && containerCenterY <= 0) || (currentOffsetY < preOffsetY && containerCenterY >= scrollView.frame.height) {
            removeCurrentVideo(on: scrollView)
        }
    }

    func removeCurrentVideo(on scrollView: VideoListPlayable) {
        playerVC.player = nil
        playerVC.view.removeFromSuperview()
        currentPlayingView?.videoStatusChanged(changeTo: false)
        currentPlayingView = nil
    }
}
