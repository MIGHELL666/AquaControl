import '../models/zone_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://xfcqwigswbylrlcfwrkq.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_Ix_XQVDINwvkaP8bz2N6Uw_yB_MDunY';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      // ignore: deprecated_member_use
      anonKey: supabaseAnonKey,
    );
    await syncAllFromSupabase();
  }

  static SupabaseClient get client => Supabase.instance.client;

  /// Descarga y sincroniza la información de Supabase a la aplicación
  static Future<void> syncAllFromSupabase() async {
    try {
      await Future.wait([
        syncClientsFromSupabase(),
        syncWorkersFromSupabase(),
        syncZonesFromSupabase(),
      ]);
      await syncDispensersFromSupabase();
    } catch (_) {}
  }

  /// Cargar clientes desde Supabase (Fusión inteligente: no sobreescribe ni borra clientes locales)
  static Future<void> syncClientsFromSupabase() async {
    try {
      final List<dynamic> rows = await client.from('clients').select();
      if (rows.isNotEmpty) {
        for (final row in rows) {
          final clientName = row['company_name']?.toString() ?? '';
          if (clientName.isEmpty) continue;
          final cId = row['id']?.toString() ?? 'CLI-${row['code'] ?? '001'}';

          final newClient = ClientItem(
            id: cId,
            companyName: clientName,
            razonSocial: row['razon_social']?.toString() ?? '',
            rfc: row['rfc']?.toString() ?? '',
            contactPerson: row['contact_person']?.toString() ?? '',
            phone: row['phone']?.toString() ?? '',
            email: row['email']?.toString() ?? '',
            domicilio: row['domicilio']?.toString() ?? '',
            calle: row['calle']?.toString() ?? '',
            numero: row['numero']?.toString() ?? '',
            cp: row['cp']?.toString() ?? '',
            colonia: row['colonia']?.toString() ?? '',
            ciudad: row['ciudad']?.toString() ?? '',
            pais: row['pais']?.toString() ?? 'México',
            address: row['address']?.toString() ?? '',
            activeDispensers: (row['active_dispensers'] as num?)?.toInt() ?? 0,
            deliveryFrequency:
                row['delivery_frequency']?.toString() ?? 'Semanal',
            status: row['status']?.toString() ?? 'Activo',
            notes: row['notes']?.toString() ?? '',
            pricePerBottle:
                (row['price_per_bottle'] as num?)?.toDouble() ?? 35.0,
            initialBottles: (row['initial_bottles'] as num?)?.toInt() ?? 10,
            racksCount: (row['racks_count'] as num?)?.toInt() ?? 1,
            rackCapacity: (row['rack_capacity'] as num?)?.toInt() ?? 8,
            hasQrScanning: row['has_qr_scanning'] as bool? ?? true,
            zoneNames: (row['client_zones'] is List)
                ? (row['client_zones'] as List)
                      .map((e) => e.toString())
                      .toList()
                : const <String>[],
          );

          final existingIdx = kDefaultClients.indexWhere(
            (c) =>
                c.id == cId ||
                c.companyName.toLowerCase() == clientName.toLowerCase(),
          );
          if (existingIdx != -1) {
            // Preservar asignaciones locales de despachadores si ya las tiene
            final existing = kDefaultClients[existingIdx];
            kDefaultClients[existingIdx] = newClient.copyWith(
              assignedDispenserIds: existing.assignedDispenserIds.isNotEmpty
                  ? existing.assignedDispenserIds
                  : newClient.assignedDispenserIds,
            );
          } else {
            kDefaultClients.add(newClient);
          }
        }
      }
    } catch (_) {}
  }

  /// Carga el catálogo global de zonas sin reemplazar los despachadores locales.
  static Future<void> syncZonesFromSupabase() async {
    try {
      final List<dynamic> rows = await client.from('zones').select();
      for (final row in rows) {
        final name = row['name']?.toString().trim() ?? '';
        if (name.isEmpty) continue;
        final index = kDefaultZones.indexWhere(
          (zone) => zone.name.trim().toLowerCase() == name.toLowerCase(),
        );
        if (index == -1) {
          addZone(
            ZoneItem(
              name: name,
              subtitle: row['subtitle']?.toString() ?? '',
              dispensers: const [],
            ),
          );
        } else {
          kDefaultZones[index].subtitle = row['subtitle']?.toString() ?? '';
        }
      }
    } catch (_) {}
  }

  /// Cargar trabajadores desde Supabase (Fusión inteligente: no sobreescribe ni borra trabajadores locales)
  static Future<void> syncWorkersFromSupabase() async {
    try {
      final List<dynamic> rows = await client.from('workers').select();
      if (rows.isNotEmpty) {
        for (final row in rows) {
          final empNum = row['employee_number']?.toString() ?? '';
          if (empNum == 'EMP-ADMIN') continue; // El admin se autentica aparte

          final assignedClients = (row['assigned_clients'] is List)
              ? (row['assigned_clients'] as List)
                    .map((e) => e.toString())
                    .toList()
              : <String>[];

          final w = WorkerItem(
            id: row['id']?.toString() ?? 'WRK-$empNum',
            name: row['name']?.toString() ?? '',
            employeeNumber: empNum,
            phone: row['phone']?.toString() ?? '',
            email: row['email']?.toString() ?? '',
            assignedZone: row['assigned_zone']?.toString() ?? 'General',
            shift: row['shift']?.toString() ?? 'General',
            status: row['status']?.toString() ?? 'Activo',
            password: row['password']?.toString() ?? 'AquaPass2026',
            assignedClients: assignedClients,
          );

          final existingIdx = kDefaultWorkers.indexWhere(
            (worker) => worker.employeeNumber == empNum || worker.id == w.id,
          );
          if (existingIdx != -1) {
            kDefaultWorkers[existingIdx] = w;
          } else {
            kDefaultWorkers.add(w);
          }
        }
      }
    } catch (_) {}
  }

  /// Cargar despachadores desde Supabase
  static Future<void> syncDispensersFromSupabase() async {
    try {
      final List<dynamic> rows = await client.from('dispensers').select();
      if (rows.isNotEmpty) {
        for (final row in rows) {
          final dispId = row['id']?.toString() ?? '';
          final brand = row['brand']?.toString() ?? '';
          final serial = row['serial_number']?.toString() ?? '';
          final zone = row['zone_name']?.toString() ?? 'General';
          final isActive = row['is_active'] as bool? ?? true;

          final rawStatus =
              row['status']?.toString().toLowerCase() ?? 'pending';
          final DispenserStatus status;
          if (rawStatus == 'supplied') {
            status = DispenserStatus.supplied;
          } else if (rawStatus == 'resupplied') {
            status = DispenserStatus.resupplied;
          } else {
            status = DispenserStatus.pending;
          }

          DateTime? lastSuppliedDate;
          final rawDate = row['last_supplied_at'] ?? row['updated_at'];
          if (rawDate != null) {
            lastSuppliedDate = DateTime.tryParse(rawDate.toString())?.toLocal();
          }

          final disp = DispenserItem(
            id: dispId,
            brand: brand,
            model: row['model']?.toString() ?? 'Estándar',
            serialNumber: serial,
            qrToken: row['qr_token']?.toString() ?? '',
            clientId: row['client_id']?.toString() ?? '',
            bottleCount: row['bottle_count'] != null
                ? int.tryParse(row['bottle_count'].toString()) ?? 1
                : 1,
            status: status,
            lastSupplyInfo:
                row['last_supply_info']?.toString() ??
                (status == DispenserStatus.pending
                    ? 'Pendiente de abastecer'
                    : 'Registrado'),
            isActive: isActive,
            lastSuppliedDate: lastSuppliedDate,
          );

          // Verificar si ya existe en las zonas locales
          bool exists = false;
          for (final z in kDefaultZones) {
            final idx = z.dispensers.indexWhere((d) => d.id == dispId);
            if (idx != -1) {
              z.dispensers[idx] = disp;
              exists = true;
              break;
            }
          }
          if (!exists) {
            addDispenser(zone, disp);
          }
        }
      }
    } catch (_) {}
  }
}

final supabase = Supabase.instance.client;
