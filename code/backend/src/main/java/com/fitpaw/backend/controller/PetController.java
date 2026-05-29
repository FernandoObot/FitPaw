package com.fitpaw.backend.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

import com.fitpaw.backend.DTOs.FeedRequest;
import com.fitpaw.backend.DTOs.PetStatusResponse;
import com.fitpaw.backend.service.PetService;

@RestController
@RequestMapping("/pet")
public class PetController {

    private final PetService petService;

    public PetController(PetService petService) {
        this.petService = petService;
    }

    private int getUsuarioIdFromAuth() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null) throw new IllegalStateException("No autenticado");
        Object d = auth.getDetails();
        if (d instanceof Integer) return (Integer) d;
        if (d instanceof String) return Integer.parseInt((String) d);
        throw new IllegalStateException("No se pudo obtener usuarioId del token");
    }

    @GetMapping("/status")
    public ResponseEntity<?> status() {
        int usuarioId = getUsuarioIdFromAuth();
        PetStatusResponse resp = petService.getPetStatus(usuarioId);
        return ResponseEntity.ok(resp);
    }

    @PostMapping("/feed")
    public ResponseEntity<?> feed(@RequestBody FeedRequest request) {
        int usuarioId = getUsuarioIdFromAuth();
        PetStatusResponse resp = petService.feedPet(usuarioId, request);
        return ResponseEntity.ok(resp);
    }

    @GetMapping("/foods")
    public ResponseEntity<?> getFoods() {
        int usuarioId = getUsuarioIdFromAuth();
        java.util.List<com.fitpaw.backend.DTOs.PetFoodResponse> foods = petService.getPetFoods(usuarioId);
        return ResponseEntity.ok(foods);
    }

    @PutMapping("/name")
    public ResponseEntity<?> updateName(@RequestBody java.util.Map<String, String> request) {
        int usuarioId = getUsuarioIdFromAuth();
        String nuevoNombre = request.get("nombre");
        PetStatusResponse resp = petService.updatePetName(usuarioId, nuevoNombre);
        return ResponseEntity.ok(resp);
    }

    @PostMapping("/hunger-decrease")
    public ResponseEntity<?> decreaseHunger(@RequestBody java.util.Map<String, Integer> request) {
        int usuarioId = getUsuarioIdFromAuth();
        Integer newHunger = request.get("cantidad");
        if (newHunger == null) {
            return ResponseEntity.badRequest().body("El campo 'cantidad' es obligatorio");
        }
        PetStatusResponse resp = petService.setHungerLevel(usuarioId, newHunger);
        return ResponseEntity.ok(resp);
    }

    @GetMapping("/clothing")
    public ResponseEntity<?> getClothing() {
        int usuarioId = getUsuarioIdFromAuth();
        java.util.List<java.util.Map<String, Object>> clothing = petService.getPetClothing(usuarioId);
        return ResponseEntity.ok(clothing);
    }

    @PostMapping("/clothing/equip")
    public ResponseEntity<?> equipClothing(@RequestBody java.util.Map<String, Object> request) {
        int usuarioId = getUsuarioIdFromAuth();
        Integer ropaId = ((Number) request.get("ropaId")).intValue();
        Boolean estaEquipado = (Boolean) request.get("estaEquipado");
        
        if (ropaId == null || estaEquipado == null) {
            return ResponseEntity.badRequest().body("Los campos 'ropaId' y 'estaEquipado' son obligatorios");
        }
        
        petService.updateClothingEquipped(usuarioId, ropaId, estaEquipado);
        return ResponseEntity.ok(java.util.Map.of("success", true, "message", "Ropa actualizada"));
    }
}
