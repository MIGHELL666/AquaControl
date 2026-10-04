import 'dart:ui' show Offset;

enum DispenserStatus { supplied, resupplied, pending }

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

  bool get isSupplied =>
      status == DispenserStatus.supplied ||
      status == DispenserStatus.resupplied;
  bool get isPending => status == DispenserStatus.pending;
  bool get isResupplied => status == DispenserStatus.resupplied;

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
  String name;
  String subtitle;
  List<DispenserItem> dispensers;

  ZoneItem({
    required this.name,
    required this.subtitle,
    required this.dispensers,
  });

  int get totalDispensers => dispensers.length;
  int get suppliedCount => dispensers.where((d) => d.isSupplied).length;
  int get pendingCount => dispensers.where((d) => d.isPending).length;
  int get resuppliedCount => dispensers.where((d) => d.isResupplied).length;
  bool get isFullySupplied => pendingCount == 0;
  int get totalBottles => dispensers.fold(0, (sum, d) => sum + d.bottleCount);
}

/// Registro detallado de un abastecimiento o reabastecimiento con firma
class SupplyRecord {
  final String id;
  final String dispenserId;
  final String zoneName;
  final int bottles;
  final DateTime timestamp;
  final String workerName;
  final bool isResupply;
  final String recipientName;
  final List<Offset>? signaturePoints;
  final String clientName;
  final double pricePerBottle;

  const SupplyRecord({
    required this.id,
    required this.dispenserId,
    required this.zoneName,
    required this.bottles,
    required this.timestamp,
    required this.workerName,
    required this.isResupply,
    required this.recipientName,
    this.signaturePoints,
    this.clientName = '',
    this.pricePerBottle = 0.0,
  });

  double get totalPrice => bottles * pricePerBottle;

  String get dateFormatted =>
      '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year}';

  String get timeFormatted =>
      '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
}

/// Sesión activa del trabajador (cliente/empresa que se está abasteciendo)
/// Actualizada al iniciar sesión o cuando el trabajador cambia la selección.
class WorkerSession {
  static String? activeClientName;
  static double activePricePerBottle = 0.0;

  static bool get hasClient =>
      activeClientName != null && activeClientName!.isNotEmpty;

  static void clear() {
    activeClientName = null;
    activePricePerBottle = 0.0;
  }

  static void setActiveClient(ClientItem client) {
    activeClientName = client.companyName;
    activePricePerBottle = client.pricePerBottle;
  }
}

/// Historial global de abastecimientos y reabastecimientos
final List<SupplyRecord> kSupplyRecords = [
  SupplyRecord(
    id: 'SR-101',
    dispenserId: '#023',
    zoneName: 'Producción',
    bottles: 2,
    timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
    workerName: 'Juan Pérez',
    isResupply: false,
    recipientName: 'Ing. Roberto Méndez',
    clientName: 'Bimbo Planta Norte',
    pricePerBottle: 38.0,
  ),
  SupplyRecord(
    id: 'SR-102',
    dispenserId: '#026',
    zoneName: 'Producción',
    bottles: 2,
    timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
    workerName: 'Juan Pérez',
    isResupply: true,
    recipientName: 'Mariana Silva',
    clientName: 'Bimbo Planta Norte',
    pricePerBottle: 38.0,
  ),
  SupplyRecord(
    id: 'SR-103',
    dispenserId: '#001',
    zoneName: 'Calidad',
    bottles: 2,
    timestamp: DateTime.now().subtract(const Duration(hours: 4, minutes: 10)),
    workerName: 'Carlos López',
    isResupply: false,
    recipientName: 'Dr. Alejandro Ruiz',
    clientName: 'Hospital San José',
    pricePerBottle: 42.0,
  ),
  SupplyRecord(
    id: 'SR-104',
    dispenserId: '#005',
    zoneName: 'Almacén',
    bottles: 3,
    timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    workerName: 'Pedro García',
    isResupply: false,
    recipientName: 'Laura Torres',
    clientName: 'Manufacturas Sigma',
    pricePerBottle: 35.0,
  ),
  SupplyRecord(
    id: 'SR-105',
    dispenserId: '#007',
    zoneName: 'Almacén',
    bottles: 2,
    timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
    workerName: 'Juan Pérez',
    isResupply: true,
    recipientName: 'Carlos Mendoza',
    clientName: 'Manufacturas Sigma',
    pricePerBottle: 35.0,
  ),
  SupplyRecord(
    id: 'SR-106',
    dispenserId: '#013',
    zoneName: 'Taller',
    bottles: 2,
    timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
    workerName: 'Carlos López',
    isResupply: false,
    recipientName: 'Esteban Morales',
    clientName: 'TechCorp Soluciones',
    pricePerBottle: 32.0,
  ),
  SupplyRecord(
    id: 'SR-107',
    dispenserId: '#018',
    zoneName: 'Oficinas',
    bottles: 2,
    timestamp: DateTime.now().subtract(const Duration(days: 3, hours: 1)),
    workerName: 'Pedro García',
    isResupply: true,
    recipientName: 'Sofía Valenzuela',
    clientName: 'TechCorp Soluciones',
    pricePerBottle: 32.0,
  ),
  SupplyRecord(
    id: 'SR-108',
    dispenserId: '#025',
    zoneName: 'Producción',
    bottles: 3,
    timestamp: DateTime.now().subtract(const Duration(days: 4, hours: 6)),
    workerName: 'Juan Pérez',
    isResupply: false,
    recipientName: 'Ing. Roberto Méndez',
    clientName: 'Logística & Distribución Bajío',
    pricePerBottle: 30.0,
  ),
];

