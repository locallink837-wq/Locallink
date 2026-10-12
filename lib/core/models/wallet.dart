/// Wallet document (`wallets/{uid}`).
class Wallet {
  final String uid;
  final int balance; // Available credits (1 credit = Rs 1)
  final DateTime? updatedAt;

  const Wallet({
    required this.uid,
    this.balance = 0,
    this.updatedAt,
  });

  bool hasSufficientBalance(int requiredFee) => balance >= requiredFee;

  factory Wallet.fromMap(String uid, Map<String, dynamic> m) => Wallet(
        uid: uid,
        balance: (m['balance'] ?? 0) as int,
        updatedAt: m['updatedAt'] != null
            ? (m['updatedAt'] is DateTime
                ? m['updatedAt'] as DateTime
                : DateTime.tryParse(m['updatedAt'].toString()))
            : null,
      );

  Map<String, dynamic> toMap() => {
        'balance': balance,
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };
}

/// Wallet transaction ledger (`wallets/{uid}/wallet_txns/{txnId}`).
class WalletTransaction {
  final String id;
  final String type; // credit | debit
  final int amount;
  final String description; // e.g., 'Lead fee -25', 'Top up +100'
  final DateTime createdAt;

  const WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.createdAt,
  });

  bool get isCredit => type == 'credit';
  bool get isDebit => type == 'debit';

  factory WalletTransaction.fromMap(String id, Map<String, dynamic> m) =>
      WalletTransaction(
        id: id,
        type: (m['type'] ?? 'debit') as String,
        amount: (m['amount'] ?? 0) as int,
        description: (m['description'] ?? '') as String,
        createdAt: m['createdAt'] != null
            ? (m['createdAt'] is DateTime
                ? m['createdAt'] as DateTime
                : DateTime.tryParse(m['createdAt'].toString()) ?? DateTime.now())
            : DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'type': type,
        'amount': amount,
        'description': description,
        'createdAt': createdAt.toIso8601String(),
      };
}
