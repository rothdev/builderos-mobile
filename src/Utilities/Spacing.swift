//
//  Spacing.swift
//  BuilderOS
//
//  Design system spacing and layout constants
//

import SwiftUI

// MARK: - Spacing Constants
enum Spacing {
    /// 4pt - Minimal spacing
    static let xs: CGFloat = 4

    /// 8pt - Small spacing
    static let sm: CGFloat = 8

    /// 12pt - Compact spacing
    static let md: CGFloat = 12

    /// 16pt - Default spacing
    static let base: CGFloat = 16

    /// 24pt - Large spacing
    static let lg: CGFloat = 24

    /// 32pt - Extra large spacing
    static let xl: CGFloat = 32

    /// 48pt - Extra extra large spacing
    static let xxl: CGFloat = 48

    /// 64pt - Massive spacing
    static let xxxl: CGFloat = 64
}

// MARK: - Corner Radius Constants
enum CornerRadius {
    /// 4pt - Minimal rounding
    static let xs: CGFloat = 4

    /// 8pt - Small rounding
    static let sm: CGFloat = 8

    /// 12pt - Default rounding
    static let md: CGFloat = 12

    /// 16pt - Large rounding
    static let lg: CGFloat = 16

    /// 20pt - Extra large rounding
    static let xl: CGFloat = 20

    /// Circle (50% of height)
    static let circle: CGFloat = 9999
}

// MARK: - Icon Sizes
enum IconSize {
    /// 16pt - Small icon
    static let sm: CGFloat = 16

    /// 24pt - Default icon
    static let md: CGFloat = 24

    /// 32pt - Large icon
    static let lg: CGFloat = 32

    /// 48pt - Extra large icon
    static let xl: CGFloat = 48

    /// 64pt - Hero icon
    static let xxl: CGFloat = 64
}

// MARK: - Layout Constants
enum Layout {
    /// 44pt - Minimum touch target (Apple HIG)
    static let minTouchTarget: CGFloat = 44

    /// 48pt - Comfortable touch target
    static let touchTarget: CGFloat = 48

    /// 56pt - Large touch target
    static let largeTouchTarget: CGFloat = 56

    /// Screen edge padding
    static let screenPadding: CGFloat = 20

    /// Card padding
    static let cardPadding: CGFloat = 16

    /// List item height
    static let listItemHeight: CGFloat = 60
}

// MARK: - Animation Constants
enum AnimationDuration {
    /// 0.15s - Fast animation
    static let fast: Double = 0.15

    /// 0.25s - Default animation
    static let normal: Double = 0.25

    /// 0.35s - Slow animation
    static let slow: Double = 0.35

    /// 0.5s - Very slow animation
    static let verySlow: Double = 0.5
}

// MARK: - Spring Animation Presets
extension Animation {
    /// Fast spring animation (quick response)
    static var springFast: Animation {
        .spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)
    }

    /// Normal spring animation (balanced)
    static var springNormal: Animation {
        .spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0)
    }

    /// Bouncy spring animation (playful)
    static var springBouncy: Animation {
        .spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0)
    }
}