/// Modelo de Empresa Cliente
class ClientItem {
  final String id;
  final String companyName;
  final String razonSocial;
  final String rfc;
  final String contactPerson;
  final String phone;
  final String email;
  final String domicilio;
  final String calle;
  final String numero;
  final String cp;
  final String colonia;
  final String ciudad;
  final String pais;
  final String address;
  final int activeDispensers;
  final List<String> assignedDispenserIds;
  final String deliveryFrequency;
  final String status;
  final String notes;
  final double pricePerBottle;

  const ClientItem({
    required this.id,
    required this.companyName,
    this.razonSocial = '',
    this.rfc = '',
    required this.contactPerson,
    required this.phone,
    required this.email,
    this.domicilio = '',
    this.calle = '',
    this.numero = '',
    this.cp = '',
    this.colonia = '',
    this.ciudad = '',
    this.pais = 'México',
    this.address = '',
    this.activeDispensers = 5,
    this.assignedDispenserIds = const [],
    this.deliveryFrequency = 'Semanal',
    this.status = 'Activo',
    this.notes = '',
    this.pricePerBottle = 35.0,
  });

  bool get isActive => status.toLowerCase() == 'activo';
  bool get isInactive => !isActive;

  int get dispenserCount =>
      assignedDispenserIds.isNotEmpty ? assignedDispenserIds.length : activeDispensers;

  String get fullAddress {
    final parts = <String>[];
    if (calle.isNotEmpty || numero.isNotEmpty) {
      parts.add('$calle $numero'.trim());
    }
    if (colonia.isNotEmpty) parts.add('Col. $colonia');
    if (cp.isNotEmpty) parts.add('C.P. $cp');
    if (ciudad.isNotEmpty) parts.add(ciudad);
    if (pais.isNotEmpty && pais != 'México') parts.add(pais);
    if (parts.isEmpty) return address;
    return parts.join(', ');
  }

  ClientItem copyWith({
    String? id,
    String? companyName,
    String? razonSocial,
    String? rfc,
    String? contactPerson,
    String? phone,
    String? email,
    String? domicilio,
    String? calle,
    String? numero,
    String? cp,
    String? colonia,
    String? ciudad,
    String? pais,
    String? address,
    int? activeDispensers,
    List<String>? assignedDispenserIds,
    String? deliveryFrequency,
    String? status,
    String? notes,
    double? pricePerBottle,
  }) {
    return ClientItem(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      razonSocial: razonSocial ?? this.razonSocial,
      rfc: rfc ?? this.rfc,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      domicilio: domicilio ?? this.domicilio,
      calle: calle ?? this.calle,
      numero: numero ?? this.numero,
      cp: cp ?? this.cp,
      colonia: colonia ?? this.colonia,
      ciudad: ciudad ?? this.ciudad,
      pais: pais ?? this.pais,
      address: address ?? this.address,
      activeDispensers: activeDispensers ?? this.activeDispensers,
      assignedDispenserIds: assignedDispenserIds ?? this.assignedDispenserIds,
      deliveryFrequency: deliveryFrequency ?? this.deliveryFrequency,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      pricePerBottle: pricePerBottle ?? this.pricePerBottle,
    );
  }
}

