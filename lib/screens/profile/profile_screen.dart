import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/volunteer_provider.dart';
import '../../providers/announcement_provider.dart';
import '../../models/event_model.dart';
import '../../models/volunteer_model.dart';
import '../auth/login_screen.dart';
import '../events/event_details_screen.dart';
import '../volunteers/volunteer_details_screen.dart';
import '../admin/admin_panel_screen.dart';
import 'edit_profile_screen.dart';

// The secret passphrase to unlock admin access
const String _adminPasscode = 'BARAKAH2024';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _versionTapCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AppAuthProvider>().currentUser?.userId ?? '';
      if (userId.isNotEmpty) {
        context.read<EventProvider>().loadUserRegisteredEvents(userId);
        context.read<VolunteerProvider>().loadUserHistory(userId);
      }
    });
  }

  void _onVersionTap() {
    _versionTapCount++;
    if (_versionTapCount >= 5) {
      _versionTapCount = 0;
      _showAdminUnlockDialog();
    }
  }

  void _showAdminUnlockDialog() {
    final codeCtrl = TextEditingController();
    bool obscure = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.admin_panel_settings, color: Color(0xFF1A6B3C)),
              SizedBox(width: 10),
              Text('Admin Access', style: TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter the admin passcode to unlock admin privileges.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: codeCtrl,
                obscureText: obscure,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'Admin passcode',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF1A6B3C), width: 2),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    onPressed: () => setDialogState(() => obscure = !obscure),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (codeCtrl.text.trim().toUpperCase() == _adminPasscode) {
                  Navigator.pop(ctx);
                  final success = await context.read<AppAuthProvider>().promoteToAdmin();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success
                            ? 'Admin access granted! You can now manage content.'
                            : 'Failed to grant admin access.'),
                        backgroundColor: success ? const Color(0xFF1A6B3C) : Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                      content: Text('Incorrect passcode. Please try again.'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A6B3C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Unlock', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('My Profile',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Profile',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  title: const Text('Logout',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel')),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text('Logout',
                          style: TextStyle(color: Colors.red.shade600)),
                    ),
                  ],
                ),
              );

              if (confirm != true || !context.mounted) return;

              context.read<EventProvider>().reset();
              context.read<VolunteerProvider>().reset();
              context.read<AnnouncementProvider>().reset();
              await context.read<AppAuthProvider>().logout();

              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('No user data found.'))
          : RefreshIndicator(
              color: const Color(0xFF1A6B3C),
              onRefresh: () async {
                final userId = user.userId;
                await Future.wait([
                  context.read<EventProvider>().loadUserRegisteredEvents(userId),
                  context.read<VolunteerProvider>().loadUserHistory(userId),
                ]);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUserCard(user),
                    if (user.isAdmin) ...[
                      const SizedBox(height: 16),
                      _buildAdminButton(context),
                    ],
                    const SizedBox(height: 24),
                    _buildRegisteredEvents(),
                    const SizedBox(height: 24),
                    _buildVolunteerHistory(),
                    const SizedBox(height: 32),
                    _buildVersionFooter(),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildUserCard(dynamic user) {
    final initials = user.name.isNotEmpty
        ? user.name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : 'U';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: const Color(0xFF1B5E20).withOpacity(0.1),
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 3),
                      Text(user.email,
                          style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      if (user.phone.isNotEmpty)
                        Text(user.phone,
                            style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      if (user.location.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 13, color: Colors.grey[500]),
                            const SizedBox(width: 3),
                            Text(user.location,
                                style: TextStyle(
                                    color: Colors.grey[500], fontSize: 12)),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B5E20).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          user.role,
                          style: const TextStyle(
                              color: Color(0xFF1B5E20),
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (user.bio.isNotEmpty) ...[
              const Divider(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  user.bio,
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      height: 1.5),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdminButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminPanelScreen()),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF2E8B57)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A6B3C).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Row(
          children: [
            Icon(Icons.admin_panel_settings, color: Colors.white, size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Admin Panel',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    'Manage events, announcements & volunteers',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisteredEvents() {
    return Consumer<EventProvider>(
      builder: (context, provider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Registered Events',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20)),
            ),
            const SizedBox(height: 10),
            if (provider.registeredEventsState == EventLoadingState.loading)
              const Center(
                  child: CircularProgressIndicator(color: Color(0xFF1A6B3C)))
            else if (provider.userRegisteredEvents.isEmpty)
              _emptySection(
                  Icons.event_busy_outlined, 'No registered events yet')
            else
              ...provider.userRegisteredEvents
                  .map((event) => _EventTile(event: event)),
          ],
        );
      },
    );
  }

  Widget _buildVolunteerHistory() {
    return Consumer<VolunteerProvider>(
      builder: (context, provider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Volunteer History',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20)),
            ),
            const SizedBox(height: 10),
            if (provider.historyState == VolunteerLoadingState.loading)
              const Center(
                  child: CircularProgressIndicator(color: Color(0xFF1A6B3C)))
            else if (provider.userHistory.isEmpty)
              _emptySection(Icons.volunteer_activism_outlined,
                  'No volunteer history yet')
            else
              ...provider.userHistory
                  .map((opp) => _VolunteerTile(opportunity: opp)),
          ],
        );
      },
    );
  }

  Widget _buildVersionFooter() {
    return Center(
      child: GestureDetector(
        onTap: _onVersionTap,
        child: Text(
          'BarakahHub v1.0.0',
          style: TextStyle(fontSize: 11, color: Colors.grey[400]),
        ),
      ),
    );
  }

  Widget _emptySection(IconData icon, String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(color: Colors.grey[500], fontSize: 13)),
        ],
      ),
    );
  }
}

// ── Profile list tiles ────────────────────────────────────────────────────────

class _EventTile extends StatelessWidget {
  final EventModel event;
  const _EventTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final upcoming = event.dateTime.isAfter(DateTime.now());
    return GestureDetector(
      onTap: () {
        context.read<EventProvider>().selectEvent(event);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => EventDetailsScreen(eventId: event.eventId)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: upcoming
                    ? const Color(0xFFE8F5EE)
                    : const Color(0xFFF0F0F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(DateFormat('d').format(event.dateTime),
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: upcoming
                              ? const Color(0xFF1A6B3C)
                              : Colors.grey,
                          height: 1)),
                  Text(
                      DateFormat('MMM')
                          .format(event.dateTime)
                          .toUpperCase(),
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: upcoming
                              ? const Color(0xFF1A6B3C)
                              : Colors.grey)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(event.location,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF999AAA)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: upcoming
                    ? const Color(0xFFE8F5EE)
                    : const Color(0xFFF0F0F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                upcoming ? 'Upcoming' : 'Past',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: upcoming
                        ? const Color(0xFF1A6B3C)
                        : Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VolunteerTile extends StatelessWidget {
  final VolunteerOpportunityModel opportunity;
  const _VolunteerTile({required this.opportunity});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<VolunteerProvider>().selectOpportunity(opportunity);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => VolunteerDetailsScreen(
                  opportunityId: opportunity.opportunityId)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.volunteer_activism_outlined,
                  size: 22, color: Color(0xFFE65100)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(opportunity.title,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(opportunity.location,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF999AAA)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                opportunity.category,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE65100)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
