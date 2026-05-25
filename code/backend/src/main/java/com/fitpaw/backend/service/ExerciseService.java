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
     */
    public void markExerciseCompleted(int usuarioId, String nombre, LocalDate fecha) {
        try (Connection conn = conexionDB.conectar()) {
            // Intentar actualizar en ejercicio_cardio
            String sqlCardio = "UPDATE public.ejercicio_cardio SET completado = true WHERE usuario_id = ? AND nombre = ? AND fecha = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlCardio)) {
                ps.setInt(1, usuarioId);
                ps.setString(2, nombre);
                ps.setDate(3, Date.valueOf(fecha));
                
                int rowsAffected = ps.executeUpdate();
                if (rowsAffected > 0) {
                    return; // Actualizado en cardio
                }
            }

            // Si no encontró en cardio, intentar en ejercicio_fuerza
            String sqlFuerza = "UPDATE public.ejercicio_fuerza SET completado = true WHERE usuario_id = ? AND nombre = ? AND fecha = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlFuerza)) {
                ps.setInt(1, usuarioId);
                ps.setString(2, nombre);
                ps.setDate(3, Date.valueOf(fecha));
                
                int rowsAffected = ps.executeUpdate();
                if (rowsAffected == 0) {
                    throw new IllegalArgumentException("No se encontró el ejercicio: " + nombre);
                }
            }
        } catch (SQLException e) {
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
