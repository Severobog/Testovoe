//
//  SearchResultCell.swift
//  IconSearch
//
//  Created by Демид Стариков on 22.06.2024.
//

import UIKit

protocol IconCellDelegate: AnyObject {
    func didTapCell(for icon: Icon)
    func didToggleFavorite(for icon: Icon, isFavorite: Bool)
}

extension IconCellDelegate {
    func didTapCell(for icon: Icon) {}
    func didToggleFavorite(for icon: Icon, isFavorite: Bool) {}
}

final class IconCell: UITableViewCell {
    
    static let reuseIdentifier = "IconCell"
    private var currentImageURL: String?
    private var icon: Icon?
    weak var delegate: IconCellDelegate?
    
    private let iconImageView = UIImageView()
    private let sizeLabel = UILabel()
    private let tagsLabel = UILabel()
    private let favoriteButton = UIButton(type: .system)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        contentView.addSubview(iconImageView)
        
        sizeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(sizeLabel)
        
        tagsLabel.translatesAutoresizingMaskIntoConstraints = false
        tagsLabel.numberOfLines = 0
        contentView.addSubview(tagsLabel)
        
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.addTarget(self, action: #selector(toggleFavorite), for: .touchUpInside)
        favoriteButton.accessibilityIdentifier = "favoriteButton"
        contentView.addSubview(favoriteButton)
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            iconImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16),
            
            
            sizeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            sizeLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            sizeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            tagsLabel.topAnchor.constraint(equalTo: sizeLabel.bottomAnchor, constant: 8),
            tagsLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            tagsLabel.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -16),
            
            favoriteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            favoriteButton.widthAnchor.constraint(equalToConstant: 80),
            favoriteButton.heightAnchor.constraint(equalToConstant: 40),
            
            contentView.bottomAnchor.constraint(greaterThanOrEqualTo: tagsLabel.bottomAnchor, constant: 16)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        contentView.addGestureRecognizer(tapGesture)
    }
    
    
    func configure(with icon: Icon, isFavorite: Bool) {
        self.icon = icon
        self.currentImageURL = icon.imageName
        
        iconImageView.image = nil
        
        IconManager.shared.loadIcon(for: icon.imageName) { [weak self] image in
            guard let self = self, self.currentImageURL == icon.imageName, let image = image else { return }
            DispatchQueue.main.async {
                self.iconImageView.image = image
            }
        }
        
        sizeLabel.text = "Largest size: \(Int(icon.largestSize.width))x\(Int(icon.largestSize.height))"
        tagsLabel.text = "Tags: \(icon.tags.prefix(10).joined(separator: ", "))"
        favoriteButton.setTitle(isFavorite ? "Remove" : "Add", for: .normal)
    }
    
    
    @objc private func cellTapped() {
        guard let icon else { return }
        delegate?.didTapCell(for: icon)
    }
    
    @objc private func toggleFavorite() {
        guard let icon else { return }
        let isFavorite = IconManager.shared.isFavorite(icon: icon)
        delegate?.didToggleFavorite(for: icon, isFavorite: !isFavorite)
    }
}
