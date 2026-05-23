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
}
