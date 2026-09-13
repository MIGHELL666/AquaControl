enum DispenserStatus {
  supplied,
  pending,
}

class DispenserItem {
  final String id;
  final String brand;
  final String model;
  final String serialNumber;
  final DispenserStatus status;
  final String lastSupplyInfo;
  final int bottleCount;
  final String alertMessage;

  const DispenserItem({
    required this.id,
    required this.brand,
    required this.model,
    required this.serialNumber,
    required this.status,
    required this.lastSupplyInfo,
    this.bottleCount = 2,
    this.alertMessage = '',
  });

  bool get isSupplied => status == DispenserStatus.supplied;

  DispenserItem copyWith({
    String? id,
    String? brand,
    String? model,
    String? serialNumber,
    DispenserStatus? status,
    String? lastSupplyInfo,
    int? bottleCount,
    String? alertMessage,
  }) {
    return DispenserItem(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      serialNumber: serialNumber ?? this.serialNumber,
      status: status ?? this.status,
      lastSupplyInfo: lastSupplyInfo ?? this.lastSupplyInfo,
      bottleCount: bottleCount ?? this.bottleCount,
      alertMessage: alertMessage ?? this.alertMessage,
    );
  }
}

class ZoneItem {
  final String name;
  final String subtitle;
  List<DispenserItem> dispensers;

  ZoneItem({
    required this.name,
    required this.subtitle,
    required this.dispensers,
  });

  int get totalDispensers => dispensers.length;
  int get suppliedCount => dispensers.where((d) => d.isSupplied).length;
  int get pendingCount => dispensers.where((d) => !d.isSupplied).length;
  bool get isFullySupplied => pendingCount == 0;
}

bool deleteDispenser(String zoneName, String dispenserId) {
  final zone = kDefaultZones.firstWhere(
    (z) => z.name.toLowerCase() == zoneName.toLowerCase(),
    orElse: () => kDefaultZones.first,
  );
  final initialLength = zone.dispensers.length;
  zone.dispensers.removeWhere((d) => d.id.trim() == dispenserId.trim());
  return zone.dispensers.length < initialLength;
}

bool updateDispenser({
  required String currentZoneName,
  required String currentDispenserId,
  required DispenserItem updatedItem,
  required String targetZoneName,
}) {
  final currentZone = kDefaultZones.firstWhere(
    (z) => z.name.toLowerCase() == currentZoneName.toLowerCase(),
    orElse: () => kDefaultZones.first,
  );

  if (currentZoneName.toLowerCase() == targetZoneName.toLowerCase()) {
    final idx = currentZone.dispensers.indexWhere((d) => d.id.trim() == currentDispenserId.trim());
    if (idx != -1) {
      currentZone.dispensers[idx] = updatedItem;
      return true;
    }
    return false;
  } else {
    currentZone.dispensers.removeWhere((d) => d.id.trim() == currentDispenserId.trim());
    final targetZone = kDefaultZones.firstWhere(
      (z) => z.name.toLowerCase() == targetZoneName.toLowerCase(),
      orElse: () => kDefaultZones.first,
    );
    targetZone.dispensers.insert(0, updatedItem);
    return true;
  }
}

void addDispenser(String zoneName, DispenserItem newItem) {
  final targetZone = kDefaultZones.firstWhere(
    (z) => z.name.toLowerCase() == zoneName.toLowerCase(),
    orElse: () => kDefaultZones.first,
  );
  targetZone.dispensers.insert(0, newItem);
}

bool markDispenserSupplied(String dispenserId, int bottleCount) {
  for (final zone in kDefaultZones) {
    final idx = zone.dispensers.indexWhere((d) => d.id.trim() == dispenserId.trim());
    if (idx != -1) {
      final old = zone.dispensers[idx];
      zone.dispensers[idx] = old.copyWith(
        status: DispenserStatus.supplied,
        bottleCount: bottleCount,
        lastSupplyInfo: 'Hoy ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')} • $bottleCount garrafones',
        alertMessage: '',
      );
      return true;
    }
  }
  return false;
}

class ZoneDispenserEntry {
  final String zoneName;
  final DispenserItem dispenser;

  const ZoneDispenserEntry({
    required this.zoneName,
    required this.dispenser,
  });
}

