import 'package:flutter/foundation.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';

enum EventLoadingState { idle, loading, loaded, error }

class EventProvider with ChangeNotifier {
  final EventService _eventService = EventService();

  // ─── State ───────────────────────────────────
  List<EventModel> _upcomingEvents = [];
  List<EventModel> _searchResults = [];
  List<EventModel> _userRegisteredEvents = [];
  EventModel? _selectedEvent;

  EventLoadingState _loadingState = EventLoadingState.idle;
  EventLoadingState _searchState = EventLoadingState.idle;
  EventLoadingState _registeredEventsState = EventLoadingState.idle;

  String _errorMessage = '';
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _isRegistering = false;

  // ─── Getters ─────────────────────────────────
  List<EventModel> get upcomingEvents => _upcomingEvents;
  List<EventModel> get searchResults => _searchResults;
  List<EventModel> get userRegisteredEvents => _userRegisteredEvents;
  EventModel? get selectedEvent => _selectedEvent;

  EventLoadingState get loadingState => _loadingState;
  EventLoadingState get searchState => _searchState;
  EventLoadingState get registeredEventsState => _registeredEventsState;

  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  bool get isRegistering => _isRegistering;

  bool get isLoading => _loadingState == EventLoadingState.loading;
  bool get isSearching => _searchState == EventLoadingState.loading;

  // ─── Displayed events (search vs. browse) ────
  List<EventModel> get displayedEvents =>
      _searchQuery.isNotEmpty ? _searchResults : _upcomingEvents;

  // ─── Load Upcoming Events ─────────────────────
  Future<void> loadUpcomingEvents() async {
    _loadingState = EventLoadingState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _upcomingEvents = await _eventService.getUpcomingEvents();
      _loadingState = EventLoadingState.loaded;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _loadingState = EventLoadingState.error;
    }
    notifyListeners();
  }

  // ─── Search Events ────────────────────────────
  Future<void> searchEvents(String query) async {
    _searchQuery = query;

    if (query.trim().isEmpty) {
      _searchResults = [];
      _searchState = EventLoadingState.idle;
      notifyListeners();
      return;
    }

    _searchState = EventLoadingState.loading;
    notifyListeners();

    try {
      _searchResults = await _eventService.searchEvents(query);
      _searchState = EventLoadingState.loaded;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _searchState = EventLoadingState.error;
    }
    notifyListeners();
  }

  /// Clear search and return to browse view
  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    _searchState = EventLoadingState.idle;
    notifyListeners();
  }

  // ─── Category Filter ──────────────────────────
  Future<void> filterByCategory(String category) async {
    _selectedCategory = category;

    if (category == 'All') {
      await loadUpcomingEvents();
      return;
    }

    _loadingState = EventLoadingState.loading;
    notifyListeners();

    try {
      _upcomingEvents = await _eventService.getEventsByCategory(category);
      _loadingState = EventLoadingState.loaded;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _loadingState = EventLoadingState.error;
    }
    notifyListeners();
  }

  // ─── Select Event ─────────────────────────────
  void selectEvent(EventModel event) {
    _selectedEvent = event;
    notifyListeners();
  }

  Future<void> loadEventById(String eventId, {bool forceServer = false}) async {
    try {
      _selectedEvent = await _eventService.getEventById(eventId, forceServer: forceServer);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  // ─── Register for Event ───────────────────────
  Future<bool> registerForEvent({
    required String userId,
    required String eventId,
  }) async {
    _isRegistering = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _eventService.registerForEvent(
          userId: userId, eventId: eventId);
      // Force server fetch so participant count reflects the committed increment
      await loadEventById(eventId, forceServer: true);
      await loadUserRegisteredEvents(userId);
      _isRegistering = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isRegistering = false;
      notifyListeners();
      return false;
    }
  }

  /// Cancel registration
  Future<bool> cancelRegistration({
    required String userId,
    required String eventId,
  }) async {
    _isRegistering = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _eventService.cancelRegistration(
          userId: userId, eventId: eventId);
      // Force server fetch so participant count reflects the decrement
      await loadEventById(eventId, forceServer: true);
      await loadUserRegisteredEvents(userId);
      _isRegistering = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isRegistering = false;
      notifyListeners();
      return false;
    }
  }

  /// Check registration status for current user
  Future<bool> checkRegistrationStatus({
    required String userId,
    required String eventId,
  }) async {
    try {
      return await _eventService.isUserRegistered(
          userId: userId, eventId: eventId);
    } catch (_) {
      return false;
    }
  }

  // ─── User Registered Events ───────────────────
  Future<void> loadUserRegisteredEvents(String userId) async {
    _registeredEventsState = EventLoadingState.loading;
    notifyListeners();

    try {
      _userRegisteredEvents =
          await _eventService.getUserRegisteredEvents(userId);
      _registeredEventsState = EventLoadingState.loaded;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _registeredEventsState = EventLoadingState.error;
    }
    notifyListeners();
  }

  // ─── Utility ──────────────────────────────────
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  void reset() {
    _upcomingEvents = [];
    _searchResults = [];
    _userRegisteredEvents = [];
    _selectedEvent = null;
    _loadingState = EventLoadingState.idle;
    _searchState = EventLoadingState.idle;
    _registeredEventsState = EventLoadingState.idle;
    _errorMessage = '';
    _searchQuery = '';
    _selectedCategory = 'All';
    _isRegistering = false;
    notifyListeners();
  }
}
