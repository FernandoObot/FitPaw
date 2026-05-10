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
    private final MascotaLogrosService mascotaLogrosService;
    private static final int DIAS_MINIMOS_RACHA = 3;

    public StreakService(ConexionDB conexionDB, MascotaLogrosService mascotaLogrosService) {
        this.conexionDB = conexionDB;
        this.mascotaLogrosService = mascotaLogrosService;
    }

    /**
     * Obtiene la información actual de la racha del usuario
     */
    public RachaResponse obtenerRachaInfo(int usuarioId) {
        validarUsuarioId(usuarioId);
        try (Connection conn = conexionDB.conectar()) {
            validarUsuarioExiste(conn, usuarioId);

            String sql = "SELECT racha_id, usuario_id, conteo_dias, ultima_fecha_actividad "
                    + "FROM public.progreso_rachas WHERE usuario_id = ?";
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

            // Generar recompensas según el conteo de días
            generarRecompensasSegunConteo(conn, usuarioId, recompensas, racha.getConteoDias());
            
            // Otorgar recompensas al inventario
            otorgarRecompensas(conn, usuarioId, recompensas);
            
            respuesta.setRecompensas(recompensas);
            respuesta.setEsNueva(true);
            return respuesta;
        } catch (SQLException e) {
            throw new IllegalStateException("Error al calcular recompensas: " + e.getMessage());
        }
    }

    // ==================== MÉTODOS PRIVADOS ====================

    private void generarRecompensasSegunConteo(Connection conn, int usuarioId, List<RecompensaItem> recompensas, int conteoDias) 
            throws SQLException {
        
        // 1. Recompensa por cada día de racha activa: 2 pescados azules
        int idPescadoAzul = obtenerIdItemPorNombre(conn, "Pescado Azul");
        if (idPescadoAzul > 0) {
            recompensas.add(new RecompensaItem(
                idPescadoAzul, 
                "Pescado Azul", 
                "comida", 
                2, 
                "Por cada día de racha activa"
            ));
        }

        // 2. Recompensa por ejercicio: 1 camarón naranja (diario)
        int idCamaronNaranja = obtenerIdItemPorNombre(conn, "Camarón Naranja");
        if (idCamaronNaranja > 0) {
            recompensas.add(new RecompensaItem(
                idCamaronNaranja,
                "Camarón Naranja",
                "comida",
                1,
                "Por completar ejercicio del día"
            ));
        }

        // 3. Recompensa cada 3 días consecutivos: 1 calamar
        if (conteoDias > 0 && conteoDias % 3 == 0) {
            int idCalamar = obtenerIdItemPorNombre(conn, "Calamar");
            if (idCalamar > 0) {
                recompensas.add(new RecompensaItem(
                    idCalamar,
                    "Calamar",
                    "comida",
                    1,
                    "Por cada 3 días consecutivos de racha"
                ));
            }
        }

        // 4. Recompensa cada 15 días consecutivos: 1 cóctel
        if (conteoDias >= 15 && conteoDias % 15 == 0) {
            int idCoctel = obtenerIdItemPorNombre(conn, "Cóctel");
            if (idCoctel > 0) {
                recompensas.add(new RecompensaItem(
                    idCoctel,
                    "Cóctel",
                    "comida",
                    1,
                    "Por cada 15 días consecutivos de racha"
                ));
            }
        }

        mascotaLogrosService.agregarRecompensasPorRacha(conn, usuarioId, conteoDias, recompensas);
    }

    private void otorgarRecompensas(Connection conn, int usuarioId, List<RecompensaItem> recompensas) 
            throws SQLException {
        
        for (RecompensaItem recompensa : recompensas) {
            agregarAlInventario(conn, usuarioId, recompensa.getItemId(), recompensa.getCantidad());
        }
    }

    private void agregarAlInventario(Connection conn, int usuarioId, int itemId, int cantidad) 
            throws SQLException {
        
        // Verificar si ya existe el item en el inventario
        String checkSql = "SELECT inventario_id, cantidad, esta_equipado FROM public.mascota_inventario "
                + "WHERE usuario_id = ? AND item_id = ?";
        try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
            checkPs.setInt(1, usuarioId);
            checkPs.setInt(2, itemId);
            try (ResultSet rs = checkPs.executeQuery()) {
                boolean itemEsRopa = esItemRopa(conn, itemId);
                if (rs.next()) {
                    // Actualizar cantidad existente
                    int inventarioId = rs.getInt("inventario_id");
                    int cantidadActual = rs.getInt("cantidad");
                    boolean equipadoActual = rs.getBoolean("esta_equipado");
                    String updateSql = "UPDATE public.mascota_inventario SET cantidad = ?, esta_equipado = ? WHERE inventario_id = ?";
                    try (PreparedStatement updatePs = conn.prepareStatement(updateSql)) {
                        updatePs.setInt(1, cantidadActual + cantidad);
                        updatePs.setBoolean(2, equipadoActual || itemEsRopa);
                        updatePs.setInt(3, inventarioId);
                        updatePs.executeUpdate();
                    }
                } else {
                    // Insertar nuevo item
                    String insertSql = "INSERT INTO public.mascota_inventario "
                            + "(usuario_id, item_id, cantidad, esta_equipado) VALUES (?, ?, ?, ?)";
                    try (PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
                        insertPs.setInt(1, usuarioId);
                        insertPs.setInt(2, itemId);
                        insertPs.setInt(3, cantidad);
                        insertPs.setBoolean(4, itemEsRopa);
                        insertPs.executeUpdate();
                    }
                }
            }
        }
    }

    private boolean esItemRopa(Connection conn, int itemId) throws SQLException {
        String sql = "SELECT tipo, nombre FROM public.mascota_catalogo_items WHERE item_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, itemId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String tipo = normalizar(rs.getString("tipo"));
                    String nombre = normalizar(rs.getString("nombre"));
                    return tipo.contains("ropa")
                            || nombre.startsWith("conjunto ")
                            || nombre.startsWith("traje ")
                            || nombre.startsWith("vestido ");
                }
            }
        }
        return false;
    }

    private String normalizar(String value) {
        if (value == null) {
            return "";
        }
        return value.trim().toLowerCase()
                .replace('á', 'a')
                .replace('é', 'e')
                .replace('í', 'i')
                .replace('ó', 'o')
                .replace('ú', 'u')
                .replace('ñ', 'n');
    }

    private int obtenerIdItemPorNombre(Connection conn, String nombre) throws SQLException {
        String sql = "SELECT item_id FROM public.mascota_catalogo_items WHERE nombre = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, nombre);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("item_id");
                }
            }
        }
        return -1;
    }

    private LocalDate obtenerUltimaFechaConActividad(Connection conn, int usuarioId) throws SQLException {
        // Buscar en progreso_bitacora_fuerza (ejercicios de fuerza)
        String sqlFuerza = "SELECT MAX(DATE(fecha)) as ultima_fecha FROM public.progreso_bitacora_fuerza "
                + "WHERE usuario_id = ? AND DATE(fecha) >= CURRENT_DATE - INTERVAL '1 day'";
        LocalDate ultimaFecha = null;
        
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

        // Buscar en progreso_bitacora_extra (deportes extra y correr)
        String sqlExtra = "SELECT MAX(fecha) as ultima_fecha FROM public.progreso_bitacora_fuerza b "
                + "JOIN public.entrenamiento_ejercicios e ON e.ejercicio_id = b.ejercicio_id "
                + "WHERE b.usuario_id = ? AND e.nombre = 'Correr' "
                + "AND b.fecha >= CURRENT_DATE - INTERVAL '1 day'";
        
        try (PreparedStatement ps = conn.prepareStatement(sqlExtra)) {
            ps.setInt(1, usuarioId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    java.sql.Date dbDate = rs.getDate("ultima_fecha");
                    if (dbDate != null) {
                        LocalDate fechaCorrer = dbDate.toLocalDate();
                        if (ultimaFecha == null || fechaCorrer.isAfter(ultimaFecha)) {
                            ultimaFecha = fechaCorrer;
                        }
                    }
                }
            }
        }

        return ultimaFecha;
    }

    private RachaResponse obtenerRachaActualOCrear(Connection conn, int usuarioId) throws SQLException {
        String sql = "SELECT racha_id, usuario_id, conteo_dias, ultima_fecha_actividad "
                + "FROM public.progreso_rachas WHERE usuario_id = ?";
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
        String sql = "INSERT INTO public.progreso_rachas (usuario_id, conteo_dias, ultima_fecha_actividad) "
                + "VALUES (?, ?, NULL) RETURNING racha_id";
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
        
        String sql = "UPDATE public.progreso_rachas SET conteo_dias = ?, ultima_fecha_actividad = ? "
                + "WHERE racha_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, nuevoConteo);
            if (ultimaFecha != null) {
                ps.setDate(2, Date.valueOf(ultimaFecha));
            } else {
                ps.setNull(2, java.sql.Types.DATE);
            }
            ps.setInt(3, rachaId);
            ps.executeUpdate();
        }
    }

    private RachaResponse mapRachaResponse(ResultSet rs) throws SQLException {
        RachaResponse racha = new RachaResponse();
        racha.setRachaId(rs.getInt("racha_id"));
        racha.setUsuarioId(rs.getInt("usuario_id"));
        racha.setConteoDias(rs.getInt("conteo_dias"));
        
        java.sql.Date dbDate = rs.getDate("ultima_fecha_actividad");
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
