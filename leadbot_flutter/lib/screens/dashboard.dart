import 'package:flutter/material.dart';
import 'wallet.dart';
import 'leads.dart';
import 'rag.dart';
import 'conversation.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Dashboard")),
        body: GridView.count(
          crossAxisCount: 2,
          padding: EdgeInsets.all(16),
          children: [
            _tile(context, "Wallet", WalletScreen()),
            _tile(context, "Leads", LeadsScreen()),
            _tile(context, "Knowledge (RAG)", RAGScreen()),
            _tile(context, "Conversation", ConversationScreen()),
          ],
        ));
  }

  Widget _tile(BuildContext ctx, String title, Widget screen) {
    return Card(
        child: InkWell(
            onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => screen)),
            child: Center(child: Text(title, textAlign: TextAlign.center))));
  }
}
