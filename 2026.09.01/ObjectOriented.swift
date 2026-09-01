
// ============================================================
// EXERCISE: Structs — Value Types
// Estimated time: 20 minutes
//
// Structs in Swift are MUCH more powerful than in C.
// They can have methods, computed properties, and protocol conformance.
// The key rule: assignment COPIES a struct. Two variables never
// share the same struct instance.
// ============================================================

import Foundation
let divider = "===================================================="

// TODO 3a: Define a struct named Transaction with these stored properties:
//   id: String
//   date: Date
//   amount: Double
//   description: String
//   isDebit: Bool
//
// Add these computed properties:
//   formattedAmount: String
//     → returns "-$250.00" if isDebit, "+$250.00" if credit
//     → use String(format: "%.2f", abs(amount))
//
//   formattedDate: String
//     → use DateFormatter with dateStyle: .medium, timeStyle: .none
//
// Add a memberwise initializer (Swift gives you this FREE for structs —
// you do not need to write init() unless you want custom behavior).

struct Transaction {
    let id:             String
    let date:           Date
    let amount:         Double
    var description:    String
    let isDebit:        Bool
    var isPending:      Bool = false

    var formattedAmount: String {
        guard isDebit == true else { return "+ $\(String(format: "%.2f", abs(amount)))"}
        return "- $\(String(format: "%.2f", abs(amount)))"
    }
    var formattedDate: String {
        let format = DateFormatter()
        format.dateStyle = .medium
        format.timeStyle = .none
        return format.string(from: date)
    }
    mutating func markAsPending() {
        isPending = true
    }
}

// TODO 3b: Create two Transaction instances:
//   t1: a credit of $2,500.00 described as "Direct Deposit"
//   t2: a debit of $45.67 described as "Starbucks"
// Print their formattedAmount and description.

var t1 = Transaction(id: "", date: Date(), amount: 2500.00, description: "Direct Deposit", isDebit: false)
print("Change: \(t1.formattedAmount) \t Description: \(t1.description)")

var t2 = Transaction(id: "", date: Date(), amount: 45.67, description: "Starbucks", isDebit: true)
print("Change: \(t2.formattedAmount) \t Description: \(t2.description)")

print(divider)

// TODO 3c: Prove value semantics
// Assign t1 to a new variable t3.
// Try to change t3.description to "Modified".
// What happens? Why?
// Fix it by declaring t3 with var instead of let.
// Then change t3.description and print both t1.description and t3.description.
// Observe that t1 is unchanged. This is the key difference from classes.

var t3 = t1
t3.description = "Modified"
print("T1 Description: \(t1.description)")
print("T3 Description: \(t3.description)")
print(divider)

// TODO 3d: Add a mutating method to Transaction named markAsPending
// that sets a new stored property isPending: Bool = false to true.
// Call it on t2 and verify.

t2.markAsPending()
print("Transaction Pending: \(t2.isPending)")
print(divider)

// ============================================================
// EXERCISE: Classes — Reference Types
// Estimated time: 20 minutes
//
// Classes add: inheritance, reference semantics (assignment shares
// the same object), and deinitializers.
// Use classes for: managers, services, view controllers — things
// that have IDENTITY and LIFECYCLE, not just data.
// ============================================================

// TODO 4a: Define a class named BankAccount with:
//   Stored properties:
//     id: String
//     accountNumber: String
//     balance: Double
//     owner: String
//
//   A designated initializer: init(id:accountNumber:owner:initialBalance:)
//   where initialBalance has a default of 0.0
//
//   Methods:
//     deposit(amount: Double) — adds to balance if amount > 0
//     withdraw(amount: Double) -> Bool — subtracts if amount > 0 and <= balance; returns success
//     printSummary() — prints "Account [accountNumber] | Owner: [owner] | Balance: $X.XX"

class BankAccount {
    let id:             String
    let accountNumber:  String
    var balance:        Double
    let owner:          String

    init(id: String, accountNumber: String, owner: String, initialBalance: Double = 0.0) {
        self.id = id
        self.accountNumber = accountNumber
        self.owner = owner
        balance = initialBalance
    }
    func deposit (amount: Double){
        guard amount > 0 else { return }
        balance += amount
    }
    @discardableResult func withdraw (amount: Double) -> Bool{
        guard amount > 0 , amount <= balance else { return false }
        balance -= amount
        return true
    }
    func printSummary () {
        print("Account: \(accountNumber) | Owner: \(owner) | Balance: $\(balance)")
    }
}

// TODO 4b: Create two BankAccount instances:
//   checking: id "acc_001", accountNumber "1234567890", owner "Jane Smith", balance 1_000.00
//   savings:  id "acc_002", accountNumber "0987654321", owner "Jane Smith", balance 5_000.00
// Call deposit and withdraw on checking. Print summaries for both.

let accountOne = BankAccount(id: "acc_001", accountNumber: "1234567890", owner: "Jane Smith", initialBalance: 1_000.00)
accountOne.deposit(amount: 500.00)     // 1_500
accountOne.withdraw(amount: 250.00)    // 500 ending balance
accountOne.printSummary()

let accountTwo = BankAccount(id: "acc_002", accountNumber: "0987654321", owner: "Jane Smith", initialBalance: 5_000.00)
accountTwo.deposit(amount: 1000.00)     // 6_000
accountTwo.withdraw(amount: 3000.00)    // 3_000 ending balance
accountTwo.printSummary()

print(divider)

