//
//  OverlayView.swift
//  AXPhotoViewer
//
//  Created by Alex Hill on 5/28/17.
//  Copyright © 2017 Alex Hill. All rights reserved.
//

import UIKit

@objc(AXOverlayView) open class OverlayView: UIView, CaptionViewDelegate {
    
    /// The caption view to be used in the overlay.
    public var captionView: CaptionViewProtocol = CaptionView() {
        didSet {
            (oldValue as? UIView)?.removeFromSuperview()
            
            guard self.captionView is UIView.Type else {
                assertionFailure("`captionView` must be a UIView.")
                return
            }
            
            self.captionView.delegate = self
            self.setNeedsLayout()
        }
    }
    
    /// The title view displayed in the navigation bar. This view is sized and centered between the `leftBarButtonItems` and `rightBarButtonItems`.
    /// This is prioritized over `title`.
    public var titleView: OverlayTitleViewProtocol? {
        set(value) {
            if let uValue = value {
                guard let view = uValue as? UIView else {
                    assertionFailure("`titleView` must be a UIView.")
                    self.navigationItem.titleView = nil
                    return
                }
                
                self.navigationItem.titleView = view
            } else {
                self.navigationItem.titleView = nil
            }
        }
        get {
            return self.navigationItem.titleView as? OverlayTitleViewProtocol
        }
    }
    
    /// The title displayed in the navigation bar. This string is centered between the `leftBarButtonItems` and `rightBarButtonItems`.
    public var title: String? {
        set(value) {
            self.navigationItem.title = value
        }
        get {
            return self.navigationItem.title
        }
    }
    
    /// The title text attributes inherited by the `title`.
    public var titleTextAttributes: [String: Any]? {
        set(value) {
            self.navigationBar.titleTextAttributes = value
        }
        get {
            return self.navigationBar.titleTextAttributes
        }
    }
    
    /// The bar button item that appears in the top left corner of the overlay.
    public var leftBarButtonItem: UIBarButtonItem? {
        set(value) {
            self.navigationItem.setLeftBarButton(value, animated: false)
        }
        get {
            return self.navigationItem.leftBarButtonItem
        }
    }
    
    /// The bar button items that appear in the top left corner of the overlay.
    public var leftBarButtonItems: [UIBarButtonItem]? {
        set(value) {
            self.navigationItem.setLeftBarButtonItems(value, animated: false)
        }
        get {
            return self.navigationItem.leftBarButtonItems
        }
    }

    /// The bar button item that appears in the top right corner of the overlay.
    public var rightBarButtonItem: UIBarButtonItem? {
        set(value) {
            self.navigationItem.setRightBarButton(value, animated: false)
        }
        get {
            return self.navigationItem.rightBarButtonItem
        }
    }
    
    /// The bar button items that appear in the top right corner of the overlay.
    public var rightBarButtonItems: [UIBarButtonItem]? {
        set(value) {
            self.navigationItem.setRightBarButtonItems(value, animated: false)
        }
        get {
            return self.navigationItem.rightBarButtonItems
        }
    }
    
    /// The navigation bar used to set the `titleView`, `leftBarButtonItems`, `rightBarButtonItems`
    public let navigationBar = UINavigationBar()
    public let navigationBarUnderlay = UIView()
    
    /// The underlying `UINavigationItem` used for setting the `titleView`, `leftBarButtonItems`, `rightBarButtonItems`.
    fileprivate var navigationItem = UINavigationItem()
    
    /// The inset of the contents of the `OverlayView`. Use this property to adjust layout for things such as status bar height.
    /// For internal use only.
    var contentInset: UIEdgeInsets = .zero
    
    fileprivate let OverlayAnimDuration: TimeInterval = 0.25
    
    init() {
        super.init(frame: .zero)
        
        self.captionView.delegate = self
        if let captionView = self.captionView as? UIView {
            self.addSubview(captionView)
        }
        
        self.navigationBarUnderlay.backgroundColor = (self.captionView as? UIView)?.backgroundColor
        self.addSubview(self.navigationBarUnderlay)
        
        self.navigationBar.backgroundColor = .clear
        self.navigationBar.barTintColor = nil
        self.navigationBar.isTranslucent = true
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationBar.items = [self.navigationItem]
        self.addSubview(self.navigationBar)
        
        NotificationCenter.default.addObserver(forName: .UIContentSizeCategoryDidChange, object: nil, queue: OperationQueue.main) { [weak self] (note) in
            self?.setNeedsLayout()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        var insetSize = self.bounds.size
        insetSize.width -= (self.contentInset.left + self.contentInset.right)
        insetSize.height -= (self.contentInset.top + self.contentInset.bottom)
        
        let navigationBarSize = self.navigationBar.sizeThatFits(insetSize)
        let navigationBarOrigin = CGPoint(x: self.contentInset.left, y: self.contentInset.top)
        self.navigationBar.frame = CGRect(origin: navigationBarOrigin, size: navigationBarSize)
        self.navigationBar.setNeedsLayout()
        
        self.navigationBarUnderlay.frame = CGRect(origin: .zero,
                                                  size: CGSize(width: self.frame.size.width,
                                                               height: self.navigationBar.frame.origin.y + self.navigationBar.frame.size.height))
        
        if let captionView = self.captionView as? UIView {
            let captionViewSize = captionView.sizeThatFits(insetSize)
            let captionViewOrigin = CGPoint(x: self.contentInset.left, y: self.frame.size.height - self.contentInset.bottom - captionViewSize.height)
            captionView.frame = CGRect(origin: captionViewOrigin, size: captionViewSize)
        }
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let view = super.hitTest(point, with: event) as? UIButton {
            return view
        }
        
        return nil
    }
    
    // MARK: - Show / hide interface
    // For internal use only.
    func setShowInterface(_ show: Bool, animated: Bool, alongside closure: (() -> Void)? = nil, completion: ((Bool) -> Void)? = nil) {
        let alpha: CGFloat = show ? 1 : 0
        guard self.alpha != alpha else {
            return
        }
        
        if alpha == 1 {
            self.isHidden = false
        }
        
        let animations = { [weak self] in
            self?.alpha = alpha
            closure?()
        }
        
        let internalCompletion: (_ finished: Bool) -> Void = { [weak self] (finished) in
            guard alpha == 0 else {
                completion?(finished)
                return
            }
            
            self?.isHidden = true
            completion?(finished)
        }
        
        if animated {
            UIView.animate(withDuration: OverlayAnimDuration, animations: animations, completion: internalCompletion)
        } else {
            animations()
            internalCompletion(true)
        }
    }
    
    // MARK: - CaptionViewDelegate
    public func captionView(_ captionView: CaptionViewProtocol, contentSizeDidChange newSize: CGSize) {
        (captionView as? UIView)?.frame = CGRect(origin: CGPoint(x: 0, y: self.frame.size.height - newSize.height), size: newSize)
    }
}

