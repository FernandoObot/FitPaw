package com.fitpaw.backend.service;

import com.fitpaw.backend.model.Pet;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

public class TrainingServiceTest {

     private TrainingService trainingService;

 @BeforeEach
 void setUp() {
     trainingService = new TrainingService();
 }

 @Test
 void calcularVolumenTotal_devuelveProducto() {
     int resultado = trainingService.calcularVolumenTotal(10, 20);
     assertEquals(200, resultado);
 }

 @Test
 void calcularVolumenTotal_lanzaExcepcionSiRepsInvalidas() {
     assertThrows(IllegalArgumentException.class,
             () -> trainingService.calcularVolumenTotal(0, 20));
 }

 @Test
 void calcularExperiencia_devuelveVolumen() {
     int resultado = trainingService.calcularExperiencia(8, 50);
     assertEquals(400, resultado);
 }

 @Test
 void esNuevoPR_trueCuandoNoHayPRPrevio() {
     assertTrue(trainingService.esNuevoPR(60, null));
 }

 @Test
 void esNuevoPR_trueCuandoSuperaPRPrevio() {
     assertTrue(trainingService.esNuevoPR(70, 65));
 }

 @Test
 void esNuevoPR_falseCuandoNoSuperaPRPrevio() {
     assertFalse(trainingService.esNuevoPR(60, 65));
 }

 @Test
 void aplicarEntrenamiento_sumaExperiencia() {
     Pet pet = new Pet();
     pet.setExperienciaActual(100);

     Pet actualizado = trainingService.aplicarEntrenamiento(pet, 50);

     assertEquals(150, actualizado.getExperienciaActual());
 }

 @Test
 void aplicarEntrenamiento_lanzaExcepcionSiPetEsNull() {
     assertThrows(IllegalArgumentException.class,
             () -> trainingService.aplicarEntrenamiento(null, 10));
 }

 @Test
 void aplicarEntrenamiento_lanzaExcepcionSiExperienciaEsNegativa() {
     Pet pet = new Pet();
     pet.setExperienciaActual(100);

     assertThrows(IllegalArgumentException.class,
             () -> trainingService.aplicarEntrenamiento(pet, -1));
 }
    
}
