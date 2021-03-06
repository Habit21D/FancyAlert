//
//  FancyAlertTextViewHeaderView.swift
//  FancyAlertDemo
//
//  Created by ancheng on 2018/5/14.
//  Copyright © 2018年 ancheng. All rights reserved.
//

import UIKit

class FancyAlertTextViewHeaderView: FancyAlertBaseHeaderView {

    var markedColor: UIColor = UIColor.fancyAlertMarkedDefaultColor {
        didSet {
            textView?.tintColor = textView?.cursorColor ?? markedColor
        }
    }
    
    override var headerHeight: CGFloat {

        return super.headerHeight + (isEditable ? textViewHeight + textViewTopMargin + 2 * textViewTopPadding + limitLabelTotalHeight : 0)
    }

    private lazy var textViewBackgroundImageView: UIImageView = {
        let selfBundle = Bundle(for: FancyAlertTextViewHeaderView.self)
        let imageView = UIImageView(image: UIImage(named: "textView_background", in: selfBundle, compatibleWith: nil))
        return imageView
    }()

    private lazy var limitLabel: UILabel? = {
        guard let textView = textView else { return nil }
        let label = UILabel()
        label.textColor = textView.maxInputLimitLabelColor
        label.font = textView.maxInputLimitLabelFont
        label.textAlignment = .right
        if let inputLength = textView.maxInputLength {
            label.text = "\(inputLength)"
        }
        return label
    }()

    private let labelSpace:CGFloat = 13
    private let bottomMargin: CGFloat = 28
    private let textViewTopMargin: CGFloat = 17
    private var textViewHeight: CGFloat {
        return textView?.height ?? Config.textViewHeight
    }
    private let textViewTopPadding: CGFloat = 10
    private let textViewLeftPadding: CGFloat = 24
    private let limitLabelHeight: CGFloat = 12
    private let limitLabelTopMargin: CGFloat = 5

    private var isEditable = false
    private var textView: FancyTextView?
    private var isHaveLimit: Bool {
        return textView?.maxInputLength != nil && limitLabel != nil
    }
    private var limitLabelTotalHeight: CGFloat {
        return isHaveLimit ? limitLabelHeight + limitLabelTopMargin : 0
    }
    private var tempInputLength: Int = 0

    init(title: String?, message: String?, width: CGFloat, margin: CGFloat, textView: FancyTextView) {
        self.textView = textView
        self.isEditable = true
        super.init(title: title, message: message, width: width, margin: margin)
        tempInputLength = textView.maxInputLength ?? 0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func makeUI(title: String?, message: String?, width: CGFloat, outsideMargin: CGFloat) {
        super.makeUI(title: title, message: message, width: width, outsideMargin: outsideMargin)

        guard isEditable, let textView = textView else { return }

        let textViewBackGroundY = margin + titleLableHeight + (title != nil && message != nil ? labelSpace : 0) + messageLabelHeight + textViewTopMargin
        addSubview(textViewBackgroundImageView)
        textViewBackgroundImageView.frame = CGRect(x: margin, y: textViewBackGroundY, width: labelWidth, height: textViewHeight + 2 * textViewTopPadding + limitLabelTotalHeight)

        addSubview(textView)
        textView.backgroundColor = .clear
        textView.tintColor = textView.cursorColor ?? markedColor
        textView.frame = CGRect(x: margin + textViewLeftPadding, y: textViewBackGroundY + textViewTopPadding, width: labelWidth - 2 * textViewLeftPadding, height: textViewHeight)
        textView.delegate = self

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = textView.lineSpacing
        paragraphStyle.alignment = textView.textAlignment
        textView.attributedText = NSAttributedString(string: textView.text ?? "",
                                                         attributes: [.paragraphStyle: paragraphStyle,
                                                                      .foregroundColor: textView.textColor as Any,
                                                                      .font: textView.font as Any])

        if textView.maxInputLength != nil, let limitLabel = limitLabel {
            addSubview(limitLabel)
            limitLabel.frame = CGRect(x: textView.frame.origin.x, y: textViewBackgroundImageView.frame.maxY - 20 - limitLabelHeight, width: textView.bounds.width, height: limitLabelHeight)
        }
    }
}

extension FancyAlertTextViewHeaderView: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        guard let tempText = textView.text, let textMaxLength = self.textView?.maxInputLength else { return }
        guard let fancyTextView = self.textView else { return }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = fancyTextView.lineSpacing
        paragraphStyle.alignment = fancyTextView.textAlignment
        let attributes: [NSAttributedString.Key: Any] = [.paragraphStyle: paragraphStyle,
                                                        .foregroundColor: fancyTextView.textColor as Any,
                                                        .font: fancyTextView.font as Any]

        let textCount = tempText.count
        let lang = textInputMode?.primaryLanguage
        if lang == "zh-Hans" {
            guard let _ = textView.markedTextRange else {
                if textCount > textMaxLength {
                    textView.attributedText = NSAttributedString(string: String(tempText.prefix(textMaxLength)), attributes: attributes)
                    limitLabel?.text = "\(max(0, tempInputLength - String(tempText.prefix(textMaxLength)).count))"
                } else {
                    textView.attributedText = NSAttributedString(string: tempText, attributes: attributes)
                    limitLabel?.text = "\(max(0, tempInputLength - tempText.count))"
                }
                return
            }
        } else {
            if textCount > textMaxLength {
                textView.attributedText = NSAttributedString(string: String(tempText.prefix(textMaxLength)), attributes: attributes)
                limitLabel?.text = "\(max(0, tempInputLength - String(tempText.prefix(textMaxLength)).count))"
            } else {
                textView.attributedText = NSAttributedString(string: tempText, attributes: attributes)
                limitLabel?.text = "\(max(0, tempInputLength - tempText.count))"
            }

        }
    }
}
