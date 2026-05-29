-- Script para agregar el campo esta_desbloqueada a la tabla mascota_ropa
-- Esto permite controlar qué prendas están desbloqueadas para cada mascota

-- Agregar la columna esta_desbloqueada con valor por defecto false
ALTER TABLE public.mascota_ropa 
ADD COLUMN esta_desbloqueada boolean DEFAULT false;

-- Actualizar todas las prendas existentes a desbloqueada = false (inicialmente todas deshabilitadas)
UPDATE public.mascota_ropa SET esta_desbloqueada = false;

-- Comentario en la tabla
COMMENT ON COLUMN public.mascota_ropa.esta_desbloqueada IS 'Indica si la prenda está desbloqueada (true) o bloqueada (false)';
