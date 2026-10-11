-- Zonas permitidas para despachadores de clientes que operan con QR.
ALTER TABLE public.clients
  ADD COLUMN IF NOT EXISTS client_zones TEXT[] NOT NULL DEFAULT '{}';
