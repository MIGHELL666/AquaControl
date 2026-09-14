import 'package:flutter_test/flutter_test.dart';
import 'package:aqua_control/models/zone_data.dart';

void main() {
  test('Test supply and resupply updates counts and records', () {
    final initialRecordsCount = kSupplyRecords.length;
    final initialBottles = getTotalBottlesCount();

    // Mark supply on a dispenser
    final successSupply = markDispenserSupplied(
      '#024',
      2,
      recipientName: 'Carlos Test',
      workerName: 'Juan Pérez',
    );
    expect(successSupply, isTrue);
    expect(kSupplyRecords.length, initialRecordsCount + 1);
    expect(kSupplyRecords.first.dispenserId, '#024');
    expect(kSupplyRecords.first.isResupply, isFalse);
    expect(kSupplyRecords.first.recipientName, 'Carlos Test');
    expect(getTotalBottlesCount(), initialBottles + 2);

    // Resupply round
    final successResupply = resupplyDispenser(
      '#024',
      3,
      recipientName: 'Mariana Test',
      workerName: 'Juan Pérez',
    );
    expect(successResupply, isTrue);
    expect(kSupplyRecords.length, initialRecordsCount + 2);
    expect(kSupplyRecords.first.isResupply, isTrue);
    expect(kSupplyRecords.first.bottles, 3);
    expect(kSupplyRecords.first.recipientName, 'Mariana Test');
    expect(getTotalBottlesCount(), initialBottles + 2 + 3);
  });

  test('Test add client and add worker with assigned clients', () {
    final initialClients = kDefaultClients.length;
    final initialWorkers = kDefaultWorkers.length;

    addClient(const ClientItem(
      id: 'CLI-TEST',
      companyName: 'Empresa de Prueba',
      contactPerson: 'Lic. Test',
      phone: '55 1111 2222',
      email: 'test@empresa.com',
      address: 'Parque Industrial Test',
    ));

    expect(kDefaultClients.length, initialClients + 1);
    expect(kDefaultClients.first.companyName, 'Empresa de Prueba');

    addWorker(const WorkerItem(
      id: 'WRK-T1',
      name: 'Trabajador Individual Test',
      employeeNumber: 'EMP-9001',
      phone: '55 0000 0001',
      email: 't1@aquacontrol.com',
      assignedZone: 'Producción',
      assignedClients: ['Empresa de Prueba', 'Bimbo Planta Norte'],
    ));

    expect(kDefaultWorkers.length, initialWorkers + 1);
    expect(kDefaultWorkers.first.name, 'Trabajador Individual Test');
    expect(kDefaultWorkers.first.assignedClients.length, 2);
    expect(kDefaultWorkers.first.assignedClients.contains('Empresa de Prueba'), isTrue);
  });
}
