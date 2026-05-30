package com.fitpaw.backend.service;

import java.util.List;
import java.util.Map;

import com.fitpaw.backend.DTOs.FeedRequest;
import com.fitpaw.backend.DTOs.PetFoodResponse;
import com.fitpaw.backend.DTOs.PetStatusResponse;

public interface PetUseCase {
    PetStatusResponse getPetStatus(int usuarioId);
    PetStatusResponse feedPet(int usuarioId, FeedRequest request);
    List<PetFoodResponse> getPetFoods(int usuarioId);
    PetStatusResponse updatePetName(int usuarioId, String nuevoNombre);
    List<Map<String, Object>> getPetClothing(int usuarioId);
    void updateClothingEquipped(int usuarioId, int ropaId, boolean estaEquipado);
    void updateClothingSlotEquipped(int usuarioId, int slot, boolean estaEquipado);
    void updateClothingByName(int usuarioId, String nombreRopa, boolean estaEquipado);
}
