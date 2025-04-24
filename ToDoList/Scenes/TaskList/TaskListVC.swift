//
//  ViewController.swift
//  ToDoList
//
//  Created by Danila Petrov on 20.04.2025.
//

import UIKit

protocol TaskListVCDeps: TaskCreateEditVCDeps {
    var taskRepository: ITaskRepository { get }
}

final class TaskListVC: UIViewController {

    // MARK: - Init

    init(deps: TaskListVCDeps) {
        self.deps = deps

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - VC Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupConstraints()
        setupTapToDismissKeyboard()
        loadTasks()
        configureSpeechManagerCallbacks()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Private Properties

    private let titleLabel = UILabel()
    private let emptyStateLabel = UILabel()
    private let tableView = UITableView()
    private let bottomBar = TaskListBottomBar()
    private let speechManager = SpeechManager()
    private var searchBar = UISearchBar()

    private var allTasks: [Task] = []
    private var filteredTasks: [Task] = []
    private var searchWorkItem: DispatchWorkItem?

    private let deps: TaskListVCDeps
}

// MARK: - Private Nested Types

private extension TaskListVC {

    enum Constants {
        static let titleFontSize: CGFloat = 34.0

        static let titleTopPadding: CGFloat = 15.0
        static let titleLeadingPadding: CGFloat = 20.0

        static let emptyStateLabelFontSize: CGFloat = 18.0

        static let searchBarTopPadding: CGFloat = 10.0
        static let searchBarHorizontalPadding: CGFloat = 10.0
        static let searchBarHeight: CGFloat = 36.0

        static let tableViewHorizontalPadding: CGFloat = 20.0
        static let tableViewTopPadding: CGFloat = 16.0

        static let bottomBarHeight: CGFloat = 83.0

        static let searchUpdateDelay: Double = 0.3
    }
}

// MARK: - Private Properties

private extension TaskListVC {

    // MARK: - UI

