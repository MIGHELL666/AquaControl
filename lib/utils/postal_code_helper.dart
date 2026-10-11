/// Helper y catálogo de Códigos Postales de México (SEPOMEX)
/// para autocompletar colonia, ciudad/municipio, estado y país.
library;

class MexicanPostalCodeInfo {
  final String cp;
  final String colonia;
  final String ciudad;
  final String estado;
  final String pais;

  const MexicanPostalCodeInfo({
    required this.cp,
    required this.colonia,
    required this.ciudad,
    required this.estado,
    this.pais = 'México',
  });

  String get fullCityState => estado.isNotEmpty ? '$ciudad, $estado' : ciudad;
}

/// Catálogo local instantáneo de códigos postales comunes y representativos
final Map<String, MexicanPostalCodeInfo> _kExactPostalCodes = {
  // CDMX
  '01210': const MexicanPostalCodeInfo(
    cp: '01210',
    colonia: 'Las Américas',
    ciudad: 'Álvaro Obregón',
    estado: 'Ciudad de México',
  ),
  '03900': const MexicanPostalCodeInfo(
    cp: '03900',
    colonia: 'Crédito Constructor',
    ciudad: 'Benito Juárez',
    estado: 'Ciudad de México',
  ),
  '03100': const MexicanPostalCodeInfo(
    cp: '03100',
    colonia: 'Del Valle Centro',
    ciudad: 'Benito Juárez',
    estado: 'Ciudad de México',
  ),
  '06600': const MexicanPostalCodeInfo(
    cp: '06600',
    colonia: 'Juárez',
    ciudad: 'Cuauhtémoc',
    estado: 'Ciudad de México',
  ),
  '06700': const MexicanPostalCodeInfo(
    cp: '06700',
    colonia: 'Roma Norte',
    ciudad: 'Cuauhtémoc',
    estado: 'Ciudad de México',
  ),
  '11000': const MexicanPostalCodeInfo(
    cp: '11000',
    colonia: 'Lomas de Chapultepec',
    ciudad: 'Miguel Hidalgo',
    estado: 'Ciudad de México',
  ),
  '11560': const MexicanPostalCodeInfo(
    cp: '11560',
    colonia: 'Polanco',
    ciudad: 'Miguel Hidalgo',
    estado: 'Ciudad de México',
  ),
  '01000': const MexicanPostalCodeInfo(
    cp: '01000',
    colonia: 'San Ángel',
    ciudad: 'Álvaro Obregón',
    estado: 'Ciudad de México',
  ),
  '04000': const MexicanPostalCodeInfo(
    cp: '04000',
    colonia: 'Del Carmen',
    ciudad: 'Coyoacán',
    estado: 'Ciudad de México',
  ),

  // Nuevo León
  '66220': const MexicanPostalCodeInfo(
    cp: '66220',
    colonia: 'Zona Industrial',
    ciudad: 'San Pedro Garza García',
    estado: 'Nuevo León',
  ),
  '64000': const MexicanPostalCodeInfo(
    cp: '64000',
    colonia: 'Centro',
    ciudad: 'Monterrey',
    estado: 'Nuevo León',
  ),
  '64700': const MexicanPostalCodeInfo(
    cp: '64700',
    colonia: 'Roma',
    ciudad: 'Monterrey',
    estado: 'Nuevo León',
  ),
  '66450': const MexicanPostalCodeInfo(
    cp: '66450',
    colonia: 'Industrial San Nicolás',
    ciudad: 'San Nicolás de los Garza',
    estado: 'Nuevo León',
  ),

  // Jalisco
  '44100': const MexicanPostalCodeInfo(
    cp: '44100',
    colonia: 'Sector Salud',
    ciudad: 'Guadalajara',
    estado: 'Jalisco',
  ),
  '44600': const MexicanPostalCodeInfo(
    cp: '44600',
    colonia: 'Ladrón de Guevara',
    ciudad: 'Guadalajara',
    estado: 'Jalisco',
  ),
  '45050': const MexicanPostalCodeInfo(
    cp: '45050',
    colonia: 'Ciudad del Sol',
    ciudad: 'Zapopan',
    estado: 'Jalisco',
  ),
  '45110': const MexicanPostalCodeInfo(
    cp: '45110',
    colonia: 'Zona Industrial Belenes',
    ciudad: 'Zapopan',
    estado: 'Jalisco',
  ),

  // Guanajuato
  '37290': const MexicanPostalCodeInfo(
    cp: '37290',
    colonia: 'Parque Logístico Bajío',
    ciudad: 'León',
    estado: 'Guanajuato',
  ),
  '37000': const MexicanPostalCodeInfo(
    cp: '37000',
    colonia: 'Centro',
    ciudad: 'León',
    estado: 'Guanajuato',
  ),
  '36500': const MexicanPostalCodeInfo(
    cp: '36500',
    colonia: 'Centro',
    ciudad: 'Irapuato',
    estado: 'Guanajuato',
  ),
  '38000': const MexicanPostalCodeInfo(
    cp: '38000',
    colonia: 'Centro Industrial',
    ciudad: 'Celaya',
    estado: 'Guanajuato',
  ),

  // Querétaro
  '76000': const MexicanPostalCodeInfo(
    cp: '76000',
    colonia: 'Centro',
    ciudad: 'Santiago de Querétaro',
    estado: 'Querétaro',
  ),
  '76120': const MexicanPostalCodeInfo(
    cp: '76120',
    colonia: 'Zona Industrial Benito Juárez',
    ciudad: 'Querétaro',
    estado: 'Querétaro',
  ),
  '76246': const MexicanPostalCodeInfo(
    cp: '76246',
    colonia: 'El Marqués Industrial',
    ciudad: 'El Marqués',
    estado: 'Querétaro',
  ),

  // Puebla
  '72000': const MexicanPostalCodeInfo(
    cp: '72000',
    colonia: 'Centro',
    ciudad: 'Puebla',
    estado: 'Puebla',
  ),
  '72260': const MexicanPostalCodeInfo(
    cp: '72260',
    colonia: 'Corredor Industrial La Ciénega',
    ciudad: 'Puebla',
    estado: 'Puebla',
  ),

  // Estado de México
  '50000': const MexicanPostalCodeInfo(
    cp: '50000',
    colonia: 'Centro',
    ciudad: 'Toluca',
    estado: 'Estado de México',
  ),
  '54000': const MexicanPostalCodeInfo(
    cp: '54000',
    colonia: 'Tlalnepantla Centro',
    ciudad: 'Tlalnepantla de Baz',
    estado: 'Estado de México',
  ),
  '53000': const MexicanPostalCodeInfo(
    cp: '53000',
    colonia: 'Naucalpan Centro',
    ciudad: 'Naucalpan de Juárez',
    estado: 'Estado de México',
  ),
  '54730': const MexicanPostalCodeInfo(
    cp: '54730',
    colonia: 'Parque Industrial Cuautitlán',
    ciudad: 'Cuautitlán Izcalli',
    estado: 'Estado de México',
  ),

  // Coahuila
  '25000': const MexicanPostalCodeInfo(
    cp: '25000',
    colonia: 'Zona Centro',
    ciudad: 'Saltillo',
    estado: 'Coahuila',
  ),
  '27000': const MexicanPostalCodeInfo(
    cp: '27000',
    colonia: 'Centro',
    ciudad: 'Torreón',
    estado: 'Coahuila',
  ),

  // Baja California & Sonora & Chihuahua
  '22000': const MexicanPostalCodeInfo(
    cp: '22000',
    colonia: 'Zona Urbana Río',
    ciudad: 'Tijuana',
    estado: 'Baja California',
  ),
  '31000': const MexicanPostalCodeInfo(
    cp: '31000',
    colonia: 'Centro',
    ciudad: 'Chihuahua',
    estado: 'Chihuahua',
  ),
  '32000': const MexicanPostalCodeInfo(
    cp: '32000',
    colonia: 'Centro',
    ciudad: 'Ciudad Juárez',
    estado: 'Chihuahua',
  ),
  '83000': const MexicanPostalCodeInfo(
    cp: '83000',
    colonia: 'Centro',
    ciudad: 'Hermosillo',
    estado: 'Sonora',
  ),

  // Yucatán & Quintana Roo
  '97000': const MexicanPostalCodeInfo(
    cp: '97000',
    colonia: 'Centro',
    ciudad: 'Mérida',
    estado: 'Yucatán',
  ),
  '77500': const MexicanPostalCodeInfo(
    cp: '77500',
    colonia: 'Centro',
    ciudad: 'Cancún / Benito Juárez',
    estado: 'Quintana Roo',
  ),

  // Aguascalientes & San Luis Potosí
  '20000': const MexicanPostalCodeInfo(
    cp: '20000',
    colonia: 'Centro',
    ciudad: 'Aguascalientes',
    estado: 'Aguascalientes',
  ),
  '78000': const MexicanPostalCodeInfo(
    cp: '78000',
    colonia: 'Centro',
    ciudad: 'San Luis Potosí',
    estado: 'San Luis Potosí',
  ),
};

