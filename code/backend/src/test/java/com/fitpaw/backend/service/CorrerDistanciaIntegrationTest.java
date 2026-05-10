package com.fitpaw.backend.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import com.fitpaw.backend.DTOs.LoginRequest;
import com.fitpaw.backend.DTOs.RegistroCorrerRequest;
import com.fitpaw.backend.DTOs.RegistroCorrerResponse;
import com.fitpaw.backend.DTOs.RegisterRequest;
import com.fitpaw.backend.repository.ConexionDB;

@SpringBootTest
class CorrerDistanciaIntegrationTest {

    private static final String TELEFONO_PRUEBA = "9990001234";
    private static final String NOMBRE_PRUEBA = "Test Correr Distancia";
    private static final String PASSWORD_PRUEBA = "123456";

    @Autowired
    private AuthService authService;

    @Autowired
    private TrainingAppService trainingAppService;

    @Autowired
    private ConexionDB conexionDB;

    @Test
    void crear_correr_persiste_distancia_en_bitacora() throws Exception {
        limpiarEstadoDePrueba();

        RegisterRequest registerRequest = new RegisterRequest();
        registerRequest.setNombreCompleto(NOMBRE_PRUEBA);
        registerRequest.setTelefono(TELEFONO_PRUEBA);
        registerRequest.setPassword(PASSWORD_PRUEBA);
        authService.register(registerRequest);

        LoginRequest loginRequest = new LoginRequest();
        loginRequest.setTelefono(TELEFONO_PRUEBA);
        loginRequest.setPassword(PASSWORD_PRUEBA);
        authService.login(loginRequest);

        int usuarioId = obtenerUsuarioIdPorTelefono(TELEFONO_PRUEBA);

        RegistroCorrerRequest request = new RegistroCorrerRequest();
        request.setUsuarioId(usuarioId);
        request.setDificultad("Media");
        request.setDistanciaKm(3.2);

        RegistroCorrerResponse response = trainingAppService.crearRegistroCorrer(request);

        assertNotNull(response);
        assertEquals(usuarioId, response.getUsuarioId());
        assertEquals(3.2, response.getDistanciaKm(), 0.0001);
        assertTrue(response.getRegistroExtraId() > 0);

        try (Connection conn = conexionDB.conectar()) {
            String sql = "SELECT b.distancia_km, b.serie_numero, e.nombre, b.fecha, u.telefono "
                    + "FROM public.progreso_bitacora_fuerza b "
                    + "JOIN public.entrenamiento_ejercicios e ON e.ejercicio_id = b.ejercicio_id "
                    + "JOIN public.usuarios_cuenta u ON u.usuario_id = b.usuario_id "
                    + "WHERE b.registro_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, response.getRegistroExtraId());
                try (ResultSet rs = ps.executeQuery()) {
                    assertTrue(rs.next(), "Debe existir el registro de correr en la bitacora");
                    assertEquals("Correr", rs.getString("nombre"));
                    assertEquals(TELEFONO_PRUEBA, rs.getString("telefono"));
                    assertEquals(3.2, rs.getDouble("distancia_km"), 0.0001);
                    assertEquals(3200, rs.getInt("serie_numero"));
                    assertNotNull(rs.getTimestamp("fecha"));
                }
            }
        }
    }

    private void limpiarEstadoDePrueba() throws Exception {
        try (Connection conn = conexionDB.conectar()) {
            Integer usuarioId = null;
            try (PreparedStatement ps = conn.prepareStatement("SELECT usuario_id FROM public.usuarios_cuenta WHERE telefono = ?")) {
                ps.setString(1, TELEFONO_PRUEBA);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        usuarioId = rs.getInt(1);
                    }
                }
            }

            if (usuarioId == null) {
                return;
            }

            try (PreparedStatement ps = conn.prepareStatement("DELETE FROM public.progreso_bitacora_fuerza WHERE usuario_id = ?")) {
                ps.setInt(1, usuarioId);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = conn.prepareStatement("DELETE FROM public.progreso_rachas WHERE usuario_id = ?")) {
                ps.setInt(1, usuarioId);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = conn.prepareStatement("DELETE FROM public.mascota_inventario WHERE usuario_id = ?")) {
                ps.setInt(1, usuarioId);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = conn.prepareStatement("DELETE FROM public.mascota_estado WHERE usuario_id = ?")) {
                ps.setInt(1, usuarioId);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = conn.prepareStatement("DELETE FROM public.usuarios_fotos_progreso WHERE usuario_id = ?")) {
                ps.setInt(1, usuarioId);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = conn.prepareStatement("DELETE FROM public.usuarios_cuenta WHERE usuario_id = ?")) {
                ps.setInt(1, usuarioId);
                ps.executeUpdate();
            }
        }
    }

    private int obtenerUsuarioIdPorTelefono(String telefono) throws Exception {
        try (Connection conn = conexionDB.conectar();
             PreparedStatement ps = conn.prepareStatement("SELECT usuario_id FROM public.usuarios_cuenta WHERE telefono = ?")) {
            ps.setString(1, telefono);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        throw new IllegalStateException("No se encontró el usuario de prueba");
    }
}
