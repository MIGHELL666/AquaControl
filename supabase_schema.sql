-- ==============================================================================
-- AQUACONTROL - ESQUEMA COMPLETO DE BASE DE DATOS PARA SUPABASE
-- ==============================================================================
-- Instrucciones:
-- 1. Ve a tu proyecto en Supabase (https://supabase.com/dashboard).
-- 2. Abre el "SQL Editor" en el menú lateral izquierdo.
-- 3. Crea una "New Query", pega todo el contenido de este archivo y presiona "Run".
-- ==============================================================================

-- 1. EXTENSIONES RECOMENDADAS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ==============================================================================
-- 2. TIPOS ENUMERADOS
-- ==============================================================================

DO $$ BEGIN
  CREATE TYPE dispenser_status AS ENUM ('supplied', 'resupplied', 'pending');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE record_type AS ENUM ('supply', 'resupply');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- ==============================================================================
-- 3. FUNCIÓN REUTILIZABLE PARA ACTUALIZAR 'updated_at'
-- ==============================================================================

CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ==============================================================================
-- 4. TABLA: ZONAS (Áreas o naves de la planta/instalación)
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.zones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  subtitle TEXT DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.zones IS 'Zonas y áreas de distribución física de despachadores';

CREATE TRIGGER tr_zones_updated_at
  BEFORE UPDATE ON public.zones
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

-- ==============================================================================
-- 5. TABLA: EMPRESAS CLIENTE
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.clients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT UNIQUE, -- Ej. CLI-001
  company_name TEXT NOT NULL,
  razon_social TEXT DEFAULT '',
  rfc TEXT DEFAULT '',
  contact_person TEXT NOT NULL DEFAULT '',
  phone TEXT NOT NULL DEFAULT '',
  email TEXT NOT NULL DEFAULT '',
  domicilio TEXT DEFAULT '',
  calle TEXT DEFAULT '',
  numero TEXT DEFAULT '',
  cp TEXT DEFAULT '',
  colonia TEXT DEFAULT '',
  ciudad TEXT DEFAULT '',
  pais TEXT DEFAULT 'México',
  address TEXT DEFAULT '',
  active_dispensers INTEGER DEFAULT 0,
  delivery_frequency TEXT DEFAULT 'Semanal',
  status TEXT NOT NULL DEFAULT 'Activo' CHECK (status IN ('Activo', 'Inactivo')),
  notes TEXT DEFAULT '',
  price_per_bottle NUMERIC(10, 2) NOT NULL DEFAULT 35.00,
  initial_bottles INTEGER NOT NULL DEFAULT 10,
  racks_count INTEGER NOT NULL DEFAULT 1,
  rack_capacity INTEGER NOT NULL DEFAULT 8,
  has_qr_scanning BOOLEAN NOT NULL DEFAULT true,
  client_zones TEXT[] NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.clients IS 'Empresas clientes que contratan el servicio de agua';

CREATE INDEX IF NOT EXISTS idx_clients_company_name ON public.clients (company_name);
CREATE INDEX IF NOT EXISTS idx_clients_status ON public.clients (status);

CREATE TRIGGER tr_clients_updated_at
  BEFORE UPDATE ON public.clients
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

-- ==============================================================================
-- 6. TABLA: DESPACHADORES / DISPENSADORES
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.dispensers (
  id TEXT PRIMARY KEY, -- Identificador único visible, ej: '#001', '#023'
  zone_id UUID REFERENCES public.zones(id) ON DELETE SET NULL,
  zone_name TEXT NOT NULL,
  client_id UUID REFERENCES public.clients(id) ON DELETE SET NULL,
  brand TEXT NOT NULL DEFAULT '',
  model TEXT NOT NULL DEFAULT '',
  serial_number TEXT NOT NULL DEFAULT '',
  qr_token TEXT DEFAULT encode(gen_random_bytes(16), 'hex'),
  status dispenser_status NOT NULL DEFAULT 'pending',
  last_supply_info TEXT DEFAULT '',
  bottle_count INTEGER NOT NULL DEFAULT 2,
  alert_message TEXT DEFAULT '',
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Añadir token exclusivo también en instalaciones que ya tenían la tabla creada.
ALTER TABLE public.dispensers
  ADD COLUMN IF NOT EXISTS qr_token TEXT;

UPDATE public.dispensers
SET qr_token = encode(gen_random_bytes(16), 'hex')
WHERE qr_token IS NULL OR qr_token = '';

ALTER TABLE public.dispensers
  ALTER COLUMN qr_token SET DEFAULT encode(gen_random_bytes(16), 'hex'),
  ALTER COLUMN qr_token SET NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS idx_dispensers_qr_token
  ON public.dispensers (qr_token);

COMMENT ON TABLE public.dispensers IS 'Equipos despachadores de agua instalados';

CREATE INDEX IF NOT EXISTS idx_dispensers_zone_id ON public.dispensers (zone_id);
CREATE INDEX IF NOT EXISTS idx_dispensers_client_id ON public.dispensers (client_id);
CREATE INDEX IF NOT EXISTS idx_dispensers_status ON public.dispensers (status);
CREATE INDEX IF NOT EXISTS idx_dispensers_zone_name ON public.dispensers (zone_name);

CREATE TRIGGER tr_dispensers_updated_at
  BEFORE UPDATE ON public.dispensers
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

-- ==============================================================================
-- 7. TABLA: USUARIOS DEL SISTEMA (ROLES Y CREDENCIALES)
-- ==============================================================================
-- Rol 0: Administrador (ÚNICO en el sistema)
-- Rol 1: Trabajador

CREATE TABLE IF NOT EXISTS public.app_users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  name TEXT NOT NULL,
  role INT NOT NULL DEFAULT 1 CHECK (role IN (0, 1)),
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Asegurar que sólo pueda existir un único usuario con rol = 0 (Administrador)
CREATE UNIQUE INDEX IF NOT EXISTS idx_single_admin_role
  ON public.app_users (role)
  WHERE role = 0;

COMMENT ON TABLE public.app_users IS 'Usuarios autenticables: 0 para Administrador único, 1 para Trabajador';

CREATE TRIGGER tr_app_users_updated_at
  BEFORE UPDATE ON public.app_users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

-- Insertar el Administrador único inicial por defecto si no existe
INSERT INTO public.app_users (email, password, name, role)
VALUES ('admin@aquacontrol.com', 'AquaAdmin2026', 'Administrador General', 0)
ON CONFLICT (email) DO NOTHING;

-- ==============================================================================
-- 8. TABLA: TRABAJADORES / OPERADORES DE RUTA
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.workers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  employee_number TEXT UNIQUE NOT NULL, -- Ej: EMP-001
  name TEXT NOT NULL,
  phone TEXT NOT NULL DEFAULT '',
  email TEXT NOT NULL DEFAULT '',
  assigned_zone TEXT NOT NULL DEFAULT 'Todas las zonas',
  shift TEXT NOT NULL DEFAULT 'Matutino',
  status TEXT NOT NULL DEFAULT 'Activo' CHECK (status IN ('Activo', 'Inactivo')),
  password TEXT NOT NULL DEFAULT 'AquaPass2026',
  assigned_clients TEXT[] NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.workers IS 'Operadores y trabajadores que realizan abastecimientos';

CREATE INDEX IF NOT EXISTS idx_workers_employee_number ON public.workers (employee_number);
CREATE INDEX IF NOT EXISTS idx_workers_status ON public.workers (status);

CREATE TRIGGER tr_workers_updated_at
  BEFORE UPDATE ON public.workers
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

-- ==============================================================================
-- 8. TABLA: HISTORIAL DE ABASTECIMIENTOS Y FIRMAS DIGITALES
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.supply_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  dispenser_id TEXT NOT NULL REFERENCES public.dispensers(id) ON DELETE CASCADE,
  zone_name TEXT NOT NULL,
  client_id UUID REFERENCES public.clients(id) ON DELETE SET NULL,
  client_name TEXT NOT NULL DEFAULT '',
  worker_id UUID REFERENCES public.workers(id) ON DELETE SET NULL,
  worker_name TEXT NOT NULL,
  bottles INTEGER NOT NULL DEFAULT 1,
  is_resupply BOOLEAN NOT NULL DEFAULT false,
  recipient_name TEXT NOT NULL DEFAULT '',
  price_per_bottle NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
  total_price NUMERIC(10, 2) GENERATED ALWAYS AS (bottles * price_per_bottle) STORED,
  signature_points JSONB, -- Array de coordenadas [{x: ..., y: ...}] para reproducir la firma
  signature_image_url TEXT, -- URL pública si la firma se guarda como imagen en Supabase Storage
  timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.supply_records IS 'Historial de suministros y firmas de conformidad';

CREATE INDEX IF NOT EXISTS idx_supply_records_dispenser ON public.supply_records (dispenser_id);
CREATE INDEX IF NOT EXISTS idx_supply_records_client_id ON public.supply_records (client_id);
CREATE INDEX IF NOT EXISTS idx_supply_records_timestamp ON public.supply_records (timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_supply_records_worker_id ON public.supply_records (worker_id);

-- ==============================================================================
-- 9. TRIGGER INTELIGENTE: ACTUALIZAR DESPACHADOR AL REGISTRAR ABASTECIMIENTO
-- ==============================================================================
-- Al registrar una firma/abastecimiento en supply_records, este trigger
-- actualiza automáticamente el estado del despachador a 'supplied' o 'resupplied'.

CREATE OR REPLACE FUNCTION public.after_supply_record_insert()
RETURNS TRIGGER AS $$
DECLARE
  v_info TEXT;
BEGIN
  IF NEW.is_resupply THEN
    v_info := 'Reabastecido hoy ' || to_char(NEW.timestamp, 'HH12:MI AM') || ' (+' || NEW.bottles || ')';
    UPDATE public.dispensers
    SET 
      status = 'resupplied',
      last_supply_info = v_info,
      bottle_count = bottle_count + NEW.bottles,
      updated_at = NOW()
    WHERE id = NEW.dispenser_id;
  ELSE
    v_info := 'Hoy ' || to_char(NEW.timestamp, 'HH12:MI AM') || ' • ' || NEW.bottles || ' garrafón(es)';
    UPDATE public.dispensers
    SET 
      status = 'supplied',
      last_supply_info = v_info,
      bottle_count = NEW.bottles,
      updated_at = NOW()
    WHERE id = NEW.dispenser_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_on_supply_record_inserted ON public.supply_records;
CREATE TRIGGER tr_on_supply_record_inserted
  AFTER INSERT ON public.supply_records
  FOR EACH ROW
  EXECUTE FUNCTION public.after_supply_record_insert();

-- ==============================================================================
-- 10. VISTAS ANALÍTICAS PARA KPIs
-- ==============================================================================

-- Vista de métricas por Empresa Cliente
CREATE OR REPLACE VIEW public.v_client_metrics AS
SELECT 
  c.id AS client_id,
  c.company_name,
  c.status,
  c.price_per_bottle,
  COUNT(d.id) AS total_dispensers,
  COUNT(CASE WHEN d.status IN ('supplied', 'resupplied') THEN 1 END) AS supplied_dispensers,
  COUNT(CASE WHEN d.status = 'pending' THEN 1 END) AS pending_dispensers,
  COALESCE(SUM(d.bottle_count), 0) AS current_bottles_on_site,
  (c.racks_count * c.rack_capacity) AS total_rack_capacity
FROM public.clients c
LEFT JOIN public.dispensers d ON d.client_id = c.id
GROUP BY c.id, c.company_name, c.status, c.price_per_bottle, c.racks_count, c.rack_capacity;

-- Vista de métricas por Zona
CREATE OR REPLACE VIEW public.v_zone_metrics AS
SELECT 
  z.id AS zone_id,
  z.name AS zone_name,
  z.subtitle,
  COUNT(d.id) AS total_dispensers,
  COUNT(CASE WHEN d.status IN ('supplied', 'resupplied') THEN 1 END) AS supplied_count,
  COUNT(CASE WHEN d.status = 'pending' THEN 1 END) AS pending_count,
  COALESCE(SUM(d.bottle_count), 0) AS total_bottles,
  (COUNT(CASE WHEN d.status = 'pending' THEN 1 END) = 0 AND COUNT(d.id) > 0) AS is_fully_supplied
FROM public.zones z
LEFT JOIN public.dispensers d ON d.zone_id = z.id
GROUP BY z.id, z.name, z.subtitle;

-- ==============================================================================
-- 11. HABILITAR ROW LEVEL SECURITY (RLS)
-- ==============================================================================

ALTER TABLE public.zones ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dispensers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.supply_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_users ENABLE ROW LEVEL SECURITY;

-- Políticas de acceso para la aplicación cliente (anon y authenticated)
-- Permite lectura, inserción, actualización y eliminación de forma completa para la app.

-- USUARIOS DEL SISTEMA (ROLES Y LOGIN)
CREATE POLICY "Permitir todo en app_users para anon y auth"
  ON public.app_users FOR ALL
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

-- ZONAS
CREATE POLICY "Permitir todo en zones para anon y auth"
  ON public.zones FOR ALL
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

-- CLIENTES
CREATE POLICY "Permitir todo en clients para anon y auth"
  ON public.clients FOR ALL
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

-- DESPACHADORES
CREATE POLICY "Permitir todo en dispensers para anon y auth"
  ON public.dispensers FOR ALL
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

-- TRABAJADORES
CREATE POLICY "Permitir todo en workers para anon y auth"
  ON public.workers FOR ALL
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

-- HISTORIAL DE ABASTECIMIENTOS
CREATE POLICY "Permitir todo en supply_records para anon y auth"
  ON public.supply_records FOR ALL
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

-- ==============================================================================
-- 12. HABILITAR REALTIME
-- ==============================================================================
-- Permite que la app de Flutter reciba cambios en tiempo real cuando cualquier
-- operador o administrador modifique datos.

DO $$ BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE public.zones;
  ALTER PUBLICATION supabase_realtime ADD TABLE public.clients;
  ALTER PUBLICATION supabase_realtime ADD TABLE public.dispensers;
  ALTER PUBLICATION supabase_realtime ADD TABLE public.workers;
  ALTER PUBLICATION supabase_realtime ADD TABLE public.supply_records;
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- ==============================================================================
-- 13. STORAGE BUCKET PARA FIRMAS DIGITALES
-- ==============================================================================
-- Inserta el bucket 'signatures' en storage.buckets si no existe.

INSERT INTO storage.buckets (id, name, public)
VALUES ('signatures', 'signatures', true)
ON CONFLICT (id) DO NOTHING;

-- Políticas de acceso al bucket de firmas
CREATE POLICY "Acceso público de lectura a firmas"
  ON storage.objects FOR SELECT
  TO anon, authenticated
  USING (bucket_id = 'signatures');

CREATE POLICY "Subida de firmas para anon y auth"
  ON storage.objects FOR INSERT
  TO anon, authenticated
  WITH CHECK (bucket_id = 'signatures');
