package com.fitpaw.backend.service;

import com.fitpaw.backend.DTOs.SaveCardioExerciseRequest;
import com.fitpaw.backend.DTOs.SaveFuerzaExerciseRequest;
import com.fitpaw.backend.repository.ConexionDB;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Date;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.time.LocalDate;

@Service
public class ExerciseService {

    @Autowired
    private ConexionDB conexionDB;

    @Autowired
    private StreakRewardService streakRewardService;

    /**
     * Guardar ejercicio cardio
     */
    public void saveCardioExercise(int usuarioId, SaveCardioExerciseRequest request) {
        if (request == null || request.getNombre() == null || request.getNombre().isEmpty()) {
            throw new IllegalArgumentException("Nombre del ejercicio es requerido");
        }

        try (Connection conn = conexionDB.conectar()) {
            String sql = "INSERT INTO public.ejercicio_cardio (nombre, dificultad, tiempo_minutos, usuario_id, fecha, hora, completado) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?)";
            
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, request.getNombre());
                ps.setObject(2, request.getDificultad());
                ps.setObject(3, request.getTiempo_minutos());
                ps.setInt(4, usuarioId);
                ps.setDate(5, Date.valueOf(request.getFecha()));
                ps.setObject(6, request.getHora());
                ps.setBoolean(7, false); // completado = false
                
                ps.executeUpdate();
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Error al guardar ejercicio cardio: " + e.getMessage());
        }
    }

    /**
     * Obtener ejercicios guardados por fecha (cardio + fuerza)
     */
    public List<Map<String, Object>> getExercisesByDate(int usuarioId, LocalDate fecha) {
        List<Map<String, Object>> results = new ArrayList<>();

        try (Connection conn = conexionDB.conectar()) {
            // Cardio
            String sqlCardio = "SELECT ejercicio_id, nombre, dificultad, tiempo_minutos, fecha, hora, completado FROM public.ejercicio_cardio WHERE usuario_id = ? AND fecha = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlCardio)) {
                ps.setInt(1, usuarioId);
                ps.setDate(2, Date.valueOf(fecha));
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> row = new HashMap<>();
                        row.put("tipo", "cardio");
                        row.put("ejercicio_id", rs.getInt("ejercicio_id"));
                        row.put("nombre", rs.getString("nombre"));
                        row.put("dificultad", rs.getInt("dificultad"));
                        row.put("tiempo_minutos", rs.getObject("tiempo_minutos"));
                        row.put("fecha", rs.getDate("fecha").toString());
                        row.put("hora", rs.getObject("hora"));
                        row.put("completado", rs.getBoolean("completado"));
                        results.add(row);
                    }
                }
            }

            // Fuerza
            String sqlFuerza = "SELECT ejercicio_id, nombre, grupo_muscular, dificultad, repeticiones, peso, fecha, hora, completado FROM public.ejercicio_fuerza WHERE usuario_id = ? AND fecha = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlFuerza)) {
                ps.setInt(1, usuarioId);
                ps.setDate(2, Date.valueOf(fecha));
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> row = new HashMap<>();
                        row.put("tipo", "fuerza");
                        row.put("ejercicio_id", rs.getInt("ejercicio_id"));
                        row.put("nombre", rs.getString("nombre"));
                        row.put("grupo_muscular", rs.getString("grupo_muscular"));
                        row.put("dificultad", rs.getInt("dificultad"));
                        row.put("repeticiones", rs.getObject("repeticiones"));
                        row.put("peso", rs.getObject("peso"));
                        row.put("fecha", rs.getDate("fecha").toString());
                        row.put("hora", rs.getObject("hora"));
                        row.put("completado", rs.getBoolean("completado"));
                        results.add(row);
                    }
                }
            }

            return results;
        } catch (SQLException e) {
            throw new IllegalStateException("Error al obtener ejercicios por fecha: " + e.getMessage());
        }
    }

    /**
     * Guardar ejercicio de fuerza
     */
    public void saveFuerzaExercise(int usuarioId, SaveFuerzaExerciseRequest request) {
        if (request == null || request.getNombre() == null || request.getNombre().isEmpty()) {
            throw new IllegalArgumentException("Nombre del ejercicio es requerido");
        }

        try (Connection conn = conexionDB.conectar()) {
            String sql = "INSERT INTO public.ejercicio_fuerza (nombre, grupo_muscular, dificultad, repeticiones, peso, usuario_id, fecha, hora, completado) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, request.getNombre());
                ps.setString(2, request.getGrupo_muscular());
                ps.setObject(3, request.getDificultad());
                ps.setObject(4, request.getRepeticiones());
                ps.setObject(5, request.getPeso());
                ps.setInt(6, usuarioId);
                ps.setDate(7, Date.valueOf(request.getFecha()));
                ps.setObject(8, request.getHora());
                ps.setBoolean(9, false); // completado = false
                
                ps.executeUpdate();
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Error al guardar ejercicio de fuerza: " + e.getMessage());
        }
    }

    /**
     * Marcar ejercicio como completado (actualizar campo completado a true)
     * También gestiona rachas y recompensas
     */
    public void markExerciseCompleted(int usuarioId, String nombre, LocalDate fecha) {
        System.out.println("\n=== MARCAR EJERCICIO COMPLETADO ===");
        System.out.println("Usuario: " + usuarioId + ", Ejercicio: " + nombre + ", Fecha: " + fecha);
        
        try (Connection conn = conexionDB.conectar()) {
            // Marcar el ejercicio como completado
            boolean ejercicioEncontrado = false;

            // Intentar actualizar en ejercicio_cardio
            String sqlCardio = "UPDATE public.ejercicio_cardio SET completado = true WHERE usuario_id = ? AND nombre = ? AND fecha = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlCardio)) {
                ps.setInt(1, usuarioId);
                ps.setString(2, nombre);
                ps.setDate(3, Date.valueOf(fecha));
                
                int rowsAffected = ps.executeUpdate();
                if (rowsAffected > 0) {
                    ejercicioEncontrado = true;
                    System.out.println("✅ Ejercicio marcado en cardio");
                }
            }

            // Si no encontró en cardio, intentar en ejercicio_fuerza
            if (!ejercicioEncontrado) {
                String sqlFuerza = "UPDATE public.ejercicio_fuerza SET completado = true WHERE usuario_id = ? AND nombre = ? AND fecha = ?";
                try (PreparedStatement ps = conn.prepareStatement(sqlFuerza)) {
                    ps.setInt(1, usuarioId);
                    ps.setString(2, nombre);
                    ps.setDate(3, Date.valueOf(fecha));
                    
                    int rowsAffected = ps.executeUpdate();
                    if (rowsAffected == 0) {
                        throw new IllegalArgumentException("No se encontró el ejercicio: " + nombre);
                    }
                    ejercicioEncontrado = true;
                    System.out.println("✅ Ejercicio marcado en fuerza");
                }
            }

            if (!ejercicioEncontrado) {
                throw new IllegalArgumentException("No se encontró el ejercicio: " + nombre);
            }

            // ===== SISTEMA DE RACHAS Y RECOMPENSAS =====
            System.out.println("\n🏆 INICIANDO SISTEMA DE RECOMPENSAS...");

            // 1. Verificar y actualizar racha (retorna true si es el primer ejercicio del día)
            boolean esFirstPasoRacha = streakRewardService.verificarYActualizarRacha(conn, usuarioId, fecha);
            System.out.println("Primer ejercicio del día: " + esFirstPasoRacha);

            if (esFirstPasoRacha) {
                // Es el primer ejercicio del día - la racha fue activada
                // Recompensa: +1 Calamar (50 puntos)
                System.out.println("🦑 Otorgando Calamar...");
                streakRewardService.otorgarAlimento(conn, usuarioId, "Calamar", 1);

                // Obtener los días de racha actual para revisar si es múltiplo de 5
                int diasRacha = streakRewardService.obtenerDiasRachaActual(conn, usuarioId);
                System.out.println("Días de racha actual: " + diasRacha);
                
                if (diasRacha > 0 && diasRacha % 5 == 0) {
                    // Múltiplo de 5 días - dar Coctel
                    System.out.println("🍸 Día múltiplo de 5! Otorgando Coctel...");
                    streakRewardService.otorgarAlimento(conn, usuarioId, "Coctel", 1);
                }
            }

            // 2. Dar Krill por completar este ejercicio
            System.out.println("🦐 Otorgando Krill...");
            streakRewardService.otorgarAlimento(conn, usuarioId, "Krill", 1);

            // 3. Verificar si ya han completado los 4 ejercicios
            System.out.println("🔍 Verificando si están los 4 ejercicios completados...");
            if (streakRewardService.verificarLos4EjerciciosCompletados(conn, usuarioId, fecha)) {
                // Dar 2 Peces (2 * 25 = 50 puntos)
                System.out.println("🐟 ¡Los 4 ejercicios completados! Otorgando 2 Peces...");
                streakRewardService.otorgarAlimento(conn, usuarioId, "Pez", 2);
            }
            
            System.out.println("=== FIN DE RECOMPENSAS ===\n");

        } catch (SQLException e) {
            System.err.println("❌ Error SQL: " + e.getMessage());
            e.printStackTrace();
            throw new IllegalStateException("Error al marcar ejercicio como completado: " + e.getMessage());
        }
    }

    /**
     * Eliminar un ejercicio de la base de datos
     */
    public void deleteExercise(int usuarioId, String nombre, LocalDate fecha) {
        try (Connection conn = conexionDB.conectar()) {
            // Intentar eliminar de ejercicio_cardio
            String sqlCardio = "DELETE FROM public.ejercicio_cardio WHERE usuario_id = ? AND nombre = ? AND fecha = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlCardio)) {
                ps.setInt(1, usuarioId);
                ps.setString(2, nombre);
                ps.setDate(3, Date.valueOf(fecha));
                
                int rowsAffected = ps.executeUpdate();
                if (rowsAffected > 0) {
                    return; // Eliminado de cardio
                }
            }

            // Si no encontró en cardio, intentar en ejercicio_fuerza
            String sqlFuerza = "DELETE FROM public.ejercicio_fuerza WHERE usuario_id = ? AND nombre = ? AND fecha = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlFuerza)) {
                ps.setInt(1, usuarioId);
                ps.setString(2, nombre);
                ps.setDate(3, Date.valueOf(fecha));
                
                int rowsAffected = ps.executeUpdate();
                if (rowsAffected == 0) {
                    throw new IllegalArgumentException("No se encontró el ejercicio para eliminar: " + nombre);
                }
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Error al eliminar ejercicio: " + e.getMessage());
        }
    }
}
