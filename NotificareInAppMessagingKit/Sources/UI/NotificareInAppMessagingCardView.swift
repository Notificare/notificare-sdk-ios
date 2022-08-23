//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation
import NotificareKit
import UIKit

public class NotificareInAppMessagingCardView: UIView, NotificareInAppMessagingView {
    public let message: NotificareInAppMessage
    public weak var delegate: NotificareInAppMessagingViewDelegate?

    // MARK: - UI views

    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

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

    private lazy var imageContentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
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

    private lazy var actionsContentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    private lazy var primaryActionButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        return view
    }()

    private lazy var secondaryActionButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        return view
    }()

    // MARK: - UI constraints

    private lazy var cardViewMaxWidthConstraints: [NSLayoutConstraint] = {
        [
            cardView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1 / 2),
//            cardView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 1/2),
//            cardView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 16),
//            cardView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),
        ]
    }()

    private lazy var cardViewFullWidthConstraints: [NSLayoutConstraint] = {
        var constraints = [
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ]

        // Setting the priority to a lower value than the default (1000).
        // Otherwise, when rotating the device and toggling between the two sets of constraints,
        // it will trigger a temporary conflict between the two constraints.
        constraints.forEach { $0.priority = UILayoutPriority(999) }

        return constraints
    }()

    private lazy var imageViewAspectRatioHeightConstraint: NSLayoutConstraint = {
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1 / 2)
    }()

    private lazy var imageViewCollapsedHeightConstraint: NSLayoutConstraint = {
        imageView.heightAnchor.constraint(equalToConstant: 0)
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

        // When in landscape, define a constraint to limit the width of the card.
        // Otherwise, given the aspect ratio of the image, the card will grow too large.
        let isLandscape = UIDevice.current.orientation.isLandscape
        cardViewMaxWidthConstraints.forEach { $0.isActive = isLandscape }
        cardViewFullWidthConstraints.forEach { $0.isActive = !isLandscape }

        let imageUrlStr = message.orientationConstrainedImage

        imageView.isHidden = imageUrlStr == nil
        imageViewAspectRatioHeightConstraint.isActive = imageUrlStr != nil
        imageViewCollapsedHeightConstraint.isActive = imageUrlStr == nil

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

        primaryActionButton.isHidden = message.primaryAction?.label == nil
        primaryActionButton.setTitle(message.primaryAction?.label, for: .normal)

        if message.primaryAction?.destructive == true {
            primaryActionButton.setTitleColor(.systemRed, for: .normal)
        } else {
            if #available(iOS 13.0, *) {
                primaryActionButton.setTitleColor(.label, for: .normal)
            } else {
                primaryActionButton.setTitleColor(.black, for: .normal)
            }
        }

        secondaryActionButton.isHidden = message.secondaryAction?.label == nil
        secondaryActionButton.setTitle(message.secondaryAction?.label, for: .normal)

        if message.secondaryAction?.destructive == true {
            secondaryActionButton.setTitleColor(.systemRed, for: .normal)
        } else {
            if #available(iOS 13.0, *) {
                secondaryActionButton.setTitleColor(.label, for: .normal)
            } else {
                secondaryActionButton.setTitleColor(.black, for: .normal)
            }
        }
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
        // Scroll view
        //

        addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: ncSafeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: ncSafeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: ncSafeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: ncSafeAreaLayoutGuide.bottomAnchor),
        ])

        //
        // Content view
        //

        let contentViewHeightConstraint = contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        contentViewHeightConstraint.priority = .defaultLow

        scrollView.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentViewHeightConstraint,
        ])

        //
        // Card view
        //

        contentView.addSubview(cardView)
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 16),
            cardView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16),
            cardView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])

        //
        // Image content view
        //

        cardView.addSubview(imageContentView)
        NSLayoutConstraint.activate([
            imageContentView.topAnchor.constraint(equalTo: cardView.topAnchor),
            imageContentView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            imageContentView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
        ])

        //
        // Image view
        //

        imageContentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: imageContentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: imageContentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: imageContentView.trailingAnchor),
            imageView.bottomAnchor.constraint(lessThanOrEqualTo: imageContentView.bottomAnchor),
        ])

        //
        // Close button
        //

        imageContentView.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 48),
            closeButton.heightAnchor.constraint(equalToConstant: 48),
            closeButton.topAnchor.constraint(equalTo: imageContentView.topAnchor),
            closeButton.trailingAnchor.constraint(equalTo: imageContentView.trailingAnchor),
            closeButton.bottomAnchor.constraint(lessThanOrEqualTo: imageContentView.bottomAnchor),
        ])

        //
        // Title & message labels
        //

        textContentStackView.addArrangedSubview(titleView)
        textContentStackView.addArrangedSubview(messageView)

        //
        // Text content view
        //

        cardView.addSubview(textContentStackView)
        NSLayoutConstraint.activate([
            textContentStackView.topAnchor.constraint(equalTo: imageContentView.bottomAnchor, constant: 16),
            textContentStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            textContentStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
        ])

        //
        // Actions content view
        //

        cardView.addSubview(actionsContentView)
        NSLayoutConstraint.activate([
            actionsContentView.topAnchor.constraint(equalTo: textContentStackView.bottomAnchor),
            actionsContentView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            actionsContentView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            actionsContentView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
        ])

        //
        // Primary action button
        //

        actionsContentView.addSubview(primaryActionButton)
        NSLayoutConstraint.activate([
            primaryActionButton.topAnchor.constraint(equalTo: actionsContentView.topAnchor),
            primaryActionButton.trailingAnchor.constraint(equalTo: actionsContentView.trailingAnchor),
            primaryActionButton.bottomAnchor.constraint(equalTo: actionsContentView.bottomAnchor),
        ])

        //
        // Secondary action button
        //

        actionsContentView.addSubview(secondaryActionButton)
        NSLayoutConstraint.activate([
            secondaryActionButton.topAnchor.constraint(equalTo: actionsContentView.topAnchor),
            secondaryActionButton.trailingAnchor.constraint(equalTo: primaryActionButton.leadingAnchor, constant: -8),
            secondaryActionButton.bottomAnchor.constraint(equalTo: actionsContentView.bottomAnchor),
        ])

        //
        // Gesture recognizers
        //

        cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onCardViewClicked)))
        closeButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onCloseButtonClicked)))
        primaryActionButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onPrimaryActionClicked)))
        secondaryActionButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onSecondaryActionClicked)))
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onRootViewClicked)))
    }

    @objc private func onCardViewClicked() {
        // This empty click listener prevents the root click listener
        // from being triggered when clicking on the card itself.
        //
        // Otherwise, the root click listener will treat clicking on
        // the card itself as a tap outside.
    }

    @objc private func onCloseButtonClicked() {
        dismiss()
    }

    @objc private func onRootViewClicked() {
        dismiss()
    }

    @objc private func onPrimaryActionClicked() {
        handleActionClicked(.primary)
    }

    @objc private func onSecondaryActionClicked() {
        handleActionClicked(.secondary)
    }
}
