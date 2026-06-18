import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/event_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/event_model.dart';
import 'event_details_screen.dart';

class MyRegisteredEventsScreen extends StatefulWidget {
  const MyRegisteredEventsScreen({Key? key}) : super(key: key);

  @override
  State<MyRegisteredEventsScreen> createState() =>
      _MyRegisteredEventsScreenState();
}

class _MyRegisteredEventsScreenState extends State<MyRegisteredEventsScreen>
    with SingleTickerProviderStateMixin {
  late String _currentUserId;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _currentUserId =
        context.read<AppAuthProvider>().currentUser?.userId ?? '';
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().loadUserRegisteredEvents(_currentUserId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'My Events',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFF1A6B3C),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: Consumer<EventProvider>(
        builder: (context, provider, _) {
          if (provider.registeredEventsState == EventLoadingState.loading) {
            return const Center(
              child:
                  CircularProgressIndicator(color: Color(0xFF1A6B3C)),
            );
          }

          if (provider.registeredEventsState == EventLoadingState.error) {
            return _buildErrorState(provider.errorMessage, () {
              provider.loadUserRegisteredEvents(_currentUserId);
            });
          }

          final now = DateTime.now();
          final upcoming = provider.userRegisteredEvents
              .where((e) => e.dateTime.isAfter(now))
              .toList();
          final past = provider.userRegisteredEvents
              .where((e) => !e.dateTime.isAfter(now))
              .toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildEventsList(upcoming, isUpcoming: true),
              _buildEventsList(past, isUpcoming: false),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEventsList(List<EventModel> events, {required bool isUpcoming}) {
    if (events.isEmpty) {
      return _buildEmptyState(isUpcoming);
    }

    return RefreshIndicator(
      color: const Color(0xFF1A6B3C),
      onRefresh: () => context.read<EventProvider>().loadUserRegisteredEvents(_currentUserId),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 12, bottom: 24),
        itemCount: events.length,
        itemBuilder: (context, index) {
          return _RegisteredEventTile(
            event: events[index],
            isUpcoming: isUpcoming,
            onTap: () {
              context.read<EventProvider>().selectEvent(events[index]);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EventDetailsScreen(
                    eventId: events[index].eventId,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isUpcoming) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUpcoming
                  ? Icons.event_available_outlined
                  : Icons.history_outlined,
              size: 72,
              color: const Color(0xFFCCDDD6),
            ),
            const SizedBox(height: 16),
            Text(
              isUpcoming ? 'No upcoming events' : 'No past events',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF888899),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isUpcoming
                  ? 'Register for events to see them here.'
                  : 'Events you have attended will appear here.',
              style:
                  const TextStyle(fontSize: 14, color: Color(0xFFAAABBB)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline,
              size: 56, color: Color(0xFFCCCCDD)),
          const SizedBox(height: 12),
          const Text('Failed to load events',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF555566))),
          const SizedBox(height: 8),
          Text(message,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFFAAABBB))),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A6B3C),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Retry',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Individual Tile ─────────────────────────────────────────────────────────

class _RegisteredEventTile extends StatelessWidget {
  final EventModel event;
  final bool isUpcoming;
  final VoidCallback onTap;

  const _RegisteredEventTile({
    required this.event,
    required this.isUpcoming,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr =
        DateFormat('EEE, d MMM yyyy').format(event.dateTime);
    final timeStr = DateFormat('h:mm a').format(event.dateTime);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
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
            // Date block
            Container(
              width: 52,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isUpcoming
                    ? const Color(0xFFE8F5EE)
                    : const Color(0xFFF0F0F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('d').format(event.dateTime),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: isUpcoming
                          ? const Color(0xFF1A6B3C)
                          : const Color(0xFF888899),
                      height: 1,
                    ),
                  ),
                  Text(
                    DateFormat('MMM').format(event.dateTime).toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isUpcoming
                          ? const Color(0xFF1A6B3C)
                          : const Color(0xFF888899),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // Event info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 12, color: Color(0xFF999AAA)),
                      const SizedBox(width: 4),
                      Text(
                        '$dateStr • $timeStr',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999AAA),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 12, color: Color(0xFF999AAA)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF999AAA)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Status pill
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isUpcoming
                    ? const Color(0xFFE8F5EE)
                    : const Color(0xFFF0F0F5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isUpcoming ? 'Upcoming' : 'Past',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isUpcoming
                      ? const Color(0xFF1A6B3C)
                      : const Color(0xFF888899),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
