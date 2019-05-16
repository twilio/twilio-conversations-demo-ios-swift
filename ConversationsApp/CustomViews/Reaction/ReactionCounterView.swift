//
//  ReactionCounterView.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import UIKit

struct ReactionViewModel {

    let reactionSymbol: String
    let reactionCount: Int
}

protocol ReactionCounterViewDelegate: AnyObject {

    func onReactionTapped(reactionModel: ReactionViewModel)
}

class ReactionCounterView: UICollectionViewCell {

    var container: UIView!
    weak var delegate: ReactionCounterViewDelegate?

    @IBOutlet weak var label: UILabel!

    var reactionModel: ReactionViewModel? {
        didSet {
            guard let reaction = reactionModel else {
                return
            }
            label.text = reaction.reactionSymbol + String(reaction.reactionCount)
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
    }

    func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        container = (nib.instantiate(withOwner: self, options: nil).first as! UIView)
        container.frame = bounds
        container.layer.cornerRadius = 8
        container.layer.borderWidth = 2
        container.layer.borderColor = UIColor.lightGray.cgColor
        addSubview(container)

        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapped)))
    }

    @objc
    func onTapped() {
        guard let reactionModel = reactionModel else {
            return
        }
        delegate?.onReactionTapped(reactionModel: reactionModel)
    }
}
