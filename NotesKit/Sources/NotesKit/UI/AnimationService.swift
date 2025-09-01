import SwiftUI
import Combine

/// Service for managing animations and transitions in the Notes app
public class AnimationService: ObservableObject {
    @Published public var isAnimating = false
    
    public init() {}
    
    // MARK: - Spring Animations
    
    /// Spring animation for note creation
    public static func noteCreationSpring() -> Animation {
        .spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0.3)
    }
    
    /// Spring animation for note deletion
    public static func noteDeletionSpring() -> Animation {
        .spring(response: 0.4, dampingFraction: 0.9, blendDuration: 0.2)
    }
    
    /// Spring animation for note updates
    public static func noteUpdateSpring() -> Animation {
        .spring(response: 0.5, dampingFraction: 0.85, blendDuration: 0.25)
    }
    
    // MARK: - Easing Animations
    
    /// Smooth easing animation for transitions
    public static func smoothEasing() -> Animation {
        .easeInOut(duration: 0.3)
    }
    
    /// Quick easing animation for micro-interactions
    public static func quickEasing() -> Animation {
        .easeInOut(duration: 0.15)
    }
    
    // MARK: - Custom Transitions
    
    /// Slide transition for note details
    public static func slideTransition() -> AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }
    
    /// Scale transition for note creation
    public static func scaleTransition() -> AnyTransition {
        .scale(scale: 0.8, anchor: .center)
            .combined(with: .opacity)
    }
    
    /// Fade transition for note updates
    public static func fadeTransition() -> AnyTransition {
        .opacity.combined(with: .scale(scale: 0.95))
    }
    
    // MARK: - Interactive Animations
    
    /// Bounce animation for button taps
    public static func bounceAnimation() -> Animation {
        .interpolatingSpring(stiffness: 300, damping: 20)
    }
    
    /// Shake animation for validation errors
    public static func shakeAnimation() -> Animation {
        .interpolatingSpring(stiffness: 1000, damping: 5)
    }
    
    // MARK: - Staggered Animations
    
    /// Staggered animation for list items
    public static func staggeredAnimation(delay: Double = 0.1) -> Animation {
        .easeInOut(duration: 0.4).delay(delay)
    }
    
    /// Cascade animation for multiple elements
    public static func cascadeAnimation(baseDelay: Double = 0.05) -> Animation {
        .easeInOut(duration: 0.3).delay(baseDelay)
    }
}

// MARK: - Animation Modifiers

public extension View {
    /// Apply note creation animation
    func noteCreationAnimation() -> some View {
        self.animation(AnimationService.noteCreationSpring(), value: true)
    }
    
    /// Apply note deletion animation
    func noteDeletionAnimation() -> some View {
        self.animation(AnimationService.noteDeletionSpring(), value: true)
    }
    
    /// Apply note update animation
    func noteUpdateAnimation() -> some View {
        self.animation(AnimationService.noteUpdateSpring(), value: true)
    }
    
    /// Apply smooth transition
    func smoothTransition() -> some View {
        self.animation(AnimationService.smoothEasing(), value: true)
    }
    
    /// Apply quick transition
    func quickTransition() -> some View {
        self.animation(AnimationService.quickEasing(), value: true)
    }
    
    /// Apply bounce animation
    func bounceAnimation() -> some View {
        self.animation(AnimationService.bounceAnimation(), value: true)
    }
    
    /// Apply shake animation
    func shakeAnimation() -> some View {
        self.animation(AnimationService.shakeAnimation(), value: true)
    }
}

// MARK: - Animated State Management

public class AnimatedStateManager: ObservableObject {
    @Published public var isVisible = false
    @Published public var isExpanded = false
    @Published public var isHighlighted = false
    
    public init() {}
    
    public func show() {
        withAnimation(AnimationService.smoothEasing()) {
            isVisible = true
        }
    }
    
    public func hide() {
        withAnimation(AnimationService.smoothEasing()) {
            isVisible = false
        }
    }
    
    public func expand() {
        withAnimation(AnimationService.noteCreationSpring()) {
            isExpanded = true
        }
    }
    
    public func collapse() {
        withAnimation(AnimationService.noteDeletionSpring()) {
            isExpanded = false
        }
    }
    
    public func highlight() {
        withAnimation(AnimationService.bounceAnimation()) {
            isHighlighted = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(AnimationService.smoothEasing()) {
                self.isHighlighted = false
            }
        }
    }
}











