import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';

enum PaintBrand {
  vallejo,
  armyPainter,
}

class AddPaintingPage extends ConsumerStatefulWidget {
  final PaintBrand initialBrand;

  const AddPaintingPage({
    super.key,
    this.initialBrand = PaintBrand.vallejo,
  });

  @override
  ConsumerState<AddPaintingPage> createState() => _AddPaintingPageState();
}

class _AddPaintingPageState extends ConsumerState<AddPaintingPage> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  late PaintBrand _selectedBrand;
  File? _imageFile;
  Uint8List? _imageBytes;
  bool _isAvailable = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedBrand = widget.initialBrand;
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );
      
      if (image == null) return;

      // Verificar el tipo de archivo
      if (kIsWeb) {
        final mimeType = image.mimeType?.toLowerCase() ?? '';
        debugPrint('Tipo MIME: $mimeType');
        
        if (!mimeType.startsWith('image/jpeg') && !mimeType.startsWith('image/png')) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Solo se admiten imágenes JPG y PNG')),
            );
          }
          return;
        }
      } else {
        final extension = path.extension(image.path).toLowerCase();
        if (extension != '.jpg' && extension != '.jpeg' && extension != '.png') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Solo se admiten imágenes JPG y PNG')),
            );
          }
          return;
        }
      }

      // Verificar tamaño (1MB máximo para base64)
      final bytes = await image.readAsBytes();
      final sizeInMB = bytes.length / (1024 * 1024);
      
      if (sizeInMB > 1) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('La imagen no debe superar los 1MB')),
          );
        }
        return;
      }

      setState(() {
        if (kIsWeb) {
          _imageBytes = bytes;
        } else {
          _imageFile = File(image.path);
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar la imagen: $e')),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFile == null && _imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona una imagen')),
      );
      return;
    }

    // Verificar si el usuario está autenticado
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para guardar pinturas'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Convertir la imagen a base64
      final bytes = kIsWeb ? _imageBytes! : await _imageFile!.readAsBytes();
      final base64Image = base64Encode(bytes);
      final mimeType = kIsWeb ? 'image/jpeg' : 'image/${path.extension(_imageFile!.path).substring(1)}';
      final dataUrl = 'data:$mimeType;base64,$base64Image';

      // Crear documento en Firestore
      final now = DateTime.now();
      final docRef = FirebaseFirestore.instance
          .collection('paintings')
          .doc(_selectedBrand.name)
          .collection('items')
          .doc(_idController.text);

      // Verificar si el documento ya existe
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        throw Exception('Ya existe una pintura con este ID');
      }

      await docRef.set({
        'id': _idController.text,
        'name': _nameController.text,
        'imageData': dataUrl,
        'brand': _selectedBrand.name,
        'isAvailable': _isAvailable,
        'createdAt': now,
        'updatedAt': now,
        'createdBy': user.uid,  // Agregamos el ID del usuario que creó la pintura
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pintura guardada correctamente')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error al guardar la pintura: $e');
      if (mounted) {
        String errorMessage = 'Error al guardar la pintura';
        if (e.toString().contains('permission-denied')) {
          errorMessage = 'No tienes permisos para guardar pinturas';
        } else if (e.toString().contains('not-found')) {
          errorMessage = 'No se encontró la base de datos';
        } else if (e.toString().contains('already-exists')) {
          errorMessage = 'Ya existe una pintura con este ID';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Pintura'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<PaintBrand>(
                    value: _selectedBrand,
                    decoration: const InputDecoration(
                      labelText: 'Marca',
                      border: OutlineInputBorder(),
                    ),
                    items: PaintBrand.values.map((brand) {
                      return DropdownMenuItem(
                        value: brand,
                        child: Text(brand.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBrand = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _idController,
                    decoration: const InputDecoration(
                      labelText: 'ID',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa un ID';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa un nombre';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _isSaving ? null : _pickImage,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _imageFile != null || _imageBytes != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: kIsWeb
                                  ? Image.memory(
                                      _imageBytes!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    )
                                  : Image.file(
                                      _imageFile!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                            )
                          : const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo, size: 48),
                                  SizedBox(height: 8),
                                  Text('Toca para seleccionar una imagen'),
                                ],
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Disponible'),
                    value: _isAvailable,
                    onChanged: _isSaving
                        ? null
                        : (value) {
                            setState(() {
                              _isAvailable = value;
                            });
                          },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _submitForm,
                    child: Text(_isSaving ? 'Guardando...' : 'Guardar'),
                  ),
                ],
              ),
            ),
          ),
          if (_isSaving)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
} 