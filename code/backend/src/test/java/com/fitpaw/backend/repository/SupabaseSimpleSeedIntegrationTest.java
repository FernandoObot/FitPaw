package com.fitpaw.backend.repository;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
class SupabaseSimpleSeedIntegrationTest {

    @Autowired
    private ConexionDB conexionDB;

    @Test
    void inserta_datos_simples_en_tablas_clave_de_supabase() throws Exception {
        int usuarioId;
        int ejercicioId;
        int itemId;

        try (Connection conn = conexionDB.conectar()) {
            usuarioId = insertarUsuarioBase(conn);
            insertarItemsCatalogo(conn);
            ejercicioId = insertarEjercicioBase(conn);
            itemId = obtenerItemId(conn, "Pescado Azul");

            insertarMascotaEstado(conn, usuarioId);
            insertarRachaInicial(conn, usuarioId);
            insertarInventarioBase(conn, usuarioId, itemId);
            insertarBitacoraFuerzaBase(conn, usuarioId, ejercicioId);

            assertTrue(existeFila(conn, "SELECT 1 FROM public.usuarios_cuenta WHERE telefono = ?", "999000000"));
            assertTrue(existeFila(conn, "SELECT 1 FROM public.mascota_estado WHERE usuario_id = ?", usuarioId));
            assertTrue(existeFila(conn, "SELECT 1 FROM public.progreso_rachas WHERE usuario_id = ?", usuarioId));
            assertTrue(existeFila(conn, "SELECT 1 FROM public.mascota_inventario WHERE usuario_id = ? AND item_id = ?", usuarioId, itemId));
            assertTrue(existeFila(conn, "SELECT 1 FROM public.progreso_bitacora_fuerza WHERE usuario_id = ? AND ejercicio_id = ?", usuarioId, ejercicioId));

            assertTrue(contarFilas(conn, "public.mascota_catalogo_items", "nombre = 'Pescado Azul'") >= 1);
            assertTrue(contarFilas(conn, "public.mascota_catalogo_items", "nombre = 'Camarón Naranja'") >= 1);
            assertTrue(contarFilas(conn, "public.mascota_catalogo_items", "nombre = 'Calamar'") >= 1);
            assertTrue(contarFilas(conn, "public.mascota_catalogo_items", "nombre = 'Cóctel'") >= 1);
        }
    }

