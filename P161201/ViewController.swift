//
//  ViewController.swift
//  P161201
//
//  Created by Dylan Wreggelsworth on 12/6/16.
//  Copyright © 2016 Dylan Wreggelsworth. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    let disposeBag = DisposeBag()

    @IBOutlet weak var canvas: UIView!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupTable() {
        MediaLibrary.shared.authorized.bindNext { [unowned self] authorized in
            if authorized {
                _ = MediaLibrary.shared.fetch()
                    .debug()
                    .bindTo(self.tableView.rx.items(cellIdentifier: "TrackCell", cellType: TrackCell.self)) { row, track, cell in
                        cell.configure(row: row, track: track, cell: cell)
                    }

                _ = self.tableView.rx
                    .modelSelected(Track.self)
                    .flatMap({ MediaLibrary.shared.export($0) })
                    .bindNext({
                        print($0.url, "exported...")
                    })
            }
        }.addDisposableTo(disposeBag)
    }

}

