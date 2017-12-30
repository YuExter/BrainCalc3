//
//  CalculatorBrain.swift
//  CalculatorBrain_3
//
//  Created by Юля Пономарева on 24.12.2017.
//  Copyright © 2017 Юля Пономарева. All rights reserved.
//

import Foundation

class CalculatorBrain {
    fileprivate var accumulator = 0.0
    fileprivate var internalProgram = [String]()
    fileprivate var descriptionAccumulator = " "
    fileprivate var isPartialResult: Bool {
        get {
            return self.pending != nil
        }
    }
    
    var description: String {
        get {
            if !isPartialResult {
                return self.descriptionAccumulator
            } else {
                guard let pending = pending else { return "" }
                
                return pending.descriptionFunction(pending.descriptionOperand, pending.descriptionOperand != self.descriptionAccumulator ? self.descriptionAccumulator : "")
            }
        }
    }
    
    var getDescription: String {
        get {
            if self.description != " " {
                return self.isPartialResult ? (self.description + "...") : (self.description + "=")
            } else {
                return " "
            }
            
        }
    }
    
    var variableValues = [String: Double]()
    
    func setOperand(with name: String) {
        self.internalProgram.append(name)
    }
    
    func setOperand(_ operand: Double) {
        self.internalProgram.append(String(operand))
    }
    
    fileprivate var operations: Dictionary<String, Operation> = [
        "π" : Operation.Constant(Double.pi),
        "e" : Operation.Constant(M_E),
        "√" : Operation.UnaryOperation(sqrt, { "√(\($0))" }),
        "sin" : Operation.UnaryOperation(sin, { "sin(\($0))" }),
        "cos" : Operation.UnaryOperation(cos, { "cos(\($0))" }),
        "tan" : Operation.UnaryOperation(tan, { "tan(\($0))" }),
        "x²" : Operation.UnaryOperation({ $0 * $0 }, { "(\($0))²"}),
        "+" : Operation.BinaryOperation({ $0 + $1 }, { "\($0)+\($1)" }, OperationPriority.Low),
        "-" : Operation.BinaryOperation({ $0 - $1 }, { "\($0)-\($1)" }, OperationPriority.Low),
        "×" : Operation.BinaryOperation({ $0 * $1 }, { "\($0)×\($1)" }, OperationPriority.High),
        "÷" : Operation.BinaryOperation({ $0 / $1 }, { "\($0)÷\($1)" }, OperationPriority.High),
        "%" : Operation.BinaryOperation({ $0.truncatingRemainder(dividingBy: $1)}, { "\($0)%\($1)" }, OperationPriority.High),
        "=" : Operation.Equals,
        "C" : Operation.Clear
    ]
    
    fileprivate enum OperationPriority: Int {
        case Low = 0, High = 1
    }
    fileprivate var currentPriority = OperationPriority.Low
    
    fileprivate enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double, (String) -> String)
        case BinaryOperation((Double, Double) -> Double, (String, String) -> String, OperationPriority)
        case Clear
        case Equals
    }
    
    func addOperation(_ symbol: String) {
        internalProgram.append(symbol)
    }
    
    func performOperation(_ symbol: String) {
        if let operation = self.operations[symbol] {
            switch operation {
            case .Constant(let value):
                self.descriptionAccumulator = symbol
                self.accumulator = value
            case .UnaryOperation(let function, let descriptionFunction):
                self.accumulator = function(accumulator)
                self.descriptionAccumulator = descriptionFunction(descriptionAccumulator)
            case .BinaryOperation(let function, let descriptionFunction, let operationPriority):
                self.executePendingBinaryOperation()
                if(self.currentPriority.rawValue < operationPriority.rawValue) {
                    self.descriptionAccumulator = "(\(self.descriptionAccumulator))"
                }
                self.currentPriority = operationPriority;
                self.pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator, descriptionFunction: descriptionFunction, descriptionOperand: descriptionAccumulator)
            case .Equals:
                self.executePendingBinaryOperation()
            case .Clear:
                self.clear()
            }
        }
    }
    
    fileprivate func executePendingBinaryOperation() {
        if self.pending != nil {
            self.descriptionAccumulator = pending!.descriptionFunction(pending!.descriptionOperand, descriptionAccumulator)
            self.accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            self.pending = nil
        }
    }
    
    fileprivate var pending: PendingBinaryOperationInfo?
    
    struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
        var descriptionFunction: (String, String) -> String
        var descriptionOperand: String
    }
    
    func clear() {
        self.accumulator = 0
        self.descriptionAccumulator = " "
        self.pending = nil
        self.internalProgram.removeAll()
        self.variableValues.removeAll()
    }
    
    func undo() {
        if self.internalProgram.count >= 1 {
            self.internalProgram.removeLast()
        }
    }
    
    var result: Double {
        get {
            return self.accumulator
        }
    }
    
    func evaluate(using variables: Dictionary<String,Double>? = nil)
        -> (result: Double?, isPending: Bool, description: String) {
            if variables != nil {
                self.variableValues = variables!
            }
            self.accumulator = 0
            self.descriptionAccumulator = " "
            self.pending = nil
            
            for entry in internalProgram {
                print(entry)
                if let operand = Double(entry) {
                    descriptionAccumulator = "\(operand)"
                    self.accumulator = operand
                } else if let _ = operations[entry] {
                    self.performOperation(entry)
                } else {
                    self.accumulator = variableValues[entry] ?? 0.0
                    self.descriptionAccumulator = entry
                }
            }
            return (self.accumulator, self.isPartialResult, self.getDescription)
    }
}
