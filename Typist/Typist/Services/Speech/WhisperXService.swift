import Foundation

/// Swift service wrapper for the WhisperX Python transcription service
/// 
/// This service manages the lifecycle of WhisperX transcription requests with proper resource cleanup:
/// - Each transcription runs in a separate Python process for isolation
/// - Models are automatically cleaned up after each request via context manager
/// - GPU/MPS memory is properly cleared to prevent accumulation
/// - Process termination ensures complete resource cleanup
class WhisperXService {
    private let pythonExecutable = "/usr/bin/python3"
    private let scriptName = "whisperx_service.py"
    
    /// Check if WhisperX service is available
    /// - Parameter completion: Completion handler with availability status
    func checkAvailability(completion: @escaping (Bool) -> Void) {
        let scriptPath = getScriptPath()
        let available = FileManager.default.fileExists(atPath: scriptPath) && 
                       FileManager.default.fileExists(atPath: pythonExecutable)
        
        if available {
            // Test if Python dependencies are installed
            testPythonDependencies { dependenciesAvailable in
                completion(dependenciesAvailable)
            }
        } else {
            completion(false)
        }
    }
    
    /// Transcribe audio using WhisperX Python service
    /// - Parameter audioURL: URL to the audio file to transcribe
    /// - Returns: Transcribed text
    /// - Throws: WhisperXError on failure
    func transcribe(audioURL: URL) async throws -> String {
        let scriptPath = getScriptPath()
        let audioPath = audioURL.path
        
        guard FileManager.default.fileExists(atPath: scriptPath) else {
            throw WhisperXError.serviceNotFound
        }
        
        guard FileManager.default.fileExists(atPath: audioPath) else {
            throw WhisperXError.audioFileNotFound
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            runPythonScript(scriptPath: scriptPath, audioPath: audioPath) { result in
                switch result {
                case .success(let transcription):
                    continuation.resume(returning: transcription)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Get the path to the WhisperX Python script
    /// - Returns: Full path to the script
    private func getScriptPath() -> String {
        // First try to find script in app bundle
        if let bundlePath = Bundle.main.path(forResource: "whisperx_service", ofType: "py") {
            return bundlePath
        }
        
        // Fall back to script in Services/Python directory
        let projectRoot = FileManager.default.currentDirectoryPath
        return "\(projectRoot)/Services/Python/whisperx_service.py"
    }
    
    /// Test if Python dependencies are installed
    /// - Parameter completion: Completion handler with test result
    private func testPythonDependencies(completion: @escaping (Bool) -> Void) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: pythonExecutable)
        process.arguments = ["-c", "import whisperx; print('Dependencies available')"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let success = process.terminationStatus == 0
            completion(success)
        } catch {
            print("Failed to test Python dependencies: \(error)")
            completion(false)
        }
    }
    
    /// Run the WhisperX Python script
    /// - Parameters:
    ///   - scriptPath: Path to the Python script
    ///   - audioPath: Path to the audio file
    ///   - completion: Completion handler with result
    private func runPythonScript(scriptPath: String, 
                                audioPath: String, 
                                completion: @escaping (Result<String, WhisperXError>) -> Void) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: pythonExecutable)
        process.arguments = [scriptPath, audioPath]
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        // Set working directory to the script's directory
        process.currentDirectoryURL = URL(fileURLWithPath: scriptPath).deletingLastPathComponent()
        
        do {
            try process.run()
            
            // Read output and error asynchronously
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            
            process.waitUntilExit()
            
            if process.terminationStatus == 0 {
                // Parse successful response
                if let outputString = String(data: outputData, encoding: .utf8) {
                    parseWhisperXResponse(outputString, completion: completion)
                } else {
                    completion(.failure(.invalidResponse))
                }
            } else {
                // Handle error
                let errorString = String(data: errorData, encoding: .utf8) ?? "Unknown error"
                print("WhisperX Python script error: \(errorString)")
                completion(.failure(.transcriptionFailed(errorString)))
            }
            
        } catch {
            print("Failed to run WhisperX Python script: \(error)")
            completion(.failure(.processError(error)))
        }
    }
    
    /// Parse the JSON response from WhisperX Python service
    /// - Parameters:
    ///   - response: JSON response string
    ///   - completion: Completion handler with parsed result
    private func parseWhisperXResponse(_ response: String, 
                                     completion: @escaping (Result<String, WhisperXError>) -> Void) {
        guard let data = response.data(using: .utf8) else {
            completion(.failure(.invalidResponse))
            return
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                
                if let error = json["error"] as? String {
                    completion(.failure(.transcriptionFailed(error)))
                    return
                }
                
                if let success = json["success"] as? Bool, success,
                   let text = json["text"] as? String {
                    completion(.success(text.trimmingCharacters(in: .whitespacesAndNewlines)))
                } else {
                    completion(.failure(.transcriptionFailed("No text in response")))
                }
            } else {
                completion(.failure(.invalidResponse))
            }
        } catch {
            print("Failed to parse WhisperX response: \(error)")
            completion(.failure(.jsonParsingError(error)))
        }
    }
}

// MARK: - Error Types

enum WhisperXError: LocalizedError {
    case serviceNotFound
    case audioFileNotFound
    case processError(Error)
    case transcriptionFailed(String)
    case invalidResponse
    case jsonParsingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .serviceNotFound:
            return "WhisperX Python service not found"
        case .audioFileNotFound:
            return "Audio file not found"
        case .processError(let error):
            return "Process error: \(error.localizedDescription)"
        case .transcriptionFailed(let message):
            return "Transcription failed: \(message)"
        case .invalidResponse:
            return "Invalid response from WhisperX service"
        case .jsonParsingError(let error):
            return "JSON parsing error: \(error.localizedDescription)"
        }
    }
}