    func setupUI() {
        titleLabel.text = Strings.taskListTitle
        titleLabel.font = UIFont.systemFont(ofSize: Constants.titleFontSize, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        emptyStateLabel.text = Strings.emptyStateLabel
        emptyStateLabel.textColor = .secondaryLabel
        emptyStateLabel.font = UIFont.systemFont(ofSize: Constants.emptyStateLabelFontSize, weight: .medium)
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.isHidden = true

        searchBar.placeholder = Strings.searchPlaceholer
        searchBar.delegate = self
        searchBar.backgroundImage = UIImage()
        searchBar.showsBookmarkButton = true
        searchBar.setImage(setMicImage(.label), for: .bookmark, state: .normal)
        searchBar.translatesAutoresizingMaskIntoConstraints = false

        bottomBar.translatesAutoresizingMaskIntoConstraints = false

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(TaskCell.self, forCellReuseIdentifier: TaskCell.reuseId)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = .zero

        bottomBar.addTaskButton.addAction(UIAction { [weak self] _ in self?.addTaskTapped() }, for: .touchUpInside)

        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(bottomBar)
        view.addSubview(searchBar)
        view.addSubview(emptyStateLabel)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.titleTopPadding),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.titleLeadingPadding),

            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.searchBarHorizontalPadding),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.searchBarHorizontalPadding),
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.searchBarTopPadding),
            searchBar.heightAnchor.constraint(equalToConstant: Constants.searchBarHeight),

            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: Constants.tableViewTopPadding),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.tableViewHorizontalPadding),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.tableViewHorizontalPadding),
            tableView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor),

            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: Constants.bottomBarHeight)        ])
    }

    func setMicImage(_ color: UIColor) -> UIImage {
        return UIImage(systemName: "mic.fill")!.withTintColor(color, renderingMode: .alwaysOriginal)
    }

    // MARK: - Data

    func loadTasks() {
        deps.taskRepository.loadTasks { [weak self] tasks in
            let sorted = tasks.sorted { $0.createdAt > $1.createdAt }
            self?.allTasks = sorted
            self?.applySearch(query: self?.searchBar.text)
        }
    }

    func applySearch(query: String?) {
        if let text = query?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
            deps.taskRepository.searchTasks(text: text) { [weak self] tasks in
                self?.filteredTasks = tasks
                self?.bottomBar.taskCountLabel.text = self?.tasksCountText(tasks.count)
                self?.emptyStateLabel.isHidden = !tasks.isEmpty
                self?.tableView.reloadData()
            }
        } else {
            filteredTasks = allTasks
            bottomBar.taskCountLabel.text = tasksCountText(filteredTasks.count)
            emptyStateLabel.isHidden = !filteredTasks.isEmpty
            tableView.reloadData()
        }
    }

    func tasksCountText(_ count: Int) -> String {
        let remainder10 = count % 10
        let remainder100 = count % 100

        let word: String

        if remainder100 >= 11 && remainder100 <= 14 {
            word = Strings.taskCountPlural
        } else if remainder10 == 1 {
            word = Strings.taskCountSingular
        } else if remainder10 >= 2 && remainder10 <= 4 {
            word = Strings.taskCountFew
        } else {
            word = Strings.taskCountPlural
        }

        return "\(count) \(word)"
    }

    // MARK: - Actions

    func addTaskTapped() {
        openTaskCreateEditVC()
    }

    func micTapped() {
        speechManager.startRecognition()
    }

    @objc func endEditing() {
        view.endEditing(true)
    }

    func openTaskCreateEditVC(_ task: Task? = nil) {
        let vc = TaskCreateEditVC(taskToEdit: task, delegate: self, coreDataManager: deps.coreDataManager, dispatchQueueWrapper: deps.dispatchQueueWrapper)
        navigationController?.pushViewController(vc, animated: true)

    }

    func setupTapToDismissKeyboard() {
        let tapGetsure = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        tapGetsure.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGetsure)
    }

    func toggleTaskCompletion(_ task: Task) {
        var updated = task
        updated.isCompleted.toggle()
        deps.coreDataManager.update(updated) { [weak self] in
            self?.loadTasks()
        }
    }

    // MARK: - Audio

    func configureSpeechManagerCallbacks() {
        speechManager.onStart = { [weak self] in
            self?.searchBar.setImage(self?.setMicImage(.systemYellow), for: .bookmark, state: .normal)
        }

        speechManager.onStop = { [weak self] in
            self?.searchBar.setImage(self?.setMicImage(.label), for: .bookmark, state: .normal)
        }

        speechManager.onTextRecognition = { [weak self] text in
            self?.searchBar.text = text
            self?.applySearch(query: text)
        }
    }
}

// MARK: - UITableViewDataSource

extension TaskListVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredTasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskCell.reuseId, for: indexPath) as? TaskCell else {
            return UITableViewCell()
        }

        let task = filteredTasks[indexPath.row]
        cell.configure(with: task)
        cell.delegate = self
        return cell
    }
}

// MARK: - UITableViewDelegate

extension TaskListVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = filteredTasks[indexPath.row]
        openTaskCreateEditVC(task)
    }

    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let task = filteredTasks[indexPath.row]

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let actions = [
                UIAction(title: Strings.contextMenuEdit, image: UIImage(systemName: "pencil")) { _ in
                    self?.openTaskCreateEditVC(task)
                },
                UIAction(title: Strings.contextMenuShare, image: UIImage(systemName: "square.and.arrow.up")) { _ in
                    let shareText = "\(task.title)\n\(task.descriptionText)"
                    let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
                    self?.present(activityVC, animated: true)
                },
                UIAction(title: Strings.contextMenuDelete, image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                    self?.deps.coreDataManager.delete(task) {
                        self?.loadTasks()
                    }
                }
            ]

            return UIMenu(title: "", children: actions)
        }
    }
}

// MARK: - TaskCellDelegate

extension TaskListVC: TaskCellDelegate {

    func didToggleComplete(for task: Task) {
        toggleTaskCompletion(task)
    }
}

// MARK: - UISearchBarDelegate

extension TaskListVC: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchWorkItem?.cancel()

        let workItem = DispatchWorkItem { [weak self] in
            self?.applySearch(query: searchText)
        }

        searchWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.searchUpdateDelay, execute: workItem)
    }

    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        micTapped()
    }
}

// MARK: - TaskCreateDelegate

extension TaskListVC: TaskCreateEditDelegate {

    func taskDidCreateOrUpdate() {
        loadTasks()
    }
}
