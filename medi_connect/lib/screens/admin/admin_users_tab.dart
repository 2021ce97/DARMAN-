import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../services/notification_service.dart';
import '../../models/notification_model.dart';

// ─── Providers ────────────────────────────────────────────────────────────────

final _allUsersProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
});

// ─── Users Tab ────────────────────────────────────────────────────────────────

class AdminUsersTab extends ConsumerStatefulWidget {
  const AdminUsersTab({super.key});

  @override
  ConsumerState<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends ConsumerState<AdminUsersTab> {
  final _searchCtrl = TextEditingController();
  String _search = '';
  String _roleFilter = 'All'; // All | patient | doctor | admin

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(_allUsersProvider);

    return Column(
      children: [
        // ── Search + filter bar ──────────────────────────────────────────
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _search = v.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search by name or email…',
                    hintStyle: const TextStyle(fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded, size: 18),
                    suffixIcon: _search.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _search = '');
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _roleFilter,
                  borderRadius: BorderRadius.circular(10),
                  items: ['All', 'patient', 'doctor', 'admin']
                      .map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 13))))
                      .toList(),
                  onChanged: (v) => setState(() => _roleFilter = v ?? 'All'),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.divider),

        // ── List ─────────────────────────────────────────────────────────
        Expanded(
          child: usersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (allUsers) {
              // apply search + role filter
              final users = allUsers.where((u) {
                final name = (u['name'] as String? ?? '').toLowerCase();
                final email = (u['email'] as String? ?? '').toLowerCase();
                final role = (u['role'] as String? ?? 'patient');
                final matchSearch = _search.isEmpty ||
                    name.contains(_search) ||
                    email.contains(_search);
                final matchRole =
                    _roleFilter == 'All' || role == _roleFilter;
                return matchSearch && matchRole;
              }).toList();

              if (users.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline_rounded,
                          size: 64, color: AppColors.outline),
                      SizedBox(height: 12),
                      Text('No users found',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(14),
                itemCount: users.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) =>
                    _UserCard(user: users[i]),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── User Card ────────────────────────────────────────────────────────────────

class _UserCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> user;
  const _UserCard({required this.user});

  @override
  ConsumerState<_UserCard> createState() => _UserCardState();
}

class _UserCardState extends ConsumerState<_UserCard> {
  bool _isLoading = false;

  bool get _isBanned => widget.user['isBanned'] == true;
  String get _uid => widget.user['id'] as String;
  String get _role => widget.user['role'] as String? ?? 'patient';
  String get _name => widget.user['name'] as String? ?? 'Unknown';
  String get _email => widget.user['email'] as String? ?? '';

  Color get _roleColor {
    switch (_role) {
      case 'doctor': return AppColors.primary;
      case 'admin': return const Color(0xFF6366F1);
      default: return const Color(0xFF10B981);
    }
  }

  // ── Toggle ban ──────────────────────────────────────────────────────────
  Future<void> _toggleBan() async {
    final action = _isBanned ? 'Unban' : 'Ban';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$action User'),
        content: Text(
          _isBanned
              ? 'Restore access for $_name?'
              : 'This will block $_name from logging in.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isBanned ? AppColors.primary : AppColors.error,
            ),
            child: Text(action, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_uid)
          .update({'isBanned': !_isBanned, 'updatedAt': FieldValue.serverTimestamp()});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$_name ${_isBanned ? 'unbanned ✓' : 'banned'}'),
          backgroundColor: _isBanned ? AppColors.primary : AppColors.error,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Change role ──────────────────────────────────────────────────────────
  Future<void> _changeRole() async {
    String selected = _role;
    final picked = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Role'),
        content: StatefulBuilder(builder: (ctx, setD) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: ['patient', 'doctor', 'admin'].map((r) {
              return RadioListTile<String>(
                value: r,
                groupValue: selected,
                title: Text(r, style: const TextStyle(fontWeight: FontWeight.w600)),
                activeColor: AppColors.primary,
                onChanged: (v) => setD(() => selected = v!),
              );
            }).toList(),
          );
        }),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, selected),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (picked == null || picked == _role || !mounted) return;

    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(_uid).update({
        'role': picked,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Role changed to $picked ✓'),
          backgroundColor: AppColors.primary,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Send notification ────────────────────────────────────────────────────
  Future<void> _sendNotification() async {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    final sent = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Notify $_name'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: bodyCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Send'),
          ),
        ],
      ),
    );

    if (sent != true || !mounted) return;
    if (titleCtrl.text.trim().isEmpty || bodyCtrl.text.trim().isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(notificationServiceProvider).sendNotification(
            userId: _uid,
            title: titleCtrl.text.trim(),
            body: bodyCtrl.text.trim(),
            type: NotificationType.general,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification sent ✓'), backgroundColor: AppColors.primary),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── View profile modal ───────────────────────────────────────────────────
  void _viewProfile() {
    final u = widget.user;
    final ts = u['createdAt'] as Timestamp?;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (ctx, ctrl) => SingleChildScrollView(
          controller: ctrl,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      (_name.isNotEmpty ? _name[0] : '?').toUpperCase(),
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                        Text(_email, style: const TextStyle(color: AppColors.textHint, fontSize: 13)),
                      ],
                    ),
                  ),
                  if (_isBanned)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('BANNED',
                          style: TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.w800)),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              _ProfileRow('Role', _role.toUpperCase()),
              _ProfileRow('Phone', u['phone'] ?? 'N/A'),
              _ProfileRow('Gender', u['gender'] ?? 'N/A'),
              _ProfileRow('Blood Type', u['bloodType'] ?? 'N/A'),
              _ProfileRow('Joined', ts != null ? DateFormat('MMM d, yyyy').format(ts.toDate()) : 'Unknown'),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () { Navigator.pop(ctx); _toggleBan(); },
                      icon: Icon(_isBanned ? Icons.lock_open_rounded : Icons.block_rounded, size: 16),
                      label: Text(_isBanned ? 'Unban' : 'Ban'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _isBanned ? AppColors.primary : AppColors.error,
                        side: BorderSide(color: _isBanned ? AppColors.primary : AppColors.error),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () { Navigator.pop(ctx); _sendNotification(); },
                      icon: const Icon(Icons.notifications_rounded, size: 16),
                      label: const Text('Notify'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ts = widget.user['createdAt'] as Timestamp?;
    final joined = ts != null ? DateFormat('MMM d, yyyy').format(ts.toDate()) : '';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: _isBanned
            ? Border.all(color: AppColors.error.withOpacity(0.4))
            : null,
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primaryLight,
              child: Text(
                (_name.isNotEmpty ? _name[0] : '?').toUpperCase(),
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800),
              ),
            ),
            if (_isBanned)
              Positioned(
                right: 0, bottom: 0,
                child: Container(
                  width: 14, height: 14,
                  decoration: const BoxDecoration(
                    color: AppColors.error, shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.block_rounded, size: 10, color: Colors.white),
                ),
              ),
          ],
        ),
        title: Text(_name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_email, style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
            if (joined.isNotEmpty)
              Text('Joined $joined', style: const TextStyle(fontSize: 11, color: AppColors.outline)),
          ],
        ),
        trailing: _isLoading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Role chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _roleColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _role,
                      style: TextStyle(color: _roleColor, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Actions menu
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, size: 18, color: AppColors.textHint),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onSelected: (v) {
                      if (v == 'view') _viewProfile();
                      if (v == 'ban') _toggleBan();
                      if (v == 'role') _changeRole();
                      if (v == 'notify') _sendNotification();
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'view', child: Row(children: [Icon(Icons.person_rounded, size: 16), SizedBox(width: 8), Text('View Profile')])),
                      PopupMenuItem(
                        value: 'ban',
                        child: Row(children: [
                          Icon(_isBanned ? Icons.lock_open_rounded : Icons.block_rounded,
                              size: 16, color: _isBanned ? AppColors.primary : AppColors.error),
                          const SizedBox(width: 8),
                          Text(_isBanned ? 'Unban User' : 'Ban User',
                              style: TextStyle(color: _isBanned ? AppColors.primary : AppColors.error)),
                        ]),
                      ),
                      const PopupMenuItem(value: 'role', child: Row(children: [Icon(Icons.manage_accounts_rounded, size: 16), SizedBox(width: 8), Text('Change Role')])),
                      const PopupMenuItem(value: 'notify', child: Row(children: [Icon(Icons.notifications_outlined, size: 16), SizedBox(width: 8), Text('Send Notification')])),
                    ],
                  ),
                ],
              ),
        onTap: _viewProfile,
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;
  const _ProfileRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(color: AppColors.textHint, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
