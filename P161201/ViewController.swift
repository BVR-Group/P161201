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
        MPMediaLibrary.requestAuthorization({ [unowned self] state in
            switch state {
            case .authorized:
                // Need to jump back to main thread...
                DispatchQueue.main.async {
                    MediaLibrary.shared.fetch()
                        .bindTo(self.tableView.rx.items(cellIdentifier: "TrackCell", cellType: TrackCell.self)) { row, track, cell in
                            cell.configure(row: row, track: track, cell: cell)
                        }.addDisposableTo(self.disposeBag)

                    self.tableView.rx
                        .modelSelected(Track.self)
                        .flatMap({ MediaLibrary.shared.export($0) })
                        .bindNext({
                            print($0.url, "exported...")
                        }).addDisposableTo(self.disposeBag)
                }

            default:
                print("not authorized")
            }
        })
    }

}

