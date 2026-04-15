package com.fitpaw.backend.controller;

import java.time.LocalDate;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fitpaw.backend.DTOs.TrainingRequest;
import com.fitpaw.backend.DTOs.TrainingResponse;
import com.fitpaw.backend.model.Pet;
import com.fitpaw.backend.service.AchievementEngine;
import com.fitpaw.backend.service.PetService;
import com.fitpaw.backend.service.ProgressService;
import com.fitpaw.backend.service.TrainingService;

@RestController
@RequestMapping("/training")
public class TrainingController {

    @Autowired
    private TrainingService trainingService;

    @Autowired
    private PetService petService;

    @Autowired
    private ProgressService progressService;

    @Autowired
    private AchievementEngine achievementEngine;

    @PostMapping("/registrar")
    public TrainingResponse registrarEntrenamiento(@RequestBody TrainingRequest request){
        // Simulación de mascota base (A.BD)
        Pet pet = new Pet();
        pet.setMascotaId(1);
        pet.setUsuarioId(request.getUsuarioId());
        pet.setNombre("PinguiPaw");
        pet.setNivel(1);
        pet.setExperienciaActual(0);
        pet.setHambre(50);
        pet.setSalud(100);

        // Calcular experiencia ganada
        int exp = trainingService.calcularExperiencia(request.getReps(), request.getPeso());

        // Aplicar entrenamiento
        pet = trainingService.aplicarEntrenamiento(pet, exp);

        // Actualizar estado de la mascota
        pet = petService.actualizarEstado(pet);

        // Simulación de racha de entrenamiento (A.BD)
        LocalDate ultimaFecha = null;
        int rachaActual = 0;
        int nuevaRacha = progressService.actualizarRacha(ultimaFecha, rachaActual);
        System.out.println("Racha actual: " + nuevaRacha);

        // Simulación de logros (A.BD)
        String logro = achievementEngine.verificarLogros(nuevaRacha, exp);
        if (logro != null) {
            System.out.println(logro);
        }

        TrainingResponse response = new TrainingResponse();
        response.setPet(pet);
        response.setRacha(nuevaRacha);
        response.setLogro(logro);

        return response;
    }

}