List<ZoneDispenserEntry> getAllDispensersWithZone() {
  final List<ZoneDispenserEntry> list = [];
  for (final zone in kDefaultZones) {
    for (final dispenser in zone.dispensers) {
      list.add(ZoneDispenserEntry(zoneName: zone.name, dispenser: dispenser));
    }
  }
  return list;
}

/// Datos iniciales con las 6 zonas principales del sistema.
/// La suma total de despachadores da exactamente 50 (37 abastecidos, 13 pendientes),
/// alineado al 100% con los indicadores del panel de control.
final List<ZoneItem> kDefaultZones = [
  ZoneItem(
    name: 'Producción',
    subtitle: 'Nave principal y líneas de ensamble',
    dispensers: [
      DispenserItem(
        id: '#023',
        brand: 'EcoWater',
        model: 'E-200',
        serialNumber: 'EW-88219',
        status: DispenserStatus.supplied,
        lastSupplyInfo: 'Hoy 10:30 AM • 2 garrafones',
        bottleCount: 2,
      ),
      DispenserItem(
        id: '#024',
        brand: 'AquaPro',
        model: 'X-100',
        serialNumber: 'AP-55410',
        status: DispenserStatus.pending,
        lastSupplyInfo: 'Ayer 14:00 PM',
        bottleCount: 0,
        alertMessage: 'Nivel bajo • Requiere 2 garrafones',
      ),
      DispenserItem(
        id: '#025',
        brand: 'Oasis',
        model: 'Titan 50',
        serialNumber: 'OS-11029',
        status: DispenserStatus.supplied,
        lastSupplyInfo: 'Hoy 08:15 AM • 3 garrafones',
        bottleCount: 3,
      ),
      DispenserItem(
        id: '#026',
        brand: 'EcoWater',
        model: 'E-200',
        serialNumber: 'EW-99312',
        status: DispenserStatus.supplied,
        lastSupplyInfo: 'Hoy 11:45 AM • 2 garrafones',
        bottleCount: 2,
      ),
      DispenserItem(
        id: '#027',
        brand: 'PureWater',
        model: 'PW-Ultra',
        serialNumber: 'PW-33018',
        status: DispenserStatus.pending,
        lastSupplyInfo: 'Hace 2 días',
        bottleCount: 0,
        alertMessage: 'Garrafón vacío',
      ),
      DispenserItem(
        id: '#028',
        brand: 'AquaPro',
        model: 'X-200',
        serialNumber: 'AP-77812',
        status: DispenserStatus.supplied,
        lastSupplyInfo: 'Hoy 09:20 AM • 2 garrafones',
        bottleCount: 2,
      ),
      DispenserItem(
        id: '#029',
        brand: 'EcoWater',
        model: 'E-150',
        serialNumber: 'EW-44510',
        status: DispenserStatus.supplied,
        lastSupplyInfo: 'Hoy 12:10 PM • 2 garrafones',
        bottleCount: 2,
      ),
      DispenserItem(
        id: '#030',
        brand: 'Oasis',
        model: 'Titan 50',
        serialNumber: 'OS-99104',
        status: DispenserStatus.pending,
        lastSupplyInfo: 'Ayer 18:30 PM',
        bottleCount: 0,
        alertMessage: 'Pendiente de reabastecimiento',
      ),
      DispenserItem(
        id: '#031',
        brand: 'EcoWater',
        model: 'E-200',
        serialNumber: 'EW-12984',
        status: DispenserStatus.supplied,
        lastSupplyInfo: 'Hoy 07:50 AM • 2 garrafones',
        bottleCount: 2,
      ),
      DispenserItem(
        id: '#032',
        brand: 'AquaPro',
        model: 'X-100',
        serialNumber: 'AP-66723',
        status: DispenserStatus.supplied,
        lastSupplyInfo: 'Hoy 10:05 AM • 2 garrafones',
        bottleCount: 2,
      ),
      DispenserItem(
        id: '#033',
        brand: 'PureWater',
        model: 'PW-Touch',
        serialNumber: 'PW-88123',
        status: DispenserStatus.supplied,
        lastSupplyInfo: 'Hoy 11:15 AM • 1 garrafón',
        bottleCount: 1,
      ),
      DispenserItem(
        id: '#034',
        brand: 'EcoWater',
        model: 'E-300',
        serialNumber: 'EW-66512',
        status: DispenserStatus.pending,
        lastSupplyInfo: 'Ayer 15:40 PM',
        bottleCount: 0,
        alertMessage: 'Nivel crítico',
      ),
      DispenserItem(
        id: '#035',
        brand: 'Oasis',
        model: 'Slim 20',
        serialNumber: 'OS-44312',
        status: DispenserStatus.supplied,
        lastSupplyInfo: 'Hoy 08:40 AM • 2 garrafones',
        bottleCount: 2,
      ),
      DispenserItem(
        id: '#036',
        brand: 'AquaPro',
        model: 'X-100',
        serialNumber: 'AP-22194',
        status: DispenserStatus.supplied,
        lastSupplyInfo: 'Hoy 09:55 AM • 2 garrafones',
        bottleCount: 2,
      ),
      DispenserItem(
        id: '#037',
        brand: 'EcoWater',
        model: 'E-200',
        serialNumber: 'EW-77123',
        status: DispenserStatus.supplied,
        lastSupplyInfo: 'Hoy 12:45 PM • 2 garrafones',
        bottleCount: 2,
      ),
    ],
  ),
  ZoneItem(
    name: 'Almacén',
    subtitle: 'Área de logística y carga',
    dispensers: [
      DispenserItem(
        id: '#018',
        brand: 'EcoWater',
        model: 'E-100',
        serialNumber: 'EW-33412',
        status: DispenserStatus.supplied,
        lastSupplyInfo: 'Hoy 09:10 AM • 2 garrafones',
        bottleCount: 2,
      ),
      DispenserItem(
        id: '#019',
        brand: 'PureWater',
        model: 'PW-Pro',
        serialNumber: 'PW-44819',
        status: DispenserStatus.supplied,
        lastSupplyInfo: 'Hoy 10:40 AM • 2 garrafones',
        bottleCount: 2,
      ),
      DispenserItem(
        id: '#020',
        brand: 'AquaPro',
        model: 'X-200',
        serialNumber: 'AP-99014',
        status: DispenserStatus.supplied,
        lastSupplyInfo: 'Hoy 11:20 AM • 1 garrafón',
        bottleCount: 1,
      ),
      DispenserItem(
        id: '#021',
        brand: 'Oasis',
        model: 'Titan 50',
        serialNumber: 'OS-22831',
        status: DispenserStatus.supplied,
        lastSupplyInfo: 'Hoy 08:30 AM • 2 garrafones',
        bottleCount: 2,
      ),
      DispenserItem(
        id: '#022',
        brand: 'EcoWater',
        model: 'E-200',
        serialNumber: 'EW-55102',
        status: DispenserStatus.supplied,
        lastSupplyInfo: 'Hoy 12:00 PM • 2 garrafones',
        bottleCount: 2,
      ),
      DispenserItem(
        id: '#042',
        brand: 'AquaPro',
        model: 'X-100',
        serialNumber: 'AP-11209',
        status: DispenserStatus.supplied,
        lastSupplyInfo: 'Hoy 07:30 AM • 2 garrafones',
        bottleCount: 2,
      ),
      DispenserItem(
        id: '#043',
        brand: 'PureWater',
        model: 'PW-Touch',
        serialNumber: 'PW-66718',
        status: DispenserStatus.supplied,
        lastSupplyInfo: 'Hoy 11:00 AM • 2 garrafones',
        bottleCount: 2,
      ),
      DispenserItem(
        id: '#044',
        brand: 'Oasis',
        model: 'Slim 20',
        serialNumber: 'OS-77123',
        status: DispenserStatus.supplied,
        lastSupplyInfo: 'Hoy 09:45 AM • 2 garrafones',
        bottleCount: 2,
      ),
    ],
  ),
  ZoneItem(
    name: 'Taller',
    subtitle: 'Área de mantenimiento mecánico',
    dispensers: [
      DispenserItem(
        id: '#013',
        brand: 'AquaPro',
        model: 'X-200',
        serialNumber: 'AP-33219',
        status: DispenserStatus.supplied,
        lastSupplyInfo: 'Hoy 08:00 AM • 2 garrafones',
        bottleCount: 2,
      ),
      DispenserItem(
        id: '#014',
        brand: 'EcoWater',
        model: 'E-200',
        serialNumber: 'EW-44109',
        status: DispenserStatus.supplied,
        lastSupplyInfo: 'Hoy 10:15 AM • 2 garrafones',
        bottleCount: 2,
      ),
      DispenserItem(
        id: '#015',
        brand: 'PureWater',
        model: 'PW-Pro',
        serialNumber: 'PW-99014',
        status: DispenserStatus.pending,
        lastSupplyInfo: 'Ayer 16:00 PM',
        bottleCount: 0,
        alertMessage: 'Garrafón vacío • Falta abastecer',
      ),
      DispenserItem(
        id: '#016',
        brand: 'Oasis',
        model: 'Titan 50',
        serialNumber: 'OS-33102',
        status: DispenserStatus.pending,
        lastSupplyInfo: 'Ayer 17:30 PM',
        bottleCount: 0,
        alertMessage: 'Nivel crítico',
      ),
      DispenserItem(
        id: '#017',
        brand: 'AquaPro',
        model: 'X-100',
        serialNumber: 'AP-88410',
        status: DispenserStatus.pending,
        lastSupplyInfo: 'Hace 2 días',
        bottleCount: 0,
        alertMessage: 'Sin servicio actual',
      ),
      DispenserItem(
        id: '#045',
        brand: 'EcoWater',
        model: 'E-150',
        serialNumber: 'EW-22194',
        status: DispenserStatus.pending,
        lastSupplyInfo: 'Ayer 12:00 PM',
        bottleCount: 0,
        alertMessage: 'Falta reabastecer',
      ),
    ],
  ),
  ZoneItem(
    name: 'Oficinas',
    subtitle: 'Edificio administrativo y ventas',
    dispensers: [
      DispenserItem(
        id: '#005',
        brand: 'Oasis',
        model: 'Slim 20',
        serialNumber: 'OS-55410',
        status: DispenserStatus.supplied,
        lastSupplyInfo: 'Hoy 09:00 AM • 2 garrafones',
        bottleCount: 2,
      ),
      DispenserItem(
        id: '#006',
        brand: 'PureWater',
        model: 'PW-Touch',
        serialNumber: 'PW-11928',
        status: DispenserStatus.supplied,
        lastSupplyInfo: 'Hoy 12:00 PM • 2 garrafones',
        bottleCount: 2,
      ),
      DispenserItem(
        id: '#007',
        brand: 'EcoWater',
        model: 'E-300',
        serialNumber: 'EW-77412',
        status: DispenserStatus.supplied,
        lastSupplyInfo: 'Hoy 08:30 AM • 2 garrafones',
        bottleCount: 2,
      ),
      DispenserItem(
        id: '#008',
        brand: 'AquaPro',
        model: 'X-100',
        serialNumber: 'AP-66319',
        status: DispenserStatus.supplied,
        lastSupplyInfo: 'Hoy 10:45 AM • 2 garrafones',
        bottleCount: 2,
      ),
      DispenserItem(
        id: '#009',
        brand: 'Oasis',
        model: 'Slim 20',
        serialNumber: 'OS-88219',
        status: DispenserStatus.supplied,
        lastSupplyInfo: 'Hoy 11:30 AM • 2 garrafones',
        bottleCount: 2,
      ),
      DispenserItem(
        id: '#010',
        brand: 'PureWater',
        model: 'PW-Touch',
        serialNumber: 'PW-44109',
        status: DispenserStatus.supplied,
        lastSupplyInfo: 'Hoy 07:45 AM • 2 garrafones',
        bottleCount: 2,
      ),
      DispenserItem(
        id: '#011',
        brand: 'EcoWater',
        model: 'E-200',
        serialNumber: 'EW-99014',
        status: DispenserStatus.supplied,
        lastSupplyInfo: 'Hoy 09:30 AM • 2 garrafones',
        bottleCount: 2,
      ),
      DispenserItem(
        id: '#012',
        brand: 'AquaPro',
        model: 'X-200',
        serialNumber: 'AP-55102',
        status: DispenserStatus.supplied,
        lastSupplyInfo: 'Hoy 10:15 AM • 2 garrafones',
        bottleCount: 2,
      ),
      DispenserItem(
        id: '#046',
        brand: 'Oasis',
        model: 'Slim 20',
        serialNumber: 'OS-11209',
        status: DispenserStatus.supplied,
        lastSupplyInfo: 'Hoy 12:15 PM • 2 garrafones',
        bottleCount: 2,
      ),
      DispenserItem(
        id: '#047',
        brand: 'EcoWater',
        model: 'E-100',
        serialNumber: 'EW-66718',
        status: DispenserStatus.pending,
        lastSupplyInfo: 'Ayer 15:00 PM',
        bottleCount: 0,
        alertMessage: 'Falta 1 garrafón',
      ),
    ],
  ),
  ZoneItem(
    name: 'Mantenimiento',
    subtitle: 'Almacén de refacciones y cuartos técnicos',
    dispensers: [
      DispenserItem(
        id: '#038',
        brand: 'AquaPro',
        model: 'Industrial X',
        serialNumber: 'AP-99412',
        status: DispenserStatus.supplied,
        lastSupplyInfo: 'Hoy 08:15 AM • 2 garrafones',
        bottleCount: 2,
      ),
      DispenserItem(
        id: '#039',
        brand: 'EcoWater',
        model: 'E-200',
        serialNumber: 'EW-33819',
        status: DispenserStatus.pending,
        lastSupplyInfo: 'Ayer 13:30 PM',
        bottleCount: 0,
        alertMessage: 'Falta abastecer • Urgente',
      ),
      DispenserItem(
        id: '#040',
        brand: 'PureWater',
        model: 'PW-Pro',
        serialNumber: 'PW-55014',
        status: DispenserStatus.pending,
        lastSupplyInfo: 'Ayer 16:45 PM',
        bottleCount: 0,
        alertMessage: 'Garrafón vacío',
      ),
      DispenserItem(
        id: '#041',
        brand: 'Oasis',
        model: 'Titan 50',
        serialNumber: 'OS-88102',
        status: DispenserStatus.pending,
        lastSupplyInfo: 'Hace 2 días',
        bottleCount: 0,
        alertMessage: 'Nivel bajo',
      ),
      DispenserItem(
        id: '#048',
        brand: 'AquaPro',
        model: 'X-100',
        serialNumber: 'AP-44194',
        status: DispenserStatus.pending,
        lastSupplyInfo: 'Ayer 17:00 PM',
        bottleCount: 0,
        alertMessage: 'Falta abastecer',
      ),
    ],
  ),
  ZoneItem(
    name: 'Calidad',
    subtitle: 'Laboratorio y control de procesos',
    dispensers: [
      DispenserItem(
        id: '#001',
        brand: 'EcoWater',
        model: 'E-200',
        serialNumber: 'EW-11209',
        status: DispenserStatus.supplied,
        lastSupplyInfo: 'Hoy 07:45 AM • 2 garrafones',
        bottleCount: 2,
      ),
      DispenserItem(
        id: '#002',
        brand: 'AquaPro',
        model: 'X-100',
        serialNumber: 'AP-66718',
        status: DispenserStatus.supplied,
        lastSupplyInfo: 'Hoy 10:15 AM • 2 garrafones',
        bottleCount: 2,
      ),
      DispenserItem(
        id: '#003',
        brand: 'PureWater',
        model: 'PW-Ultra',
        serialNumber: 'PW-77123',
        status: DispenserStatus.supplied,
        lastSupplyInfo: 'Hoy 11:30 AM • 2 garrafones',
        bottleCount: 2,
      ),
      DispenserItem(
        id: '#004',
        brand: 'Oasis',
        model: 'Slim 20',
        serialNumber: 'OS-99014',
        status: DispenserStatus.supplied,
        lastSupplyInfo: 'Hoy 08:50 AM • 2 garrafones',
        bottleCount: 2,
      ),
      DispenserItem(
        id: '#049',
        brand: 'EcoWater',
        model: 'E-300',
        serialNumber: 'EW-55410',
        status: DispenserStatus.supplied,
        lastSupplyInfo: 'Hoy 12:20 PM • 2 garrafones',
        bottleCount: 2,
      ),
      DispenserItem(
        id: '#050',
        brand: 'AquaPro',
        model: 'X-200',
        serialNumber: 'AP-33018',
        status: DispenserStatus.supplied,
        lastSupplyInfo: 'Hoy 09:15 AM • 2 garrafones',
        bottleCount: 2,
      ),
    ],
  ),
];
