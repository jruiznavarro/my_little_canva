import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../pages/add_painting_page.dart';
import 'package:my_little_canva/features/admin/presentation/widgets/paintings_table.dart';

class PaintingsTab extends StatefulWidget {
  const PaintingsTab({super.key});

  @override
  State<PaintingsTab> createState() => _PaintingsTabState();
}

class _PaintingsTabState extends State<PaintingsTab> {
  PaintBrand _selectedBrand = PaintBrand.vallejo;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<PaintBrand>(
                  value: _selectedBrand,
                  decoration: const InputDecoration(
                    labelText: 'Marca de Pintura',
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
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddPaintingPage(
                        initialBrand: _selectedBrand,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Añadir Pintura'),
              ),
            ],
          ),
        ),
        Expanded(
          child: PaintingsTable(selectedBrand: _selectedBrand),
        ),
      ],
    );
  }
} 