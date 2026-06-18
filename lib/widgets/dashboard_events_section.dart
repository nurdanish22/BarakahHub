import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/event_provider.dart';
import '../../models/event_model.dart';
import '../screens/events/event_listing_screen.dart';
import '../screens/events/event_details_screen.dart';

/// Drop-in widget for the Dashboard screen (Member 4) showing upcoming events.
/// Usage: just add <DashboardEventsSection /> inside your dashboard's column.
class DashboardEventsSection extends StatelessWidget {
  const DashboardEventsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, provider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section Header ───────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Upcoming Events',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EventListingScreen()),
                    ),
                    child: const Text(
                      'See all',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1A6B3C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Events Horizontal List ────────────────────
            if (provider.isLoading)
              const SizedBox(
                height: 160,
                child: Center(
                  child: CircularProgressIndicator(
                      color: Color(0xFF1A6B3C), strokeWidth: 2.5),
                ),
              )
            else if (provider.upcomingEvents.isEmpty)
              _EmptyEventsCard()
            else
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.upcomingEvents.length > 5
                      ? 5
                      : provider.upcomingEvents.length,
                  itemBuilder: (context, index) {
                    final event = provider.upcomingEvents[index];
                    return _DashboardEventCard(
                      event: event,
                      onTap: () {
                        provider.selectEvent(event);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EventDetailsScreen(eventId: event.eventId),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class _DashboardEventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;

  const _DashboardEventCard({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final day = DateFormat('d').format(event.dateTime);
    final month =
        DateFormat('MMM').format(event.dateTime).toUpperCase();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
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
            // Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: Stack(
                children: [
                  event.imageUrl.isNotEmpty
                      ? Image.network(
                          event.imageUrl,
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _placeholderImage(),
                        )
                      : _placeholderImage(),
                  // Date badge overlay
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A6B3C),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$day $month',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 11, color: Color(0xFF888899)),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          event.location,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF888899),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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

  Widget _placeholderImage() {
    return Container(
      height: 100,
      width: double.infinity,
      color: const Color(0xFFE8F5EE),
      child: const Icon(Icons.mosque_outlined,
          size: 32, color: Color(0xFF1A6B3C)),
    );
  }
}

class _EmptyEventsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F7F3),
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: const Color(0xFFCCE5D8), width: 1.5),
        ),
        child: const Center(
          child: Text(
            'No upcoming events right now.',
            style: TextStyle(
              color: Color(0xFF888899),
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
