import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_little_canva/features/auth/presentation/controllers/auth_controller.dart';
import 'package:my_little_canva/features/auth/presentation/pages/admin_page.dart';
import 'package:my_little_canva/features/auth/domain/entities/user_role.dart';
import 'package:my_little_canva/features/auth/presentation/pages/inventory_page.dart';
import 'package:my_little_canva/features/auth/presentation/pages/learn_to_paint_page.dart';
import 'package:my_little_canva/features/auth/presentation/pages/login_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;
  UserRole? _userRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final role = await ref.read(authControllerProvider.notifier).getUserRole();
    setState(() {
      _userRole = role;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          // Si el usuario no está autenticado, navegar a LoginPage
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          });
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          body: Stack(
            children: [
              IndexedStack(
                index: _selectedIndex,
                children: [
                  const _HomeContent(),
                  const LearnToPaintPage(),
                  const InventoryPage(),
                  const _ProfileContent(),
                  if (_userRole == UserRole.admin) const AdminPage(),
                ],
              ),
              // Botón de perfil siempre presente
              const Positioned(
                top: 48,
                right: 16,
                child: ProfileButton(),
              ),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Inicio',
              ),
              const NavigationDestination(
                icon: Icon(Icons.palette_outlined),
                selectedIcon: Icon(Icons.palette),
                label: 'Aprende',
              ),
              const NavigationDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory_2),
                label: 'Inventario',
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Perfil',
              ),
              if (_userRole == UserRole.admin)
                const NavigationDestination(
                  icon: Icon(Icons.admin_panel_settings_outlined),
                  selectedIcon: Icon(Icons.admin_panel_settings),
                  label: 'Admin',
                ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: const Center(
        child: Text('Contenido de la página de inicio'),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Contenido del perfil'),
    );
  }
}

class ProfileButton extends ConsumerWidget {
  const ProfileButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTapDown: (details) {
        final RenderBox button = context.findRenderObject() as RenderBox;
        final Offset offset = button.localToGlobal(Offset.zero);
        
        showMenu<void>(
          context: context,
          position: RelativeRect.fromLTRB(
            offset.dx,
            offset.dy + button.size.height,
            offset.dx + button.size.width,
            offset.dy + button.size.height + 100,
          ),
          items: <PopupMenuEntry<void>>[
            PopupMenuItem<void>(
              child: const Row(
                children: [
                  Icon(Icons.settings),
                  SizedBox(width: 8),
                  Text('Ajustes'),
                ],
              ),
              onTap: () {
                // Cerramos el menú
                Future.delayed(const Duration(seconds: 0), () {
                  _showSettingsModal(context);
                });
              },
            ),
            const PopupMenuDivider(),
            PopupMenuItem<void>(
              child: const Row(
                children: [
                  Icon(Icons.logout, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
                ],
              ),
              onTap: () async {
                // Cerramos el menú y esperamos un momento antes de cerrar sesión
                Future.delayed(const Duration(milliseconds: 100), () async {
                  await ref.read(authControllerProvider.notifier).signOut();
                });
              },
            ),
          ],
        );
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.person,
          color: Color(0xFF4285F4),
        ),
      ),
    );
  }

  void _showSettingsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text(
                  'Ajustes',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Aquí irán las opciones de ajustes
            const Text('Contenido de ajustes'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4285F4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Aceptar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 