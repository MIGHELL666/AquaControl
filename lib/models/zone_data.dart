import 'dart:ui' show Offset;
import '../services/supabase_service.dart';

enum DispenserStatus { supplied, resupplied, pending }

class DispenserItem {
  final String id;
  final String brand;
  final String model;
  final String serialNumber;
  final String qrToken;
  final String clientId;
  final DispenserStatus status;
  final String lastSupplyInfo;
  final int bottleCount;
  final String alertMessage;

  final bool isActive;
  final DateTime? lastSuppliedDate;

  const DispenserItem({
    required this.id,
    required this.brand,
    required this.model,
    required this.serialNumber,
    this.qrToken = '',
    this.clientId = '',
    required this.status,
    required this.lastSupplyInfo,
    this.bottleCount = 1,
    this.alertMessage = '',
    this.isActive = true,
    this.lastSuppliedDate,
  });

  bool get isSuppliedToday {
    if (status != DispenserStatus.supplied &&
        status != DispenserStatus.resupplied) {
      return false;
    }
    if (lastSuppliedDate == null) {
      // Si la descripción contiene "Hoy", fue hoy
      return lastSupplyInfo.toLowerCase().contains('hoy');
    }
    final now = DateTime.now();
    return lastSuppliedDate!.year == now.year &&
        lastSuppliedDate!.month == now.month &&
        lastSuppliedDate!.day == now.day;
  }

  bool get isSupplied => isSuppliedToday;
  bool get isPending => !isSuppliedToday;
  bool get isResupplied =>
      status == DispenserStatus.resupplied && isSuppliedToday;

  DispenserStatus get effectiveStatus =>
      isSuppliedToday ? status : DispenserStatus.pending;

  DispenserItem copyWith({
    String? id,
    String? brand,
    String? model,
    String? serialNumber,
    String? qrToken,
    String? clientId,
    DispenserStatus? status,
    String? lastSupplyInfo,
    int? bottleCount,
    String? alertMessage,
    bool? isActive,
    DateTime? lastSuppliedDate,
  }) {
    return DispenserItem(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      serialNumber: serialNumber ?? this.serialNumber,
      qrToken: qrToken ?? this.qrToken,
      clientId: clientId ?? this.clientId,
      status: status ?? this.status,
      lastSupplyInfo: lastSupplyInfo ?? this.lastSupplyInfo,
      bottleCount: bottleCount ?? this.bottleCount,
      alertMessage: alertMessage ?? this.alertMessage,
      isActive: isActive ?? this.isActive,
      lastSuppliedDate: lastSuppliedDate ?? this.lastSuppliedDate,
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

  double get effectivePricePerBottle {
    if (pricePerBottle > 0) return pricePerBottle;
    if (clientName.isNotEmpty) {
      final idx = kDefaultClients.indexWhere(
        (c) =>
            c.companyName.trim().toLowerCase() ==
            clientName.trim().toLowerCase(),
      );
      if (idx != -1) return kDefaultClients[idx].pricePerBottle;
    }
    return 0.0;
  }

  double get totalPrice => bottles * effectivePricePerBottle;

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
  static WorkerItem? currentWorker;

  static bool get hasClient =>
      activeClientName != null && activeClientName!.isNotEmpty;

  static ClientItem? get activeClient {
    if (!hasClient) return null;
    final idx = kDefaultClients.indexWhere(
      (c) =>
          c.companyName.trim().toLowerCase() ==
          activeClientName!.trim().toLowerCase(),
    );
    if (idx != -1) return kDefaultClients[idx];
    return null;
  }

  static bool get isQrScanEnabled {
    final client = activeClient;
    return client?.hasQrScanning ?? true;
  }

  static void clear() {
    activeClientName = null;
    activePricePerBottle = 0.0;
    currentWorker = null;
  }

  static void setActiveClient(ClientItem client) {
    activeClientName = client.companyName;
    activePricePerBottle = client.pricePerBottle;
  }
}

/// Historial global de abastecimientos y reabastecimientos
final List<SupplyRecord> kSupplyRecords = [];

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
  final int initialBottles;
  final int racksCount;
  final int rackCapacity;
  final bool hasQrScanning;
  final List<String> zoneNames;

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
    this.initialBottles = 10,
    this.racksCount = 1,
    this.rackCapacity = 8,
    this.hasQrScanning = true,
    this.zoneNames = const [],
  });

  bool get isActive => status.toLowerCase() == 'activo';
  bool get isInactive => !isActive;

  int get dispenserCount => assignedDispenserIds.isNotEmpty
      ? assignedDispenserIds.length
      : activeDispensers;

  int get totalRackCapacity => racksCount * rackCapacity;

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
    int? initialBottles,
    int? racksCount,
    int? rackCapacity,
    bool? hasQrScanning,
    List<String>? zoneNames,
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
      initialBottles: initialBottles ?? this.initialBottles,
      racksCount: racksCount ?? this.racksCount,
      rackCapacity: rackCapacity ?? this.rackCapacity,
      hasQrScanning: hasQrScanning ?? this.hasQrScanning,
      zoneNames: zoneNames ?? this.zoneNames,
    );
  }
}

