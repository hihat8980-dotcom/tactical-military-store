import 'package:flutter/material.dart';
import 'package:tactical_military_store/models/app_user.dart';

class UserTile extends StatelessWidget {
  final AppUser user;
  final ValueChanged<String> onRoleChanged;

  const UserTile({
    super.key,
    required this.user,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSuperAdmin = user.isSuperAdmin;

    // 🔵 نحدد حالة الاتصال اعتمادًا على lastSeenText
    final bool isOnline = user.lastSeenText == 'متصل الآن';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Stack(
          children: [
            const CircleAvatar(child: Icon(Icons.person)),
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 6,
                backgroundColor:
                    isOnline ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
        title: Row(
          children: [
            Text(user.email),
            if (isSuperAdmin)
              const Padding(
                padding: EdgeInsets.only(left: 6),
                child: Icon(
                  Icons.lock,
                  size: 16,
                  color: Colors.redAccent,
                ),
              ),
          ],
        ),
        subtitle: Text(user.lastSeenText),
        trailing: isSuperAdmin
            ? const Chip(
                label: Text('SUPER ADMIN'),
                backgroundColor: Colors.redAccent,
                labelStyle: TextStyle(color: Colors.white),
              )
            : DropdownButton<String>(
                value: user.role,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(
                    value: 'user',
                    child: Text('user'),
                  ),
                  DropdownMenuItem(
                    value: 'admin',
                    child: Text('admin'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    onRoleChanged(value);
                  }
                },
              ),
      ),
    );
  }
}
