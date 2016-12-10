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
import GistSwift

class ViewController: UIViewController {

    let disposeBag = DisposeBag()

    @IBOutlet weak var canvas: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var peakPowerLabel: UILabel!


    let player = AVAudioPlayerNode()
    let engine = AVAudioEngine()

    let decay = 0.75
    var peakEnergy: Float = 0.0
    var rms: Float = 0.0
    var centroid: Float = 0.0
    var pitch: Float = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        let displayLink = CADisplayLink(target: self, selector: #selector(updateMeter))
        displayLink.add(to: RunLoop.main, forMode: .commonModes)
    }
    
    @objc func updateMeter() {
        UIView.animate(withDuration: 0.15, delay: 0, options: .allowUserInteraction, animations: {
            let base = self.pitch
            self.canvas.backgroundColor = UIColor(colorLiteralRed: self.peakEnergy - (base / Float(4.0)), green: self.centroid - (base / Float(4.0)), blue: self.rms - (base / Float(4.0)), alpha: 1.0)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc
    func handleCanvasTap(sender: UITapGestureRecognizer) {
        player.stop()
    }

    func setup() {
        canvas.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleCanvasTap)))

        MPMediaLibrary.requestAuthorization({ [unowned self] state in
            switch state {
            case .authorized:
                // Need to jump back to main thread...
                DispatchQueue.main.async {

                    self.engine.attach(self.player)
                    self.engine.connect(self.player, to: self.engine.outputNode, format: nil)
                    self.engine.prepare()
                    try? self.engine.start()

                    MediaLibrary.shared.fetch()
                        .bindTo(self.tableView.rx.items(cellIdentifier: "TrackCell", cellType: TrackCell.self)) { row, track, cell in
                            cell.configure(row: row, track: track, cell: cell)
                        }.addDisposableTo(self.disposeBag)

                    self.tableView.rx
                        .modelSelected(Track.self)
                        .flatMap({ MediaLibrary.shared.export($0) })
                        .bindNext({ avFile in

                            self.player.stop()
                            print(avFile.url, "exported...")

                            let gist = Gist(frameSize: 1024, sampleRate: Int(avFile.fileFormat.sampleRate))

                            self.player.scheduleFile(avFile, at: AVAudioTime(from: 0))
                            self.player.play()
                            self.player.removeTap(onBus: 0)

                            let tap: AVAudioNodeTapBlock = { (buffer, time) in
                                buffer.frameLength = 1024 // Speed things up.

                                let leftChannel = buffer.floatChannelData![0].withMemoryRebound(to: Float.self, capacity: Int(buffer.frameLength)) { $0 }
                                gist.processAudio(frame: Array(UnsafeBufferPointer<Float>(start: leftChannel, count: 1024)))
                                DispatchQueue.main.async {
                                    self.peakEnergy = gist.peakEnergy()
                                    self.rms        = gist.rootMeanSquare()
                                    self.centroid   = min(gist.spectralCentroid() / 256, 1.0)
                                    self.pitch   = min(gist.pitch() / 256, 1.0)
                                }
                            }

                            self.player.installTap(onBus: 0, bufferSize: 1024, format: self.player.outputFormat(forBus: 0), block: tap)
                        }).addDisposableTo(self.disposeBag)
                }

            default:
                print("not authorized")
            }
        })
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

