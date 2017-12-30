//
//  CalculatorViewController.swift
//  CalculatorBrain_3
//
//  Created by Юля Пономарева on 24.12.2017.
//  Copyright © 2017 Юля Пономарева. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController, UISplitViewControllerDelegate {
    
    @IBOutlet fileprivate var displaying: UILabel!
    @IBOutlet fileprivate var descriptionLabel: UILabel!
    @IBOutlet fileprivate var MDisplayLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.splitViewController?.delegate = self
    }
    
    var userInTheMiddleOfTyping : Bool = false
    
    private var displayValue: Double {
        get {
            guard let textValue = self.displaying.text, let doubleValue = Double(textValue) else {
                return 0.0
            }
            return doubleValue
        }
        set {
            self.displaying.text = String(newValue)
        }
    }
    
    private var brain: CalculatorBrain = CalculatorBrain()
    
    @IBAction func touchDigits(_ sender: UIButton) {
        let digit = sender.currentTitle ?? ""
        
        if self.userInTheMiddleOfTyping {
            if let text = self.displaying.text, text == "0" {
                self.displaying.text = digit
            } else {
                let textCurrentlyDisplay = self.displaying.text ?? ""
                self.displaying.text = textCurrentlyDisplay + digit
            }
        } else {
            self.displaying.text = digit
            self.userInTheMiddleOfTyping = true
        }
    }
    
    @IBAction func touchingClearButton(_ sender: UIButton) {
        self.brain.performOperation(sender.currentTitle ?? "")
        let (result, _, description) = brain.evaluate()
        self.userInTheMiddleOfTyping = false
        self.displayValue = result ?? 0
        descriptionLabel.text = description
        self.MDisplayLabel.text = "M = 0"
    }
    
    @IBAction func erasingDigit(_ sender: UIButton) {
        if self.userInTheMiddleOfTyping {
            var displayedText = self.displaying.text ?? ""
            switch displayedText.count {
            case let count where count > 1:
                displayedText.remove(at: displayedText.index(before: displayedText.endIndex))
                self.displaying.text = displayedText
            case let count where count == 1:
                self.displaying.text = "0"
            default:
                break
            }
        } else {
            self.brain.undo()
            self.updateUI()
        }
    }
    
    @IBAction func touchFloatDot() {
        if self.userInTheMiddleOfTyping {
            guard let textCurrentDisplay = self.displaying.text, !textCurrentDisplay.contains(".") else {
                return
            }
            let textCurrentlyDisplay = self.displaying.text ?? ""
            self.displaying.text = textCurrentlyDisplay + "."
        } else {
            guard let textCurrentDisplay = self.displaying.text, !textCurrentDisplay.contains(".") else {
                return
            }
            self.displaying.text = textCurrentDisplay + "."
            self.userInTheMiddleOfTyping = true
        }
    }
    
    func updateUI() {
        let (result, _, description) = self.brain.evaluate()
        self.displayValue = result ?? 0
        self.descriptionLabel.text = description
    }
    
    @IBAction func settingVariable() {
        self.brain.setOperand(with: "M")
        self.userInTheMiddleOfTyping = false
    }
    
    @IBAction func evaluatingVariable(_ sender: UIButton) {
        let variableValues: [String: Double] = ["M": self.displayValue]
        self.MDisplayLabel.text = "M = \(displayValue)"
        let (result, _, description) = self.brain.evaluate(using: variableValues)
        self.userInTheMiddleOfTyping = false
        self.displayValue = result ?? 0
        descriptionLabel.text = description
    }
    
    @IBAction func performingOperation(_ sender: UIButton) {
        if self.userInTheMiddleOfTyping {
            self.brain.setOperand(self.displayValue)
            self.userInTheMiddleOfTyping = false
        }
        
        if let mathSymbol = sender.currentTitle {
            self.brain.addOperation(mathSymbol)
        }
        
        self.updateUI()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        let (_, pending, _) = self.brain.evaluate()
        return !pending
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let graphicVC = segue.destination.contents as? GraphicViewController {
            graphicVC.navigationItem.title = self.brain.description
            graphicVC.function = {
                (x: CGFloat) -> CGFloat in
                self.brain.variableValues["M"] = Double(x)
                let (result, _, _) = self.brain.evaluate()
                return CGFloat(result ?? 0)
            }
        }
    }
    
    func splitViewController(_ splitViewController: UISplitViewController,
                             collapseSecondary secondaryViewController: UIViewController,
                             onto primaryViewController: UIViewController) -> Bool {
        if primaryViewController.contents == self {
            if let graphicVC = secondaryViewController.contents as? GraphicViewController, graphicVC.function == nil {
                return true
            }
        }
        return false
    }
}

extension UIViewController {
    var contents: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? self
        } else {
            return self
        }
    }
}

