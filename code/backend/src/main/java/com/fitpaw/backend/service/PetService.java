package com.fitpaw.backend.service;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.fitpaw.backend.DTOs.FeedRequest;
import com.fitpaw.backend.DTOs.PetStatusResponse;
import com.fitpaw.backend.repository.ConexionDB;

@Service
public class PetService {

    private final ConexionDB conexionDB;
    private final StreakRewardService streakRewardService;

    @Value("${pet.hunger.decrease-ms-per-point:600000}")
    private long decreaseMsPerPoint; // default 10 minutes per 1 hunger point

    public PetService(ConexionDB conexionDB, StreakRewardService streakRewardService) {
        this.conexionDB = conexionDB;
        this.streakRewardService = streakRewardService;
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
            // Obtener mascota_id
            String selectMascota = "SELECT mascota_id FROM public.mascota_estado WHERE usuario_id = ? FOR UPDATE";
            int mascotaId = -1;
            try (PreparedStatement ps = conn.prepareStatement(selectMascota)) {
                ps.setInt(1, usuarioId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        mascotaId = rs.getInt("mascota_id");
                    } else {
                        throw new IllegalStateException("Mascota no encontrada para el usuario");
                    }
                }
            }

            // Verificar que hay cantidad del alimento disponible
            String checkFood = "SELECT cantidad FROM public.mascota_alimento WHERE mascota_id = ? AND LOWER(nombre_comida) = LOWER(?) FOR UPDATE";
            int foodQuantity = 0;
            try (PreparedStatement ps = conn.prepareStatement(checkFood)) {
                ps.setInt(1, mascotaId);
                ps.setString(2, request.getItem());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        foodQuantity = rs.getInt("cantidad");
                    }
                }
            }

            if (foodQuantity <= 0) {
                throw new IllegalArgumentException("No hay cantidad suficiente de este alimento");
            }

            // Disminuir la cantidad de alimento en 1
            String decreaseFood = "UPDATE public.mascota_alimento SET cantidad = cantidad - 1 WHERE mascota_id = ? AND LOWER(nombre_comida) = LOWER(?)";
            try (PreparedStatement ps = conn.prepareStatement(decreaseFood)) {
                ps.setInt(1, mascotaId);
                ps.setString(2, request.getItem());
                ps.executeUpdate();
            }

            // Actualizar hambre de la mascota
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
        if (k.equals("calamar") || k.equals("squid")) return 50;
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

    /**
     * Actualiza el nombre de la mascota
     */
    public PetStatusResponse updatePetName(int usuarioId, String nuevoNombre) {
        if (nuevoNombre == null || nuevoNombre.trim().isEmpty()) {
            throw new IllegalArgumentException("El nombre no puede estar vacío");
        }

        String nombreLimpio = nuevoNombre.trim();
        if (nombreLimpio.length() > 50) {
            throw new IllegalArgumentException("El nombre no puede exceder 50 caracteres");
        }

        try (Connection conn = conexionDB.conectar()) {
            String sql = "UPDATE public.mascota_estado SET nombre = ? WHERE usuario_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, nombreLimpio);
                ps.setInt(2, usuarioId);
                int updated = ps.executeUpdate();
                if (updated == 0) {
                    throw new IllegalStateException("Mascota no encontrada para el usuario");
                }
            }

            return getPetStatus(usuarioId);
        } catch (SQLException e) {
            throw new IllegalStateException("Error al actualizar nombre de mascota: " + e.getMessage());
        }
    }

    /**
     * Establece el nivel de hambre de la mascota
     */
    public PetStatusResponse setHungerLevel(int usuarioId, int nuevoHambre) {
        if (nuevoHambre < 0 || nuevoHambre > 100) {
            throw new IllegalArgumentException("El hambre debe estar entre 0 y 100");
        }

        try (Connection conn = conexionDB.conectar()) {
            String sql = "UPDATE public.mascota_estado SET hambre = ?, ultima_vez_alimentado = ? WHERE usuario_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, nuevoHambre);
                ps.setTimestamp(2, Timestamp.valueOf(LocalDateTime.now()));
                ps.setInt(3, usuarioId);
                int updated = ps.executeUpdate();
                if (updated == 0) {
                    throw new IllegalStateException("Mascota no encontrada para el usuario");
                }
            }

            return getPetStatus(usuarioId);
        } catch (SQLException e) {
            throw new IllegalStateException("Error al actualizar hambre de mascota: " + e.getMessage());
        }
    }

    /**
     * Obtiene la ropa desbloqueada para la mascota del usuario
     */
    public java.util.List<Map<String, Object>> getPetClothing(int usuarioId) {
        try (Connection conn = conexionDB.conectar()) {
            // Obtener mascota_id
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

            java.util.List<Map<String, Object>> clothing = new java.util.ArrayList<>();
            
            if (mascotaId > 0) {
                streakRewardService.verificarDesbloqueoAtuendos30Dias(conn, usuarioId);

                String sqlClothing = "SELECT ropa_id, nombre_ropa, esta_equipado FROM public.mascota_ropa WHERE mascota_id = ? ORDER BY ropa_id";
                try (PreparedStatement ps = conn.prepareStatement(sqlClothing)) {
                    ps.setInt(1, mascotaId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            Map<String, Object> item = new java.util.HashMap<>();
                            item.put("ropa_id", rs.getInt("ropa_id"));
                            item.put("nombre_ropa", rs.getString("nombre_ropa"));
                            item.put("esta_equipado", rs.getBoolean("esta_equipado"));
                            clothing.add(item);
                        }
                    }
                }
            }
            return clothing;
        } catch (SQLException e) {
            throw new IllegalStateException("Error al obtener ropa: " + e.getMessage());
        }
    }

    /**
     * Actualiza el estado de equipado para una prenda de ropa
     */
    public void updateClothingEquipped(int usuarioId, int ropaId, boolean estaEquipado) {
        try (Connection conn = conexionDB.conectar()) {
            // Primero, si se está equipando, desequipar todas las demás
            if (estaEquipado) {
                String desequiparSql = "UPDATE public.mascota_ropa SET esta_equipado = false WHERE ropa_id != ? AND mascota_id = (SELECT mascota_id FROM public.mascota_estado WHERE usuario_id = ?)";
                try (PreparedStatement ps = conn.prepareStatement(desequiparSql)) {
                    ps.setInt(1, ropaId);
                    ps.setInt(2, usuarioId);
                    ps.executeUpdate();
                }
            }

            // Actualizar la ropa especificada
            String updateSql = "UPDATE public.mascota_ropa SET esta_equipado = ? WHERE ropa_id = ? AND mascota_id = (SELECT mascota_id FROM public.mascota_estado WHERE usuario_id = ?)";
            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setBoolean(1, estaEquipado);
                ps.setInt(2, ropaId);
                ps.setInt(3, usuarioId);
                int updated = ps.executeUpdate();
                if (updated == 0) {
                    throw new IllegalStateException("Ropa no encontrada para el usuario");
                }
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Error al actualizar ropa: " + e.getMessage());
        }
    }
}
