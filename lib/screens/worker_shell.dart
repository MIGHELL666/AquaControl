import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/aqua_colors.dart';
import '../widgets/aqua_background.dart';
import '../widgets/zoom_container.dart';
import 'qr_scanner_screen.dart';
import 'worker_dispensers_screen.dart';
import 'worker_history_table_screen.dart';

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
          child: AquaZoomContainer(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                const QrScannerScreen(),
                WorkerDispensersScreen(
                  onNavigateToScan: () => _onTabSelected(0),
                ),
                const WorkerHistoryTableScreen(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: AquaColors.glassSurfaceLight,
              border: const Border(
                top: BorderSide(color: AquaColors.glassBorder, width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: AquaColors.shadowFloat,
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
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
                    _buildNavItem(
                      2,
                      Icons.table_chart_rounded,
                      'Tabla',
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
    final color = isSelected ? AquaColors.turquoise : AquaColors.textSecondary;

    return Expanded(
      child: InkWell(
        onTap: () => _onTabSelected(index),
        splashColor: AquaColors.turquoise.withValues(alpha: 0.08),
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: isSelected ? 16 : 0,
                  vertical: isSelected ? 3 : 0,
                ),
                decoration: isSelected
                    ? BoxDecoration(
                        color: AquaColors.turquoise.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      )
                    : null,
                child: Icon(
                  icon,
                  size: 22,
                  color: color,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
