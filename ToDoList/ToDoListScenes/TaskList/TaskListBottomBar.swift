//
//  TaskListBottomBar.swift
//  ToDoList
//
//  Created by Danila Petrov on 22.04.2025.
//

import UIKit

final class TaskListBottomBar: UIView {

    // MARK: - Public Properties

    let addTaskButton = UIButton(type: .system)
    let taskCountLabel = UILabel()

    // MARK: - Constructors

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupView()
        setupConstraints()
    }
}

// MARK: - Private Nested Types

private extension TaskListBottomBar {

    enum Constants {
        static let labelFontSize: CGFloat = 11.0

        static let height: CGFloat = 83.0
        static let buttonTrailingPadding: CGFloat = -20.0
    }
}

// MARK: - Private Methods

private extension TaskListBottomBar {

    func setupView() {
        backgroundColor = .secondarySystemBackground

        taskCountLabel.translatesAutoresizingMaskIntoConstraints = false
        taskCountLabel.font = UIFont.systemFont(ofSize: Constants.labelFontSize)
        taskCountLabel.textColor = .secondaryLabel

        addTaskButton.translatesAutoresizingMaskIntoConstraints = false
        addTaskButton.setImage(Icons.addTask, for: .normal)

        addSubview(taskCountLabel)
        addSubview(addTaskButton)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: Constants.height),

            taskCountLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            taskCountLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20.5),

            addTaskButton.topAnchor.constraint(equalTo: topAnchor, constant: 13),
            addTaskButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Constants.buttonTrailingPadding)
        ])
    }
}
