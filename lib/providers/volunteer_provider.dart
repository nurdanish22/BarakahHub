import 'package:flutter/foundation.dart';
import '../models/volunteer_model.dart';
import '../services/volunteer_service.dart';

enum VolunteerLoadingState { idle, loading, loaded, error }

class VolunteerProvider with ChangeNotifier {
  final VolunteerService _service = VolunteerService();

  List<VolunteerOpportunityModel> _opportunities = [];
  List<VolunteerOpportunityModel> _userHistory = [];
  VolunteerOpportunityModel? _selectedOpportunity;

  VolunteerLoadingState _loadingState = VolunteerLoadingState.idle;
  VolunteerLoadingState _historyState = VolunteerLoadingState.idle;

  String _errorMessage = '';
  String _selectedCategory = 'All';
  bool _isApplying = false;

  List<VolunteerOpportunityModel> get opportunities => _opportunities;
  List<VolunteerOpportunityModel> get userHistory => _userHistory;
  VolunteerOpportunityModel? get selectedOpportunity => _selectedOpportunity;

  VolunteerLoadingState get loadingState => _loadingState;
  VolunteerLoadingState get historyState => _historyState;

  String get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _loadingState == VolunteerLoadingState.loading;
  bool get isApplying => _isApplying;

  Future<void> loadOpportunities() async {
    _loadingState = VolunteerLoadingState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _opportunities = await _service.getOpportunities();
      _loadingState = VolunteerLoadingState.loaded;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _loadingState = VolunteerLoadingState.error;
    }
    notifyListeners();
  }

  Future<void> filterByCategory(String category) async {
    _selectedCategory = category;
    if (category == 'All') {
      await loadOpportunities();
      return;
    }

    _loadingState = VolunteerLoadingState.loading;
    notifyListeners();

    try {
      _opportunities = await _service.getOpportunitiesByCategory(category);
      _loadingState = VolunteerLoadingState.loaded;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _loadingState = VolunteerLoadingState.error;
    }
    notifyListeners();
  }

  void selectOpportunity(VolunteerOpportunityModel opportunity) {
    _selectedOpportunity = opportunity;
    notifyListeners();
  }

  Future<void> loadOpportunityById(String id) async {
    try {
      _selectedOpportunity = await _service.getOpportunityById(id);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<bool> applyForOpportunity({
    required String userId,
    required String opportunityId,
  }) async {
    _isApplying = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _service.applyForOpportunity(
          userId: userId, opportunityId: opportunityId);
      await loadOpportunityById(opportunityId);
      await loadUserHistory(userId);
      _isApplying = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isApplying = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelApplication({
    required String userId,
    required String opportunityId,
  }) async {
    _isApplying = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _service.cancelApplication(
          userId: userId, opportunityId: opportunityId);
      await loadOpportunityById(opportunityId);
      await loadUserHistory(userId);
      _isApplying = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isApplying = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> checkApplicationStatus({
    required String userId,
    required String opportunityId,
  }) async {
    try {
      return await _service.hasApplied(
          userId: userId, opportunityId: opportunityId);
    } catch (_) {
      return false;
    }
  }

  Future<void> loadUserHistory(String userId) async {
    _historyState = VolunteerLoadingState.loading;
    notifyListeners();

    try {
      _userHistory = await _service.getUserVolunteerHistory(userId);
      _historyState = VolunteerLoadingState.loaded;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _historyState = VolunteerLoadingState.error;
    }
    notifyListeners();
  }

  void reset() {
    _opportunities = [];
    _userHistory = [];
    _selectedOpportunity = null;
    _loadingState = VolunteerLoadingState.idle;
    _historyState = VolunteerLoadingState.idle;
    _errorMessage = '';
    _selectedCategory = 'All';
    _isApplying = false;
    notifyListeners();
  }
}
