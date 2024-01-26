//
//  Created by Dimitrios Chatzieleftheriou on 11/11/2020.
//  Copyright © 2020 Decimal. All rights reserved.
//

import AVFoundation

protocol AudioEntryProviding {
    func provideAudioEntry(
        url: URL,
        headers: [String: String],
        querys: [URLQueryItem],
        method: AudioRemoteHttpMethod
    ) -> AudioEntry
    func provideAudioEntry(url: URL, headers: [String: String]) -> AudioEntry
    func provideAudioEntry(url: URL) -> AudioEntry
}

final class AudioEntryProvider: AudioEntryProviding {
    private let networkingClient: NetworkingClient
    private let underlyingQueue: DispatchQueue
    private let outputAudioFormat: AVAudioFormat

    init(networkingClient: NetworkingClient,
         underlyingQueue: DispatchQueue,
         outputAudioFormat: AVAudioFormat)
    {
        self.networkingClient = networkingClient
        self.underlyingQueue = underlyingQueue
        self.outputAudioFormat = outputAudioFormat
    }

    func provideAudioEntry(
        url: URL,
        headers: [String: String],
        querys: [URLQueryItem],
        method: AudioRemoteHttpMethod
    ) -> AudioEntry {
        let source = self.source(
            for: url,
            headers: headers,
            querys: querys,
            method: method
        )
        return AudioEntry(
            source: source,
            entryId: AudioEntryId(id: url.absoluteString),
            outputAudioFormat: outputAudioFormat,
            querys: querys,
            method: method
        )
    }

    func provideAudioEntry(
        url: URL,
        headers: [String: String]
    ) -> AudioEntry {
        let source = self.source(for: url, headers: headers, querys: [], method: .GET)
        return AudioEntry(
            source: source,
            entryId: AudioEntryId(id: url.absoluteString),
            outputAudioFormat: outputAudioFormat
        )
    }

    func provideAudioEntry(url: URL) -> AudioEntry {
        provideAudioEntry(url: url, headers: [:])
    }

    func provideAudioSource(
        url: URL,
        headers: [String: String],
        querys: [URLQueryItem],
        method: AudioRemoteHttpMethod
    ) -> AudioStreamSource {
        RemoteAudioSource(
            networking: networkingClient,
            url: url,
            underlyingQueue: underlyingQueue,
            httpHeaders: headers,
            querys: querys,
            method: method
        )
    }

    func provideFileAudioSource(url: URL) -> CoreAudioStreamSource {
        FileAudioSource(url: url, underlyingQueue: underlyingQueue)
    }

    func source(
        for url: URL,
        headers: [String: String],
        querys: [URLQueryItem],
        method: AudioRemoteHttpMethod
    ) -> CoreAudioStreamSource {
        guard !url.isFileURL else {
            return provideFileAudioSource(url: url)
        }
        return provideAudioSource(
            url: url,
            headers: headers,
            querys: querys,
            method: method
        )
    }
}