/// Resuelve el estado y ciudad aproximada según el prefijo oficial de 2 dígitos del C.P. mexicano
String _getStateFromPrefix(int prefix) {
  if (prefix >= 1 && prefix <= 16) return 'Ciudad de México';
  if (prefix == 20) return 'Aguascalientes';
  if (prefix >= 21 && prefix <= 22) return 'Baja California';
  if (prefix == 23) return 'Baja California Sur';
  if (prefix == 24) return 'Campeche';
  if (prefix >= 25 && prefix <= 27) return 'Coahuila';
  if (prefix == 28) return 'Colima';
  if (prefix >= 29 && prefix <= 30) return 'Chiapas';
  if (prefix >= 31 && prefix <= 33) return 'Chihuahua';
  if (prefix >= 34 && prefix <= 35) return 'Durango';
  if (prefix >= 36 && prefix <= 38) return 'Guanajuato';
  if (prefix >= 39 && prefix <= 41) return 'Guerrero';
  if (prefix >= 42 && prefix <= 43) return 'Hidalgo';
  if (prefix >= 44 && prefix <= 49) return 'Jalisco';
  if (prefix >= 50 && prefix <= 57) return 'Estado de México';
  if (prefix >= 58 && prefix <= 61) return 'Michoacán';
  if (prefix == 62) return 'Morelos';
  if (prefix == 63) return 'Nayarit';
  if (prefix >= 64 && prefix <= 67) return 'Nuevo León';
  if (prefix >= 68 && prefix <= 71) return 'Oaxaca';
  if (prefix >= 72 && prefix <= 75) return 'Puebla';
  if (prefix == 76) return 'Querétaro';
  if (prefix == 77) return 'Quintana Roo';
  if (prefix >= 78 && prefix <= 79) return 'San Luis Potosí';
  if (prefix >= 80 && prefix <= 82) return 'Sinaloa';
  if (prefix >= 83 && prefix <= 85) return 'Sonora';
  if (prefix == 86) return 'Tabasco';
  if (prefix >= 87 && prefix <= 89) return 'Tamaulipas';
  if (prefix == 90) return 'Tlaxcala';
  if (prefix >= 91 && prefix <= 96) return 'Veracruz';
  if (prefix == 97) return 'Yucatán';
  if (prefix >= 98 && prefix <= 99) return 'Zacatecas';
  return 'México';
}

/// Busca y resuelve información geográfica para un código postal mexicano de 5 dígitos.
MexicanPostalCodeInfo? lookupMexicanPostalCode(String rawCp) {
  final clean = rawCp.replaceAll(RegExp(r'\D'), '').trim();
  if (clean.length != 5) return null;

  // 1. Coincidencia exacta en catálogo
  if (_kExactPostalCodes.containsKey(clean)) {
    return _kExactPostalCodes[clean];
  }

  // 2. Coincidencia por prefijo oficial SEPOMEX
  final prefix = int.tryParse(clean.substring(0, 2));
  if (prefix != null) {
    final estado = _getStateFromPrefix(prefix);
    return MexicanPostalCodeInfo(
      cp: clean,
      colonia: 'Sector C.P. $clean',
      ciudad: estado,
      estado: estado,
      pais: 'México',
    );
  }

  return null;
}
