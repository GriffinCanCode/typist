import SwiftUI

// MARK: - View Extensions

extension View {
    /// Apply glassmorphism effect to any view
    func glassmorphism(cornerRadius: CGFloat = 25) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.6),
                                        Color.white.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
    }
    
    /// Apply a subtle glow effect
    func glow(color: Color = .white, radius: CGFloat = 10) -> some View {
        self
            .shadow(color: color.opacity(0.6), radius: radius / 3, x: 0, y: 0)
            .shadow(color: color.opacity(0.3), radius: radius / 2, x: 0, y: 0)
            .shadow(color: color.opacity(0.1), radius: radius, x: 0, y: 0)
    }
    
    /// Apply a pulsing animation
    func pulsing(duration: TimeInterval = 1.0, minOpacity: Double = 0.3) -> some View {
        self
            .opacity(minOpacity)
            .animation(
                .easeInOut(duration: duration)
                .repeatForever(autoreverses: true),
                value: UUID()
            )
            .onAppear {
                // Trigger the animation
            }
    }
    
    /// Conditional view modifier
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    /// Apply modifier only on certain platforms
    @ViewBuilder
    func macOS<Content: View>(_ modifier: (Self) -> Content) -> some View {
        #if os(macOS)
        modifier(self)
        #else
        self
        #endif
    }
    
    /// Frame with minimum and maximum dimensions
    func flexibleFrame(
        minWidth: CGFloat? = nil,
        maxWidth: CGFloat? = nil,
        minHeight: CGFloat? = nil,
        maxHeight: CGFloat? = nil
    ) -> some View {
        self.frame(
            minWidth: minWidth,
            idealWidth: nil,
            maxWidth: maxWidth,
            minHeight: minHeight,
            idealHeight: nil,
            maxHeight: maxHeight
        )
    }
    
    /// Add a subtle inner shadow
    func innerShadow<S: Shape>(
        using shape: S,
        angle: Angle = .degrees(0),
        color: Color = .black,
        width: CGFloat = 6,
        blur: CGFloat = 6
    ) -> some View {
        let finalX = CGFloat(cos(angle.radians - .pi / 2))
        let finalY = CGFloat(sin(angle.radians - .pi / 2))
        
        return self
            .overlay(
                shape
                    .stroke(color, lineWidth: width)
                    .offset(x: finalX * width * 0.6, y: finalY * width * 0.6)
                    .blur(radius: blur)
                    .mask(shape)
            )
    }
}

// MARK: - Color Extensions

extension Color {
    /// Initialize color from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    /// Convert to hex string
    var hexString: String {
        guard let components = self.cgColor?.components, components.count >= 3 else {
            return "#000000"
        }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        
        return String(format: "#%02lX%02lX%02lX",
                     lroundf(r * 255),
                     lroundf(g * 255),
                     lroundf(b * 255))
    }
    
    /// Create a lighter version of the color
    func lighter(by percentage: CGFloat = 30.0) -> Color {
        return self.adjustBrightness(by: abs(percentage))
    }
    
    /// Create a darker version of the color
    func darker(by percentage: CGFloat = 30.0) -> Color {
        return self.adjustBrightness(by: -1 * abs(percentage))
    }
    
    private func adjustBrightness(by percentage: CGFloat) -> Color {
        guard let components = self.cgColor?.components, components.count >= 3 else {
            return self
        }
        
        let red = min(max(components[0] + (percentage / 100), 0.0), 1.0)
        let green = min(max(components[1] + (percentage / 100), 0.0), 1.0)
        let blue = min(max(components[2] + (percentage / 100), 0.0), 1.0)
        let alpha = components.count >= 4 ? components[3] : 1.0
        
        return Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}

// MARK: - EdgeInsets Extensions

extension EdgeInsets {
    /// Create equal insets for all edges
    static func all(_ value: CGFloat) -> EdgeInsets {
        return EdgeInsets(top: value, leading: value, bottom: value, trailing: value)
    }
    
    /// Create horizontal insets
    static func horizontal(_ value: CGFloat) -> EdgeInsets {
        return EdgeInsets(top: 0, leading: value, bottom: 0, trailing: value)
    }
    
    /// Create vertical insets
    static func vertical(_ value: CGFloat) -> EdgeInsets {
        return EdgeInsets(top: value, leading: 0, bottom: value, trailing: 0)
    }
}

// MARK: - Animation Extensions

extension Animation {
    /// Smooth spring animation
    static var smoothSpring: Animation {
        return .spring(response: 0.5, dampingFraction: 0.8)
    }
    
    /// Bouncy spring animation
    static var bouncySpring: Animation {
        return .spring(response: 0.6, dampingFraction: 0.6)
    }
    
    /// Gentle ease animation
    static var gentleEase: Animation {
        return .easeInOut(duration: 0.4)
    }
}

// MARK: - Binding Extensions

extension Binding {
    /// Create a binding that ignores writes
    static func readonly(_ value: Value) -> Binding<Value> {
        Binding(
            get: { value },
            set: { _ in }
        )
    }
    
    /// Transform a binding's value
    func map<NewValue>(
        get: @escaping (Value) -> NewValue,
        set: @escaping (NewValue) -> Value
    ) -> Binding<NewValue> {
        Binding<NewValue>(
            get: { get(self.wrappedValue) },
            set: { self.wrappedValue = set($0) }
        )
    }
}
