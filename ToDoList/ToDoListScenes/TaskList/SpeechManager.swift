//
//  SpeechManager.swift
//  ToDoList
//
//  Created by Danila Petrov on 23.04.2025.
//

import Foundation
import Speech
import AVFoundation

final class SpeechManager: NSObject {

    // MARK: - Public Properties

    var onTextRecognition: ((String) -> Void)?
    var onStart: (() -> Void)?
    var onStop: (() -> Void)?

    // MARK: - Private Properties

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ru-RU"))
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var isOnTextRecognition = false

    private var silenceTimer: Timer?
    private let silenceTimeout: TimeInterval = Constants.silenceTimeoutInterval

    // MARK: - Public Methods

    func startRecognition() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            guard status == .authorized else {
                print("Разрешение не получено")
                return
            }

            DispatchQueue.main.async {
                try? self?.startListening()
            }
        }
    }

    func stopRecognition() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()

        recognitionRequest = nil
        recognitionTask = nil
        silenceTimer?.invalidate()

        onStop?()
    }
}

// MARK: - Private Nested Types

private extension SpeechManager {

    enum Constants {
        static let silenceTimeoutInterval: TimeInterval = 2.5

        static let inputNodeOnBus: AVAudioNodeBus = 0
        static let inputNodeBufferSize: AVAudioFrameCount = 1024
    }
}

// MARK: - Private Methods

private extension SpeechManager {

    func startListening() throws {

        if audioEngine.isRunning {
            stopRecognition()
            return
        }

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        onStart?()
        isOnTextRecognition = false

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: Constants.inputNodeOnBus)

        inputNode.removeTap(onBus: Constants.inputNodeOnBus)
        inputNode.installTap(onBus: Constants.inputNodeOnBus, bufferSize: Constants.inputNodeBufferSize, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()


        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest!) { [weak self] result, error in
            guard let self else { return }

            if let result = result, !isOnTextRecognition {
                isOnTextRecognition = true
                self.onTextRecognition?(result.bestTranscription.formattedString)
                self.restartSilenceTimer()
            }

            if error != nil || (result?.isFinal ?? false) {
                self.stopRecognition()
            }
        }

    }

    func restartSilenceTimer() {
        silenceTimer?.invalidate()
        silenceTimer = Timer.scheduledTimer(withTimeInterval: silenceTimeout, repeats: false) { [weak self] _ in
            self?.stopRecognition()
        }
    }
}