    private int insertarUsuarioBase(Connection conn) throws Exception {
        String sql = "INSERT INTO public.usuarios_cuenta (nickname, telefono, password, rol, fecha_registro) "
                + "VALUES (?, ?, ?, ?, ?) "
            + "ON CONFLICT (telefono) DO UPDATE SET nickname = EXCLUDED.nickname "
                + "RETURNING usuario_id";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "Usuario Prueba FitPaw");
            ps.setString(2, "999000000");
            ps.setString(3, "$2a$10$wH5D1u3v7QG1cK6uKQxM2eNwZf7G7e6r6J1m0mY6rFQbR2kzQ1u4Z2");
            ps.setString(4, "USER");
            ps.setTimestamp(5, Timestamp.valueOf(LocalDateTime.now()));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        throw new IllegalStateException("No se pudo crear el usuario base");
    }

    private void insertarItemsCatalogo(Connection conn) throws Exception {
        insertarItemSiNoExiste(conn, "Pescado Azul", "comida", 10);
        insertarItemSiNoExiste(conn, "Camarón Naranja", "comida", 5);
        insertarItemSiNoExiste(conn, "Calamar", "comida", 15);
        insertarItemSiNoExiste(conn, "Cóctel", "bebida", 20);
    }

    private void insertarItemSiNoExiste(Connection conn, String nombre, String tipo, int puntos) throws Exception {
        String sql = "INSERT INTO public.mascota_catalogo_items (nombre, tipo, beneficio_puntos, url_imagen) "
                + "SELECT ?, ?, ?, NULL "
                + "WHERE NOT EXISTS (SELECT 1 FROM public.mascota_catalogo_items WHERE nombre = ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, nombre);
            ps.setString(2, tipo);
            ps.setInt(3, puntos);
            ps.setString(4, nombre);
            ps.executeUpdate();
        }
    }

    private int insertarEjercicioBase(Connection conn) throws Exception {
        String sql = "INSERT INTO public.entrenamiento_ejercicios (nombre, grupo_muscular, descripcion, instrucciones_json, url_media) "
                + "SELECT ?, ?, ?, NULL, NULL "
                + "WHERE NOT EXISTS (SELECT 1 FROM public.entrenamiento_ejercicios WHERE nombre = ?) "
                + "RETURNING ejercicio_id";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "Sentadilla");
            ps.setString(2, "Pierna");
            ps.setString(3, "Ejercicio base de fuerza");
            ps.setString(4, "Sentadilla");
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        try (PreparedStatement ps = conn.prepareStatement("SELECT ejercicio_id FROM public.entrenamiento_ejercicios WHERE nombre = ?")) {
            ps.setString(1, "Sentadilla");
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        throw new IllegalStateException("No se pudo obtener el ejercicio base");
    }

    private void insertarMascotaEstado(Connection conn, int usuarioId) throws Exception {
        String sql = "INSERT INTO public.mascota_estado (usuario_id, nombre, nivel, experiencia_actual, hambre, salud, ultima_vez_alimentado) "
                + "SELECT ?, ?, ?, ?, ?, ?, ? "
                + "WHERE NOT EXISTS (SELECT 1 FROM public.mascota_estado WHERE usuario_id = ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            Timestamp now = Timestamp.valueOf(LocalDateTime.now());
            ps.setInt(1, usuarioId);
            ps.setString(2, "Pingui");
            ps.setInt(3, 1);
            ps.setInt(4, 0);
            ps.setInt(5, 100);
            ps.setInt(6, 100);
            ps.setTimestamp(7, now);
            ps.setInt(8, usuarioId);
            ps.executeUpdate();
        }
    }

    private void insertarRachaInicial(Connection conn, int usuarioId) throws Exception {
        String sql = "INSERT INTO public.progreso_rachas (usuario_id, conteo_dias, ultima_fecha_actividad) "
                + "SELECT ?, ?, ? "
                + "WHERE NOT EXISTS (SELECT 1 FROM public.progreso_rachas WHERE usuario_id = ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, usuarioId);
            ps.setInt(2, 1);
            ps.setDate(3, Date.valueOf(LocalDate.now()));
            ps.setInt(4, usuarioId);
            ps.executeUpdate();
        }
    }

    private void insertarInventarioBase(Connection conn, int usuarioId, int itemId) throws Exception {
        String sql = "INSERT INTO public.mascota_inventario (usuario_id, item_id, cantidad, esta_equipado) "
                + "SELECT ?, ?, ?, ? "
                + "WHERE NOT EXISTS (SELECT 1 FROM public.mascota_inventario WHERE usuario_id = ? AND item_id = ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, usuarioId);
            ps.setInt(2, itemId);
            ps.setInt(3, 2);
            ps.setBoolean(4, false);
            ps.setInt(5, usuarioId);
            ps.setInt(6, itemId);
            ps.executeUpdate();
        }
    }

    private void insertarBitacoraFuerzaBase(Connection conn, int usuarioId, int ejercicioId) throws Exception {
        String sql = "INSERT INTO public.progreso_bitacora_fuerza (usuario_id, ejercicio_id, serie_numero, peso_kg, repeticiones, fecha) "
                + "SELECT ?, ?, ?, ?, ?, ? "
                + "WHERE NOT EXISTS (SELECT 1 FROM public.progreso_bitacora_fuerza WHERE usuario_id = ? AND ejercicio_id = ? AND serie_numero = ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            Timestamp now = Timestamp.valueOf(LocalDateTime.now());
            ps.setInt(1, usuarioId);
            ps.setInt(2, ejercicioId);
            ps.setInt(3, 1);
            ps.setBigDecimal(4, java.math.BigDecimal.valueOf(20));
            ps.setInt(5, 10);
            ps.setTimestamp(6, now);
            ps.setInt(7, usuarioId);
            ps.setInt(8, ejercicioId);
            ps.setInt(9, 1);
            ps.executeUpdate();
        }
    }

    private int obtenerItemId(Connection conn, String nombre) throws Exception {
        try (PreparedStatement ps = conn.prepareStatement("SELECT item_id FROM public.mascota_catalogo_items WHERE nombre = ?")) {
            ps.setString(1, nombre);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        throw new IllegalStateException("No se pudo obtener item_id para " + nombre);
    }

    private boolean existeFila(Connection conn, String sql, Object... params) throws Exception {
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < params.length; i++) {
                Object param = params[i];
                if (param instanceof Integer integer) {
                    ps.setInt(i + 1, integer);
                } else if (param instanceof String string) {
                    ps.setString(i + 1, string);
                } else {
                    throw new IllegalArgumentException("Tipo de parámetro no soportado: " + param.getClass());
                }
            }
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private long contarFilas(Connection conn, String tabla, String whereClause) throws Exception {
        String sql = "SELECT COUNT(*) FROM " + tabla + " WHERE " + whereClause;
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getLong(1);
            }
        }
        return 0L;
    }
}