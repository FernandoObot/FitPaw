package com.fitpaw.backend.service;

import com.fitpaw.backend.repository.ConexionDB;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Date;
import java.time.LocalDate;

@Service
public class StreakRewardService {

    @Autowired
    private ConexionDB conexionDB;

    /**
     * Obtiene la mascota del usuario para asignar recompensas
     */
    private int obtenerMascotaId(Connection conn, int usuarioId) throws SQLException {
        String sql = "SELECT mascota_id FROM public.mascota_estado WHERE usuario_id = ? LIMIT 1";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, usuarioId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int mascotaId = rs.getInt("mascota_id");
                    System.out.println("✅ Mascota encontrada para usuario " + usuarioId + ": mascota_id=" + mascotaId);
                    return mascotaId;
                }
            }
        }
        System.out.println("❌ No se encontró mascota para usuario " + usuarioId);
        return -1;
    }

    /**
     * Verifica y actualiza la racha del usuario
     * Retorna true si es el primer ejercicio del día (racha fue activada)
     */
    public boolean verificarYActualizarRacha(Connection conn, int usuarioId, LocalDate fechaHoy) throws SQLException {
        System.out.println("🔄 Verificando racha para usuario " + usuarioId + " en fecha " + fechaHoy);
        
        try {
            // Obtener la racha actual
            String sqlObtener = "SELECT racha_id, cantidad_dias, fecha_ultima_actividad, activa FROM public.usuarios_racha WHERE usuario_id = ? ORDER BY racha_id DESC LIMIT 1";
            
            try (PreparedStatement ps = conn.prepareStatement(sqlObtener)) {
                ps.setInt(1, usuarioId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        // Primera vez, crear racha nueva
                        System.out.println("✅ Primera racha para usuario " + usuarioId);
                        crearRachaInicial(conn, usuarioId, fechaHoy);
                        return true;
                    }

                    int rachaId = rs.getInt("racha_id");
                    int cantidadDias = rs.getInt("cantidad_dias");
                    LocalDate fechaUltimaActividad = rs.getDate("fecha_ultima_actividad") != null ? 
                        rs.getDate("fecha_ultima_actividad").toLocalDate() : null;
                    boolean activa = rs.getBoolean("activa");
                    
                    System.out.println("📊 Racha actual - ID: " + rachaId + ", Días: " + cantidadDias + 
                        ", Última actividad: " + fechaUltimaActividad + ", Activa: " + activa);

                    // Verificar si ya hay actividad hoy
                    if (fechaUltimaActividad != null && fechaUltimaActividad.equals(fechaHoy)) {
                        // Ya hay actividad hoy, no es el primer ejercicio
                        System.out.println("⏭️ Ya hay actividad hoy, no es primer ejercicio");
                        return false;
                    }

                    // Verificar si debe continuar o reiniciar la racha
                    if (fechaUltimaActividad != null) {
                        long diasDiferencia = java.time.temporal.ChronoUnit.DAYS.between(fechaUltimaActividad, fechaHoy);
                        System.out.println("📅 Días desde última actividad: " + diasDiferencia);

                        if (diasDiferencia == 1) {
                            // Continuar racha (fue ayer el último ejercicio)
                            int nuevosDias = cantidadDias + 1;
                            System.out.println("➕ Continuando racha: " + cantidadDias + " -> " + nuevosDias + " días");
                            actualizarRacha(conn, rachaId, nuevosDias, fechaHoy, true);
                            return true;
                        } else if (diasDiferencia > 1) {
                            // Reiniciar racha (pasaron más de 1 día)
                            System.out.println("🔄 Reiniciando racha (pasaron " + diasDiferencia + " días)");
                            crearRachaInicial(conn, usuarioId, fechaHoy);
                            return true;
                        }
                    } else {
                        // Primera actividad, actualizar
                        System.out.println("🆕 Primera actividad en la racha");
                        actualizarRacha(conn, rachaId, 1, fechaHoy, true);
                        return true;
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ Error al actualizar racha: " + e.getMessage());
            e.printStackTrace();
            throw new IllegalStateException("Error al actualizar racha: " + e.getMessage());
        }
        return false;
    }

    /**
     * Crea una racha inicial para el usuario
     */
    private void crearRachaInicial(Connection conn, int usuarioId, LocalDate fechaHoy) throws SQLException {
        String sql = "INSERT INTO public.usuarios_racha (usuario_id, fecha_inicio, fecha_ultima_actividad, cantidad_dias, activa) " +
                     "VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, usuarioId);
            ps.setDate(2, Date.valueOf(fechaHoy));
            ps.setDate(3, Date.valueOf(fechaHoy));
            ps.setInt(4, 1);
            ps.setBoolean(5, true);
            ps.executeUpdate();
        }
    }

    /**
     * Actualiza una racha existente
     */
    private void actualizarRacha(Connection conn, int rachaId, int nuevosDias, LocalDate fechaUltima, boolean activa) throws SQLException {
        String sql = "UPDATE public.usuarios_racha SET cantidad_dias = ?, fecha_ultima_actividad = ?, activa = ? WHERE racha_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, nuevosDias);
            ps.setDate(2, Date.valueOf(fechaUltima));
            ps.setBoolean(3, activa);
            ps.setInt(4, rachaId);
            ps.executeUpdate();
        }
    }

    /**
     * Obtiene la cantidad actual de días de racha
     */
    public int obtenerDiasRachaActual(Connection conn, int usuarioId) throws SQLException {
        String sql = "SELECT cantidad_dias FROM public.usuarios_racha WHERE usuario_id = ? ORDER BY racha_id DESC LIMIT 1";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, usuarioId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("cantidad_dias");
                }
            }
        }
        return 0;
    }

    /**
     * Cuenta cuántos ejercicios fueron completados hoy
     */
    public int contarEjerciciosCompletadosHoy(Connection conn, int usuarioId, LocalDate fechaHoy) throws SQLException {
        int totalCompletados = 0;

        // Contar en cardio
        String sqlCardio = "SELECT COUNT(*) FROM public.ejercicio_cardio WHERE usuario_id = ? AND fecha = ? AND completado = true";
        try (PreparedStatement ps = conn.prepareStatement(sqlCardio)) {
            ps.setInt(1, usuarioId);
            ps.setDate(2, Date.valueOf(fechaHoy));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalCompletados += rs.getInt(1);
                }
            }
        }

        // Contar en fuerza
        String sqlFuerza = "SELECT COUNT(*) FROM public.ejercicio_fuerza WHERE usuario_id = ? AND fecha = ? AND completado = true";
        try (PreparedStatement ps = conn.prepareStatement(sqlFuerza)) {
            ps.setInt(1, usuarioId);
            ps.setDate(2, Date.valueOf(fechaHoy));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalCompletados += rs.getInt(1);
                }
            }
        }

        return totalCompletados;
    }

    /**
     * Verifica los ejercicios específicos completados hoy:
     * - Sentadillas
     * - Correr
     * - Press de hombros
     * - Flexión una pierna
     */
    public boolean verificarLos4EjerciciosCompletados(Connection conn, int usuarioId, LocalDate fechaHoy) throws SQLException {
        String[] ejerciciosRequeridos = {"Sentadillas", "Correr", "Press de hombros", "Flexión una pierna"};
        int completados = 0;

        for (String ejercicio : ejerciciosRequeridos) {
            String sql = "SELECT COUNT(*) FROM public.ejercicio_fuerza WHERE usuario_id = ? AND fecha = ? AND nombre = ? AND completado = true " +
                        "UNION ALL " +
                        "SELECT COUNT(*) FROM public.ejercicio_cardio WHERE usuario_id = ? AND fecha = ? AND nombre = ? AND completado = true";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, usuarioId);
                ps.setDate(2, Date.valueOf(fechaHoy));
                ps.setString(3, ejercicio);
                ps.setInt(4, usuarioId);
                ps.setDate(5, Date.valueOf(fechaHoy));
                ps.setString(6, ejercicio);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        if (rs.getInt(1) > 0) {
                            completados++;
                            break;
                        }
                    }
                }
            }
        }

        return completados == ejerciciosRequeridos.length;
    }

    /**
     * Otorga alimento a la mascota del usuario
     * NOTA: Asume que los registros de comida ya existen en mascota_alimento (creados al registrarse)
     */
    public boolean otorgarAlimento(Connection conn, int usuarioId, String nombreComida, int cantidad) throws SQLException {
        System.out.println("🍽️ Intentando otorgar: " + cantidad + "x " + nombreComida + " a usuario " + usuarioId);
        
        int mascotaId = obtenerMascotaId(conn, usuarioId);
        if (mascotaId <= 0) {
            System.out.println("❌ No se pudo otorgar alimento: mascota no encontrada");
            return false;
        }

        try {
            int beneficioPuntos = obtenerBeneficioPuntos(nombreComida);
            System.out.println("📊 Beneficio de puntos para " + nombreComida + ": " + beneficioPuntos);

            // Actualizar cantidad existente (el registro SIEMPRE existe)
            String sqlUpdate = "UPDATE public.mascota_alimento SET cantidad = cantidad + ? WHERE mascota_id = ? AND nombre_comida = ?";
            try (PreparedStatement psUpdate = conn.prepareStatement(sqlUpdate)) {
                psUpdate.setInt(1, cantidad);
                psUpdate.setInt(2, mascotaId);
                psUpdate.setString(3, nombreComida);
                int updated = psUpdate.executeUpdate();
                
                if (updated > 0) {
                    System.out.println("✅ Alimento actualizado: " + nombreComida + " +=" + cantidad);
                    return true;
                } else {
                    String insertSql = "INSERT INTO public.mascota_alimento (mascota_id, nombre_comida, cantidad, beneficio_puntos) "
                            + "VALUES (?, ?, ?, ?)";
                    try (PreparedStatement psInsert = conn.prepareStatement(insertSql)) {
                        psInsert.setInt(1, mascotaId);
                        psInsert.setString(2, nombreComida);
                        psInsert.setInt(3, cantidad);
                        psInsert.setInt(4, beneficioPuntos);
                        psInsert.executeUpdate();
                        System.out.println("✅ Alimento creado: " + nombreComida + " +=" + cantidad);
                        return true;
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("❌ Error al otorgar alimento: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
    }

    /**
     * Obtiene los puntos de beneficio según el nombre del alimento
     */
    private int obtenerBeneficioPuntos(String nombreComida) {
        switch (nombreComida) {
            case "Krill":
                return 15;
            case "Pez":
                return 25;
            case "Calamar":
                return 50;
            case "Coctel":
                return 100;
            default:
                return 0;
        }
    }

    /**
     * Verifica si se alcanzó racha de 30 días y desbloquea atuendos
     */
    public java.util.List<String> verificarDesbloqueoAtuendos30Dias(Connection conn, int usuarioId) throws SQLException {
        String sqlObtenerRacha = "SELECT cantidad_dias FROM public.usuarios_racha WHERE usuario_id = ? ORDER BY racha_id DESC LIMIT 1";
        
        try (PreparedStatement ps = conn.prepareStatement(sqlObtenerRacha)) {
            ps.setInt(1, usuarioId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int diasRacha = rs.getInt("cantidad_dias");
                    
                    if (diasRacha >= 30) {
                        System.out.println("🎉 ¡Racha de 30 días alcanzada para usuario " + usuarioId + "!");
                        int mascotaId = obtenerMascotaId(conn, usuarioId);
                        if (mascotaId > 0) {
                            return crearAtuendosDesbloqueados(conn, mascotaId);
                        }
                    }
                }
            }
        }
        return new java.util.ArrayList<>();
    }

    /**
     * Crea los atuendos desbloqueados a los 30 días
     * Los 5 prendas disponibles son: Conjunto 1, 2, 3, 4, 5
     * Al registrarse, solo "vacio" se crea
     * A los 30 días, se desbloquean Conjunto 1, 2, 3, 4, 5
     */
    private java.util.List<String> crearAtuendosDesbloqueados(Connection conn, int mascotaId) throws SQLException {
        // Estos son los 5 prendas que se muestran en el frontend
        String[] atuendos = {"Conjunto 1", "Conjunto 2", "Conjunto 3", "Conjunto 4", "Conjunto 5"};
        java.util.List<String> nuevos = new java.util.ArrayList<>();
        
        for (String atuendo : atuendos) {
            // Verificar si ya existe
            String checkSql = "SELECT ropa_id FROM public.mascota_ropa WHERE mascota_id = ? AND nombre_ropa = ?";
            boolean existe = false;
            
            try (PreparedStatement psCheck = conn.prepareStatement(checkSql)) {
                psCheck.setInt(1, mascotaId);
                psCheck.setString(2, atuendo);
                try (ResultSet rs = psCheck.executeQuery()) {
                    existe = rs.next();
                }
            }
            
            if (!existe) {
                String insertSql = "INSERT INTO public.mascota_ropa (mascota_id, nombre_ropa, esta_equipado) VALUES (?, ?, ?)";
                try (PreparedStatement psInsert = conn.prepareStatement(insertSql)) {
                    psInsert.setInt(1, mascotaId);
                    psInsert.setString(2, atuendo);
                    psInsert.setBoolean(3, false); // No equipado por defecto
                    psInsert.executeUpdate();
                    nuevos.add(atuendo);
                    System.out.println("✅ Atuendo desbloqueado: " + atuendo + " para mascota " + mascotaId);
                }
            } else {
                System.out.println("⚠️ Atuendo ya existe: " + atuendo);
            }
        }
        return nuevos;
    }
}