/// Catálogo de empresas clientes
final List<ClientItem> kDefaultClients = [
  const ClientItem(
    id: 'CLI-001',
    companyName: 'Bimbo Planta Norte',
    razonSocial: 'Grupo Bimbo S.A.B. de C.V.',
    rfc: 'BIM900101XYZ',
    contactPerson: 'Lic. Fernando Garza',
    phone: '55 4123 8900',
    email: 'compras@bimbo-norte.com',
    domicilio: 'Planta de Producción Norte, Nave 2',
    calle: 'Parque Industrial Las Américas',
    numero: '#140',
    cp: '01210',
    colonia: 'Las Américas',
    ciudad: 'Ciudad de México',
    pais: 'México',
    address: 'Parque Industrial Las Américas #140, Col. Las Américas, C.P. 01210, Ciudad de México',
    activeDispensers: 12,
    assignedDispenserIds: [
      '#023', '#024', '#025', '#026', '#027', '#028',
      '#029', '#030', '#031', '#032', '#033', '#034'
    ],
    deliveryFrequency: 'Diario',
    status: 'Activo',
    notes: 'Requiere entrega a las 8:00 AM en puertas 2 y 4.',
    pricePerBottle: 38.0,
  ),
  const ClientItem(
    id: 'CLI-002',
    companyName: 'Manufacturas Sigma',
    razonSocial: 'Sigma Alimentos Manufactura S.A. de C.V.',
    rfc: 'SMA850315ABC',
    contactPerson: 'Ing. Patricia Ortega',
    phone: '55 8970 3341',
    email: 'almacen@sigma-ind.mx',
    domicilio: 'Nave Industrial C, Caseta 3',
    calle: 'Av. Las Industrias',
    numero: '#520',
    cp: '66220',
    colonia: 'Zona Industrial',
    ciudad: 'Monterrey, N.L.',
    pais: 'México',
    address: 'Av. Las Industrias #520, Nave C, Col. Zona Industrial, C.P. 66220, Monterrey, N.L.',
    activeDispensers: 8,
    assignedDispenserIds: [
      '#035', '#036', '#037', '#018', '#019', '#020', '#021', '#022'
    ],
    deliveryFrequency: 'Cada 2 días',
    status: 'Activo',
    notes: 'Revisar filtros de despachador #014 periódicamente.',
    pricePerBottle: 35.0,
  ),
  const ClientItem(
    id: 'CLI-003',
    companyName: 'Hospital San José',
    razonSocial: 'Hospital San José TecSalud S.A. de C.V.',
    rfc: 'HSJ921104K98',
    contactPerson: 'Dr. Alejandro Ruiz',
    phone: '55 2290 1156',
    email: 'suministros@hospitalsanjose.org',
    domicilio: 'Torre Médica de Especialidades',
    calle: 'Calzada Médica',
    numero: '#890',
    cp: '44100',
    colonia: 'Sector Salud',
    ciudad: 'Guadalajara, Jal.',
    pais: 'México',
    address: 'Calzada Médica #890, Col. Sector Salud, C.P. 44100, Guadalajara, Jal.',
    activeDispensers: 15,
    assignedDispenserIds: [
      '#005', '#006', '#007', '#008', '#009', '#010',
      '#011', '#012', '#046', '#047', '#038', '#039',
      '#040', '#041', '#048'
    ],
    deliveryFrequency: 'Diario',
    status: 'Activo',
    notes: 'Áreas de terapia intensiva y urgencias prioritarias.',
    pricePerBottle: 42.0,
  ),
  const ClientItem(
    id: 'CLI-004',
    companyName: 'TechCorp Soluciones',
    razonSocial: 'TechCorp Soluciones Digitales S. de R.L. de C.V.',
    rfc: 'TCS1406209J1',
    contactPerson: 'Ing. David Salinas',
    phone: '55 7712 4433',
    email: 'contacto@techcorp.com',
    domicilio: 'Torre Corporativa Piso 6',
    calle: 'Av. Insurgentes Sur',
    numero: '#1602',
    cp: '03900',
    colonia: 'Crédito Constructor',
    ciudad: 'Ciudad de México',
    pais: 'México',
    address: 'Av. Insurgentes Sur #1602 Piso 6, Col. Crédito Constructor, C.P. 03900, Ciudad de México',
    activeDispensers: 6,
    assignedDispenserIds: [
      '#001', '#002', '#003', '#004', '#049', '#050'
    ],
    deliveryFrequency: 'Semanal',
    status: 'Activo',
    notes: 'Acceso por recepción con gafete de visitante.',
    pricePerBottle: 32.0,
  ),
  const ClientItem(
    id: 'CLI-005',
    companyName: 'Logística & Distribución Bajío',
    razonSocial: 'Distribución y Carga del Bajío S.A. de C.V.',
    rfc: 'DCB170810772',
    contactPerson: 'Martín Escobedo',
    phone: '55 6601 9922',
    email: 'm.escobedo@bajiodist.com',
    domicilio: 'Centro de Distribución Bajío, Andén 5',
    calle: 'Carretera Federal 45',
    numero: 'Km 24',
    cp: '37290',
    colonia: 'Parque Logístico Bajío',
    ciudad: 'León, Gto.',
    pais: 'México',
    address: 'Carretera Federal 45 Km 24, Col. Parque Logístico Bajío, C.P. 37290, León, Gto.',
    activeDispensers: 9,
    assignedDispenserIds: [
      '#042', '#043', '#044', '#013', '#014', '#015', '#016', '#017', '#045'
    ],
    deliveryFrequency: 'Cada 2 días',
    status: 'Activo',
    pricePerBottle: 30.0,
  ),
];

