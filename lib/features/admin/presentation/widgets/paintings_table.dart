import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_little_canva/features/admin/presentation/pages/add_painting_page.dart';
import 'package:my_little_canva/features/admin/presentation/pages/edit_painting_page.dart';

class PaintingsTable extends StatelessWidget {
  final PaintBrand selectedBrand;

  const PaintingsTable({
    super.key,
    required this.selectedBrand,
  });

  Future<void> _deletePainting(BuildContext context, String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('paintings')
          .doc(selectedBrand.name)
          .collection('items')
          .doc(id)
          .delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pintura eliminada correctamente')),
        );
      }
    } catch (e) {
      debugPrint('Error al eliminar la pintura: $e');
      if (context.mounted) {
        String errorMessage = 'Error al eliminar la pintura';
        if (e.toString().contains('permission-denied')) {
          errorMessage = 'No tienes permisos para eliminar pinturas';
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
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context, String id) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text('¿Estás seguro de que deseas eliminar esta pintura?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Eliminar'),
              onPressed: () {
                Navigator.of(context).pop();
                _deletePainting(context, id);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('paintings')
          .doc(selectedBrand.name)
          .collection('items')
          .orderBy('name')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final paintings = snapshot.data?.docs ?? [];

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('ID')),
              DataColumn(label: Text('Nombre')),
              DataColumn(label: Text('Imagen')),
              DataColumn(label: Text('Disponible')),
              DataColumn(label: Text('Acciones')),
            ],
            rows: paintings.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return DataRow(
                cells: [
                  DataCell(Text(data['id'] ?? '')),
                  DataCell(Text(data['name'] ?? '')),
                  DataCell(
                    data['imageData'] != null
                        ? Image.network(
                            data['imageData'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.image_not_supported),
                  ),
                  DataCell(
                    Icon(
                      data['isAvailable'] == true
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: data['isAvailable'] == true
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditPaintingPage(
                                  id: data['id'],
                                  name: data['name'],
                                  imageData: data['imageData'],
                                  brand: PaintBrand.values.firstWhere(
                                    (brand) => brand.name == data['brand'],
                                  ),
                                  isAvailable: data['isAvailable'] ?? true,
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _showDeleteConfirmation(context, data['id']);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }
} 