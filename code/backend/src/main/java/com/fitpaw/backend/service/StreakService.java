package com.fitpaw.backend.service;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Date;
import java.time.LocalDate;
import java.util.NoSuchElementException;

import org.springframework.stereotype.Service;

import com.fitpaw.backend.DTOs.RachaResponse;
import com.fitpaw.backend.repository.DatabaseConnectionProvider;

@Service
public class StreakService implements StreakQueryUseCase {

    private final DatabaseConnectionProvider conexionDB;
    private final StreakRewardService streakRewardService;
    private static final String ORDEN_RACHA_ACTUAL =
            "ORDER BY CASE WHEN cantidad_dias > 0 THEN 0 ELSE 1 END, fecha_ultima_actividad DESC, racha_id DESC LIMIT 1";

    public StreakService(DatabaseConnectionProvider conexionDB, StreakRewardService streakRewardService) {
        this.conexionDB = conexionDB;
        this.streakRewardService = streakRewardService;
    }

    /**
     * Obtiene la información actual de la racha del usuario
     */
    public RachaResponse obtenerRachaInfo(int usuarioId) {
        validarUsuarioId(usuarioId);
        try (Connection conn = conexionDB.conectar()) {
            validarUsuarioExiste(conn, usuarioId);

            String sql = "SELECT racha_id, usuario_id, cantidad_dias, fecha_ultima_actividad "
                    + "FROM public.usuarios_racha WHERE usuario_id = ? " + ORDEN_RACHA_ACTUAL;
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, usuarioId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        RachaResponse racha = mapRachaResponse(rs);
                        if (racha.getConteoDias() <= 0 && existeEjercicioCompletadoEnFecha(conn, usuarioId, LocalDate.now())) {
                            activarRachaDesdeCero(conn, racha.getRachaId(), LocalDate.now());
                            streakRewardService.otorgarAlimento(conn, usuarioId, "Calamar", 1);
                            racha.setConteoDias(1);
                            racha.setUltimaFechaActividad(LocalDate.now());
                            racha.setActiva(true);
                            racha.setProximaFechaSinActividad(LocalDate.now().plusDays(1));
                        }
                        return racha;
                    }
                }
            }
            RachaResponse racha = new RachaResponse();
            racha.setUsuarioId(usuarioId);
            racha.setConteoDias(0);
            racha.setActiva(false);
            return racha;
        } catch (SQLException e) {
            throw new IllegalStateException("Error al obtener racha: " + e.getMessage());
        }
    }

    private RachaResponse mapRachaResponse(ResultSet rs) throws SQLException {
        RachaResponse racha = new RachaResponse();
        racha.setRachaId(rs.getInt("racha_id"));
        racha.setUsuarioId(rs.getInt("usuario_id"));
        racha.setConteoDias(rs.getInt("cantidad_dias"));
        
        java.sql.Date dbDate = rs.getDate("fecha_ultima_actividad");
        if (dbDate != null) {
            racha.setUltimaFechaActividad(dbDate.toLocalDate());
        }
        
        racha.setActiva(racha.getConteoDias() > 0);
        
        if (racha.getUltimaFechaActividad() != null) {
            racha.setProximaFechaSinActividad(racha.getUltimaFechaActividad().plusDays(1));
        }
        
        return racha;
    }

    private boolean existeEjercicioCompletadoEnFecha(Connection conn, int usuarioId, LocalDate fecha) throws SQLException {
        String sql = "SELECT EXISTS ("
                + "SELECT 1 FROM public.ejercicio_cardio WHERE usuario_id = ? AND fecha = ? AND completado = true "
                + "UNION ALL "
                + "SELECT 1 FROM public.ejercicio_fuerza WHERE usuario_id = ? AND fecha = ? AND completado = true"
                + ")";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, usuarioId);
            ps.setDate(2, Date.valueOf(fecha));
            ps.setInt(3, usuarioId);
            ps.setDate(4, Date.valueOf(fecha));
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getBoolean(1);
            }
        }
    }

    private void activarRachaDesdeCero(Connection conn, int rachaId, LocalDate fecha) throws SQLException {
        String sql = "UPDATE public.usuarios_racha SET cantidad_dias = 1, fecha_ultima_actividad = ?, activa = true WHERE racha_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(fecha));
            ps.setInt(2, rachaId);
            ps.executeUpdate();
        }
    }

    private void validarUsuarioId(int usuarioId) {
        if (usuarioId <= 0) {
            throw new IllegalArgumentException("usuarioId invalido");
        }
    }

    private void validarUsuarioExiste(Connection conn, int usuarioId) throws SQLException {
        String sql = "SELECT 1 FROM public.usuarios_cuenta WHERE usuario_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, usuarioId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    throw new NoSuchElementException("Usuario no existe: " + usuarioId);
                }
            }
        }
    }
}
