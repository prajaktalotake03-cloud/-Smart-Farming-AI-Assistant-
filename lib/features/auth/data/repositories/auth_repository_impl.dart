import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final StreamController<UserModel?> _authStateController = StreamController<UserModel?>.broadcast();
  bool _useMock = true;
  UserModel? _currentUser;

  AuthRepositoryImpl() {
    _checkFirebaseState();
  }

  Future<void> _checkFirebaseState() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        _useMock = false;
        // Listen to Firebase Auth state updates
        fb.FirebaseAuth.instance.authStateChanges().listen((fb.User? user) {
          if (user != null) {
            _currentUser = UserModel(
              uid: user.uid,
              email: user.email ?? '',
              displayName: user.displayName ?? 'Framer',
              photoUrl: user.photoURL,
              isMock: false,
            );
          } else {
            _currentUser = null;
          }
          _authStateController.add(_currentUser);
        });
      } else {
        await _loadMockUser();
      }
    } catch (_) {
      await _loadMockUser();
    }
  }

  Future<void> _loadMockUser() async {
    _useMock = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('mock_user_session');
      if (userJson != null) {
        _currentUser = UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
      } else {
        _currentUser = null;
      }
    } catch (_) {
      _currentUser = null;
    }
    _authStateController.add(_currentUser);
  }

  @override
  Stream<UserModel?> get onAuthStateChanged => _authStateController.stream;

  @override
  Future<UserModel?> getCurrentUser() async {
    if (_useMock) {
      await _loadMockUser();
      return _currentUser;
    } else {
      final fbUser = fb.FirebaseAuth.instance.currentUser;
      if (fbUser != null) {
        return UserModel(
          uid: fbUser.uid,
          email: fbUser.email ?? '',
          displayName: fbUser.displayName ?? 'Framer',
          photoUrl: fbUser.photoURL,
          isMock: false,
        );
      }
      return null;
    }
  }

  @override
  Future<UserModel> signInWithEmailAndPassword(String email, String password) async {
    if (_useMock) {
      // Simulate network latency
      await Future.delayed(const Duration(milliseconds: 1200));
      
      // Basic mock verification
      if (email.length < 5 || !email.contains('@')) {
        throw Exception('Invalid email address format.');
      }
      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters.');
      }

      final mockUser = UserModel(
        uid: 'mock_user_123',
        email: email,
        displayName: email.split('@')[0].toUpperCase(),
        isMock: true,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('mock_user_session', jsonEncode(mockUser.toJson()));
      _currentUser = mockUser;
      _authStateController.add(_currentUser);
      return mockUser;
    } else {
      try {
        final credential = await fb.FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        final fbUser = credential.user!;
        final user = UserModel(
          uid: fbUser.uid,
          email: fbUser.email ?? '',
          displayName: fbUser.displayName ?? 'Framer',
          photoUrl: fbUser.photoURL,
          isMock: false,
        );
        _currentUser = user;
        return user;
      } catch (e) {
        throw Exception(e.toString().replaceAll(RegExp(r'\[.*?\]'), ''));
      }
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword(
      String email, String password, String displayName) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 1200));
      
      if (email.length < 5 || !email.contains('@')) {
        throw Exception('Invalid email address format.');
      }
      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters.');
      }
      if (displayName.trim().isEmpty) {
        throw Exception('Please enter your name.');
      }

      final mockUser = UserModel(
        uid: 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: displayName,
        isMock: true,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('mock_user_session', jsonEncode(mockUser.toJson()));
      _currentUser = mockUser;
      _authStateController.add(_currentUser);
      return mockUser;
    } else {
      try {
        final credential = await fb.FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        final fbUser = credential.user!;
        await fbUser.updateDisplayName(displayName);
        final user = UserModel(
          uid: fbUser.uid,
          email: fbUser.email ?? '',
          displayName: displayName,
          photoUrl: fbUser.photoURL,
          isMock: false,
        );
        _currentUser = user;
        return user;
      } catch (e) {
        throw Exception(e.toString().replaceAll(RegExp(r'\[.*?\]'), ''));
      }
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 1000));
      final mockUser = UserModel(
        uid: 'mock_google_user_999',
        email: 'farmer.assistant@gmail.com',
        displayName: 'Smart Farmer',
        isMock: true,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('mock_user_session', jsonEncode(mockUser.toJson()));
      _currentUser = mockUser;
      _authStateController.add(_currentUser);
      return mockUser;
    } else {
      try {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) {
          throw Exception('Google Sign-In was cancelled by user.');
        }
        
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final fb.AuthCredential credential = fb.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        
        final fbUserCredential = await fb.FirebaseAuth.instance.signInWithCredential(credential);
        final fbUser = fbUserCredential.user!;
        final user = UserModel(
          uid: fbUser.uid,
          email: fbUser.email ?? '',
          displayName: fbUser.displayName ?? 'Google User',
          photoUrl: fbUser.photoURL,
          isMock: false,
        );
        _currentUser = user;
        return user;
      } catch (e) {
        throw Exception(e.toString().replaceAll(RegExp(r'\[.*?\]'), ''));
      }
    }
  }

  @override
  Future<void> signOut() async {
    if (_useMock) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('mock_user_session');
      _currentUser = null;
      _authStateController.add(null);
    } else {
      await fb.FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      _currentUser = null;
    }
  }
}
