import UIKit

protocol BottomContainerViewDelegate: class {

  func pickerButtonDidPress()
  func doneButtonDidPress()
  func cancelButtonDidPress()
  func imageStackViewDidPress()
}

class BottomContainerView: UIView {

  lazy var pickerButton: ButtonPicker = {
    let pickerButton = ButtonPicker()
    pickerButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    pickerButton.setTranslatesAutoresizingMaskIntoConstraints(false)
    pickerButton.delegate = self

    return pickerButton
    }()

  lazy var borderPickerButton: UIView = {
    let view = UIView()
    view.backgroundColor = .clearColor()
    view.layer.borderColor = UIColor.whiteColor().CGColor
    view.layer.borderWidth = ButtonPicker.Dimensions.borderWidth
    view.layer.cornerRadius = ButtonPicker.Dimensions.buttonBorderSize / 2
    view.setTranslatesAutoresizingMaskIntoConstraints(false)

    return view
    }()

  lazy var doneButton: UIButton = { [unowned self] in
    let button = UIButton()
    button.setTitle(self.configuration.cancelButtonTitle, forState: .Normal)
    button.titleLabel!.font = self.configuration.doneButton
    button.addTarget(self, action: "doneButtonDidPress:", forControlEvents: .TouchUpInside)
    button.setTranslatesAutoresizingMaskIntoConstraints(false)

    return button
    }()

  lazy var stackView: ImageStackView = {
    let view = ImageStackView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
    view.setTranslatesAutoresizingMaskIntoConstraints(false)

    return view
    }()
  lazy var configuration: PickerConfiguration = {
    let configuration = PickerConfiguration()
    return configuration
    }()

  lazy var topSeparator: UIView = { [unowned self] in
    let view = UIView()
    view.setTranslatesAutoresizingMaskIntoConstraints(false)
    view.backgroundColor = self.configuration.backgroundColor

    return view
    }()

  lazy var tapGestureRecognizer: UITapGestureRecognizer = {
    let gesture = UITapGestureRecognizer()
    gesture.addTarget(self, action: "handleTapGestureRecognizer:")

    return gesture
    }()

  weak var delegate: BottomContainerViewDelegate?
  var pastCount = 0

  // MARK: Initializers

  override init(frame: CGRect) {
    super.init(frame: frame)

    [borderPickerButton, pickerButton, doneButton, stackView, topSeparator].map { self.addSubview($0) }
    backgroundColor = configuration.backgroundColor
    stackView.addGestureRecognizer(tapGestureRecognizer)

    setupConstraints()
  }

  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Autolayout

  func setupConstraints() {
    let attributesBorder: [NSLayoutAttribute] = [.CenterX, .CenterY]
    let attributesSeparator: [NSLayoutAttribute] = [.Width, .Left, .Top]
    let attributesSize: [NSLayoutAttribute] = [.Width, .Height]

    attributesBorder.map {
      self.addConstraint(NSLayoutConstraint(item: self.pickerButton, attribute: $0,
        relatedBy: .Equal, toItem: self, attribute: $0,
        multiplier: 1, constant: 0))
    }

    attributesSize.map {
      self.addConstraint(NSLayoutConstraint(item: self.pickerButton, attribute: $0,
        relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
        multiplier: 1, constant: ButtonPicker.Dimensions.buttonSize))
    }

    attributesSize.map {
      self.addConstraint(NSLayoutConstraint(item: self.borderPickerButton, attribute: $0,
        relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
        multiplier: 1, constant: ButtonPicker.Dimensions.buttonBorderSize))
    }

    attributesSize.map {
      self.addConstraint(NSLayoutConstraint(item: self.stackView, attribute: $0,
        relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
        multiplier: 1, constant: ImageStackView.Dimensions.imageSize))
    }

    attributesBorder.map {
      self.addConstraint(NSLayoutConstraint(item: self.borderPickerButton, attribute: $0,
        relatedBy: .Equal, toItem: self, attribute: $0,
        multiplier: 1, constant: 0))
    }

    addConstraint(NSLayoutConstraint(item: doneButton, attribute: .CenterY,
      relatedBy: .Equal, toItem: self, attribute: .CenterY,
      multiplier: 1, constant: 0))

    addConstraint(NSLayoutConstraint(item: stackView, attribute: .CenterY,
      relatedBy: .Equal, toItem: self, attribute: .CenterY,
      multiplier: 1, constant: -2))

    attributesSeparator.map {
      self.addConstraint(NSLayoutConstraint(item: self.topSeparator, attribute: $0,
        relatedBy: .Equal, toItem: self, attribute: $0,
        multiplier: 1, constant: 0))
    }

    addConstraint(NSLayoutConstraint(item: doneButton, attribute: .CenterX,
      relatedBy: .Equal, toItem: self, attribute: .Right,
      multiplier: 1, constant: -(UIScreen.mainScreen().bounds.width - (ButtonPicker.Dimensions.buttonBorderSize + UIScreen.mainScreen().bounds.width)/2)/2))

    addConstraint(NSLayoutConstraint(item: stackView, attribute: .CenterX,
      relatedBy: .Equal, toItem: self, attribute: .Left,
      multiplier: 1, constant: UIScreen.mainScreen().bounds.width/4 - ButtonPicker.Dimensions.buttonBorderSize/4))

    addConstraint(NSLayoutConstraint(item: topSeparator, attribute: .Height,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: 1))
  }

  // MARK: - Action methods

  func doneButtonDidPress(button: UIButton) {
    if button.currentTitle == configuration.cancelButtonTitle {
      delegate?.cancelButtonDidPress()
    } else {
      delegate?.doneButtonDidPress()
    }
  }

  func handleTapGestureRecognizer(recognizer: UITapGestureRecognizer) {
    delegate?.imageStackViewDidPress()
  }

  private func animateImageView(imageView: UIImageView) {
    imageView.transform = CGAffineTransformMakeScale(0, 0)

    UIView.animateWithDuration(0.3, animations: { [unowned self] in
      imageView.transform = CGAffineTransformMakeScale(1.05, 1.05)
      }, completion: { _ in
        UIView.animateWithDuration(0.2, animations: { _ in
          imageView.transform = CGAffineTransformIdentity
        })
    })
  }
}

// MARK: - ButtonPickerDelegate methods

extension BottomContainerView: ButtonPickerDelegate {

  func buttonDidPress() {
    delegate?.pickerButtonDidPress()
  }
}
