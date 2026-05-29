//
//  KeFuMediaPagerViewController.swift
//  TeneasyChatSDKUI_iOS
//
//  全屏媒体浏览器，支持左右滑动切换会话内的其他图片/视频，
//  以及向下拖拽跟手关闭。等价于 Flutter 端的 MediaPagerView。
//

import AVKit
import Foundation
import Kingfisher
import UIKit

public struct KeFuMediaItem: Equatable {
    public let url: URL
    public let isVideo: Bool

    public init(url: URL, isVideo: Bool) {
        self.url = url
        self.isVideo = isVideo
    }
}

class KeFuMediaPagerViewController: UIViewController {
    // MARK: - 输入

    private let items: [KeFuMediaItem]
    private var currentIndex: Int

    // MARK: - 子视图

    private let backdrop = UIView()
    private let pageVC = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal,
        options: nil
    )
    private let indicatorLabel = UILabel()
    private let closeButton = UIButton(type: .system)

    /// 已生成的页面缓存（避免左右来回滑反复创建）。
    private var pages: [Int: UIViewController] = [:]

    // MARK: - 下拉关闭

    private var dragOffsetY: CGFloat = 0
    private let dismissThreshold: CGFloat = 120
    private let fadeDistance: CGFloat = 400

    // MARK: - 初始化

    init(items: [KeFuMediaItem], initialIndex: Int) {
        self.items = items
        let clamped = max(0, min(initialIndex, max(0, items.count - 1)))
        self.currentIndex = clamped
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        setupBackdrop()
        setupPager()
        setupOverlay()
        setupDragGesture()
    }

    override var prefersStatusBarHidden: Bool { true }

    private func setupBackdrop() {
        backdrop.backgroundColor = .black
        view.addSubview(backdrop)
        backdrop.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backdrop.topAnchor.constraint(equalTo: view.topAnchor),
            backdrop.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backdrop.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backdrop.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setupPager() {
        addChild(pageVC)
        view.addSubview(pageVC.view)
        pageVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageVC.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        pageVC.didMove(toParent: self)
        pageVC.dataSource = self
        pageVC.delegate = self
        pageVC.view.backgroundColor = .clear

        if let first = page(at: currentIndex) {
            pageVC.setViewControllers([first], direction: .forward, animated: false)
        }
    }

    private func setupOverlay() {
        // 关闭按钮（左上）
        let closeImg = UIImage.svgInit("backicon", size: CGSize(width: 40, height: 40))?
            .withTintColor(.white)
        closeButton.setImage(closeImg, for: .normal)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        view.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            closeButton.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
        ])

        // 指示器（顶部居中）
        indicatorLabel.textColor = .white
        indicatorLabel.font = .systemFont(ofSize: 16, weight: .medium)
        indicatorLabel.textAlignment = .center
        view.addSubview(indicatorLabel)
        indicatorLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indicatorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicatorLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
        ])
        updateIndicator()
    }

    private func setupDragGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.delegate = self
        view.addGestureRecognizer(pan)
    }

    // MARK: - 页面工厂

    private func page(at index: Int) -> UIViewController? {
        guard index >= 0, index < items.count else { return nil }
        if let cached = pages[index] { return cached }
        let item = items[index]
        let vc: KeFuMediaPageProtocol
        if item.isVideo {
            vc = KeFuMediaVideoPage(url: item.url, pageIndex: index)
        } else {
            vc = KeFuMediaImagePage(url: item.url, pageIndex: index) { [weak self] in
                self?.dismissPager()
            }
        }
        pages[index] = vc
        return vc
    }

    private func updateIndicator() {
        indicatorLabel.text = items.isEmpty ? "" : "\(currentIndex + 1) / \(items.count)"
    }

    // MARK: - 关闭

    @objc private func closeTapped() {
        dismissPager()
    }

    private func dismissPager() {
        for vc in pages.values {
            (vc as? KeFuMediaVideoPage)?.pause()
        }
        dismiss(animated: true, completion: nil)
    }

    // MARK: - 下拉关闭手势

    @objc private func handlePan(_ pan: UIPanGestureRecognizer) {
        let translation = pan.translation(in: view)
        switch pan.state {
        case .changed:
            dragOffsetY = max(0, translation.y)
            applyDragTransform()
        case .ended, .cancelled, .failed:
            if dragOffsetY > dismissThreshold {
                UIView.animate(withDuration: 0.2, animations: {
                    self.pageVC.view.transform = CGAffineTransform(
                        translationX: 0, y: self.view.bounds.height)
                    self.backdrop.alpha = 0
                }, completion: { _ in
                    self.dismissPager()
                })
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.pageVC.view.transform = .identity
                    self.backdrop.alpha = 1
                }
                dragOffsetY = 0
            }
        default:
            break
        }
    }

    private func applyDragTransform() {
        pageVC.view.transform = CGAffineTransform(translationX: 0, y: dragOffsetY)
        let opacity = max(0, 1 - dragOffsetY / fadeDistance)
        backdrop.alpha = opacity
    }
}

// MARK: - UIPageViewControllerDataSource / Delegate

extension KeFuMediaPagerViewController: UIPageViewControllerDataSource,
    UIPageViewControllerDelegate
{
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let p = viewController as? KeFuMediaPageProtocol else { return nil }
        return page(at: p.pageIndex - 1)
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let p = viewController as? KeFuMediaPageProtocol else { return nil }
        return page(at: p.pageIndex + 1)
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed else { return }
        for prev in previousViewControllers {
            (prev as? KeFuMediaVideoPage)?.pause()
        }
        guard let current = pageViewController.viewControllers?.first as? KeFuMediaPageProtocol
        else { return }
        currentIndex = current.pageIndex
        updateIndicator()
        (current as? KeFuMediaVideoPage)?.play()
    }
}

// MARK: - 手势冲突仲裁

extension KeFuMediaPagerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        let v = pan.velocity(in: view)
        // 只在主要为竖直方向的手势开始时启动下拉关闭，避免抢 PageView 的横向滑动。
        return abs(v.y) > abs(v.x) && v.y > 0
    }
}

// MARK: - 页面协议

protocol KeFuMediaPageProtocol: UIViewController {
    var pageIndex: Int { get }
}

// MARK: - 图片页面

class KeFuMediaImagePage: UIViewController, KeFuMediaPageProtocol {
    let pageIndex: Int
    private let url: URL
    private let onTap: () -> Void
    private let imageView = UIImageView()

    init(url: URL, pageIndex: Int, onTap: @escaping () -> Void) {
        self.url = url
        self.pageIndex = pageIndex
        self.onTap = onTap
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.kf.setImage(with: url)
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        imageView.addGestureRecognizer(tap)
    }

    @objc private func tapped() {
        onTap()
    }
}

// MARK: - 视频页面

class KeFuMediaVideoPage: UIViewController, KeFuMediaPageProtocol {
    let pageIndex: Int
    private let url: URL
    private var player: AVPlayer?
    private var playerVC: AVPlayerViewController?

    init(url: URL, pageIndex: Int) {
        self.url = url
        self.pageIndex = pageIndex
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        let p = AVPlayer(url: url)
        player = p

        let pvc = AVPlayerViewController()
        pvc.player = p
        pvc.showsPlaybackControls = true
        pvc.view.backgroundColor = .clear
        addChild(pvc)
        view.addSubview(pvc.view)
        pvc.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pvc.view.topAnchor.constraint(equalTo: view.topAnchor),
            pvc.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pvc.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pvc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        pvc.didMove(toParent: self)
        playerVC = pvc
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player?.play()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
    }

    func play() { player?.play() }
    func pause() { player?.pause() }
}
