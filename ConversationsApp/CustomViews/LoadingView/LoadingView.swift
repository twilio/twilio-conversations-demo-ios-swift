//
//  LoadingView.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import UIKit

class LoadingView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        let nibName = type(of: self).description().components(separatedBy: ".").last!
        Bundle.main.loadNibNamed(nibName, owner: self, options: nil)
        contentView.embedInView(self)
        self.isHidden = true
    }
    
    func startLoading() {
        self.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func stopLoading() {
        self.isHidden = true
        activityIndicator.stopAnimating()
    }
}
