import Foundation
let divider = "==========================================="

// Section 1: Enumerations

// 1A:

enum TransactionType: String, CaseIterable, Codable {
    case credit
    case debit
    case transfer
    case fee

    var isExpense: Bool {
        switch self {
            case .debit, .fee: return true
            default: return false
        }
    }
}

// 2B:
enum TransactionStatus: String, Codable {
    case pending
    case completed
    case failed
    case cancelled

    var isTerminal: Bool {
        switch self {
            case .completed, .failed, .cancelled: return true
            case .pending: return false
        }
    }
}

// Section 2: Transaction Structs
struct Transaction: Identifiable, Codable, Equatable, Hashable, Summarizable {
    var id: String = UUID().uuidString
    let date: Date
    let amount: Double
    let description: String
    let type: TransactionType
    var status: TransactionStatus = .completed
    let category: String?
    let merchantName: String?

    init (date: Date, amount: Double, description: String, type: TransactionType, 
    status: TransactionStatus, category: String?, merchantName: String?) {
        self.date = date
        self.amount = amount
        self.description = description
        self.type = type
        self.status = status
        self.category = category
        self.merchantName = merchantName 
    }
    var formattedAmount: String {
        "\(type.isExpense ? "-" : "+")$\(String(format: "%.2f", amount))"
    }
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    var resolvedCategory: String {
        category ?? "Uncatergorized"
    }
    var summary: String { "" }
}
// 3B
class BankAccount: Identifiable, AccountOperations, Summarizable {
    let id: String
    let accountNumber: String
    let accountType: String
    let nickname: String?
    var balance: Double
    var availableBalance: Double
    let currency: String = "USD"
    let isActive: Bool = true
    var transactions: [Transaction]
    var summary: String { "" }

    init (id:String, accountNumber: String, accountType: String, nickname: String?,
    initialBalance: Double, currency: String, isActive: Bool, transactions: [Transaction]) {
        self.id = id
        self.accountNumber = accountNumber
        self.accountType = accountType
        self.nickname = nickname
        self.balance = initialBalance
        self.availableBalance = initialBalance
        self.transactions = transactions
    }

    var displayName: String { self.nickname ?? accountType.capitalized }
    var maskedAccountNumber: String { "****\(accountNumber.suffix(4))" }
    var formattedBalance: String { "$\(String(format: "%.2f", balance))" }
    var recentTransactions: [Transaction] = []
    var pendingCount: Int { 
        recentTransactions.filter { $0.status.isTerminal }.count
    }   
    func deposit(amount: Double)  throws -> String  {
        guard isActive else { throw AccountOperationsError.accountInactive }
        guard amount > 0 else { throw AccountOperationsError.invalidAmount }
        balance += amount
        return ("Deposit Successful")
    }
    func withdraw(amount: Double) throws -> String {
        guard isActive else { throw AccountOperationsError.accountInactive }
        guard amount > 0 else { throw AccountOperationsError.invalidAmount }
        guard amount <= balance else { 
            throw AccountOperationsError.insufficientFunds(available: balance, required: amount)
        }
        balance -= amount
        return ("Withdraw Successful")
    }
    func transfer(amount: Double, to destination: BankAccount) throws -> String { 
        guard isActive else { throw AccountOperationsError.accountInactive }
        guard amount > 0 else { throw AccountOperationsError.invalidAmount }
        guard amount <= balance else { 
            throw AccountOperationsError.insufficientFunds(available: amount, required: amount)
        }
        guard self.id != destination.id else { throw AccountOperationsError.transferToSameAccount }
        balance -= amount
        destination.balance += amount
        return ("Transfew to \(destination.id) from \(id) Successful")
    }
    func addTransaction (_ transaction: Transaction) {
        transactions.append (transaction)
        if transaction.type.isExpense { balance -= transaction.amount }
        else { balance += transaction.amount }
        availableBalance = balance
    }
}


// throw -> AccountOptionalsError

// 4A
protocol Summarizable {
    var summary : String { get }
}
extension Summarizable {
    func printSummary() { print(summary) }
}
// 4B
protocol AccountOperations {
    func deposit (amount: Double) throws -> String
    func withdraw (amount: Double) throws -> String
    func transfer (amount: Double, to destination: BankAccount) throws -> String
}

enum AccountOperationsError: LocalizedError {
    case invalidAmount
    case insufficientFunds (available: Double, required: Double)
    case accountInactive
    case transferToSameAccount
    case dailyLimitExceeded (limit: Double)


    var errorDescription: String? {
        switch self {
            case .invalidAmount:        
                return "The amount must be greater than zero"
            case .insufficientFunds(available: let avail, required: let req):  
                return "Insuffiecient Funds. Available: $\(String(format: "%.2f", avail)) | $\(String(format: "%.2f", req))"
            case .accountInactive:
                return "Account is not longer active."
            case .transferToSameAccount:
                return "Transfer can not be sent to the same account."
            case .dailyLimitExceeded(limit: let lim):
                return "Daily transfer limit exceeded: $\(String(format: "%.2f", lim))))"
        }
    }
}

// Section 5 Analytics

