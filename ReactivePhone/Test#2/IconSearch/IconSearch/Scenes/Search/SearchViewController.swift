//
//  SearchViewController.swift
//  IconSearch
//
//  Created by Демид Стариков on 22.06.2024.
//

import UIKit

final class SearchViewController: UIViewController {
    
    private let viewModel = SearchViewModel()
    private let tableView = UITableView()
    private let searchBar = UISearchBar()
    private let searchButton = UIButton(type: .system)
    private let searchContainerView = UIView()
    private var query = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindViewModel()
        setupGestureRecognizers()
        setupNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        searchContainerView.backgroundColor = .white
        searchContainerView.layer.cornerRadius = 10
        searchContainerView.layer.shadowColor = UIColor.black.cgColor
        searchContainerView.layer.shadowOpacity = 0.1
        searchContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        searchContainerView.layer.shadowRadius = 4
        searchContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchContainerView)
        
        searchBar.placeholder = "Search for icons"
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchContainerView.addSubview(searchBar)
        
        searchButton.setTitle("Search", for: .normal)
        searchButton.backgroundColor = .systemBlue
        searchButton.setTitleColor(.white, for: .normal)
        searchButton.layer.cornerRadius = 5
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.accessibilityIdentifier = "searchButton"
        searchContainerView.addSubview(searchButton)
        
        tableView.register(IconCell.self, forCellReuseIdentifier: IconCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableView.automaticDimension
        tableView.accessibilityIdentifier = "searchTableView"
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            searchContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            searchContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            searchContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            searchContainerView.heightAnchor.constraint(equalToConstant: 60),
            
            searchBar.centerYAnchor.constraint(equalTo: searchContainerView.centerYAnchor),
            searchBar.leadingAnchor.constraint(equalTo: searchContainerView.leadingAnchor, constant: 10),
            searchBar.trailingAnchor.constraint(equalTo: searchButton.leadingAnchor, constant: -10),
            
            searchButton.centerYAnchor.constraint(equalTo: searchContainerView.centerYAnchor),
            searchButton.trailingAnchor.constraint(equalTo: searchContainerView.trailingAnchor, constant: -10),
            searchButton.widthAnchor.constraint(equalToConstant: 80),
            searchButton.heightAnchor.constraint(equalToConstant: 40),
            
            tableView.topAnchor.constraint(equalTo: searchContainerView.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    
    private func bindViewModel() {
        viewModel.onDataChanged = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        viewModel.onErrorOccurred = { [weak self] error in
            DispatchQueue.main.async {
                self?.showErrorAlert(error: error)
            }
        }
    }
    
    private func setupGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func showErrorAlert(error: Error) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleFavoriteRemoved(notification:)), name: NSNotification.Name("FavoriteRemoved"), object: nil)
    }
    
    @objc private func handleFavoriteRemoved(notification: Notification) {
        if notification.object is Icon {
            viewModel.reloadIcons(for: query)
        }
    }
    
    @objc private func searchButtonTapped() {
        query = searchBar.text ?? ""
        viewModel.searchIcons(query: query)
        dismissKeyboard()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchButtonTapped()
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getIcons().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: IconCell.reuseIdentifier, for: indexPath) as? IconCell else {
            return UITableViewCell()
        }
        
        let icon = viewModel.getIcons()[indexPath.row]
        cell.configure(with: icon, isFavorite: viewModel.isFavorite(icon: icon))
        cell.delegate = self
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        
        if position > contentHeight - frameHeight * 2 {
            viewModel.loadMoreIcons(query: query)
        }
    }
}

extension SearchViewController: IconCellDelegate {
    func didToggleFavorite(for icon: Icon, isFavorite: Bool) {
        if isFavorite {
            viewModel.addFavorite(icon: icon)
        } else {
            viewModel.removeFavorite(icon: icon)
        }
    }
}