void addClient(ClientItem client) {
  kDefaultClients.insert(0, client);
}

void updateClient(ClientItem updatedClient) {
  final idx = kDefaultClients.indexWhere((c) => c.id == updatedClient.id);
  if (idx != -1) kDefaultClients[idx] = updatedClient;
}

void deleteClient(String clientId) {
  kDefaultClients.removeWhere((c) => c.id == clientId);
}

/// Movimientos de abastecimiento registrados para este cliente
int getClientSupplyRecordsCount(ClientItem client) {
  return kSupplyRecords.where((r) {
    final recordClient = r.clientName.trim().toLowerCase();
    final cName = client.companyName.trim().toLowerCase();
    final rName = client.razonSocial.trim().toLowerCase();
    return recordClient == cName || (rName.isNotEmpty && recordClient == rName);
  }).length;
}

/// Determina si un cliente puede eliminarse (sólo si no tiene movimientos en el historial)
bool canDeleteClient(ClientItem client) {
  return getClientSupplyRecordsCount(client) == 0;
}

bool clientHasMovements(ClientItem client) {
  return getClientSupplyRecordsCount(client) > 0;
}

/// Cambia el estado de un cliente entre Activo e Inactivo
bool toggleClientStatus(String clientId) {
  final idx = kDefaultClients.indexWhere((c) => c.id == clientId);
  if (idx != -1) {
    final old = kDefaultClients[idx];
    final newStatus = old.status == 'Activo' ? 'Inactivo' : 'Activo';
    kDefaultClients[idx] = old.copyWith(status: newStatus);
    return true;
  }
  return false;
}

/// Obtiene la lista de despachadores asignados a un cliente específico
List<DispenserItem> getDispensersForClient(ClientItem client) {
  final List<DispenserItem> list = [];
  for (final zone in kDefaultZones) {
    for (final dispenser in zone.dispensers) {
      if (client.assignedDispenserIds.contains(dispenser.id.trim())) {
        list.add(dispenser);
      }
    }
  }
  return list;
}

/// Busca a qué cliente pertenece un despachador determinado
ClientItem? getClientForDispenser(String dispenserId) {
  final cleanId = dispenserId.trim();
  for (final client in kDefaultClients) {
    if (client.assignedDispenserIds.any((id) => id.trim() == cleanId)) {
      return client;
    }
  }
  return null;
}

