//
//  MPMediaItem.swift
//  P161201
//
//  Created by Dylan Wreggelsworth on 12/6/16.
//  Copyright © 2016 Dylan Wreggelsworth. All rights reserved.
//

import Foundation
import MediaPlayer
import AudioToolbox
import RxSwift

extension MPMediaItem {

    var hasDRM: Bool {
        return self.assetURL == nil
    }

    enum ExportError: Error {
        case assetURLNotFound
        case avAudioFileRead
        case assetReader
        case assetWriter
    }

    func export() -> Observable<AVAudioFile> {
        return Observable<AVAudioFile>.create { observer in
            do {
                guard let url = self.assetURL else {
                    throw ExportError.assetURLNotFound
                }
                let asset = AVURLAsset(url: url)

                let exportURL = Location.cache.url.appendingPathComponent("\(self.persistentID)").appendingPathExtension("wav")

                if FileManager.default.fileExists(atPath: exportURL.path) {
                    guard let avAudioFile = try? AVAudioFile(forReading: exportURL) else {
                        throw ExportError.avAudioFileRead
                    }
                    observer.onNext(avAudioFile)
                    observer.onCompleted()
                    return Disposables.create()
                }

                let assetReader = try AVAssetReader(asset: asset)
                let assetReaderOutput = AVAssetReaderAudioMixOutput(audioTracks: asset.tracks, audioSettings: nil)

                if assetReader.canAdd(assetReaderOutput) == false {
                    throw ExportError.assetReader
                }

                assetReader.add(assetReaderOutput)

                let assetWriter = try AVAssetWriter(url: exportURL, fileType: AVFileTypeCoreAudioFormat)

                var outputSettings: [String: Any] = [:]
                outputSettings[AVFormatIDKey]               = kAudioFormatLinearPCM
                outputSettings[AVSampleRateKey]             = 44100.0
                outputSettings[AVNumberOfChannelsKey]       = 2
                outputSettings[AVLinearPCMBitDepthKey]      = 16
                outputSettings[AVLinearPCMIsNonInterleaved] = false
                outputSettings[AVLinearPCMIsFloatKey]       = false
                outputSettings[AVLinearPCMIsBigEndianKey]   = false

                let assetWriterInput = AVAssetWriterInput(mediaType: AVMediaTypeAudio, outputSettings: outputSettings)
                if assetWriter.canAdd(assetWriterInput) == false {
                    throw ExportError.assetWriter
                }

                assetWriter.add(assetWriterInput)

                assetWriterInput.expectsMediaDataInRealTime = false
                assetWriter.startWriting()
                assetReader.startReading()

                let track = asset.tracks.first!
                let cmtStartTime = CMTime(seconds: 0, preferredTimescale: track.naturalTimeScale)
                assetWriter.startSession(atSourceTime: cmtStartTime)

                var convertedByteCount: Int = 0
                var buffers: Float = 0
                let mediaInputQueue = DispatchQueue.init(label: "MPMediaItem.export")

                assetWriterInput.requestMediaDataWhenReady(on: mediaInputQueue) {
                    while assetWriterInput.isReadyForMoreMediaData {
                        guard let next = assetReaderOutput.copyNextSampleBuffer() else {
                            // Finished.
                            assetWriterInput.markAsFinished()
                            assetWriter.finishWriting() {
                                assetReader.cancelReading()
                                guard let file = try? AVAudioFile(forReading: exportURL) else {
                                    observer.onError(ExportError.avAudioFileRead)
                                    return
                                }
                                observer.onNext(file)
                                observer.onCompleted()
                            }
                            break
                        }
                        // Process the next part.
                        assetWriterInput.append(next)
                        convertedByteCount += CMSampleBufferGetTotalSampleSize(next)
                        buffers += 0.0002
                    }
                }
            } catch let error {
                observer.onError(error)
            }

            return Disposables.create()
        }
    }
}
