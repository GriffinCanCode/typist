import SwiftUI

// MARK: - Glass Button Style

/// A glassmorphism button style with blur and glass effects
struct GlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(10)
            .background(
                Circle()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Glass Card Button Style

/// A glassmorphism button style for card-like buttons
struct GlassCardButtonStyle: ButtonStyle {
    let cornerRadius: CGFloat
    
    init(cornerRadius: CGFloat = 12) {
        self.cornerRadius = cornerRadius
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Pulsing Button Style

/// A button style with pulsing animation for attention-grabbing elements
struct PulsingButtonStyle: ButtonStyle {
    @State private var isPulsing = false
    let color: Color
    
    init(color: Color = .blue) {
        self.color = color
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(
                Circle()
                    .fill(color.opacity(0.2))
                    .overlay(
                        Circle()
                            .stroke(color, lineWidth: 2)
                    )
                    .scaleEffect(isPulsing ? 1.1 : 1.0)
                    .opacity(isPulsing ? 0.7 : 1.0)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), 
                      value: isPulsing)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .onAppear {
                isPulsing = true
            }
    }
}

#Preview("Button Styles") {
    ZStack {
        // Background for preview
        LinearGradient(
            colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        VStack(spacing: 30) {
            // Glass button
            Button("Glass Button") {}
                .buttonStyle(GlassButtonStyle())
            
            // Glass card button
            Button("Glass Card Button") {}
                .buttonStyle(GlassCardButtonStyle())
            
            // Pulsing button
            Button("Pulsing Button") {}
                .buttonStyle(PulsingButtonStyle())
        }
        .padding()
    }
}