/// Reasigna despachadores a un cliente, asegurando que no queden duplicados en otros clientes
void assignDispensersToClient(String clientId, List<String> dispenserIds) {
  for (int i = 0; i < kDefaultClients.length; i++) {
    final client = kDefaultClients[i];
    if (client.id == clientId) {
      kDefaultClients[i] = client.copyWith(
        assignedDispenserIds: dispenserIds,
        activeDispensers: dispenserIds.length,
      );
    } else {
      final updatedIds = client.assignedDispenserIds
          .where((id) => !dispenserIds.contains(id))
          .toList();
      if (updatedIds.length != client.assignedDispenserIds.length) {
        kDefaultClients[i] = client.copyWith(
          assignedDispenserIds: updatedIds,
          activeDispensers: updatedIds.length,
        );
      }
    }
  }
}

/// Métricas de despachadores y garrafones para KPI cards
class ClientKpiMetrics {
  final int totalDispensers;
  final int suppliedCount;
  final int pendingCount;
  final int totalBottles;

  const ClientKpiMetrics({
    required this.totalDispensers,
    required this.suppliedCount,
    required this.pendingCount,
    required this.totalBottles,
  });
}

ClientKpiMetrics getKpisForClient(ClientItem? client) {
  if (client == null) {
    return ClientKpiMetrics(
      totalDispensers: getTotalDispensersCount(),
      suppliedCount: getTotalSuppliedCount(),
      pendingCount: getTotalPendingCount(),
      totalBottles: getTotalBottlesCount(),
    );
  }
  final dispensers = getDispensersForClient(client);
  final total = client.assignedDispenserIds.isNotEmpty
      ? client.assignedDispenserIds.length
      : client.activeDispensers;
  final supplied = dispensers.where((d) => d.isSupplied).length;
  final pending = dispensers.where((d) => d.isPending).length;
  final bottles = dispensers.fold(0, (sum, d) => sum + d.bottleCount);
  return ClientKpiMetrics(
    totalDispensers: total,
    suppliedCount: supplied,
    pendingCount: pending,
    totalBottles: bottles,
  );
}

/// Modelo de Trabajador
class WorkerItem {
  final String id;
  final String name;
  final String employeeNumber;
  final String phone;
  final String email;
  final String assignedZone;
  final String shift;
  final String status;
  final List<String> assignedClients;

  const WorkerItem({
    required this.id,
    required this.name,
    required this.employeeNumber,
    required this.phone,
    required this.email,
    required this.assignedZone,
    this.shift = 'Matutino',
    this.status = 'Activo',
    this.assignedClients = const [],
  });

  WorkerItem copyWith({
    String? id,
    String? name,
    String? employeeNumber,
    String? phone,
    String? email,
    String? assignedZone,
    String? shift,
    String? status,
    List<String>? assignedClients,
  }) {
    return WorkerItem(
      id: id ?? this.id,
      name: name ?? this.name,
      employeeNumber: employeeNumber ?? this.employeeNumber,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      assignedZone: assignedZone ?? this.assignedZone,
      shift: shift ?? this.shift,
      status: status ?? this.status,
      assignedClients: assignedClients ?? this.assignedClients,
    );
  }
}

