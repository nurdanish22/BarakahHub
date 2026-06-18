import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/announcement_provider.dart';

class AnnouncementDetailsScreen extends StatefulWidget {
  final String announcementId;

  const AnnouncementDetailsScreen({Key? key, required this.announcementId})
      : super(key: key);

  @override
  State<AnnouncementDetailsScreen> createState() =>
      _AnnouncementDetailsScreenState();
}

class _AnnouncementDetailsScreenState
    extends State<AnnouncementDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AnnouncementProvider>();
      if (provider.selectedAnnouncement?.announcementId !=
          widget.announcementId) {
        provider.loadAnnouncementById(widget.announcementId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AnnouncementProvider>(
      builder: (context, provider, _) {
        final announcement = provider.selectedAnnouncement;

        if (announcement == null) {
          return const Scaffold(
            body: Center(
                child: CircularProgressIndicator(color: Color(0xFF1A6B3C))),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight:
                    announcement.imageUrl.isNotEmpty ? 220 : 0,
                pinned: true,
                backgroundColor: const Color(0xFF1A6B3C),
                foregroundColor: Colors.white,
                flexibleSpace: announcement.imageUrl.isNotEmpty
                    ? FlexibleSpaceBar(
                        background: Image.network(
                          announcement.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _placeholderBanner(),
                        ),
                      )
                    : null,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _Badge(label: announcement.category),
                          const Spacer(),
                          Row(
                            children: [
                              const Icon(Icons.access_time,
                                  size: 14, color: Color(0xFF999AAA)),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('d MMM yyyy, h:mm a')
                                    .format(announcement.dateTime),
                                style: const TextStyle(
                                    fontSize: 13, color: Color(0xFF999AAA)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        announcement.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A2E),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: Color(0xFFEEEEF2)),
                      const SizedBox(height: 16),
                      Text(
                        announcement.content,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF444455),
                          height: 1.75,
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _placeholderBanner() {
    return Container(
      color: const Color(0xFF1A6B3C),
      child: const Center(
        child: Icon(Icons.campaign_outlined, size: 80, color: Colors.white24),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  const _Badge({required this.label});

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
        ),
      ),
    );
  }
}
