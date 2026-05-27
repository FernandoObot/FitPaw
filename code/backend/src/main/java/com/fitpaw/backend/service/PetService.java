package com.fitpaw.backend.service;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.ZoneId;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.fitpaw.backend.DTOs.FeedRequest;
import com.fitpaw.backend.DTOs.PetStatusResponse;
import com.fitpaw.backend.repository.ConexionDB;

@Service
public class PetService {

    private final ConexionDB conexionDB;

    @Value("${pet.hunger.decrease-ms-per-point:600000}")
    private long decreaseMsPerPoint; // default 10 minutes per 1 hunger point

    public PetService(ConexionDB conexionDB) {
        this.conexionDB = conexionDB;
    }

    public PetStatusResponse getPetStatus(int usuarioId) {
        try (Connection conn = conexionDB.conectar()) {
            // 🔑 SELECT solo con campos que existen en BD
            String sql = "SELECT mascota_id, nombre, hambre, ultima_vez_alimentado FROM public.mascota_estado WHERE usuario_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, usuarioId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        PetStatusResponse res = new PetStatusResponse();
                        res.setMascotaId(rs.getInt("mascota_id"));
                        res.setNombre(rs.getString("nombre"));
                        Integer storedHunger = rs.getObject("hambre") != null ? rs.getInt("hambre") : 100;
                        Timestamp last = rs.getTimestamp("ultima_vez_alimentado");
                        int current = computeHunger(storedHunger, last);
                        res.setHambre(current);
                        if (last != null) {
                            res.setUltimaVezAlimentado(last.toLocalDateTime());
                        }
                        return res;
                    } else {
                        // If no pet row, return defaults (hungry full)
                        PetStatusResponse res = new PetStatusResponse();
                        res.setMascotaId(null);
                        res.setNombre(null);
                        res.setHambre(100);
                        res.setUltimaVezAlimentado(null);
                        return res;
                    }
                }
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Error al obtener estado de mascota: " + e.getMessage());
        }
    }

    public PetStatusResponse feedPet(int usuarioId, FeedRequest request) {
        if (request == null || request.getItem() == null) {
            throw new IllegalArgumentException("El item es obligatorio");
        }

        int points = mapItemToPoints(request.getItem());
        if (points <= 0) throw new IllegalArgumentException("Item desconocido");

        try (Connection conn = conexionDB.conectar()) {
            // read current
            String select = "SELECT hambre, ultima_vez_alimentado FROM public.mascota_estado WHERE usuario_id = ? FOR UPDATE";
            try (PreparedStatement ps = conn.prepareStatement(select)) {
                ps.setInt(1, usuarioId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        Integer storedHunger = rs.getObject("hambre") != null ? rs.getInt("hambre") : 100;
                        Timestamp last = rs.getTimestamp("ultima_vez_alimentado");
                        int current = computeHunger(storedHunger, last);

                        int newHunger = Math.min(100, current + points);
                        Timestamp now = Timestamp.valueOf(LocalDateTime.now(ZoneId.systemDefault()));

                        String update = "UPDATE public.mascota_estado SET hambre = ?, ultima_vez_alimentado = ? WHERE usuario_id = ?";
                        try (PreparedStatement ups = conn.prepareStatement(update)) {
                            ups.setInt(1, newHunger);
                            ups.setTimestamp(2, now);
                            ups.setInt(3, usuarioId);
                            int updated = ups.executeUpdate();
                            if (updated == 0) {
                                throw new IllegalStateException("Usuario no encontrado en mascota_estado");
                            }
                        }

                        PetStatusResponse resp = getPetStatus(usuarioId);
                        resp.setHambre(newHunger);
                        resp.setUltimaVezAlimentado(now.toLocalDateTime());
                        return resp;
                    } else {
                        // create a new mascota_estado row for user
                        Timestamp now = Timestamp.valueOf(LocalDateTime.now(ZoneId.systemDefault()));
                        int newHunger = 100;
                        String insert = "INSERT INTO public.mascota_estado (usuario_id, nombre, nivel, experiencia_actual, hambre, ultima_vez_alimentado) VALUES (?, ?, ?, ?, ?, ?)";
                        try (PreparedStatement ins = conn.prepareStatement(insert)) {
                            ins.setInt(1, usuarioId);
                            ins.setString(2, "Mascota FitPaw");
                            ins.setInt(3, 1);
                            ins.setInt(4, 0);
                            ins.setInt(5, newHunger);
                            ins.setTimestamp(6, now);
                            ins.executeUpdate();
                        }
                        PetStatusResponse resp = getPetStatus(usuarioId);
                        return resp;
                    }
                }
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Error al alimentar mascota: " + e.getMessage());
        }
    }

    private int computeHunger(int storedHunger, Timestamp last) {
        if (storedHunger < 0) storedHunger = 0;
        if (storedHunger > 100) storedHunger = 100;
        if (last == null) return storedHunger;
        long elapsed = System.currentTimeMillis() - last.getTime();
        if (elapsed <= 0) return storedHunger;
        long pointsLost = decreaseMsPerPoint <= 0 ? 0 : (elapsed / decreaseMsPerPoint);
        long cur = storedHunger - pointsLost;
        if (cur > 100) cur = 100;
        if (cur < 0) cur = 0;
        return (int) cur;
    }

    private int mapItemToPoints(String key) {
        if (key == null) return 0;
        String k = key.trim().toLowerCase();
        // normalize basic accents
        k = k.replace('á','a').replace('é','e').replace('í','i').replace('ó','o').replace('ú','u').replace('ñ','n');
        if (k.equals("krill") || k.equals("camaron") || k.equals("shrimp")) return 5;
        if (k.equals("pez") || k.equals("fish")) return 10;
        if (k.equals("calamar") || k.equals("squid")) return 25;
        if (k.equals("coctel") || k.equals("cocktail")) return 50;
        return 0;
    }

    /**
     * Obtiene el inventario de comidas para una mascota
     */
    public java.util.List<com.fitpaw.backend.DTOs.PetFoodResponse> getPetFoods(int usuarioId) {
        try (Connection conn = conexionDB.conectar()) {
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

            java.util.List<com.fitpaw.backend.DTOs.PetFoodResponse> foods = new java.util.ArrayList<>();
            
            if (mascotaId > 0) {
                String sqlFoods = "SELECT nombre_comida, cantidad, beneficio_puntos FROM public.mascota_alimento WHERE mascota_id = ? ORDER BY nombre_comida";
                try (PreparedStatement ps = conn.prepareStatement(sqlFoods)) {
                    ps.setInt(1, mascotaId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            String nombreComida = rs.getString("nombre_comida");
                            Integer cantidad = rs.getInt("cantidad");
                            Integer beneficioPuntos = rs.getInt("beneficio_puntos");
                            foods.add(new com.fitpaw.backend.DTOs.PetFoodResponse(nombreComida, cantidad, beneficioPuntos));
                        }
                    }
                }
            }
            return foods;
        } catch (SQLException e) {
            throw new IllegalStateException("Error al obtener comidas: " + e.getMessage());
        }
    }
}
