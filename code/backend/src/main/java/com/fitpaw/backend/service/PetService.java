package com.fitpaw.backend.service;

import com.fitpaw.backend.model.Pet;
import org.springframework.stereotype.Service;

@Service
public class PetService {
    
    public Pet actualizarEstado(Pet pet){
        
        // Simulación de tiempo → aumenta hambre
        pet.setHambre(pet.getHambre() + 5);

        // Si hambre alta → baja salud
        if (pet.getHambre() > 70) {
            pet.setSalud(pet.getSalud() - 10);
        }

        // Subir nivel
        if (pet.getExperienciaActual() >= 100) {
            pet.setNivel(pet.getNivel() + 1);
            pet.setExperienciaActual(0);
        }

        return pet;
    }

}
