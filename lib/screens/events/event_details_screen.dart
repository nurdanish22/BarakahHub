import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/event_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/event_model.dart';

/// Receives [eventId] and resolves it from the provider (or pre-loaded [event])
class EventDetailsScreen extends StatefulWidget {
  final String eventId;

  const EventDetailsScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  late String _currentUserId;
  bool _isRegistered = false;
  bool _checkingStatus = true;

  @override
  void initState() {
    super.initState();
    _currentUserId =
        context.read<AppAuthProvider>().currentUser?.userId ?? '';
    _initScreen();
  }

  Future<void> _initScreen() async {
    final provider = context.read<EventProvider>();
    // If the selected event doesn't match, load it fresh
    if (provider.selectedEvent?.eventId != widget.eventId) {
      await provider.loadEventById(widget.eventId);
    }
    // Check registration status
    final registered = await provider.checkRegistrationStatus(
      userId: _currentUserId,
      eventId: widget.eventId,
    );
    if (mounted) {
      setState(() {
        _isRegistered = registered;
        _checkingStatus = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, provider, _) {
        final event = provider.selectedEvent;

        if (event == null || _checkingStatus) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF1A6B3C)),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          body: CustomScrollView(
            slivers: [
              // ── Collapsing App Bar with Banner ────────
              _buildSliverAppBar(event),

              // ── Content ───────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category + Title
                      _CategoryBadge(label: event.category),
                      const SizedBox(height: 12),
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A2E),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Info Cards
                      _InfoCard(children: [
                        _DetailRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Date & Time',
                          value: DateFormat('EEEE, d MMMM yyyy')
                              .format(event.dateTime),
                          subValue: DateFormat('h:mm a').format(event.dateTime),
                        ),
                        const _Divider(),
                        _DetailRow(
                          icon: Icons.location_on_outlined,
                          label: 'Location',
                          value: event.location,
                        ),
                        const _Divider(),
                        _DetailRow(
                          icon: Icons.people_outline,
                          label: 'Participants',
                          value:
                              '${event.currentParticipants} / ${event.maxParticipants}',
                          subValue: event.isFull
                              ? 'Fully booked'
                              : '${event.remainingSlots} slots remaining',
                          subValueColor: event.isFull
                              ? Colors.red.shade500
                              : const Color(0xFF1A6B3C),
                        ),
                      ]),
                      const SizedBox(height: 20),

                      // Participant Progress
                      _ParticipantSection(event: event),
                      const SizedBox(height: 24),

                      // Description
                      const Text(
                        'About This Event',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        event.description,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF555566),
                          height: 1.65,
                        ),
                      ),
                      const SizedBox(height: 100), // space for bottom button
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Register / Cancel Button ──────────────────
          bottomNavigationBar: _buildBottomBar(context, provider, event),
        );
      },
    );
  }

  Widget _buildSliverAppBar(EventModel event) {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      backgroundColor: const Color(0xFF1A6B3C),
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: event.imageUrl.isNotEmpty
            ? Image.network(
                event.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholderBanner(),
              )
            : _placeholderBanner(),
      ),
    );
  }

  Widget _placeholderBanner() {
    return Container(
      color: const Color(0xFF1A6B3C),
      child: const Center(
        child: Icon(Icons.mosque_outlined, size: 80, color: Colors.white24),
      ),
    );
  }

  Widget _buildBottomBar(
      BuildContext context, EventProvider provider, EventModel event) {
    final canRegister = !event.isFull || _isRegistered;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: provider.isRegistering || (!canRegister && !_isRegistered)
              ? null
              : () => _handleRegistration(context, provider, event),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                _isRegistered ? Colors.red.shade600 : const Color(0xFF1A6B3C),
            disabledBackgroundColor: const Color(0xFFCCCCDD),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: provider.isRegistering
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white),
                )
              : Text(
                  _isRegistered
                      ? 'Cancel Registration'
                      : event.isFull
                          ? 'Event Full'
                          : 'Register for Event',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _handleRegistration(
      BuildContext context, EventProvider provider, EventModel event) async {
    if (_isRegistered) {
      // Show confirmation dialog before cancelling
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Cancel Registration',
              style: TextStyle(fontWeight: FontWeight.w700)),
          content: const Text(
              'Are you sure you want to cancel your registration for this event?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Keep Registration')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Cancel Registration',
                  style: TextStyle(color: Colors.red.shade600)),
            ),
          ],
        ),
      );
      if (confirm != true) return;

      final success = await provider.cancelRegistration(
        userId: _currentUserId,
        eventId: event.eventId,
      );
      if (mounted) {
        setState(() => _isRegistered = !success);
        _showSnackBar(
            success ? 'Registration cancelled.' : provider.errorMessage,
            success ? false : true);
      }
    } else {
      final success = await provider.registerForEvent(
        userId: _currentUserId,
        eventId: event.eventId,
      );
      if (mounted) {
        setState(() => _isRegistered = success);
        _showSnackBar(
            success
                ? 'You\'re registered! Jazakallah khair.'
                : provider.errorMessage,
            !success);
      }
    }
  }

  void _showSnackBar(String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.red.shade600 : const Color(0xFF1A6B3C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }
}

// ── Supporting Widgets ──────────────────────────────────────────────────────

class _CategoryBadge extends StatelessWidget {
  final String label;
  const _CategoryBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5EE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF1A6B3C),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subValue;
  final Color? subValueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.subValue,
    this.subValueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5EE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF1A6B3C)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF999AAA),
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF1A1A2E),
                        fontWeight: FontWeight.w600)),
                if (subValue != null) ...[
                  const SizedBox(height: 2),
                  Text(subValue!,
                      style: TextStyle(
                          fontSize: 13,
                          color: subValueColor ?? const Color(0xFF888899))),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 68, color: Color(0xFFF0F0F5));
  }
}

class _ParticipantSection extends StatelessWidget {
  final EventModel event;
  const _ParticipantSection({required this.event});

  @override
  Widget build(BuildContext context) {
    final progress = event.maxParticipants > 0
        ? event.currentParticipants / event.maxParticipants
        : 0.0;
    final color = event.isFull
        ? Colors.red.shade400
        : progress > 0.8
            ? Colors.orange.shade400
            : const Color(0xFF1A6B3C);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Registration Progress',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E))),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: color),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: const Color(0xFFEEEEF2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