/// Catálogo de trabajadores
final List<WorkerItem> kDefaultWorkers = [
  const WorkerItem(
    id: 'WRK-001',
    name: 'Juan Pérez',
    employeeNumber: 'EMP-1042',
    phone: '55 1234 5678',
    email: 'juan.perez@aquacontrol.com',
    assignedZone: 'Producción',
    shift: 'Matutino',
    assignedClients: ['Bimbo Planta Norte', 'Manufacturas Sigma', 'Hospital San José', 'TechCorp Soluciones', 'Logística & Distribución Bajío'],
  ),
  const WorkerItem(
    id: 'WRK-002',
    name: 'Carlos López',
    employeeNumber: 'EMP-1045',
    phone: '55 2345 6789',
    email: 'carlos.lopez@aquacontrol.com',
    assignedZone: 'Almacén',
    shift: 'Vespertino',
    assignedClients: ['Bimbo Planta Norte', 'Manufacturas Sigma', 'Hospital San José', 'TechCorp Soluciones', 'Logística & Distribución Bajío'],
  ),
  const WorkerItem(
    id: 'WRK-003',
    name: 'Pedro García',
    employeeNumber: 'EMP-1049',
    phone: '55 3456 7890',
    email: 'pedro.garcia@aquacontrol.com',
    assignedZone: 'Calidad',
    shift: 'Matutino',
    assignedClients: ['Bimbo Planta Norte', 'Manufacturas Sigma', 'Hospital San José', 'TechCorp Soluciones', 'Logística & Distribución Bajío'],
  ),
  const WorkerItem(
    id: 'WRK-004',
    name: 'Miguel Hernández',
    employeeNumber: 'EMP-1053',
    phone: '55 4567 8901',
    email: 'miguel.h@aquacontrol.com',
    assignedZone: 'Oficinas',
    shift: 'Mixto',
    assignedClients: ['Bimbo Planta Norte', 'Manufacturas Sigma', 'Hospital San José', 'TechCorp Soluciones', 'Logística & Distribución Bajío'],
  ),
  const WorkerItem(
    id: 'WRK-005',
    name: 'Lucía Mendoza',
    employeeNumber: 'EMP-1058',
    phone: '55 5678 9012',
    email: 'lucia.m@aquacontrol.com',
    assignedZone: 'Taller',
    shift: 'Matutino',
    assignedClients: ['Bimbo Planta Norte', 'Manufacturas Sigma', 'Hospital San José', 'TechCorp Soluciones', 'Logística & Distribución Bajío'],
  ),
];

void addWorker(WorkerItem worker) {
  kDefaultWorkers.insert(0, worker);
}

// ─── CRUD de Zonas ─────────────────────────────────────────────
void addZone(ZoneItem zone) {
  kDefaultZones.add(zone);
}

bool updateZone(String oldName, ZoneItem updatedZone) {
  final idx = kDefaultZones.indexWhere(
    (z) => z.name.toLowerCase() == oldName.toLowerCase(),
  );
  if (idx != -1) {
    kDefaultZones[idx] = updatedZone;
    return true;
  }
  return false;
}

bool deleteZone(String zoneName) {
  final before = kDefaultZones.length;
  kDefaultZones.removeWhere(
    (z) => z.name.toLowerCase() == zoneName.toLowerCase(),
  );
  return kDefaultZones.length < before;
}

// ─── CRUD de Despachadores ─────────────────────────────────────
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
    final idx = currentZone.dispensers.indexWhere(
      (d) => d.id.trim() == currentDispenserId.trim(),
    );
    if (idx != -1) {
      currentZone.dispensers[idx] = updatedItem;
      return true;
    }
    return false;
  } else {
    currentZone.dispensers.removeWhere(
      (d) => d.id.trim() == currentDispenserId.trim(),
    );
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

bool markDispenserSupplied(
  String dispenserId,
  int bottleCount, {
  String recipientName = 'Responsable de Zona',
  List<Offset>? signaturePoints,
  String workerName = 'Juan Pérez',
  String clientName = '',
  double pricePerBottle = 0.0,
}) {
  for (final zone in kDefaultZones) {
    final idx = zone.dispensers.indexWhere(
      (d) => d.id.trim() == dispenserId.trim(),
    );
    if (idx != -1) {
      final old = zone.dispensers[idx];
      zone.dispensers[idx] = old.copyWith(
        status: DispenserStatus.supplied,
        bottleCount: bottleCount,
        lastSupplyInfo:
            'Hoy ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')} • $bottleCount garrafones',
      );
      kSupplyRecords.insert(
        0,
        SupplyRecord(
          id: 'SR-${DateTime.now().millisecondsSinceEpoch}',
          dispenserId: dispenserId,
          zoneName: zone.name,
          bottles: bottleCount,
          timestamp: DateTime.now(),
          workerName: workerName,
          isResupply: false,
          recipientName: recipientName,
          signaturePoints: signaturePoints,
          clientName: clientName,
          pricePerBottle: pricePerBottle,
        ),
      );
      return true;
    }
  }
  return false;
}

