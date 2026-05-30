package com.fitpaw.backend.service;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Date;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.NoSuchElementException;

import org.springframework.stereotype.Service;

import com.fitpaw.backend.DTOs.RachaResponse;
import com.fitpaw.backend.DTOs.RecompensaRachaResponse;
import com.fitpaw.backend.DTOs.RecompensaRachaResponse.RecompensaItem;
import com.fitpaw.backend.repository.ConexionDB;

@Service
public class StreakService {

    private final ConexionDB conexionDB;
    private static final int DIAS_MINIMOS_RACHA = 3;

    public StreakService(ConexionDB conexionDB) {
        this.conexionDB = conexionDB;
    }

    /**
     * Obtiene la información actual de la racha del usuario
     */
    public RachaResponse obtenerRachaInfo(int usuarioId) {
        validarUsuarioId(usuarioId);
        try (Connection conn = conexionDB.conectar()) {
            validarUsuarioExiste(conn, usuarioId);

            String sql = "SELECT racha_id, usuario_id, cantidad_dias, fecha_ultima_actividad "
                    + "FROM public.usuarios_racha WHERE usuario_id = ? ORDER BY racha_id DESC LIMIT 1";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, usuarioId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return mapRachaResponse(rs);
                    }
                }
            }
            // Si no existe racha, crear una nueva con 0 días
            return crearRachaInicial(conn, usuarioId);
        } catch (SQLException e) {
            throw new IllegalStateException("Error al obtener racha: " + e.getMessage());
        }
    }

    /**
     * Verifica y actualiza la racha basada en la actividad registrada
     */
    public RachaResponse verificarYActualizarRacha(int usuarioId) {
        validarUsuarioId(usuarioId);
        try (Connection conn = conexionDB.conectar()) {
            validarUsuarioExiste(conn, usuarioId);

            // Obtener o crear racha actual
            RachaResponse rachaActual = obtenerRachaActualOCrear(conn, usuarioId);
            
            // Calcular últimas 24 horas con actividad
            LocalDate ultimaFechaConActividad = obtenerUltimaFechaConActividad(conn, usuarioId);
            LocalDate hoy = LocalDate.now();

            if (ultimaFechaConActividad == null) {
                // Sin actividad, resetear racha
                actualizarRachaEnDB(conn, rachaActual.getRachaId(), 0, null);
                rachaActual.setConteoDias(0);
                rachaActual.setActiva(false);
                return rachaActual;
            }

            long diasDesdeUltimaActividad = ChronoUnit.DAYS.between(ultimaFechaConActividad, hoy);

            if (diasDesdeUltimaActividad == 0) {
                // Actividad en el último día (dentro de 24h)
                int nuevoDias = rachaActual.getConteoDias() + 1;
                actualizarRachaEnDB(conn, rachaActual.getRachaId(), nuevoDias, ultimaFechaConActividad);
                rachaActual.setConteoDias(nuevoDias);
                rachaActual.setUltimaFechaActividad(ultimaFechaConActividad);
                rachaActual.setActiva(nuevoDias >= DIAS_MINIMOS_RACHA);
                return rachaActual;
            } else if (diasDesdeUltimaActividad == 1) {
                // Actividad hace 1 día, continuar racha
                int nuevoDias = rachaActual.getConteoDias() + 1;
                actualizarRachaEnDB(conn, rachaActual.getRachaId(), nuevoDias, ultimaFechaConActividad);
                rachaActual.setConteoDias(nuevoDias);
                rachaActual.setUltimaFechaActividad(ultimaFechaConActividad);
                rachaActual.setActiva(nuevoDias >= DIAS_MINIMOS_RACHA);
                return rachaActual;
            } else {
                // Más de 1 día sin actividad, resetear racha
                actualizarRachaEnDB(conn, rachaActual.getRachaId(), 0, null);
                rachaActual.setConteoDias(0);
                rachaActual.setActiva(false);
                return rachaActual;
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Error al actualizar racha: " + e.getMessage());
        }
    }

    /**
     * Calcula y genera las recompensas para el día actual
     */
    public RecompensaRachaResponse calcularRecompensas(int usuarioId) {
        validarUsuarioId(usuarioId);
        try (Connection conn = conexionDB.conectar()) {
            validarUsuarioExiste(conn, usuarioId);

            // Primero actualizar racha
            RachaResponse racha = verificarYActualizarRacha(usuarioId);
            
            List<RecompensaItem> recompensas = new ArrayList<>();
            RecompensaRachaResponse respuesta = new RecompensaRachaResponse();
            respuesta.setUsuarioId(usuarioId);
            respuesta.setConteoDias(racha.getConteoDias());
            respuesta.setDiasActual(racha.getConteoDias());

            if (!racha.isActiva() || racha.getConteoDias() < DIAS_MINIMOS_RACHA) {
                respuesta.setRecompensas(recompensas);
                respuesta.setEsNueva(false);
                return respuesta;
            }

            // Otorgar recompensas de comida basadas en el conteo
            if (racha.getConteoDias() > 0) {
                // Cada día: 2 Pescados Azules
                agregarAlimento(conn, usuarioId, "Pescado Azul", 2);
                recompensas.add(new RecompensaItem(1, "Pescado Azul", "comida", 2, "Por cada día de racha"));
            }

            if (racha.getConteoDias() % 3 == 0 && racha.getConteoDias() > 0) {
                // Cada 3 días: 1 Calamar
                agregarAlimento(conn, usuarioId, "Calamar", 1);
                recompensas.add(new RecompensaItem(2, "Calamar", "comida", 1, "Cada 3 días"));
            }

            if (racha.getConteoDias() % 15 == 0 && racha.getConteoDias() > 0) {
                // Cada 15 días: 1 Cóctel
                agregarAlimento(conn, usuarioId, "Cóctel", 1);
                recompensas.add(new RecompensaItem(3, "Cóctel", "comida", 1, "Cada 15 días"));
            }
            
            respuesta.setRecompensas(recompensas);
            respuesta.setEsNueva(!recompensas.isEmpty());
            return respuesta;
        } catch (SQLException e) {
            throw new IllegalStateException("Error al calcular recompensas: " + e.getMessage());
        }
    }

    // ==================== MÉTODOS PRIVADOS ====================

    /**
     * Obtiene la última fecha con actividad del usuario (ejercicios)
     */
    private LocalDate obtenerUltimaFechaConActividad(Connection conn, int usuarioId) throws SQLException {
        LocalDate ultimaFecha = null;

        // Buscar en ejercicio_fuerza
        String sqlFuerza = "SELECT MAX(fecha::date) as ultima_fecha FROM public.ejercicio_fuerza "
                + "WHERE usuario_id = ? AND fecha >= CURRENT_DATE - INTERVAL '1 day'";
        
        try (PreparedStatement ps = conn.prepareStatement(sqlFuerza)) {
            ps.setInt(1, usuarioId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    java.sql.Date dbDate = rs.getDate("ultima_fecha");
                    if (dbDate != null) {
                        ultimaFecha = dbDate.toLocalDate();
                    }
                }
            }
        }

        // Buscar en ejercicio_cardio
        String sqlCardio = "SELECT MAX(fecha::date) as ultima_fecha FROM public.ejercicio_cardio "
                + "WHERE usuario_id = ? AND fecha >= CURRENT_DATE - INTERVAL '1 day'";
        
        try (PreparedStatement ps = conn.prepareStatement(sqlCardio)) {
            ps.setInt(1, usuarioId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    java.sql.Date dbDate = rs.getDate("ultima_fecha");
                    if (dbDate != null) {
                        LocalDate fechaCardio = dbDate.toLocalDate();
                        if (ultimaFecha == null || fechaCardio.isAfter(ultimaFecha)) {
                            ultimaFecha = fechaCardio;
                        }
                    }
                }
            }
        }

        return ultimaFecha;
    }

    /**
     * Agrega comida al inventario (mascota_alimento)
     */
    private void agregarAlimento(Connection conn, int usuarioId, String nombreComida, int cantidad) throws SQLException {
        // Obtener mascota_id del usuario
        String sqlMascota = "SELECT mascota_id FROM public.mascota_estado WHERE usuario_id = ? LIMIT 1";
        int mascotaId = -1;
        
        try (PreparedStatement ps = conn.prepareStatement(sqlMascota)) {
            ps.setInt(1, usuarioId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    mascotaId = rs.getInt("mascota_id");
                }
            }
        }

        if (mascotaId <= 0) {
            return; // Sin mascota, no agregar alimento
        }

        // Verificar si ya existe este alimento
        String checkSql = "SELECT alimento_id, cantidad FROM public.mascota_alimento "
                + "WHERE mascota_id = ? AND nombre_comida = ?";
        
        try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
            ps.setInt(1, mascotaId);
            ps.setString(2, nombreComida);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    // Actualizar cantidad existente
                    int alimentoId = rs.getInt("alimento_id");
                    int cantidadActual = rs.getInt("cantidad");
                    String updateSql = "UPDATE public.mascota_alimento SET cantidad = ? WHERE alimento_id = ?";
                    try (PreparedStatement updatePs = conn.prepareStatement(updateSql)) {
                        updatePs.setInt(1, cantidadActual + cantidad);
                        updatePs.setInt(2, alimentoId);
                        updatePs.executeUpdate();
                    }
                } else {
                    // Insertar nuevo alimento
                    String insertSql = "INSERT INTO public.mascota_alimento (mascota_id, nombre_comida, cantidad, beneficio_puntos) "
                            + "VALUES (?, ?, ?, 0)";
                    try (PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
                        insertPs.setInt(1, mascotaId);
                        insertPs.setString(2, nombreComida);
                        insertPs.setInt(3, cantidad);
                        insertPs.executeUpdate();
                    }
                }
            }
        }
    }

    private RachaResponse obtenerRachaActualOCrear(Connection conn, int usuarioId) throws SQLException {
        String sql = "SELECT racha_id, usuario_id, cantidad_dias, fecha_ultima_actividad "
                + "FROM public.usuarios_racha WHERE usuario_id = ? ORDER BY racha_id DESC LIMIT 1";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, usuarioId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRachaResponse(rs);
                }
            }
        }
        return crearRachaInicialEnDB(conn, usuarioId);
    }

    private RachaResponse crearRachaInicial(Connection conn, int usuarioId) throws SQLException {
        String sql = "INSERT INTO public.usuarios_racha (usuario_id, cantidad_dias, fecha_inicio, fecha_ultima_actividad, activa) "
                + "VALUES (?, ?, CURRENT_DATE, NULL, false) RETURNING racha_id";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, usuarioId);
            ps.setInt(2, 0);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    RachaResponse racha = new RachaResponse();
                    racha.setRachaId(rs.getInt("racha_id"));
                    racha.setUsuarioId(usuarioId);
                    racha.setConteoDias(0);
                    racha.setActiva(false);
                    return racha;
                }
            }
        }
        throw new IllegalStateException("No se pudo crear racha inicial");
    }

    private RachaResponse crearRachaInicialEnDB(Connection conn, int usuarioId) throws SQLException {
        return crearRachaInicial(conn, usuarioId);
    }

    private void actualizarRachaEnDB(Connection conn, int rachaId, int nuevoConteo, LocalDate ultimaFecha) 
            throws SQLException {
        
        String sql = "UPDATE public.usuarios_racha SET cantidad_dias = ?, fecha_ultima_actividad = ?, activa = ? "
                + "WHERE racha_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, nuevoConteo);
            if (ultimaFecha != null) {
                ps.setDate(2, Date.valueOf(ultimaFecha));
            } else {
                ps.setNull(2, java.sql.Types.DATE);
            }
            ps.setBoolean(3, nuevoConteo >= DIAS_MINIMOS_RACHA);
            ps.setInt(4, rachaId);
            ps.executeUpdate();
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
        
        racha.setActiva(racha.getConteoDias() >= DIAS_MINIMOS_RACHA);
        
        if (racha.getUltimaFechaActividad() != null) {
            racha.setProximaFechaSinActividad(racha.getUltimaFechaActividad().plusDays(1));
        }
        
        return racha;
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
