//
//  ViewController.swift
//  VideoListPlayDemo
//
//  Created by zackzheng on 2019/9/18.
//  Copyright © 2019 zackzheng. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let cellInfos: [(ratio: CGFloat, url: URL?, cover: UIImage?)] = [
        (ratio: 1.78,
         url: URL(string: "http://vfx.mtime.cn/Video/2019/03/21/mp4/190321153853126488.mp4"),
         cover: UIImage(named: "190321153853126488")),
        (ratio: 2.4,
         url: URL(string: "http://vfx.mtime.cn/Video/2019/02/04/mp4/190204084208765161.mp4"),
         cover: UIImage(named: "190204084208765161")),
        (ratio: 1.78,
         url: URL(string: "http://vfx.mtime.cn/Video/2019/03/19/mp4/190319222227698228.mp4"),
         cover: UIImage(named: "190319222227698228")),
        (ratio: 2.39,
         url: URL(string: "http://vfx.mtime.cn/Video/2019/03/19/mp4/190319212559089721.mp4"),
         cover: UIImage(named: "190319212559089721")),
        (ratio: 0.5, nil, nil),
        (ratio: 2.39,
         url: URL(string: "http://vfx.mtime.cn/Video/2019/03/18/mp4/190318231014076505.mp4"),
         cover: UIImage(named: "190318231014076505")),
        (ratio: 0.5, nil, nil),
    ]
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        VideoListAutoPlayManager.shared.scrollViewDidScroll(tableView)
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.bounds.width / cellInfos[indexPath.row].ratio
    }
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellInfos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellInfo = cellInfos[indexPath.row]
        if let url = cellInfo.url {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "VideoControllerCell") as! VideoControllerCell
            cell.url = url
            cell.cover = cellInfo.cover
            cell.delegate = self
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "VideoControllerEmptyCell")!
            return cell
        }
    }
}

extension ViewController: VideoControllerCellDelegate {
    func videoControllerCell(_ cell: VideoControllerCell, didClickToPlay videoURL: URL) {
        VideoListAutoPlayManager.shared.play(at: cell, on: tableView)
    }
}
