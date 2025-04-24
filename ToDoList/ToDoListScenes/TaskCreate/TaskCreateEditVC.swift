//
//  TaskCreateVC.swift
//  ToDoList
//
//  Created by Danila Petrov on 23.04.2025.
//

import UIKit

// MARK: - TaskCreateEditDelegate

protocol TaskCreateEditDelegate: AnyObject {

    func taskDidCreateOrUpdate()
}

// MARK: - TaskCreateEditVC

final class TaskCreateEditVC: UIViewController {

    // MARK: - Public Properties

    weak var delegate: TaskCreateEditDelegate?

    // MARK: - Constructors

    init(taskToEdit: Task? = nil) {
        self.taskToEdit = taskToEdit
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - VC Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        setupUI()
        setupConstraints()
        configure()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        saveTaskIfNeeded()
    }

    // MARK: - Private Properties

    private let titleTextView = TaskDetailTextView()
    private let descriptionTextView = TaskDetailTextView()
    private let dateLabel = UILabel()
    private var taskToEdit: Task?
}

// MARK: - Private Nested Types

private extension TaskCreateEditVC {

    enum Constants {
        static let titleFontSize: CGFloat = 34.0
        static let dateFontSize: CGFloat = 16.0
        static let descriptionFontSize: CGFloat = 16.0

        static let titleTopPadding: CGFloat = 8.0
        static let titleHorizontalPadding: CGFloat = 15.0

        static let dateTopPadding: CGFloat = 8.0
        static let dateHorizontalPadding: CGFloat = 20.0

        static let descriptionTopPadding: CGFloat = 16.0
        static let descriptionHorizontalPadding: CGFloat = 15.0
    }
}

// MARK: - Private Methods

private extension TaskCreateEditVC {

    // MARK: - UI

    func setupNavigation() {
        navigationController?.navigationBar.tintColor = .systemYellow
    }

    func setupUI() {
        view.backgroundColor = .systemBackground

        titleTextView.textFont = .systemFont(ofSize: Constants.titleFontSize, weight: .bold)
        titleTextView.placeholder = Strings.newTaskTitlePlaceholder
        titleTextView.returnKeyType = .next
        titleTextView.nextTextView = descriptionTextView
        titleTextView.translatesAutoresizingMaskIntoConstraints = false

        dateLabel.font = .systemFont(ofSize: Constants.dateFontSize)
        dateLabel.textColor = .secondaryLabel
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        descriptionTextView.textFont = .systemFont(ofSize: Constants.descriptionFontSize)
        descriptionTextView.placeholder = Strings.newTaskDescriptionPlaceholder
        descriptionTextView.returnKeyType = .done
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleTextView)
        view.addSubview(dateLabel)
        view.addSubview(descriptionTextView)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.titleTopPadding),
            titleTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.titleHorizontalPadding),
            titleTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.titleHorizontalPadding),

            dateLabel.topAnchor.constraint(equalTo: titleTextView.bottomAnchor, constant: Constants.dateTopPadding),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.dateHorizontalPadding),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.dateHorizontalPadding),

            descriptionTextView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: Constants.descriptionTopPadding),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.descriptionHorizontalPadding),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.descriptionHorizontalPadding)
        ])
    }

    func configure() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"

        if let task = taskToEdit {
            titleTextView.text = task.title
            descriptionTextView.text = task.descriptionText
            dateLabel.text = formatter.string(from: task.createdAt)
        } else {
            dateLabel.text = formatter.string(from: Date())
        }
    }

    func saveTaskIfNeeded() {
        guard let titleText = titleTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !titleText.isEmpty else { return }

        let newTask = Task(
            id: taskToEdit?.id ?? Int64(),
            title: titleText,
            descriptionText: descriptionTextView.text ?? "",
            isCompleted: taskToEdit?.isCompleted ?? false,
            createdAt: taskToEdit?.createdAt ?? Date()
        )

        if taskToEdit != nil {
            CoreDataManager.shared.update(newTask)
        } else {
            CoreDataManager.shared.create(newTask)
        }

        delegate?.taskDidCreateOrUpdate()
        navigationController?.popViewController(animated: true)
    }
}
