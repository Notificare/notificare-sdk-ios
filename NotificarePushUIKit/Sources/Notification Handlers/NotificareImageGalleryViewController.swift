//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import NotificareCore
import NotificarePushKit
import UIKit

public class NotificareImageGalleryViewController: NotificareBaseNotificationViewController {
    // UI references
    private(set) var collectionView: UICollectionView!
    private(set) var pageControl: UIPageControl!

    private var theme: NotificareConfiguration.Theme?
    private var imageViews = [UIImageView]()

    override public func viewDidLoad() {
        super.viewDidLoad()
        theme = NotificareUtils.getConfiguration()?.theme(for: self)

        setupViews()
        setupContent()
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, didFinishPresentingNotification: notification)
    }

    private func setupViews() {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.sectionInset = .zero

        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cellIdentifier")
        if let colorStr = theme?.backgroundColor {
            collectionView.backgroundColor = UIColor(hexString: colorStr)
        }

        pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.numberOfPages = notification.content.count
        pageControl.currentPage = 1

        view.addSubview(collectionView)
        view.addSubview(pageControl)

        let guide: UILayoutGuide
        if #available(iOS 11.0, *) {
            guide = view.safeAreaLayoutGuide
        } else {
            guide = view.layoutMarginsGuide
        }

        // Constrain the collection view.
        NSLayoutConstraint.activate([
            guide.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            collectionView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: guide.topAnchor),
            guide.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor),
        ])

        // Constraint the page control.
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: -50),
        ])
    }

    private func setupContent() {
        guard !notification.content.isEmpty else {
            NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, didFailToPresentNotification: notification)
            return
        }

        notification.content.forEach { content in
            var bottomPadding: CGFloat = 64.0
            if #available(iOS 11.0, *) {
                bottomPadding += UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0.0
            }

            let imageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: collectionView.bounds.width, height: collectionView.bounds.height - bottomPadding))
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            imageViews.append(imageView)

            let url = URL(string: content.data as! String)!
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data {
                    DispatchQueue.main.async {
                        imageView.image = UIImage(data: data)
                        self.collectionView.reloadData()
                    }
                }
            }.resume()
        }

        NotificarePushUI.shared.delegate?.notificare(NotificarePushUI.shared, didPresentNotification: notification)
    }

    private func openSharingActionSheet(for image: UIImage) {
        let items: [Any] = [image, NotificareLocalizable.string(resource: .actionsShareImageTextPlaceholder)]

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
        imageViews.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellIdentifier", for: indexPath)
        cell.contentView.addSubview(imageViews[indexPath.row])

        if let colorStr = theme?.backgroundColor {
            cell.backgroundColor = UIColor(hexString: colorStr)
        }

        return cell
    }

    public func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        CGSize(width: view.frame.size.width, height: view.frame.size.height)
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.x
        let width = scrollView.frame.size.width
        let horizontalCenter = width / 2

        pageControl.currentPage = Int((offset + horizontalCenter) / width)
    }

    public func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if NotificareUtils.getConfiguration()?.options?.imageSharing == true {
            openSharingActionSheet(for: imageViews[indexPath.row].image!)
        }
    }
}

extension NotificareImageGalleryViewController: NotificareNotificationPresenter {
    func present(in controller: UIViewController) {
        NotificarePushUI.shared.presentController(self, in: controller)
    }
}
