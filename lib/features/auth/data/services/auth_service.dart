import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_role.dart';
import 'package:flutter/material.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<UserRole?> getUserRole() async {
    try {
      debugPrint('Obteniendo rol del usuario...');
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('No hay usuario autenticado');
        return null;
      }

      debugPrint('Buscando documento del usuario ${user.uid} en Firestore...');
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        debugPrint('Documento no existe, creando con rol por defecto...');
        await _firestore.collection('users').doc(user.uid).set({
          'email': user.email,
          'displayName': user.displayName,
          'role': UserRole.user.toString().split('.').last,
          'createdAt': FieldValue.serverTimestamp(),
        });
        return UserRole.user;
      }

      final role = userDoc.data()?['role'] as String?;
      debugPrint('Rol encontrado: $role');
      if (role == null) return null;
      
      return UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.$role',
        orElse: () => UserRole.user,
      );
    } catch (e) {
      debugPrint('Error en getUserRole: ${e.toString()}');
      return null;
    }
  }

  Future<void> setUserRole(String uid, UserRole role) async {
    try {
      debugPrint('Actualizando rol del usuario $uid a ${role.toString()}...');
      await _firestore.collection('users').doc(uid).update({
        'role': role.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('Rol actualizado exitosamente');
    } catch (e) {
      debugPrint('Error en setUserRole: ${e.toString()}');
      rethrow;
    }
  }

  // Método para crear o actualizar el documento del usuario cuando se registra
  Future<void> createOrUpdateUser(User user) async {
    try {
      debugPrint('Creando/actualizando usuario ${user.uid} en Firestore...');
      final userRef = _firestore.collection('users').doc(user.uid);
      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        debugPrint('Documento no existe, creando nuevo...');
        await userRef.set({
          'email': user.email,
          'displayName': user.displayName,
          'role': UserRole.user.toString().split('.').last,
          'createdAt': FieldValue.serverTimestamp(),
        });
        debugPrint('Documento creado exitosamente');
      } else {
        debugPrint('Documento ya existe');
      }
    } catch (e) {
      debugPrint('Error en createOrUpdateUser: ${e.toString()}');
      rethrow;
    }
  }
} 