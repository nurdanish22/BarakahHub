import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/admin_service.dart';
import '../../models/event_model.dart';
import '../../models/announcement_model.dart';
import '../../models/volunteer_model.dart';
import 'event_form_screen.dart';
import 'announcement_form_screen.dart';
import 'volunteer_form_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AdminService _adminService = AdminService();

  List<EventModel> _events = [];
  List<AnnouncementModel> _announcements = [];
  List<VolunteerOpportunityModel> _volunteers = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _adminService.getAllEvents(),
        _adminService.getAllAnnouncements(),
        _adminService.getAllVolunteerOpportunities(),
      ]);
      if (!mounted) return;
      setState(() {
        _events = results[0] as List<EventModel>;
        _announcements = results[1] as List<AnnouncementModel>;
        _volunteers = results[2] as List<VolunteerOpportunityModel>;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _confirmDelete(String type, String id, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Delete "$title"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                if (type == 'event') await _adminService.deleteEvent(id);
                if (type == 'announcement') await _adminService.deleteAnnouncement(id);
                if (type == 'volunteer') await _adminService.deleteVolunteerOpportunity(id);
                await _loadAll();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Deleted successfully'),
                      backgroundColor: Color(0xFF1A6B3C),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: Text('Delete', style: TextStyle(color: Colors.red.shade600, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Future<void> _fixEventCount(String eventId, String title) async {
    try {
      final count = await _adminService.fixEventParticipantCount(eventId);
      await _loadAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Fixed "$title" — count set to $count confirmed registrant(s).'),
          backgroundColor: const Color(0xFF1A6B3C),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fixing count: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _openCreateForm() async {
    Widget form;
    if (_tabController.index == 0) {
      form = const EventFormScreen();
    } else if (_tabController.index == 1) {
      form = const AnnouncementFormScreen();
    } else {
      form = const VolunteerFormScreen();
    }
    await Navigator.push(context, MaterialPageRoute(builder: (_) => form));
    _loadAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Admin Panel', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: const Color(0xFF1A6B3C),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: [
            Tab(text: 'Events (${_events.length})'),
            Tab(text: 'Announcements (${_announcements.length})'),
            Tab(text: 'Volunteers (${_volunteers.length})'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A6B3C)))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildEventsList(),
                _buildAnnouncementsList(),
                _buildVolunteersList(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateForm,
        backgroundColor: const Color(0xFF1A6B3C),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add New', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildEventsList() {
    if (_events.isEmpty) {
      return _emptyState(Icons.event_outlined, 'No events yet.\nTap + to add the first one.');
    }
    return RefreshIndicator(
      color: const Color(0xFF1A6B3C),
      onRefresh: _loadAll,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
        itemCount: _events.length,
        itemBuilder: (_, i) => _AdminCard(
          icon: Icons.event,
          title: _events[i].title,
          subtitle: DateFormat('d MMM yyyy, h:mm a').format(_events[i].dateTime),
          category: _events[i].category,
          isActive: _events[i].isActive,
          extraInfo: '${_events[i].currentParticipants}/${_events[i].maxParticipants} joined',
          onEdit: () async {
            await Navigator.push(context, MaterialPageRoute(
              builder: (_) => EventFormScreen(event: _events[i]),
            ));
            _loadAll();
          },
          onDelete: () => _confirmDelete('event', _events[i].eventId, _events[i].title),
          onFix: () => _fixEventCount(_events[i].eventId, _events[i].title),
        ),
      ),
    );
  }

  Widget _buildAnnouncementsList() {
    if (_announcements.isEmpty) {
      return _emptyState(Icons.campaign_outlined, 'No announcements yet.\nTap + to add the first one.');
    }
    return RefreshIndicator(
      color: const Color(0xFF1A6B3C),
      onRefresh: _loadAll,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
        itemCount: _announcements.length,
        itemBuilder: (_, i) => _AdminCard(
          icon: Icons.campaign,
          title: _announcements[i].title,
          subtitle: DateFormat('d MMM yyyy').format(_announcements[i].dateTime),
          category: _announcements[i].category,
          isActive: _announcements[i].isActive,
          onEdit: () async {
            await Navigator.push(context, MaterialPageRoute(
              builder: (_) => AnnouncementFormScreen(announcement: _announcements[i]),
            ));
            _loadAll();
          },
          onDelete: () => _confirmDelete(
              'announcement', _announcements[i].announcementId, _announcements[i].title),
        ),
      ),
    );
  }

  Widget _buildVolunteersList() {
    if (_volunteers.isEmpty) {
      return _emptyState(Icons.volunteer_activism_outlined, 'No volunteer opportunities yet.\nTap + to add the first one.');
    }
    return RefreshIndicator(
      color: const Color(0xFF1A6B3C),
      onRefresh: _loadAll,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
        itemCount: _volunteers.length,
        itemBuilder: (_, i) => _AdminCard(
          icon: Icons.volunteer_activism,
          title: _volunteers[i].title,
          subtitle: DateFormat('d MMM yyyy, h:mm a').format(_volunteers[i].dateTime),
          category: _volunteers[i].category,
          isActive: _volunteers[i].isActive,
          onEdit: () async {
            await Navigator.push(context, MaterialPageRoute(
              builder: (_) => VolunteerFormScreen(opportunity: _volunteers[i]),
            ));
            _loadAll();
          },
          onDelete: () => _confirmDelete(
              'volunteer', _volunteers[i].opportunityId, _volunteers[i].title),
        ),
      ),
    );
  }

  Widget _emptyState(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], fontSize: 14, height: 1.6),
          ),
        ],
      ),
    );
  }
}

// ── Reusable admin list card ──────────────────────────────────────────────────

class _AdminCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String category;
  final bool isActive;
  final String? extraInfo;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onFix;

  const _AdminCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.isActive,
    this.extraInfo,
    required this.onEdit,
    required this.onDelete,
    this.onFix,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF1A6B3C).withOpacity(0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isActive ? const Color(0xFF1A6B3C) : Colors.grey,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      _Tag(category, const Color(0xFF1A6B3C)),
                      const SizedBox(width: 6),
                      _Tag(
                        isActive ? 'Active' : 'Inactive',
                        isActive ? const Color(0xFF1A6B3C) : Colors.grey,
                      ),
                      if (extraInfo != null) ...[
                        const SizedBox(width: 6),
                        _Tag(extraInfo!, Colors.blueGrey),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: onEdit,
                  color: const Color(0xFF1A6B3C),
                  tooltip: 'Edit',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
                if (onFix != null)
                  IconButton(
                    icon: const Icon(Icons.sync, size: 18),
                    onPressed: onFix,
                    color: Colors.blueGrey,
                    tooltip: 'Fix participant count',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: onDelete,
                  color: Colors.red.shade400,
                  tooltip: 'Delete',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
