//
//  SpeechService.swift
//  Jeonghee
//
//  Created by Kang MinSeong on 1/3/26.
//

import AVFoundation

final class SpeechService {

    static let shared = SpeechService()

    private let synthesizer = AVSpeechSynthesizer()

    private init() {}

    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        utterance.rate = 0.45
        synthesizer.speak(utterance)
    }
}
