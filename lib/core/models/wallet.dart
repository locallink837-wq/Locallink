/// wallets/{uid}  (written by Cloud Functions ONLY)
class Wallet {
  final String uid;
  final int balance; // credits
  const Wallet({required this.uid, this.balance = 0});

  factory Wallet.fromMap(String uid, Map<String, dynamic> m) =>
      Wallet(uid: uid, balance: (m['balance'] ?? 0) as int);
}
