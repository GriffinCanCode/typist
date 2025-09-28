import SwiftUI

// MARK: - Glassmorphism Background

/// A glassmorphism background view with blur, gradient, and border effects
struct GlassmorphismBackground: View {
    var body: some View {
        ZStack {
            // Base blur background
            RoundedRectangle(cornerRadius: 25)
                .fill(.ultraThinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.25),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
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
        }
    }
}

// MARK: - Glass Card Background

/// A variant glassmorphism background for cards and containers
struct GlassCardBackground: View {
    let cornerRadius: CGFloat
    
    init(cornerRadius: CGFloat = 16) {
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(.regularMaterial)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.15),
                                Color.white.opacity(0.02)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.4),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            )
    }
}

#Preview("Glassmorphism Backgrounds") {
    ZStack {
        // Background gradient for preview
        LinearGradient(
            colors: [.blue, .purple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        VStack(spacing: 20) {
            // Main glassmorphism background
            Text("Main Glass Background")
                .padding(20)
                .background(GlassmorphismBackground())
            
            // Card variant
            Text("Glass Card Background")
                .padding(20)
                .background(GlassCardBackground())
        }
        .padding()
    }
}
