import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/aqua_colors.dart';
import '../widgets/aqua_background.dart';
import 'qr_scanner_screen.dart';
import 'worker_dispensers_screen.dart';

class WorkerShell extends StatefulWidget {
  final int initialTabIndex;

  const WorkerShell({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<WorkerShell> createState() => _WorkerShellState();
}

class _WorkerShellState extends State<WorkerShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AquaBackground(
        child: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: _currentIndex,
            children: [
              const QrScannerScreen(),
              WorkerDispensersScreen(
                onNavigateToScan: () => _onTabSelected(0),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF091438).withValues(alpha: 0.88),
          border: const Border(
            top: BorderSide(color: AquaColors.glassBorderSubtle, width: 1),
          ),
        ),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 64,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      0,
                      Icons.qr_code_scanner_rounded,
                      'Escanear QR',
                    ),
                    _buildNavItem(
                      1,
                      Icons.checklist_rounded,
                      'Despachadores',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AquaColors.cornflowerBlue : AquaColors.textMuted;

    return Expanded(
      child: InkWell(
        onTap: () => _onTabSelected(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: color,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
