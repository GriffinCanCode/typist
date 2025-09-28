import Foundation

// MARK: - String Extensions

extension String {
    /// Remove leading and trailing whitespace and newlines
    var trimmed: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Check if string is empty or contains only whitespace
    var isBlank: Bool {
        return trimmed.isEmpty
    }
    
    /// Capitalize only the first letter of the string
    var capitalizedFirst: String {
        guard !isEmpty else { return self }
        return prefix(1).capitalized + dropFirst()
    }
    
    /// Clean up text for voice transcription (remove extra spaces, fix punctuation)
    var cleanedForTranscription: String {
        return self
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ,", with: ",")
            .replacingOccurrences(of: " .", with: ".")
            .replacingOccurrences(of: " !", with: "!")
            .replacingOccurrences(of: " ?", with: "?")
    }
}

// MARK: - URL Extensions

extension URL {
    /// Check if the URL points to an audio file
    var isAudioFile: Bool {
        let audioExtensions = ["wav", "mp3", "m4a", "aac", "flac", "ogg", "wma"]
        return audioExtensions.contains(pathExtension.lowercased())
    }
    
    /// Get file size in bytes
    var fileSize: Int64? {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: path)
            return attributes[.size] as? Int64
        } catch {
            return nil
        }
    }
    
    /// Format file size as human readable string
    var fileSizeFormatted: String? {
        guard let size = fileSize else { return nil }
        return ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
}

// MARK: - Date Extensions

extension Date {
    /// Format date for logging
    var logTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter.string(from: self)
    }
    
    /// Format date for file names
    var fileTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        return formatter.string(from: self)
    }
    
    /// Check if date is within the last few seconds
    func isWithinLastSeconds(_ seconds: TimeInterval) -> Bool {
        return Date().timeIntervalSince(self) <= seconds
    }
}

// MARK: - TimeInterval Extensions

extension TimeInterval {
    /// Format time interval as human readable duration
    var formattedDuration: String {
        let hours = Int(self) / 3600
        let minutes = (Int(self) % 3600) / 60
        let seconds = Int(self) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    /// Convert to milliseconds
    var milliseconds: Int {
        return Int(self * 1000)
    }
}

// MARK: - UserDefaults Extensions

extension UserDefaults {
    /// Get enum value from UserDefaults
    func enumValue<T: RawRepresentable>(forKey key: String, type: T.Type) -> T? where T.RawValue == String {
        guard let rawValue = string(forKey: key) else { return nil }
        return T(rawValue: rawValue)
    }
    
    /// Set enum value to UserDefaults
    func set<T: RawRepresentable>(_ value: T, forKey key: String) where T.RawValue == String {
        set(value.rawValue, forKey: key)
    }
    
    /// Safely get URL from UserDefaults
    func url(forKey key: String) -> URL? {
        guard let urlString = string(forKey: key) else { return nil }
        return URL(string: urlString)
    }
    
    /// Safely set URL to UserDefaults
    func set(_ url: URL?, forKey key: String) {
        set(url?.absoluteString, forKey: key)
    }
}

// MARK: - Bundle Extensions

extension Bundle {
    /// App version string
    var versionString: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    /// App build number
    var buildString: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
    
    /// Full version and build string
    var fullVersionString: String {
        return "\(versionString) (\(buildString))"
    }
    
    /// App bundle identifier
    var bundleID: String {
        return bundleIdentifier ?? "unknown.app"
    }
}
