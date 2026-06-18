import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/announcement_provider.dart';
import '../../providers/volunteer_provider.dart';
import '../../models/event_model.dart';
import '../../models/announcement_model.dart';
import '../../models/volunteer_model.dart';
import '../events/event_details_screen.dart';
import '../announcements/announcement_details_screen.dart';
import '../volunteers/volunteer_details_screen.dart';
import '../main_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().loadUpcomingEvents();
      context.read<AnnouncementProvider>().loadAnnouncements();
      context.read<VolunteerProvider>().loadOpportunities();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();
    final userName = auth.currentUser?.name.split(' ').first ?? 'there';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: RefreshIndicator(
        color: const Color(0xFF1A6B3C),
        onRefresh: () async {
          await Future.wait([
            context.read<EventProvider>().loadUpcomingEvents(),
            context.read<AnnouncementProvider>().loadAnnouncements(),
            context.read<VolunteerProvider>().loadOpportunities(),
          ]);
        },
        child: CustomScrollView(
          slivers: [
            _buildAppBar(userName),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEventsSection(),
                  _buildAnnouncementsSection(),
                  _buildVolunteerSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(String firstName) {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: const Color(0xFF1A6B3C),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A6B3C), Color(0xFF2E8B57)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.mosque_outlined,
                          color: Colors.white70, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'BarakahHub',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Assalamualaikum, $firstName',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventsSection() {
    return Consumer<EventProvider>(
      builder: (context, provider, _) {
        return _Section(
          title: 'Upcoming Events',
          onSeeAll: () => _switchTab(context, 1),
          child: provider.isLoading
              ? _LoadingBox(height: 190)
              : provider.upcomingEvents.isEmpty
                  ? _EmptyBox(
                      icon: Icons.event_busy_outlined,
                      label: 'No upcoming events')
                  : SizedBox(
                      height: 190,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: provider.upcomingEvents.length > 5
                            ? 5
                            : provider.upcomingEvents.length,
                        itemBuilder: (ctx, i) {
                          final event = provider.upcomingEvents[i];
                          return _EventMiniCard(
                            event: event,
                            onTap: () {
                              provider.selectEvent(event);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EventDetailsScreen(
                                      eventId: event.eventId),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
        );
      },
    );
  }

  Widget _buildAnnouncementsSection() {
    return Consumer<AnnouncementProvider>(
      builder: (context, provider, _) {
        final recent = provider.announcements.take(3).toList();
        return _Section(
          title: 'Announcements',
          onSeeAll: () => _switchTab(context, 3),
          child: provider.isLoading
              ? _LoadingBox(height: 80)
              : recent.isEmpty
                  ? _EmptyBox(
                      icon: Icons.campaign_outlined,
                      label: 'No announcements yet')
                  : Column(
                      children: recent
                          .map((a) => _AnnouncementMiniCard(
                                announcement: a,
                                onTap: () {
                                  provider.selectAnnouncement(a);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          AnnouncementDetailsScreen(
                                              announcementId: a.announcementId),
                                    ),
                                  );
                                },
                              ))
                          .toList(),
                    ),
        );
      },
    );
  }

  Widget _buildVolunteerSection() {
    return Consumer<VolunteerProvider>(
      builder: (context, provider, _) {
        final recent = provider.opportunities.take(3).toList();
        return _Section(
          title: 'Volunteer Opportunities',
          onSeeAll: () => _switchTab(context, 2),
          child: provider.isLoading
              ? _LoadingBox(height: 80)
              : recent.isEmpty
                  ? _EmptyBox(
                      icon: Icons.volunteer_activism_outlined,
                      label: 'No opportunities right now')
                  : Column(
                      children: recent
                          .map((opp) => _VolunteerMiniCard(
                                opportunity: opp,
                                onTap: () {
                                  provider.selectOpportunity(opp);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          VolunteerDetailsScreen(
                                              opportunityId: opp.opportunityId),
                                    ),
                                  );
                                },
                              ))
                          .toList(),
                    ),
        );
      },
    );
  }

  void _switchTab(BuildContext context, int index) {
    final mainState =
        context.findAncestorStateOfType<MainScreenState>();
    mainState?.switchTab(index);
  }
}

// ── Section wrapper ──────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onSeeAll;

  const _Section({required this.title, required this.child, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              if (onSeeAll != null)
                GestureDetector(
                  onTap: onSeeAll,
                  child: const Text(
                    'See all',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF1A6B3C),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        child,
      ],
    );
  }
}

// ── Mini cards ───────────────────────────────────────────────────────────────

class _EventMiniCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;

  const _EventMiniCard({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170,
        margin: const EdgeInsets.only(right: 12, bottom: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: event.imageUrl.isNotEmpty
                  ? Image.network(event.imageUrl,
                      height: 96,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder())
                  : _placeholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 11, color: Color(0xFF1A6B3C)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          DateFormat('d MMM').format(event.dateTime),
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF888899)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        height: 96,
        color: const Color(0xFFE8F5EE),
        child: const Center(
          child:
              Icon(Icons.mosque_outlined, size: 32, color: Color(0xFF1A6B3C)),
        ),
      );
}

class _AnnouncementMiniCard extends StatelessWidget {
  final AnnouncementModel announcement;
  final VoidCallback onTap;

  const _AnnouncementMiniCard(
      {required this.announcement, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
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
                color: const Color(0xFFE8F5EE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.campaign_outlined,
                  size: 22, color: Color(0xFF1A6B3C)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    announcement.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    DateFormat('d MMM yyyy')
                        .format(announcement.dateTime),
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF999AAA)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                size: 18, color: Color(0xFFCCCCDD)),
          ],
        ),
      ),
    );
  }
}

class _VolunteerMiniCard extends StatelessWidget {
  final VolunteerOpportunityModel opportunity;
  final VoidCallback onTap;

  const _VolunteerMiniCard({required this.opportunity, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
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
                  Text(
                    opportunity.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${opportunity.currentVolunteers}/${opportunity.maxVolunteers} volunteers',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF999AAA)),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: opportunity.isFull
                    ? Colors.red.shade50
                    : const Color(0xFFE8F5EE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                opportunity.isFull ? 'Full' : 'Open',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: opportunity.isFull
                      ? Colors.red.shade600
                      : const Color(0xFF1A6B3C),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingBox extends StatelessWidget {
  final double height;
  const _LoadingBox({required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: const Center(
        child: CircularProgressIndicator(
            color: Color(0xFF1A6B3C), strokeWidth: 2.5),
      ),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  final IconData icon;
  final String label;
  const _EmptyBox({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F7F3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFCCE5D8)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: const Color(0xFF9ABFAA)),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF888899))),
          ],
        ),
      ),
    );
  }
}
