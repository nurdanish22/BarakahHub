import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../models/event_model.dart';
import '../../services/admin_service.dart';

class EventFormScreen extends StatefulWidget {
  final EventModel? event;
  const EventFormScreen({super.key, this.event});

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _adminService = AdminService();

  late TextEditingController _titleCtrl;
  late TextEditingController _descriptionCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _maxParticipantsCtrl;
  late TextEditingController _imageUrlCtrl;

  final List<String> _categories = [
    'Tazkirah', 'Charity', 'Education', 'Community', 'Youth', 'Other'
  ];

  late String _category;
  bool _isActive = true;
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);
  bool _saving = false;
  String _previewUrl = '';

  bool get _isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _descriptionCtrl = TextEditingController(text: e?.description ?? '');
    _locationCtrl = TextEditingController(text: e?.location ?? '');
    _maxParticipantsCtrl = TextEditingController(
      text: (e?.maxParticipants ?? 100).toString(),
    );
    _imageUrlCtrl = TextEditingController(text: e?.imageUrl ?? '');
    _previewUrl = e?.imageUrl ?? '';
    final existing = e?.category ?? '';
    _category = _categories.contains(existing) ? existing : _categories.last;
    _isActive = e?.isActive ?? true;
    if (e != null) {
      _date = e.dateTime;
      _time = TimeOfDay.fromDateTime(e.dateTime);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _locationCtrl.dispose();
    _maxParticipantsCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      builder: (_, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF1A6B3C)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (_, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF1A6B3C)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _time = picked);
  }

  DateTime get _combined => DateTime(
    _date.year, _date.month, _date.day, _time.hour, _time.minute,
  );

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final data = {
      'title': _titleCtrl.text.trim(),
      'description': _descriptionCtrl.text.trim(),
      'location': _locationCtrl.text.trim(),
      'date': Timestamp.fromDate(_combined),
      'category': _category,
      'maxParticipants': int.tryParse(_maxParticipantsCtrl.text) ?? 100,
      'currentParticipants': widget.event?.currentParticipants ?? 0,
      'isActive': _isActive,
      'imageUrl': _imageUrlCtrl.text.trim(),
      'organizerId': widget.event?.organizerId ?? '',
    };

    try {
      if (_isEditing) {
        await _adminService.updateEvent(widget.event!.eventId, data);
      } else {
        await _adminService.createEvent(data);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isEditing ? 'Event updated!' : 'Event created!'),
          backgroundColor: const Color(0xFF1A6B3C),
        ));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Event' : 'New Event',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFF1A6B3C),
        foregroundColor: Colors.white,
        actions: [
          _saving
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  ),
                )
              : TextButton(
                  onPressed: _save,
                  child: const Text('Save',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Event Image ──────────────────────────────────────────────────
            _label('Event Image'),
            _buildImageSection(),
            const SizedBox(height: 20),

            _label('Title'),
            TextFormField(
              controller: _titleCtrl,
              decoration: _decoration('Event title'),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 20),

            _label('Description'),
            TextFormField(
              controller: _descriptionCtrl,
              decoration: _decoration('Describe the event'),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 20),

            _label('Location'),
            TextFormField(
              controller: _locationCtrl,
              decoration: _decoration('Venue / address'),
              textCapitalization: TextCapitalization.words,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 20),

            _label('Date & Time'),
            Row(children: [
              Expanded(
                child: _dateButton(
                  Icons.calendar_today_outlined,
                  DateFormat('d MMM yyyy').format(_date),
                  _pickDate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _dateButton(
                  Icons.access_time_outlined,
                  _time.format(context),
                  _pickTime,
                ),
              ),
            ]),
            const SizedBox(height: 20),

            _label('Category'),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: _decoration('Select category'),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 20),

            _label('Max Participants'),
            TextFormField(
              controller: _maxParticipantsCtrl,
              decoration: _decoration('e.g. 100'),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (int.tryParse(v) == null) return 'Enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: 20),

            Row(children: [
              const Text('Active', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              const Spacer(),
              Switch(
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
                activeColor: const Color(0xFF1A6B3C),
              ),
            ]),
            const SizedBox(height: 32),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A6B3C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _isEditing ? 'Update Event' : 'Create Event',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Preview box
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 180,
            width: double.infinity,
            color: const Color(0xFFE8F5EE),
            child: _previewUrl.isNotEmpty
                ? Image.network(
                    _previewUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imagePlaceholder(),
                    loadingBuilder: (_, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(color: Color(0xFF1A6B3C)),
                      );
                    },
                  )
                : _imagePlaceholder(),
          ),
        ),
        const SizedBox(height: 10),
        // URL input
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _imageUrlCtrl,
                decoration: InputDecoration(
                  hintText: 'Paste image URL here (e.g. from Unsplash)',
                  prefixIcon: const Icon(Icons.image_outlined, color: Color(0xFF1A6B3C)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF1A6B3C), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
                onChanged: (v) {
                  // Only update preview when user stops typing (debounce via setState)
                },
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => setState(() => _previewUrl = _imageUrlCtrl.text.trim()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A6B3C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              ),
              child: const Text('Preview'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Tip: Use a free image from unsplash.com → right-click → Copy image address',
          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
        ),
      ],
    );
  }

  Widget _imagePlaceholder() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_outlined,
              size: 48, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text('No image added',
              style: TextStyle(color: Colors.grey[400], fontSize: 13)),
        ],
      );

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1A1A2E))),
      );

  InputDecoration _decoration(String hint) => InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1A6B3C), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      );

  Widget _dateButton(IconData icon, String label, VoidCallback onTap) =>
      OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 13)),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF1A6B3C),
          side: const BorderSide(color: Color(0xFF1A6B3C)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      );
}