/// Catálogo de empresas clientes
final List<ClientItem> kDefaultClients = [];

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

/// Obtiene la lista de despachadores con su zona para el cliente seleccionado
List<ZoneDispenserEntry> getDispensersWithZoneForClient(String? clientName) {
  if (clientName == null || clientName.trim().isEmpty) {
    return getAllDispensersWithZone();
  }
  final cleanName = clientName.trim().toLowerCase();
  final client = kDefaultClients.firstWhere(
    (c) => c.companyName.trim().toLowerCase() == cleanName,
    orElse: () => const ClientItem(
      id: '',
      companyName: '',
      contactPerson: '',
      phone: '',
      email: '',
    ),
  );
  if (client.id.isEmpty) {
    return getAllDispensersWithZone();
  }

  final List<ZoneDispenserEntry> list = [];
  for (final zone in kDefaultZones) {
    for (final dispenser in zone.dispensers) {
      final isAssigned =
          client.assignedDispenserIds.any(
            (id) => id.trim() == dispenser.id.trim(),
          ) ||
          dispenser.clientId == client.id;
      final isAllowedZone =
          !client.hasQrScanning ||
          client.zoneNames.isEmpty ||
          client.zoneNames.any(
            (name) =>
                name.trim().toLowerCase() == zone.name.trim().toLowerCase(),
          );
      if (isAssigned && isAllowedZone) {
        list.add(ZoneDispenserEntry(zoneName: zone.name, dispenser: dispenser));
      }
    }
  }
  return list;
}

/// Busca a qué cliente pertenece un despachador determinado
ClientItem? getClientForDispenser(String dispenserId) {
  final cleanId = dispenserId.trim();
  for (final client in kDefaultClients) {
    if (client.assignedDispenserIds.any((id) => id.trim() == cleanId) ||
        kDefaultZones.any(
          (zone) => zone.dispensers.any(
            (dispenser) =>
                dispenser.id.trim() == cleanId &&
                dispenser.clientId == client.id,
          ),
        )) {
      return client;
    }
  }
  return null;
}

/// Reasigna despachadores a un cliente, asegurando que no queden duplicados en otros clientes
/// y que los despachadores asignados al cliente inicien en estado 'pending' (Pendientes de abastecer)
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

  for (final zone in kDefaultZones) {
    for (var i = 0; i < zone.dispensers.length; i++) {
      final dispenser = zone.dispensers[i];
      final owningClient = kDefaultClients.cast<ClientItem?>().firstWhere(
        (client) => client!.assignedDispenserIds.any(
          (id) => id.trim() == dispenser.id.trim(),
        ),
        orElse: () => null,
      );
      zone.dispensers[i] = dispenser.copyWith(clientId: owningClient?.id ?? '');
    }
  }

  // Al asignar despachadores al cliente, deben figurar como pendientes de abastecer
  for (final id in dispenserIds) {
    final cleanId = id.trim();
    for (final zone in kDefaultZones) {
      final idx = zone.dispensers.indexWhere((d) => d.id.trim() == cleanId);
      if (idx != -1) {
        final current = zone.dispensers[idx];
        zone.dispensers[idx] = current.copyWith(
          status: DispenserStatus.pending,
          lastSupplyInfo: 'Pendiente de abastecer',
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
  final String password;

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
    this.password = 'AquaPass2026',
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
    String? password,
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
      password: password ?? this.password,
    );
  }
}

/// Catálogo de trabajadores
final List<WorkerItem> kDefaultWorkers = [];

void addWorker(WorkerItem worker) {
  kDefaultWorkers.insert(0, worker);
}

bool updateWorker(String workerId, WorkerItem updatedWorker) {
  final idx = kDefaultWorkers.indexWhere(
    (w) =>
        w.id.trim() == workerId.trim() ||
        w.employeeNumber.trim() == workerId.trim(),
  );
  if (idx != -1) {
    kDefaultWorkers[idx] = updatedWorker;
    return true;
  }
  return false;
}

bool toggleWorkerStatus(String workerId) {
  final idx = kDefaultWorkers.indexWhere(
    (w) =>
        w.id.trim() == workerId.trim() ||
        w.employeeNumber.trim() == workerId.trim(),
  );
  if (idx != -1) {
    final current = kDefaultWorkers[idx];
    final newStatus = current.status.toLowerCase() == 'activo'
        ? 'Inactivo'
        : 'Activo';
    kDefaultWorkers[idx] = current.copyWith(status: newStatus);
    return true;
  }
  return false;
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
  final zoneIdx = kDefaultZones.indexWhere(
    (z) => z.name.toLowerCase() == zoneName.toLowerCase(),
  );
  if (zoneIdx == -1) return false;
  final zone = kDefaultZones[zoneIdx];
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
  final currentIdx = kDefaultZones.indexWhere(
    (z) => z.name.toLowerCase() == currentZoneName.toLowerCase(),
  );
  if (currentIdx == -1) return false;
  final currentZone = kDefaultZones[currentIdx];

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
    final targetIdx = kDefaultZones.indexWhere(
      (z) => z.name.toLowerCase() == targetZoneName.toLowerCase(),
    );
    if (targetIdx != -1) {
      kDefaultZones[targetIdx].dispensers.insert(0, updatedItem);
      return true;
    } else {
      kDefaultZones.add(
        ZoneItem(name: targetZoneName, subtitle: '', dispensers: [updatedItem]),
      );
      return true;
    }
  }
}

