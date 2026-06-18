import 'package:flutter/foundation.dart';
import '../models/announcement_model.dart';
import '../services/announcement_service.dart';

enum AnnouncementLoadingState { idle, loading, loaded, error }

class AnnouncementProvider with ChangeNotifier {
  final AnnouncementService _service = AnnouncementService();

  List<AnnouncementModel> _announcements = [];
  AnnouncementModel? _selectedAnnouncement;
  AnnouncementLoadingState _loadingState = AnnouncementLoadingState.idle;
  String _errorMessage = '';

  List<AnnouncementModel> get announcements => _announcements;
  AnnouncementModel? get selectedAnnouncement => _selectedAnnouncement;
  AnnouncementLoadingState get loadingState => _loadingState;
  String get errorMessage => _errorMessage;
  bool get isLoading => _loadingState == AnnouncementLoadingState.loading;

  Future<void> loadAnnouncements() async {
    _loadingState = AnnouncementLoadingState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _announcements = await _service.getAnnouncements();
      _loadingState = AnnouncementLoadingState.loaded;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _loadingState = AnnouncementLoadingState.error;
    }
    notifyListeners();
  }

  void selectAnnouncement(AnnouncementModel announcement) {
    _selectedAnnouncement = announcement;
    notifyListeners();
  }

  Future<void> loadAnnouncementById(String id) async {
    try {
      _selectedAnnouncement = await _service.getAnnouncementById(id);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void reset() {
    _announcements = [];
    _selectedAnnouncement = null;
    _loadingState = AnnouncementLoadingState.idle;
    _errorMessage = '';
    notifyListeners();
  }
}
