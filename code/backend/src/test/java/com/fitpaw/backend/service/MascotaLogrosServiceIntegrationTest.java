package com.fitpaw.backend.service;

import static org.junit.jupiter.api.Assertions.assertTrue;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import com.fitpaw.backend.DTOs.LoginRequest;
import com.fitpaw.backend.DTOs.RegisterRequest;
import com.fitpaw.backend.repository.ConexionDB;

@SpringBootTest
class MascotaLogrosServiceIntegrationTest {

    @Autowired
    private AuthService authService;

    @Autowired
    private MascotaLogrosService mascotaLogrosService;

    @Autowired
    private ConexionDB conexionDB;

    @Test
    void otorga_trajes_gratis_y_recompensas_por_racha_desde_el_backend() throws Exception {
        String telefono = generarTelefonoUnico();
        String nombre = "Usuario Racha Prueba " + telefono.substring(telefono.length() - 4);
        String password = "123456";

        RegisterRequest registerRequest = new RegisterRequest();
        registerRequest.setNombreCompleto(nombre);
        registerRequest.setTelefono(telefono);
        registerRequest.setPassword(password);
        authService.register(registerRequest);

        LoginRequest loginRequest = new LoginRequest();
        loginRequest.setTelefono(telefono);
        loginRequest.setPassword(password);
        authService.login(loginRequest);

        try (Connection conn = conexionDB.conectar()) {
            int usuarioId = obtenerUsuarioIdPorTelefono(conn, telefono);

            assertTrue(existeFila(conn,
                    "SELECT 1 FROM public.mascota_inventario i JOIN public.mascota_catalogo_items c ON c.item_id = i.item_id WHERE i.usuario_id = ? AND c.nombre = ? AND i.esta_equipado = TRUE",
                    usuarioId, "Conjunto Paw Celeste"));
            assertTrue(existeFila(conn,
                    "SELECT 1 FROM public.mascota_inventario i JOIN public.mascota_catalogo_items c ON c.item_id = i.item_id WHERE i.usuario_id = ? AND c.nombre = ? AND i.esta_equipado = TRUE",
                    usuarioId, "Conjunto Paw Rosa"));

            mascotaLogrosService.agregarRecompensasPorRacha(conn, usuarioId, 60, new ArrayList<>());

            assertTrue(existeFila(conn,
                    "SELECT 1 FROM public.mascota_inventario i JOIN public.mascota_catalogo_items c ON c.item_id = i.item_id WHERE i.usuario_id = ? AND c.nombre = ? AND i.esta_equipado = TRUE",
                    usuarioId, "Vestido Azul"));
            assertTrue(existeFila(conn,
                    "SELECT 1 FROM public.mascota_inventario i JOIN public.mascota_catalogo_items c ON c.item_id = i.item_id WHERE i.usuario_id = ? AND c.nombre = ? AND i.esta_equipado = TRUE",
                    usuarioId, "Traje Pirata"));
            assertTrue(existeFila(conn,
                    "SELECT 1 FROM public.mascota_inventario i JOIN public.mascota_catalogo_items c ON c.item_id = i.item_id WHERE i.usuario_id = ? AND c.nombre = ? AND i.esta_equipado = TRUE",
                    usuarioId, "Traje con Lentes"));

            assertTrue(contar(conn, "public.mascota_logros") >= 5,
                    "La tabla mascota_logros debe contener los logros configurados");
        }
    }

    private String generarTelefonoUnico() {
        long suffix = Math.abs(System.currentTimeMillis() % 1_000_000_000L);
        return String.format("9%09d", suffix);
    }

    private int obtenerUsuarioIdPorTelefono(Connection conn, String telefono) throws Exception {
        try (PreparedStatement ps = conn.prepareStatement("SELECT usuario_id FROM public.usuarios_cuenta WHERE telefono = ?")) {
            ps.setString(1, telefono);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        throw new IllegalStateException("No se encontró el usuario de prueba");
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
                    ps.setObject(i + 1, param);
                }
            }
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private long contar(Connection conn, String tabla) throws Exception {
        try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM " + tabla);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getLong(1);
            }
        }
        return 0L;
    }
}