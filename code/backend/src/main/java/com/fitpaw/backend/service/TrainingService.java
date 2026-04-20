package com.fitpaw.backend.service;

import org.springframework.stereotype.Service;

import com.fitpaw.backend.model.Pet;

@Service
public class TrainingService {

    public int calcularVolumenTotal(int reps, int peso) {
        validarPositivos(reps, peso);
        return reps * peso;
    }

    public int calcularExperiencia(int reps, int peso) {
        int volumen = calcularVolumenTotal(reps, peso);
        return volumen;
    }

    public boolean esNuevoPR(int pesoSesion, Integer prActual){
        if (prActual == null) {
            return true; // Si no hay PR actual, cualquier peso es un nuevo PR
        }
        return pesoSesion > prActual;
    }

    public Pet aplicarEntrenamiento(Pet pet, int experienciaGanada) {
        if (pet == null) {
            throw new IllegalArgumentException("La mascota no puede ser nula");
        }
        if (experienciaGanada < 0) {
            throw new IllegalArgumentException("La experiencia ganada no puede ser negativa");
    }
        pet.setExperienciaActual(pet.getExperienciaActual() + experienciaGanada);
        return pet;
    }

    private void validarPositivos(int reps, int peso) {
        if (reps <= 0 || peso <= 0) {
            throw new IllegalArgumentException("Las repeticiones y el peso deben ser positivos");
        }
    }

}
