import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import 'add_painting_page.dart';

class EditPaintingPage extends ConsumerStatefulWidget {
  final String id;
  final String name;
  final String imageData;
  final PaintBrand brand;
  final bool isAvailable;

  const EditPaintingPage({
    super.key,
    required this.id,
    required this.name,
    required this.imageData,
    required this.brand,
    required this.isAvailable,
  });

  @override
  ConsumerState<EditPaintingPage> createState() => _EditPaintingPageState();
}

class _EditPaintingPageState extends ConsumerState<EditPaintingPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late PaintBrand _selectedBrand;
  File? _imageFile;
  Uint8List? _imageBytes;
  late bool _isAvailable;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _selectedBrand = widget.brand;
    _isAvailable = widget.isAvailable;
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

    // Verificar si el usuario está autenticado
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para editar pinturas'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      String imageData = widget.imageData;
      if (_imageBytes != null || _imageFile != null) {
        final bytes = kIsWeb ? _imageBytes! : await _imageFile!.readAsBytes();
        final base64Image = base64Encode(bytes);
        final mimeType = kIsWeb ? 'image/jpeg' : 'image/${path.extension(_imageFile!.path).substring(1)}';
        imageData = 'data:$mimeType;base64,$base64Image';
      }

      // Actualizar documento en Firestore
      final now = DateTime.now();
      await FirebaseFirestore.instance
          .collection('paintings')
          .doc(_selectedBrand.name)
          .collection('items')
          .doc(widget.id)
          .update({
        'name': _nameController.text,
        'imageData': imageData,
        'brand': _selectedBrand.name,
        'isAvailable': _isAvailable,
        'updatedAt': now,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pintura actualizada correctamente')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error al actualizar la pintura: $e');
      if (mounted) {
        String errorMessage = 'Error al actualizar la pintura';
        if (e.toString().contains('permission-denied')) {
          errorMessage = 'No tienes permisos para editar pinturas';
        } else if (e.toString().contains('not-found')) {
          errorMessage = 'No se encontró la pintura';
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
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Pintura'),
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
                          : Image.network(
                              widget.imageData,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
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
                    child: Text(_isSaving ? 'Guardando...' : 'Guardar Cambios'),
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