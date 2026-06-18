import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/volunteer_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/volunteer_model.dart';

class VolunteerDetailsScreen extends StatefulWidget {
  final String opportunityId;

  const VolunteerDetailsScreen({Key? key, required this.opportunityId})
      : super(key: key);

  @override
  State<VolunteerDetailsScreen> createState() => _VolunteerDetailsScreenState();
}

class _VolunteerDetailsScreenState extends State<VolunteerDetailsScreen> {
  late String _currentUserId;
  bool _hasApplied = false;
  bool _checkingStatus = true;

  @override
  void initState() {
    super.initState();
    _currentUserId =
        context.read<AppAuthProvider>().currentUser?.userId ?? '';
    _initScreen();
  }

  Future<void> _initScreen() async {
    final provider = context.read<VolunteerProvider>();
    if (provider.selectedOpportunity?.opportunityId != widget.opportunityId) {
      await provider.loadOpportunityById(widget.opportunityId);
    }
    final applied = await provider.checkApplicationStatus(
      userId: _currentUserId,
      opportunityId: widget.opportunityId,
    );
    if (mounted) {
      setState(() {
        _hasApplied = applied;
        _checkingStatus = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VolunteerProvider>(
      builder: (context, provider, _) {
        final opp = provider.selectedOpportunity;

        if (opp == null || _checkingStatus) {
          return const Scaffold(
            body: Center(
                child: CircularProgressIndicator(color: Color(0xFF1A6B3C))),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          body: CustomScrollView(
            slivers: [
              _buildAppBar(opp),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CategoryBadge(label: opp.category, color: const Color(0xFFE65100)),
                      const SizedBox(height: 12),
                      Text(
                        opp.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A2E),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _InfoCard(children: [
                        _DetailRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Date',
                          value: DateFormat('EEEE, d MMMM yyyy')
                              .format(opp.dateTime),
                          subValue:
                              DateFormat('h:mm a').format(opp.dateTime),
                        ),
                        const _Divider(),
                        _DetailRow(
                          icon: Icons.location_on_outlined,
                          label: 'Location',
                          value: opp.location,
                        ),
                        const _Divider(),
                        _DetailRow(
                          icon: Icons.people_outline,
                          label: 'Volunteers',
                          value:
                              '${opp.currentVolunteers} / ${opp.maxVolunteers}',
                          subValue: opp.isFull
                              ? 'Fully booked'
                              : '${opp.remainingSlots} slots remaining',
                          subValueColor: opp.isFull
                              ? Colors.red.shade500
                              : const Color(0xFF1A6B3C),
                        ),
                      ]),
                      const SizedBox(height: 20),
                      _ProgressSection(opportunity: opp),
                      if (opp.requirements.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Requirements',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          opp.requirements,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF555566),
                            height: 1.65,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      const Text(
                        'About This Opportunity',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        opp.description,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF555566),
                          height: 1.65,
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomBar(context, provider, opp),
        );
      },
    );
  }

  Widget _buildAppBar(VolunteerOpportunityModel opp) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: const Color(0xFFE65100),
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: opp.imageUrl.isNotEmpty
            ? Image.network(opp.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholderBanner())
            : _placeholderBanner(),
      ),
    );
  }

  Widget _placeholderBanner() {
    return Container(
      color: const Color(0xFFE65100),
      child: const Center(
        child: Icon(Icons.volunteer_activism_outlined,
            size: 80, color: Colors.white24),
      ),
    );
  }

  Widget _buildBottomBar(
      BuildContext context, VolunteerProvider provider, VolunteerOpportunityModel opp) {
    final canApply = !opp.isFull || _hasApplied;

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
          onPressed: provider.isApplying || (!canApply && !_hasApplied)
              ? null
              : () => _handleApplication(context, provider, opp),
          style: ElevatedButton.styleFrom(
            backgroundColor: _hasApplied
                ? Colors.red.shade600
                : const Color(0xFFE65100),
            disabledBackgroundColor: const Color(0xFFCCCCDD),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: provider.isApplying
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white),
                )
              : Text(
                  _hasApplied
                      ? 'Cancel Application'
                      : opp.isFull
                          ? 'Fully Booked'
                          : 'Join as Volunteer',
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

  Future<void> _handleApplication(BuildContext context,
      VolunteerProvider provider, VolunteerOpportunityModel opp) async {
    if (_hasApplied) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text('Cancel Application',
              style: TextStyle(fontWeight: FontWeight.w700)),
          content: const Text(
              'Are you sure you want to cancel your volunteer application?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Keep Application')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Cancel Application',
                  style: TextStyle(color: Colors.red.shade600)),
            ),
          ],
        ),
      );
      if (confirm != true) return;

      final success = await provider.cancelApplication(
        userId: _currentUserId,
        opportunityId: opp.opportunityId,
      );
      if (mounted) {
        setState(() => _hasApplied = !success);
        _showSnackBar(
            success
                ? 'Application cancelled.'
                : provider.errorMessage,
            !success);
      }
    } else {
      final success = await provider.applyForOpportunity(
        userId: _currentUserId,
        opportunityId: opp.opportunityId,
      );
      if (mounted) {
        setState(() => _hasApplied = success);
        _showSnackBar(
            success
                ? 'Application submitted! Jazakallah khair.'
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

// ── Supporting widgets ────────────────────────────────────────────────────────

class _CategoryBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _CategoryBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3)),
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
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFFE65100)),
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
                          color:
                              subValueColor ?? const Color(0xFF888899))),
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
  Widget build(BuildContext context) =>
      const Divider(height: 1, indent: 68, color: Color(0xFFF0F0F5));
}

class _ProgressSection extends StatelessWidget {
  final VolunteerOpportunityModel opportunity;
  const _ProgressSection({required this.opportunity});

  @override
  Widget build(BuildContext context) {
    final progress = opportunity.maxVolunteers > 0
        ? opportunity.currentVolunteers / opportunity.maxVolunteers
        : 0.0;
    final color = opportunity.isFull
        ? Colors.red.shade400
        : progress > 0.8
            ? Colors.orange.shade400
            : const Color(0xFFE65100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Volunteer Progress',
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
