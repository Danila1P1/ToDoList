//
//  TaskDetailTextView.swift
//  ToDoList
//
//  Created by Danila Petrov on 23.04.2025.
//

import UIKit

final class TaskDetailTextView: UITextView {

    // MARK: - Public Properties
    
    public var nextTextView: UIResponder?

    public var placeholder: String? {
        didSet {
            placeholderLabel.text = placeholder
        }
    }

    public var textFont: UIFont? {
        didSet {
            font = textFont
            placeholderLabel.font = textFont
        }
    }

    public override var text: String! {
        didSet {
            placeholderLabel.isHidden = !text.isEmpty
        }
    }

    // MARK: - Constructors

    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)

        setupUI()
        setupConstraints()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupUI()
        setupConstraints()
    }

    // MARK: - Private Properties

    private let placeholderLabel = UILabel()
}

// MARK: - Private Nested Types

private extension TaskDetailTextView {

    enum Constants {
        static let placeholderTopPadding: CGFloat = 8.0
        static let placeholderHorizontalPadding: CGFloat = 5.0
    }
}

// MARK: - Private Properties

private extension TaskDetailTextView {

    func setupUI() {
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.textColor = .secondaryLabel
        placeholderLabel.isHidden = !text.isEmpty

        textColor = .label
        delegate = self
        isScrollEnabled = false

        addSubview(placeholderLabel)
    }

    func setupConstraints() { 
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.placeholderTopPadding),
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.placeholderHorizontalPadding),
            placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.placeholderHorizontalPadding)
        ])
    }
}

// MARK: - UITextViewDelegate

extension TaskDetailTextView: UITextViewDelegate {

    public func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !text.isEmpty
    }

    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            if textView == self, let next = nextTextView {
                next.becomeFirstResponder()
            } else {
                let newText = (textView.text as NSString?)?.replacingCharacters(in: range, with: "\n")
                textView.text = newText
            }
            return false
        }
        return true
    }
}