// Section 5A: AnalyticsProvider protocol 
protocol AnalyticsProvider {
    var totalCredits: Double { get }
    var totalDebits: Double { get }
    var netFlow: Double { get }
    var largestTransaction: Transaction? { get }
    func monthlyTotal(month: Int, year: Int) -> Double
    func transactionsByCategory() -> [String: [Transaction]]
}

struct AccountAnalytics: AnalyticsProvider {
    var transactions: [Transaction] = []
    var totalCredits: Double {
        transactions.filter { !$0.type.isExpense }.reduce(0){ $0 + $1.amount }
    }
    var totalDebits: Double {
        transactions.filter { $0.type.isExpense }.reduce(0) { $0 + $1.amount }
    }
    var netFlow: Double { totalCredits - totalDebits }
    var largestTransaction: Transaction? { 
        transactions.max(by: { $0.amount < $1.amount }) ?? nil 
    }

    func monthlyTotal (month: Int, year: Int) -> Double {
        let calendar = Calendar.current
        return transactions
        .filter {
            transaction in 
            let components = calendar.dateComponents([.year, .month], from: transaction.date)
            return components.year == year && components.month == month && transaction.type.isExpense
        } .reduce(0) { $0 + $1.amount }
    }
    func transactionsByCategory() -> [String: [Transaction]] {
        Dictionary(grouping: transactions, by: {$0.resolvedCategory})
    }
}

// Section 6
func reportResults<T: Summarizable>(_ items: [T], title: String) {
    items.forEach { item in
        print ("=== [title] ===\n(items.count)")
        item.printSummary()
        print ("=== End of [title] ===")
    }
}


// Section 7: Testing

// 7a: Create at least two BankAccount instances
  
func runlabDemo() {
    // 7A: Creating two BankAccounts
    let bankAccount001 = BankAccount(
        id:             "Checking Account",
        accountNumber:  "123456",
        accountType:    "Checking",
        nickname:       "",
        initialBalance: 3500.00,
        currency:       "USD",
        isActive:       true,
        transactions:   []
    )
    let bankAccount002 = BankAccount(
        id:             "Savings Account",
        accountNumber:  "654321",
        accountType:    "Savings",
        nickname:       "",
        initialBalance: 12500.00,
        currency:       "USD",
        isActive:       true,
        transactions:   []
    )
    // 7B: Creating five Transactions and checking the balance was updated
    print("======= 7B Testing =======")
    let credit1 = Transaction(
        date:         Date(),
        amount:       1500,
        description:  "Paycheck",
        type:         .credit,
        status:       .completed,
        category:     "Income",
        merchantName: "PNC"
    )
    bankAccount001.addTransaction(credit1)
    print(bankAccount001.formattedBalance) // Should be 5000
    let debit1 = Transaction(
        date:         Date(),
        amount:       1000,
        description:  "Rent",
        type:         .debit,
        status:       .completed,
        category:     "Bill",
        merchantName: "Landlord"
    )
    bankAccount001.addTransaction(debit1)
    print(bankAccount001.formattedBalance) // Should be 4000
        let debit2 = Transaction(
        date:         Date(),
        amount:       150,
        description:  "Groceries",
        type:         .debit,
        status:       .completed,
        category:     "Grocery",
        merchantName: "Giant Eagle"
    )
    bankAccount001.addTransaction(debit2)
    print(bankAccount001.formattedBalance) // Should be 3850
        let fee1 = Transaction(
        date:         Date(),
        amount:       50,
        description:  "Late fee",
        type:         .fee,
        status:       .completed,
        category:     "Late fee",
        merchantName: "Bank Name"
    )
    bankAccount001.addTransaction(fee1)
    print(bankAccount001.formattedBalance) // Should be 3800
        let transfer1 = Transaction(
        date:         Date(),
        amount:       1000,
        description:  "Transfer from credit account to savings account",
        type:         .transfer,
        status:       .completed,
        category:     "Transfer",
        merchantName: "PNC"
    )
    bankAccount001.addTransaction(transfer1)
    do { 
        _ = try bankAccount001.transfer(amount: transfer1.amount, to: bankAccount002) 
    } catch {print("Transfer failed")}
    print(bankAccount001.formattedBalance) // Should be 2800
    print(bankAccount002.formattedBalance)
    // end of Transaction testing

    // 7C: Testing all Errors
    print("======= 7C =======")
        do {
            _ = try bankAccount001.withdraw(amount: 10000)
        } catch let error as AccountOperationsError { print(error.localizedDescription)
        } catch { print(error)}
        do {
            _ = try bankAccount001.deposit(amount: -100)
        } catch let error as AccountOperationsError { print(error.localizedDescription)
        } catch { print(error)}
        do {
            _ = try bankAccount001.transfer(amount: 100, to: bankAccount001)
        } catch let error as AccountOperationsError { print(error.localizedDescription)
        } catch { print(error)}
    // end of Testing Errors

    // 7D:
}

print(runlabDemo())


//let bankAccount002 = BankAccount

    // init (date: Date, amount: Double, description: String, type: TransactionType, 
    // status: TransactionStatus, category: String?, merchantName: String?)      










