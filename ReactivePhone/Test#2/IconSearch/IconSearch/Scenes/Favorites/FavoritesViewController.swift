//
//  FavoritesViewController.swift
//  IconSearch
//
//  Created by Демид Стариков on 22.06.2024.
//

import UIKit

final class FavoritesViewController: UIViewController {
    
    private let viewModel = FavoritesViewModel()
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindViewModel()
        setupNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadFavorites()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        tableView.register(IconCell.self, forCellReuseIdentifier: IconCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableView.automaticDimension
        tableView.accessibilityIdentifier = "favoritesTableView"
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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
    }
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleFavoriteRemoved(notification:)), name: NSNotification.Name("FavoriteRemoved"), object: nil)
    }
    
    private func showDownloadConfirmation() {
        let alertController = UIAlertController(title: "Download Complete", message: "The image has been saved to your gallery.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
    
    @objc private func handleFavoriteRemoved(notification: Notification) {
        if let icon = notification.object as? Icon {
            viewModel.removeFavorite(icon: icon)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension FavoritesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getFavorites().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: IconCell.reuseIdentifier, for: indexPath) as? IconCell else {
            return UITableViewCell()
        }
        
        let icon = viewModel.getFavorites()[indexPath.row]
        cell.configure(with: icon, isFavorite: true)
        cell.delegate = self
        return cell
    }
}

extension FavoritesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { }
}

extension FavoritesViewController: IconCellDelegate {
    func didTapCell(for icon: Icon) {
        viewModel.saveIconToGallery(icon: icon)
        showDownloadConfirmation()
    }
    
    func didToggleFavorite(for icon: Icon, isFavorite: Bool) {
        viewModel.removeFavorite(icon: icon)
    }
}
