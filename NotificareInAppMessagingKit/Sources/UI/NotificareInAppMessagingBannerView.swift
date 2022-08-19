//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation
import NotificareKit
import UIKit

public class NotificareInAppMessagingBannerView: UIView {
    private let message: NotificareInAppMessage

    // MARK: - UI views

    private lazy var cardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        if #available(iOS 13.0, *) {
            view.backgroundColor = .tertiarySystemBackground
        } else {
            view.backgroundColor = .white
        }

        view.layer.cornerRadius = 8
        view.clipsToBounds = true

        return view
    }()

    private lazy var contentStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.alignment = .center
        view.distribution = .fill
        view.spacing = 16

        return view
    }()

    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true

        return view
    }()

    private lazy var textContentStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.alignment = .leading
        view.distribution = .fill

        return view
    }()

    private lazy var titleView: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.font = UIFont.preferredFont(forTextStyle: .headline)

        return view
    }()

    private lazy var messageView: UILabel = {
        let view = UILabel()
        view.numberOfLines = 3
        view.font = UIFont.preferredFont(forTextStyle: .body)

        return view
    }()

    // MARK: - Constructors

    public init(message: NotificareInAppMessage) {
        self.message = message

        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View setup

    override public func layoutSubviews() {
        super.layoutSubviews()

        let imageUrlStr = message.orientationConstrainedImage

        imageView.isHidden = imageUrlStr == nil
        if let imageUrlStr = imageUrlStr, let imageUrl = URL(string: imageUrlStr) {
            URLSession.shared.dataTask(with: imageUrl) { data, _, _ in
                if let data = data {
                    DispatchQueue.main.async { [weak self] in
                        self?.imageView.image = UIImage(data: data)
                    }
                }
            }.resume()
        }

        titleView.isHidden = message.title == nil
        titleView.text = message.title

        messageView.isHidden = message.message == nil
        messageView.text = message.message
    }

    // MARK: - Private API

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)

        //
        // Card view
        //

        addSubview(cardView)
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: ncSafeAreaLayoutGuide.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: ncSafeAreaLayoutGuide.trailingAnchor, constant: -16),
            cardView.topAnchor.constraint(equalTo: ncSafeAreaLayoutGuide.topAnchor, constant: 16),
        ])

        //
        // Image view
        //

        cardView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 64),
            imageView.heightAnchor.constraint(equalToConstant: 64),
        ])

        //
        // Content stack view
        //

        cardView.addSubview(contentStackView)
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            contentStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
            contentStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
        ])

        //
        // Content subviews
        //

        contentStackView.addArrangedSubview(imageView)
        contentStackView.addArrangedSubview(textContentStackView)

        //
        // Title & message labels
        //

        textContentStackView.addArrangedSubview(titleView)
        textContentStackView.addArrangedSubview(messageView)

        //
        // Gesture recognizers
        //

        cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onCardViewClicked)))
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onRootViewClicked)))
    }

    private func dismiss() {
        removeFromSuperview()
    }

    @objc private func onCardViewClicked() {}

    @objc private func onRootViewClicked() {
        dismiss()
    }
}
