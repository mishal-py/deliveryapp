import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../pages/admin_panel.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('User Role Management')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminPanel()),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final users = snapshot.data!.docs;
                  return Column(
                    children: users.asMap().entries.map((entry) {
                      final user = entry.value;
                      return UserApprovalCard(user: user);
                    }).toList(),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UserApprovalCard extends StatefulWidget {
  final QueryDocumentSnapshot user;

  const UserApprovalCard({super.key, required this.user});

  @override
  State<UserApprovalCard> createState() => _UserApprovalCardState();
}

class _UserApprovalCardState extends State<UserApprovalCard> {
  String? selectedRole;
  final roles = ['client', 'waiter', 'kitchen', 'cashier'];

  @override
  Widget build(BuildContext context) {
    final data = widget.user.data() as Map<String, dynamic>;
    final currentRequestedRole = data['requestedRole'] ?? '';

    // Ensure the requestedRole is one of the valid roles
    final initialRole = roles.contains(currentRequestedRole)
        ? currentRequestedRole
        : roles.first;

    return Card(
      child: Center(
        child: ListTile(
          title: Center(child: Text(data['email'] ?? '')),
          subtitle: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Requested role: $currentRequestedRole"),
              DropdownButton<String>(
                value: selectedRole ?? initialRole,
                alignment: Alignment.center,
                items: roles.map((role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    alignment: Alignment.center,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRole = value;
                  });
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  final approvedRole = selectedRole ?? initialRole;
                  try {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.user.id)
                        .update({
                      'role': approvedRole,
                      'approved': true,
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User role updated')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating role: $e')),
                    );
                  }
                },
                child: const Text('Update Role'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}