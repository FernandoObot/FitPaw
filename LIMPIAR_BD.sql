-- Script para limpiar usuarios de prueba
-- Ejecuta esto en Supabase SQL Editor

-- Eliminar todos los usuarios excepto el primero (para test)
DELETE FROM public.usuarios_racha WHERE usuario_id > 1;
DELETE FROM public.mascota_alimento WHERE mascota_id IN (SELECT mascota_id FROM public.mascota_estado WHERE usuario_id > 1);
DELETE FROM public.mascota_estado WHERE usuario_id > 1;
DELETE FROM public.usuarios_cuenta WHERE usuario_id > 1;

-- Resetear secuencia
SELECT setval('public.usuarios_cuenta_usuario_id_seq', 1, true);

-- Verificar
SELECT usuario_id, nickname, telefono FROM public.usuarios_cuenta;
SELECT mascota_id, usuario_id, nombre FROM public.mascota_estado;
SELECT alimento_id, mascota_id, nombre_comida, cantidad FROM public.mascota_alimento;
