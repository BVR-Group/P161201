//
//  MediaLibrary.swift
//  P161201
//
//  Created by Dylan Wreggelsworth on 12/6/16.
//  Copyright © 2016 Dylan Wreggelsworth. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer
import RxSwift
import RxCocoa

class MediaLibrary {
    static let shared = MediaLibrary()

    private let bgScheduler = ConcurrentDispatchQueueScheduler(qos: .background)

    private let songsQuery = MPMediaQuery.songs()

    public var authorized = Observable<Bool>
        .create({ (observer: AnyObserver<Bool>) -> Disposable in
            MPMediaLibrary.requestAuthorization({ status in
                switch status {
                case .authorized:
                    observer.onNext(true)
                default:
                    observer.onNext(false)
                }
                observer.onCompleted()
            })
            return Disposables.create()
        })
        .debug()
        .observeOn(MainScheduler.instance)
        .startWith(false)
        .distinctUntilChanged()

    func fetch() -> Observable<[Track]> {
        return Observable<[Track]>.create({ observer in
            self.songsQuery.addFilterPredicate(
                MPMediaPropertyPredicate(value: false, forProperty: MPMediaItemPropertyIsCloudItem)
            )
            if let items = self.songsQuery.items {
                let tracks = items.filter({ $0.hasDRM == false })
                                  .map({ Track(from: $0) })
                observer.onNext(tracks)
            }
            observer.onCompleted()
            return Disposables.create()
        })
    }

    func export(_ track: Track) -> Observable<AVAudioFile> {
        return Observable.deferred {
            return track.mediaItem
                .export()
                .observeOn(self.bgScheduler)
        }
    }
}
