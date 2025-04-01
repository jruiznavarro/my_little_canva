import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_little_canva/features/admin/presentation/pages/add_painting_page.dart';

class PaintingsTable extends StatelessWidget {
  final PaintBrand selectedBrand;

  const PaintingsTable({
    super.key,
    required this.selectedBrand,
  });

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
                            // TODO: Implementar edición
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            // TODO: Implementar eliminación
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