//
//  Track.swift
//  P161201
//
//  Created by Dylan Wreggelsworth on 12/6/16.
//  Copyright © 2016 Dylan Wreggelsworth. All rights reserved.
//

import Foundation
import MediaPlayer

struct Track {
    let id: UInt64
    let title: String
    let artist: String
    let duration: TimeInterval
    let albumArt: UIImage?
    let mediaItem: MPMediaItem

    init(from mediaItem: MPMediaItem) {
        self.id          = mediaItem.persistentID
        self.title       = mediaItem.title ?? "Untitled"
        self.artist      = mediaItem.artist ?? "Unknown Artist"
        self.duration    = mediaItem.playbackDuration
        self.albumArt    = mediaItem.artwork?.image(at: CGSize(width: 256, height: 256))
        self.mediaItem   = mediaItem
    }

}

extension Track: Hashable {
    var hashValue: Int {
        return Int(id)
    }
    static func ==(lhs: Track, rhs: Track) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