void addDispenser(String zoneName, DispenserItem newItem) {
  final idx = kDefaultZones.indexWhere(
    (z) => z.name.toLowerCase() == zoneName.toLowerCase(),
  );
  if (idx != -1) {
    kDefaultZones[idx].dispensers.insert(0, newItem);
  } else {
    kDefaultZones.add(
      ZoneItem(name: zoneName, subtitle: '', dispensers: [newItem]),
    );
  }
}

bool toggleDispenserStatus(String dispenserId) {
  for (final zone in kDefaultZones) {
    final idx = zone.dispensers.indexWhere(
      (d) => d.id.trim() == dispenserId.trim(),
    );
    if (idx != -1) {
      final old = zone.dispensers[idx];
      zone.dispensers[idx] = old.copyWith(isActive: !old.isActive);
      return true;
    }
  }
  return false;
}

Future<bool> markDispenserSupplied(
  String dispenserId,
  int bottleCount, {
  String recipientName = 'Responsable de Zona',
  List<Offset>? signaturePoints,
  String workerName = 'Juan Pérez',
  String clientName = '',
  double pricePerBottle = 0.0,
}) async {
  for (final zone in kDefaultZones) {
    final idx = zone.dispensers.indexWhere(
      (d) => d.id.trim() == dispenserId.trim(),
    );
    if (idx != -1) {
      final old = zone.dispensers[idx];
      final now = DateTime.now();
      final supplyInfo =
          'Hoy ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} • $bottleCount garrafones';
      try {
        await SupabaseService.client
            .from('dispensers')
            .update({
              'status': 'supplied',
              'bottle_count': bottleCount,
              'last_supply_info': supplyInfo,
            })
            .eq('id', dispenserId.trim());
      } catch (_) {
        return false;
      }

      zone.dispensers[idx] = old.copyWith(
        status: DispenserStatus.supplied,
        bottleCount: bottleCount,
        lastSuppliedDate: now,
        lastSupplyInfo: supplyInfo,
      );
      kSupplyRecords.insert(
        0,
        SupplyRecord(
          id: 'SR-${DateTime.now().millisecondsSinceEpoch}',
          dispenserId: dispenserId,
          zoneName: zone.name,
          bottles: bottleCount,
          timestamp: now,
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
Future<bool> resupplyDispenser(
  String dispenserId,
  int addedBottles, {
  String recipientName = 'Responsable de Zona',
  List<Offset>? signaturePoints,
  String workerName = 'Juan Pérez',
  String clientName = '',
  double pricePerBottle = 0.0,
}) async {
  for (final zone in kDefaultZones) {
    final idx = zone.dispensers.indexWhere(
      (d) => d.id.trim() == dispenserId.trim(),
    );
    if (idx != -1) {
      final old = zone.dispensers[idx];
      final newTotal = old.bottleCount + addedBottles;
      final now = DateTime.now();
      final supplyInfo =
          'Reabastecido hoy ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} (+$addedBottles)';
      try {
        await SupabaseService.client
            .from('dispensers')
            .update({
              'status': 'resupplied',
              'bottle_count': newTotal,
              'last_supply_info': supplyInfo,
            })
            .eq('id', dispenserId.trim());
      } catch (_) {
        return false;
      }

      zone.dispensers[idx] = old.copyWith(
        status: DispenserStatus.resupplied,
        bottleCount: newTotal,
        lastSuppliedDate: now,
        lastSupplyInfo: supplyInfo,
      );
      kSupplyRecords.insert(
        0,
        SupplyRecord(
          id: 'SR-${DateTime.now().millisecondsSinceEpoch}',
          dispenserId: dispenserId,
          zoneName: zone.name,
          bottles: addedBottles,
          timestamp: now,
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
final List<ZoneItem> kDefaultZones = [];
