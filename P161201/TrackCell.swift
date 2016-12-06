//
//  TrackCell.swift
//  P161201
//
//  Created by Dylan Wreggelsworth on 12/6/16.
//  Copyright © 2016 Dylan Wreggelsworth. All rights reserved.
//

import UIKit

class TrackCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!

    public func configure(row: Int, track: Track, cell: TrackCell) {
        titleLabel.text = "\(track.title) - \(track.artist)"
        durationLabel.text = "\(track.duration)"
    }
}
