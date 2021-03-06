//
//  FancyAlertTransitionAnimator.swift
//  FancyAlertDemo
//
//  Created by ancheng on 2018/3/20.
//  Copyright © 2018年 ancheng. All rights reserved.
//

import UIKit

class FancyAlertTransitionAnimator: NSObject {
    var isDismissing: Bool = false

    private let type: UIAlertController.Style

    init(type: UIAlertController.Style) {
        self.type = type
        super.init()
    }
}

extension FancyAlertTransitionAnimator: UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        switch type {
        case .alert:
            return 0.15
        case .actionSheet:
            return 0.25
        }
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        let key: UITransitionContextViewControllerKey = isDismissing ? .from : .to
        let controller = transitionContext.viewController(forKey: key)!
        if !isDismissing {
            transitionContext.containerView.addSubview(controller.view)
        }
        let initialAlpha: CGFloat = isDismissing ? 1 : 0
        let finalAlpha: CGFloat = isDismissing ? 0 : 1

        let animationDuration = transitionDuration(using: transitionContext)

        guard let alertController = controller as? FancyAlertViewController else { return }
        let tableViewHeight = (alertController.tableView as! FancyAlertTableViewSource).tableViewHeight
        let margin = (alertController.tableView as! FancyAlertTableViewSource).margin
        switch type {
        case .alert:
            alertController.view.alpha = initialAlpha
            if !isDismissing {
                alertController.tableView.center = alertController.view.center
                alertController.tableView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }
            alertController.tableView.bounds.size = CGSize(width: alertController.view.bounds.width - 2 * margin, height: tableViewHeight)
            UIView.animate(withDuration: animationDuration, animations: {
                alertController.view.alpha = finalAlpha
                alertController.tableView.transform = CGAffineTransform.identity
            }, completion: { [weak self] finished in
                transitionContext.completeTransition(finished)
                let textField = alertController.textFields.first
                let textView = alertController.textView
                guard let strongSelf = self else { return }
                if strongSelf.isDismissing {
                    textField?.resignFirstResponder()
                    textView?.resignFirstResponder()
                } else {
                    textField?.becomeFirstResponder()
                    textView?.becomeFirstResponder()
                }
            })
        case .actionSheet:
            alertController.maskControl.alpha = initialAlpha
            let beginY = !isDismissing ? alertController.view.bounds.height : alertController.view.bounds.height - tableViewHeight - margin - alertController.safeAreaInsetsBottom
            let endY = isDismissing ? alertController.view.bounds.height : alertController.view.bounds.height - tableViewHeight - margin - alertController.safeAreaInsetsBottom
            alertController.tableView.frame = CGRect(x: margin, y: beginY, width: alertController.view.bounds.width - 2 * margin, height: tableViewHeight)
            UIView.animate(withDuration: animationDuration, animations: { 
                alertController.maskControl.alpha = finalAlpha
                alertController.tableView.frame.origin.y = endY
            }, completion: { finished in
                transitionContext.completeTransition(finished)
            })
        }

    }

}
