package com.fitpaw.backend.service;

import org.springframework.stereotype.Service;

import com.fitpaw.backend.model.Pet;

@Service
public class TrainingService {

    public int calcularExperiencia(int reps, int peso) {
        return reps * peso; // Ejemplo simple de cálculo de experiencia
    }

    public Pet aplicarEntrenamiento(Pet pet, int experienciaGanada) {
        pet.setExperienciaActual(pet.getExperienciaActual() + experienciaGanada);

        return pet;
    }

}
