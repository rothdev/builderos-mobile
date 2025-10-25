//
//  TerminalKeyboardAccessoryView.swift
//  BuilderOS
//
//  Mobile-optimized keyboard toolbar for terminal special keys
//

import UIKit
import SwiftUI

class TerminalKeyboardAccessoryView: UIView {
    private let onKeyPress: (TerminalKey) -> Void
    private let onDismiss: () -> Void

    init(onKeyPress: @escaping (TerminalKey) -> Void, onDismiss: @escaping () -> Void) {
        self.onKeyPress = onKeyPress
        self.onDismiss = onDismiss

        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))

        setupToolbar()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupToolbar() {
        // Background
        backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.95)

        // Scroll view for horizontal scrolling
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)

        // Stack view for buttons
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)

        // Add all keys
        for key in TerminalKey.allCases {
            let button = createKeyButton(for: key)
            stackView.addArrangedSubview(button)
        }

        // Add dismiss keyboard button
        let dismissButton = createDismissButton()
        stackView.addArrangedSubview(dismissButton)

        // Constraints
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            scrollView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),

            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
    }

    private func createKeyButton(for key: TerminalKey) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(key.rawValue, for: .normal)
        button.titleLabel?.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(white: 0.3, alpha: 0.6)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)

        // Minimum tap target size (44pt per Apple HIG)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: 36),
            button.widthAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])

        button.addTarget(self, action: #selector(keyButtonTapped(_:)), for: .touchUpInside)
        button.tag = TerminalKey.allCases.firstIndex(of: key) ?? 0

        return button
    }

    private func createDismissButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "keyboard.chevron.compact.down"), for: .normal)
        button.tintColor = .systemGray
        button.backgroundColor = UIColor(white: 0.2, alpha: 0.6)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)

        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 36),
            button.widthAnchor.constraint(equalToConstant: 44)
        ])

        button.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)

        return button
    }

    @objc private func keyButtonTapped(_ sender: UIButton) {
        guard sender.tag >= 0 && sender.tag < TerminalKey.allCases.count else { return }
        let key = TerminalKey.allCases[sender.tag]

        // Visual feedback
        UIView.animate(withDuration: 0.1, animations: {
            sender.alpha = 0.5
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                sender.alpha = 1.0
            }
        }

        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        onKeyPress(key)
    }

    @objc private func dismissButtonTapped() {
        onDismiss()
    }
}