// TODO 4c: Prove reference semantics
// Assign checking to a new variable checkingRef.
// Call checkingRef.deposit(amount: 500)
// Print checking.balance and checkingRef.balance.
// Observe they are THE SAME object — both show the updated balance.
// Write a comment explaining why this is different from the struct in 3c.

let checking = BankAccount(id: "A", accountNumber: "1", owner: "", initialBalance: 0.0)
let checkingRef = checking
checkingRef.deposit(amount: 500)
print("Checking:\t\(checking.balance)")
print("CheckingRef\t\(checkingRef.balance)")
// This is different than the struct in 3c because BankAccount() is a class which is a reference type.
// so checkingRef = checking does not copy the object but copies the reference to the same instance
// hence checkingRef.depost(amount: 500) modidies the same instance. Struct is a value type 
// which allowed t2 to be assigned to t1 which made a brand new instance.

print(divider)

// TODO 4d: Inheritance
// Define a class PremiumBankAccount that inherits from BankAccount.
// Add a stored property overdraftLimit: Double
// Override withdraw(amount:) so that withdrawal succeeds if
// amount <= balance + overdraftLimit (draws from overdraft if needed).
// Add a convenience initializer that takes the same params as BankAccount
// plus overdraftLimit.
//
// Test it: create a premium account with balance 100 and overdraftLimit 500.
// Withdraw 400 — should succeed (draws on overdraft).
// Withdraw 800 — should fail (exceeds balance + overdraftLimit).

class PremiumBankAccount: BankAccount {
    let overdraftLimit: Double

    init(id: String, accountNumber: String, owner: String, initialBalance: Double = 0.0, limit: Double){
        overdraftLimit = limit
        super.init(id: id, accountNumber: accountNumber, owner: owner, initialBalance: initialBalance)
    }
    convenience override init(id: String, accountNumber: String, owner: String, initialBalance: Double = 0.0){
        self.init(id: id, accountNumber: accountNumber, owner: owner, initialBalance: initialBalance, limit: 0.0)
    }
    @discardableResult override func withdraw (amount: Double) -> Bool{
        guard amount <= balance + overdraftLimit else { print("\nWithdraw Failed"); return false }
        balance -= amount
        return true
    }

}

let accountPrem = PremiumBankAccount(id: "Prem_Acc_001", accountNumber: "789456", owner: "Solomon C", initialBalance: 500.00, limit: 500)

accountPrem.withdraw(amount: 400.00)
accountPrem.printSummary()

accountPrem.withdraw(amount: 800.00)
accountPrem.printSummary()

print(divider)

// ============================================================
// EXERCISE: Enumerations
// Estimated time: 15 minutes
//
// Swift enums are the richest in any mainstream language.
// They can carry associated values — meaning each case can
// store different data. This replaces many patterns where
// Python/JS developers would use a dict or tuple.
// ============================================================

// TODO 5a: Define an enum TransactionType with cases:
//   credit, debit, transfer, fee
// Make it conform to String and CaseIterable:
//   enum TransactionType: String, CaseIterable

enum TransactionType: String , CaseIterable{
    case credit     = "credit"
    case debit      = "debit"
    case transfer   = "transfer"
    case fee        = "fee" 

    var displayName: String {
        switch self {
            case .credit:   return "Credit"
            case .debit:    return "Debit"
            case .transfer: return "Transfer"
            case .fee:      return "Fee"
        }
    }
}

// TODO 5b: Add a computed property displayName: String to TransactionType
// using a switch that returns:
//   credit   → "Credit"
//   debit    → "Debit"
//   transfer → "Transfer"
//   fee      → "Fee"


// TODO 5c: Enum with associated values
// Define an enum AccountError with these cases:
//   insufficientFunds(available: Double, requested: Double)
//   accountInactive
//   dailyLimitExceeded(limit: Double)
//   invalidAmount
//
// Write a function describeError(_ error: AccountError) -> String
// that uses a switch with associated value binding to return
// a user-friendly message for each case.
// Test it with all four cases.

enum AccountError {
    case insufficientFunds  (available: Double, requested: Double)
    case accountInactive
    case dailyLimitExceeded (limit: Double)
    case invalidAmount      
}

func describeError(_ error: AccountError) -> String {
    switch error {
        case .accountInactive:
            return "Cannot withdraw from an inactive account"
        case .insufficientFunds(available: let avail, requested: let req):
            return "Not enough funds. You only have \(avail)"
        case .invalidAmount:
            return "Invalid amount requested"
        case .dailyLimitExceeded(limit: let lim):
            return "You have exceeded your daily limit of \(lim)"
    }
}

let error_1 = AccountError.insufficientFunds(available: 1_000, requested: 2_000)
let error_2 = AccountError.accountInactive
let error_3 = AccountError.dailyLimitExceeded(limit: 1_000)
let error_4 = AccountError.invalidAmount

print(describeError(error_1))
print(describeError(error_2))
print(describeError(error_3))
print(describeError(error_4))
print(divider)

// TODO 5d: Iterate over all cases
// Using CaseIterable on TransactionType, print all transaction types
// and their raw values:
// for type in TransactionType.allCases { print(...) }
// Expected:
//   credit → "credit"
//   debit → "debit"
//   etc.

for type in TransactionType.allCases {
    if type.rawValue.count >= 8 {
        print("\(type)\t -> \t\"\(type.rawValue)\"")
    } else if type.rawValue.count <= 4 {
        print("\(type)\t\t\t -> \t\"\(type.rawValue)\"")
    } else {
        print("\(type)\t\t -> \t\"\(type.rawValue)\"")
    }
}

print(divider)

// Groovy! 

// Have a nice evening!