/// Reabastece un despachador sumando o actualizando garrafones en las rondas de trabajo
bool resupplyDispenser(
  String dispenserId,
  int addedBottles, {
  String recipientName = 'Responsable de Zona',
  List<Offset>? signaturePoints,
  String workerName = 'Juan Pérez',
  String clientName = '',
  double pricePerBottle = 0.0,
}) {
  for (final zone in kDefaultZones) {
    final idx = zone.dispensers.indexWhere(
      (d) => d.id.trim() == dispenserId.trim(),
    );
    if (idx != -1) {
      final old = zone.dispensers[idx];
      final newTotal = old.bottleCount + addedBottles;
      zone.dispensers[idx] = old.copyWith(
        status: DispenserStatus.resupplied,
        bottleCount: newTotal,
        lastSupplyInfo:
            'Reabastecido hoy ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')} (+$addedBottles)',
      );
      kSupplyRecords.insert(
        0,
        SupplyRecord(
          id: 'SR-${DateTime.now().millisecondsSinceEpoch}',
          dispenserId: dispenserId,
          zoneName: zone.name,
          bottles: addedBottles,
          timestamp: DateTime.now(),
          workerName: workerName,
          isResupply: true,
          recipientName: recipientName,
          signaturePoints: signaturePoints,
          clientName: clientName,
          pricePerBottle: pricePerBottle,
        ),
      );
      return true;
    }
  }
  return false;
}

int getTotalDispensersCount() {
  return kDefaultZones.fold(0, (sum, z) => sum + z.totalDispensers);
}

int getTotalSuppliedCount() {
  return kDefaultZones.fold(0, (sum, z) => sum + z.suppliedCount);
}

int getTotalPendingCount() {
  return kDefaultZones.fold(0, (sum, z) => sum + z.pendingCount);
}

int getTotalBottlesCount() {
  return kDefaultZones.fold(0, (sum, z) => sum + z.totalBottles);
}

class ZoneDispenserEntry {
  final String zoneName;
  final DispenserItem dispenser;

  const ZoneDispenserEntry({required this.zoneName, required this.dispenser});
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
        status: DispenserStatus.resupplied,
        lastSupplyInfo: 'Reabastecido hoy 11:45 AM (+2)',
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
        status: DispenserStatus.resupplied,
        lastSupplyInfo: 'Reabastecido hoy 12:45 PM (+2)',
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
        status: DispenserStatus.resupplied,
        lastSupplyInfo: 'Reabastecido hoy 12:00 PM (+2)',
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
      ),
      DispenserItem(
        id: '#016',
        brand: 'Oasis',
        model: 'Titan 50',
        serialNumber: 'OS-33102',
        status: DispenserStatus.pending,
        lastSupplyInfo: 'Ayer 17:30 PM',
        bottleCount: 0,
      ),
      DispenserItem(
        id: '#017',
        brand: 'AquaPro',
        model: 'X-100',
        serialNumber: 'AP-88410',
        status: DispenserStatus.pending,
        lastSupplyInfo: 'Hace 2 días',
        bottleCount: 0,
      ),
      DispenserItem(
        id: '#045',
        brand: 'EcoWater',
        model: 'E-150',
        serialNumber: 'EW-22194',
        status: DispenserStatus.pending,
        lastSupplyInfo: 'Ayer 12:00 PM',
        bottleCount: 0,
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
        status: DispenserStatus.resupplied,
        lastSupplyInfo: 'Reabastecido hoy 08:30 AM (+2)',
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
      ),
      DispenserItem(
        id: '#040',
        brand: 'PureWater',
        model: 'PW-Pro',
        serialNumber: 'PW-55014',
        status: DispenserStatus.pending,
        lastSupplyInfo: 'Ayer 16:45 PM',
        bottleCount: 0,
      ),
      DispenserItem(
        id: '#041',
        brand: 'Oasis',
        model: 'Titan 50',
        serialNumber: 'OS-88102',
        status: DispenserStatus.pending,
        lastSupplyInfo: 'Hace 2 días',
        bottleCount: 0,
      ),
      DispenserItem(
        id: '#048',
        brand: 'AquaPro',
        model: 'X-100',
        serialNumber: 'AP-44194',
        status: DispenserStatus.pending,
        lastSupplyInfo: 'Ayer 17:00 PM',
        bottleCount: 0,
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
        status: DispenserStatus.resupplied,
        lastSupplyInfo: 'Reabastecido hoy 12:20 PM (+2)',
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
