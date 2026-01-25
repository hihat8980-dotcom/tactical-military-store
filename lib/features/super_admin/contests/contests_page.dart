import 'package:flutter/material.dart';
import 'package:tactical_military_store/core/services/supabase_service.dart';

class ContestsPage extends StatefulWidget {
  const ContestsPage({super.key});

  @override
  State<ContestsPage> createState() => _ContestsPageState();
}

class _ContestsPageState extends State<ContestsPage> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = SupabaseService().getContests();
  }

  Future<void> _toggleContest(int id, bool value) async {
    await SupabaseService().toggleContest(
      contestId: id,
      isActive: value,
    );
    setState(_load);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المسابقات'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('مسابقة جديدة'),
        onPressed: () async {
          final result = await showDialog<bool>(
            context: context,
            builder: (_) => const _CreateContestDialog(),
          );
          if (result == true) setState(_load);
        },
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final contests = snapshot.data!;
          if (contests.isEmpty) {
            return const Center(child: Text('لا توجد مسابقات'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: contests.length,
            itemBuilder: (context, index) {
              final c = contests[index];
              final isActive = c['is_active'] as bool;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    c['title'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    c['description'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Switch(
                    value: isActive,
                    onChanged: (v) => _toggleContest(c['id'], v),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ================= CREATE CONTEST DIALOG =================
class _CreateContestDialog extends StatefulWidget {
  const _CreateContestDialog();

  @override
  State<_CreateContestDialog> createState() => _CreateContestDialogState();
}

class _CreateContestDialogState extends State<_CreateContestDialog> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  bool _loading = false;

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) return;

    setState(() => _loading = true);
    await SupabaseService().createContest(
      title: _title.text.trim(),
      description: _desc.text.trim(),
    );
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'إنشاء مسابقة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'اسم المسابقة'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _desc,
              decoration: const InputDecoration(labelText: 'الوصف'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }
}
