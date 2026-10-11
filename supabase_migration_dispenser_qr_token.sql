-- Ejecutar una sola vez en Supabase SQL Editor para actualizar una base existente.
-- Agrega un token QR persistente y exclusivo a cada despachador, incluidos los antiguos.
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

-- Confirma que todos los despachadores ya tienen un token y no hay duplicados.
SELECT
  COUNT(*) AS total_dispensers,
  COUNT(qr_token) AS dispensers_with_qr_token,
  COUNT(DISTINCT qr_token) AS unique_qr_tokens
FROM public.dispensers;
