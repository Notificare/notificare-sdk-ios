//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareKit
import UIKit

public class NotificareImageGalleryViewController: NotificareBaseNotificationViewController {
    // UI references
    private(set) var collectionView: UICollectionView!
    private(set) var pageControl: UIPageControl!

    private var images = [UIImage?]()

    override public func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupContent()
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFinishPresentingNotification: notification)
    }

    private func setupViews() {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.minimumInteritemSpacing = 0
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.sectionInset = .zero

        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.scrollIndicatorInsets = .zero
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.register(NotificareImageGalleryCollectionViewCell.self, forCellWithReuseIdentifier: "standard")
        if let colorStr = theme?.backgroundColor {
            collectionView.backgroundColor = UIColor(hexString: colorStr)
        } else {
            if #available(iOS 13.0, *) {
                collectionView.backgroundColor = .systemBackground
            } else {
                collectionView.backgroundColor = .white
            }
        }

        pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.numberOfPages = notification.content.count
        pageControl.hidesForSinglePage = true
        pageControl.currentPage = 0

        view.addSubview(collectionView)
        view.addSubview(pageControl)

        // Constrain the collection view.
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.ncSafeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.ncSafeAreaLayoutGuide.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.ncSafeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        // Constraint the page control.
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.ncSafeAreaLayoutGuide.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.ncSafeAreaLayoutGuide.bottomAnchor, constant: -48),
        ])
    }

    private func setupContent() {
        guard !notification.content.isEmpty else {
            Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didFailToPresentNotification: notification)
            return
        }

        // Prepare the array with empty images.
        images = .init(repeating: nil, count: notification.content.count)

        notification.content.enumerated().forEach { index, content in
            let url = URL(string: content.data as! String)!
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data {
                    DispatchQueue.main.async {
                        self.images[index] = UIImage(data: data)
                        self.collectionView.reloadData()
                    }
                }
            }.resume()
        }

        Notificare.shared.pushUI().delegate?.notificare(Notificare.shared.pushUI(), didPresentNotification: notification)
    }

    private func openSharingActionSheet(for image: UIImage) {
        let placeholderText = NotificareLocalizable.string(resource: .actionsShareImageTextPlaceholder)
        let items: [Any] = placeholderText == NotificareLocalizable.StringResource.actionsShareImageTextPlaceholder.rawValue
            ? [image]
            : [image, placeholderText]

        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        controller.excludedActivityTypes = [.postToWeibo, .assignToContact, .message, .mail]

        present(controller, animated: true, completion: nil)
    }
}

extension NotificareImageGalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func numberOfSections(in _: UICollectionView) -> Int {
        1
    }

    public func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        images.count
    }

    public func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        collectionView.frame.size
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "standard", for: indexPath) as! NotificareImageGalleryCollectionViewCell
        cell.imageView.image = images[indexPath.row]

        return cell
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.x
        let width = scrollView.frame.size.width
        let horizontalCenter = width / 2

        pageControl.currentPage = Int((offset + horizontalCenter) / width)
    }

    public func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if Notificare.shared.options!.imageSharingEnabled == true, let image = images[indexPath.row] {
            openSharingActionSheet(for: image)
        }
    }
}

extension NotificareImageGalleryViewController: NotificareNotificationPresenter {
    func present(in controller: UIViewController) {
        controller.presentOrPush(self)
    }
}
