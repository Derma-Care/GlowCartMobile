import 'package:cutomer_app/Customers/GetCustomerModel.dart';
import 'package:cutomer_app/Dashboard/GetCustomerData.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:cutomer_app/Utils/capitalizeFirstLetter.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReferralWalletPage extends StatefulWidget {
  const ReferralWalletPage({super.key});

  @override
  State<ReferralWalletPage> createState() => _ReferralWalletPageState();
}

class _ReferralWalletPageState extends State<ReferralWalletPage> {
  final int walletBalance = 2000;

  late Future<GetCustomerModel> _futureUserData;
  String? customerId;
  GetCustomerModel? userData;
  @override
  void initState() {
    super.initState();
    _loadCustomerData();
  }

  Future<void> _loadCustomerData() async {
    final prefs = await SharedPreferences.getInstance();
    customerId = prefs.getString('customerId');
    setState(() {
      _futureUserData = fetchUserData(customerId ?? "");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Referral Wallet'),
        backgroundColor: mainColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _walletCard(),
            const SizedBox(height: 20),
            _referralCodeCard(context),
            const SizedBox(height: 20),
            _sectionTitle("Referral Rewards History"),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: 4,
                itemBuilder: (context, index) => _historyTile(
                  title: "Referral Reward",
                  subtitle: "Friend joined using your code",
                  amount: 500,
                  date: "10 July 2025",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _walletCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [mainColor, secondaryColor],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: secondaryColor,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Wallet Balance",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          Text(
            "💰 $walletBalance",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _referralCodeCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: mainColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            "Your Referral Code",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          FutureBuilder<GetCustomerModel>(
            future: _futureUserData, // Mobile number passed here
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (!snapshot.hasData) {
                return const Center(child: Text("No data available."));
              } else {
                userData = snapshot.data!;
                print("userData: ${userData!.referralCode}"); // Debug print

                return Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Text('${capitalizeEachWord(userData!.fullName)}',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: mainColor)),
                      Text(
                        '${userData!.referralCode}',
                        textAlign: TextAlign.center, // ✅ Correct way
                      )
                    ],
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () async {
              try {
                await Share.share(
                  "Use my referral code ${userData!.referralCode} and earn rewards in the DermaCare app!",
                );
              } catch (e) {
                print("❌ Share failed: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Sharing failed. Please try again.")),
                );
              }
            },
            icon: const Icon(
              Icons.share,
              color: Colors.white,
            ),
            label: const Text("Share Code"),
            style: ElevatedButton.styleFrom(
              backgroundColor: mainColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _historyTile({
    required String title,
    required String subtitle,
    required int amount,
    required String date,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.card_giftcard, color: mainColor),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "+ 💰$amount",
              style: const TextStyle(
                color: mainColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(date, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
