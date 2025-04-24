//
//  TaskCell.swift
//  ToDoList
//
//  Created by Danila Petrov on 21.04.2025.
//

import UIKit

// MARK: - TaskCellDeleate

protocol TaskCellDelegate: AnyObject {
    func didToggleComplete(for task: Task)
}

// MARK: - TaskCell

final class TaskCell: UITableViewCell {
    
    // MARK: - ReuseID

    static let reuseId = "TaskCell"

    // MARK: - Public Properties
    
    weak var delegate: TaskCellDelegate?

    // MARK: - Constructors

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("Init(coder:) has not been implemented")
    }

    // MARK: - Private Properties

    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let dateLabel = UILabel()
    private let statusButton = UIButton(type: .system)
    private let textStack = UIStackView()
    private var currentTask: Task?

    // MARK: - Public Methods

    func configure(with task: Task) {
        currentTask = task
        descriptionLabel.text = task.descriptionText
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        dateLabel.text = formatter.string(from: task.createdAt)

        if task.isCompleted {
            let labelAttributes: [NSAttributedString.Key: Any] = [
                .strikethroughStyle: NSUnderlineStyle.single.rawValue
            ]
            titleLabel.textColor = .secondaryLabel
            titleLabel.attributedText = NSAttributedString(string: task.title, attributes: labelAttributes)
            descriptionLabel.textColor = .secondaryLabel
            statusButton.setImage(Icons.checkCircle_24, for: .normal)
        } else {
            titleLabel.textColor = .label
            titleLabel.attributedText = nil
            titleLabel.text = task.title
            descriptionLabel.textColor = .label
            statusButton.setImage(Icons.circle_24, for: .normal)
        }
    }
}

// MARK: - Private Nested Types

private extension TaskCell {

    enum Constants {
        static let titleFontSize: CGFloat = 16.0
        static let descriptionFontSize: CGFloat = 12.0
        static let dateFontSize: CGFloat = 12.0

        static let statusButtonHeight: CGFloat = 24.0
        static let statusButtonWidth: CGFloat = 24.0

        static let textStackSpacing: CGFloat = 6.0

        static let topPadding: CGFloat = 12.0
        static let bottomPadding: CGFloat = -12.0
        static let textStackLeadingPadding: CGFloat = 8.0

        static let descriptionNumberOfLines: Int = 2
    }
}

// MARK: - Private Methods

private extension TaskCell {
    
    // MARK: - UI

    func setupUI() {
        backgroundColor = .clear

        titleLabel.font = .systemFont(ofSize: Constants.titleFontSize, weight: .semibold)
        descriptionLabel.font = .systemFont(ofSize: Constants.descriptionFontSize)
        descriptionLabel.numberOfLines = Constants.descriptionNumberOfLines
        dateLabel.font = .systemFont(ofSize: Constants.dateFontSize)
        dateLabel.textColor = .secondaryLabel

        statusButton.translatesAutoresizingMaskIntoConstraints = false
        statusButton.addAction(UIAction { [weak self] _ in self?.handleTap() }, for: .touchUpInside)


        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(descriptionLabel)
        textStack.addArrangedSubview(dateLabel)
        textStack.axis = .vertical
        textStack.spacing = Constants.textStackSpacing
        textStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(statusButton)
        contentView.addSubview(textStack)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            statusButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            statusButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.topPadding),
            statusButton.widthAnchor.constraint(equalToConstant: Constants.statusButtonWidth),
            statusButton.heightAnchor.constraint(equalToConstant: Constants.statusButtonHeight),

            textStack.leadingAnchor.constraint(equalTo: statusButton.trailingAnchor, constant: Constants.textStackLeadingPadding),
            textStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.topPadding),
            textStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            textStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: Constants.bottomPadding)
        ])
    }

    // MARK: - Actions

    func handleTap() {
        guard let task = currentTask else { return }
        delegate?.didToggleComplete(for: task)
    }
}
