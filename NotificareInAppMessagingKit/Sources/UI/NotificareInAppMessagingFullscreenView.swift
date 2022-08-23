//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation
import NotificareKit
import UIKit

public class NotificareInAppMessagingFullscreenView: UIView, NotificareInAppMessagingView {
    public let message: NotificareInAppMessage
    public weak var delegate: NotificareInAppMessagingViewDelegate?

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

    private lazy var closeButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.imageEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        view.setImage(NotificareLocalizable.image(resource: .closeCircle), for: .normal)

        return view
    }()

    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true

        return view
    }()

    private lazy var footerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.insertSublayer(gradientLayer, at: 0)

        return view
    }()

    private lazy var textContentView: UIStackView = {
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

    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.white.withAlphaComponent(0).cgColor,
            UIColor.white.cgColor,
        ]

        return layer
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

        if let imageUrlStr = imageUrlStr, let imageUrl = URL(string: imageUrlStr) {
            URLSession.shared.dataTask(with: imageUrl) { data, _, _ in
                if let data = data {
                    DispatchQueue.main.async { [weak self] in
                        self?.imageView.image = UIImage(data: data)
                    }
                }
            }.resume()
        }

        footerView.isHidden = message.title == nil && message.message == nil

        titleView.isHidden = message.title == nil
        titleView.text = message.title

        messageView.isHidden = message.message == nil
        messageView.text = message.message
    }

    override public func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        gradientLayer.frame = footerView.bounds
    }

    // MARK: - NotificareInAppMessagingView

    public func animate(transition: NotificareInAppMessagingViewTransition, _ completion: @escaping () -> Void) {
        switch transition {
        case .enter:
            cardView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            cardView.alpha = 0
        case .exit:
            cardView.transform = .identity
            cardView.alpha = 1
        }

        superview?.layoutIfNeeded()

        UIView.animate(withDuration: 0.3, delay: 0, options: []) {
            switch transition {
            case .enter:
                self.cardView.transform = .identity
                self.cardView.alpha = 1
            case .exit:
                self.cardView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                self.cardView.alpha = 0
            }

            self.superview?.layoutIfNeeded()
        } completion: { _ in
            completion()
        }
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
            cardView.topAnchor.constraint(equalTo: ncSafeAreaLayoutGuide.topAnchor, constant: 16),
            cardView.leadingAnchor.constraint(equalTo: ncSafeAreaLayoutGuide.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: ncSafeAreaLayoutGuide.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: ncSafeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])

        //
        // Image view
        //

        cardView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: cardView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            imageView.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor),
        ])

        //
        // Close button
        //

        cardView.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 48),
            closeButton.heightAnchor.constraint(equalToConstant: 48),
            closeButton.topAnchor.constraint(equalTo: cardView.topAnchor),
            closeButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            closeButton.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor),
        ])

        //
        // Footer view
        //

        cardView.addSubview(footerView)
        NSLayoutConstraint.activate([
            footerView.topAnchor.constraint(greaterThanOrEqualTo: cardView.topAnchor),
            footerView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
        ])

        //
        // Title & message labels
        //

        textContentView.addArrangedSubview(titleView)
        textContentView.addArrangedSubview(messageView)

        //
        // Text content view
        //

        footerView.addSubview(textContentView)
        NSLayoutConstraint.activate([
            textContentView.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 32),
            textContentView.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 16),
            textContentView.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -16),
            textContentView.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: -16),
        ])

        //
        // Gesture recognizers
        //

        cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onCardViewClicked)))
        closeButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onCloseButtonClicked)))
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onRootViewClicked)))
    }

    @objc private func onCardViewClicked() {
        handleActionClicked(.primary)
    }

    @objc private func onCloseButtonClicked() {
        dismiss()
    }

    @objc private func onRootViewClicked() {
        dismiss()
    }
}
