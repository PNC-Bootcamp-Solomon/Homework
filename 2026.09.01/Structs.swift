import Foundation

struct Transaction {
    let id: String
    let amount: Double
    var description: String
}

let t1 = Transaction(id: "1001", amount: 475.00, description: "Test Transaction")
// t2 must be a var if we want to change the description below
// because Swift constants are deeply enforced on value types
var t2 = t1

t2.description = "Updated Test Transaction"

print("t1.description = \(t1.description)")
print("t2.description = \(t2.description)")


struct Transaction2 {
    let id: String
    let amount: Double
    var description: String

    mutating func addNote(note: String) {
        description = "\(description). \(note)"
    }
}

var t3 = Transaction2(id: "ABS", amount : 500.00, description: "")
t3.addNote(note: "Some Comment")
print("t3.description = \(t3.description)")

let divider = "-----------------------------------"
print(divider)

class BankAccount {
    let id: String
    let accountNumber: String
    var balance: Double
    let owner: String

    init(id: String, acctNum: String, balance: Double, owner: String) {
        self.id = id
        accountNumber = acctNum
        self.balance = balance
        self.owner = owner
    }
    func deposit (amount: Double) {
        guard amount > 0 else { return }
        balance += amount
    }
    @discardableResult func withdraw (amount: Double) -> Bool {
        guard amount > 0 , amount <= balance else { return false }
        balance -= amount
        return true
    }

}

let acc1 = BankAccount(id: "ABC", acctNum: "12345", balance: 500.00, owner: "Solomon")

acc1.deposit(amount: 200.00)

let acc2 = acc1
acc2.withdraw(amount: 50.00)

print("Balance of acc1 = \(acc1.balance)")

print(divider)

// ENUM

enum AccountType: String {
    case checking = "CHECKING"
    case savings = "SAVINGS"
    case investment = "INVESTMENT"
    case credit = "CREDIT" 

    // create a read-only property for the displayName
    var displayName: String {
        switch self {
            case .checking:     return "Checking Account"
            case .savings:      return "Savings Account"
            case .investment:   return "Investment Account"
            case .credit:       return "Credit Card"
            // best practice to OMIT the default: case for an enum 
        }


    }
}

// one of the advantages of having Raw Values associated with each enum value:
var myType: AccountType? = AccountType(rawValue: "SAVINGS")

// Enums can also have data associated with each case
// each case could have different kinds of data associated

// create an enum for the ways a withdrawal can fail
enum AccountError {
    case insufficientFunds  (available: Double, requested: Double)
    case accountInactive
    case dailyLimitExceeded (limit: Double)
    case invalidAmount      (requested: Double)

}

class BankAccount2 {
    let id:             String
    let accountNumber:  String
    var balance:        Double
    let owner:          String
    var inactive:      Bool = false

    init(id: String, acctNum: String, balance: Double, owner: String) {
        self.id = id
        accountNumber = acctNum
        self.balance = balance
        self.owner = owner
    }
    func deposit (amount: Double) {
        guard amount > 0 else { return }
        balance += amount
    }
    func withdraw (amount: Double) -> ( success: Bool, error: AccountError?) {
        guard inactive == false else    { return (false, .accountInactive)}
        guard amount > 0 else           { return (false, .invalidAmount(requested: amount))}
        guard amount <= balance else    { return (false, .insufficientFunds(available: balance, requested: amount))}
        balance -= amount
        return (true, nil)
    }

}

let acc3 = BankAccount2(id: "12345", acctNum: "ABC456", balance: 1000, owner: "Alice")

let result = acc3.withdraw(amount: 1500)

switch result.error {
    case nil:
        print("Successful withdrawal")
    case .accountInactive:
        print("Cannot withdraw from an inactive account")
    case .insufficientFunds(available: let avail, requested: let req):
        print("Not enough funds. You only have \(avail)")
    case .invalidAmount(requested: let req):
        print("Invalid amount requested: \(req)")
    case .dailyLimitExceeded(limit: let lim):
        print("You have exceeded your daily limit of \(lim)")
}

print(divider)

// PROTOCOL is a contract describing a set of attributes (properties and/or methods)
protocol Describable {
    var description: String { get }

}

struct Transaction3: Describable { 
    let id: String
    let amount: Double
    var description: String

}

class BankAccount3: Describable {
    let id:             String
    let accountNumber:  String
    var balance:        Double
    let owner:          String
    var inactive:      Bool = false

    var description: String {
        return "BankAccount #\(accountNumber) owned by \(owner)"
    }

    init(id: String, acctNum: String, balance: Double, owner: String) {
        self.id = id
        accountNumber = acctNum
        self.balance = balance
        self.owner = owner
    }
    func deposit (amount: Double) {
        guard amount > 0 else { return }
        balance += amount
    }
    func withdraw (amount: Double) -> ( success: Bool, error: AccountError?) {
        guard inactive == false else    { return (false, .accountInactive)}
        guard amount > 0 else           { return (false, .invalidAmount(requested: amount))}
        guard amount <= balance else    { return (false, .insufficientFunds(available: balance, requested: amount))}
        balance -= amount
        return (true, nil)
    }

}

func printAll(_ items: [Describable]) {
    items.forEach{print($0.description)}
}

let things = [
    Transaction3(id: "X111", amount: 150.00, description: "Traveler's Checkque Order")
    Transaction3(id: "A222", acctNum: ABC12, balance: 894.00 owner: "Stuart")
    Transaction3(id: "X555", amount: 99.00, description: "Utility Payment")
]

printAll(things)

































