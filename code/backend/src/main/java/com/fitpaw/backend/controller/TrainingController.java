package com.fitpaw.backend.controller;

import java.util.List;
import java.util.NoSuchElementException;
import java.util.function.Supplier;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestParam;

import com.fitpaw.backend.DTOs.CreateEjercicioRequest;
import com.fitpaw.backend.DTOs.EjercicioCatalogoResponse;
import com.fitpaw.backend.DTOs.EstadisticasResponse;
import com.fitpaw.backend.DTOs.OperacionResponse;
import com.fitpaw.backend.DTOs.RegistroCorrerRequest;
import com.fitpaw.backend.DTOs.RegistroCorrerResponse;
import com.fitpaw.backend.DTOs.SerieFuerzaResponse;
import com.fitpaw.backend.DTOs.UpdateEjercicioRequest;
import com.fitpaw.backend.DTOs.CumplimientoMetaRequest;
import com.fitpaw.backend.DTOs.RegistrarDeporteExtraRequest;
import com.fitpaw.backend.DTOs.RegistrarSerieRequest;
import com.fitpaw.backend.service.TrainingAppService;

@RestController
@RequestMapping("/training")
public class TrainingController {

    private final TrainingAppService trainingAppService;

    public TrainingController(TrainingAppService trainingAppService) {
        this.trainingAppService = trainingAppService;
    }

    @PostMapping("/ejercicios")
    public ResponseEntity<?> crearEjercicio(@RequestBody CreateEjercicioRequest body) {
        return run(() -> trainingAppService.crearEjercicio(body), HttpStatus.CREATED);
    }

    @GetMapping("/ejercicios/{ejercicioId}")
    public ResponseEntity<?> getEjercicio(@PathVariable int ejercicioId) {
        return run(() -> trainingAppService.getEjercicioById(ejercicioId), HttpStatus.OK);
    }

    @PutMapping("/ejercicios/{ejercicioId}")
    public ResponseEntity<?> actualizarEjercicio(@PathVariable int ejercicioId, @RequestBody UpdateEjercicioRequest body) {
        return run(() -> trainingAppService.actualizarEjercicio(ejercicioId, body), HttpStatus.OK);
    }

    @DeleteMapping("/ejercicios/{ejercicioId}")
    public ResponseEntity<?> eliminarEjercicio(@PathVariable int ejercicioId) {
        return run(() -> {
            trainingAppService.eliminarEjercicio(ejercicioId);
            return new OperacionResponse("ok", "DELETE /training/ejercicios/{ejercicioId}", "Ejercicio eliminado");
        }, HttpStatus.OK);
    }

    @PostMapping("/series")
    public ResponseEntity<?> registrarSeries(@RequestBody RegistrarSerieRequest body) {
        return run(() -> trainingAppService.registrarSerie(body), HttpStatus.OK);
    }

    @GetMapping("/series")
    public ResponseEntity<?> listarSeries(@RequestParam int usuarioId) {
        return run(() -> trainingAppService.listarRegistrosFuerzaPorUsuario(usuarioId), HttpStatus.OK);
    }

    @GetMapping("/series/{registroId}")
    public ResponseEntity<?> getSerie(@PathVariable int registroId) {
        return run(() -> trainingAppService.obtenerRegistroFuerza(registroId), HttpStatus.OK);
    }

    @PutMapping("/series/{registroId}")
    public ResponseEntity<?> actualizarSerie(@PathVariable int registroId, @RequestBody RegistrarSerieRequest body) {
        return run(() -> trainingAppService.actualizarRegistroFuerza(registroId, body), HttpStatus.OK);
    }

    @DeleteMapping("/series/{registroId}")
    public ResponseEntity<?> eliminarSerie(@PathVariable int registroId) {
        return run(() -> {
            trainingAppService.eliminarRegistroFuerza(registroId);
            return new OperacionResponse("ok", "DELETE /training/series/{registroId}", "Registro de fuerza eliminado");
        }, HttpStatus.OK);
    }

    @PostMapping("/deporte-extra")
    public ResponseEntity<?> registrarDeporteExtra(@RequestBody RegistrarDeporteExtraRequest body) {
        return run(() -> trainingAppService.registrarDeporteExtra(body), HttpStatus.OK);
    }

    @PostMapping("/correr")
    public ResponseEntity<?> crearRegistroCorrer(@RequestBody RegistroCorrerRequest body) {
        return run(() -> trainingAppService.crearRegistroCorrer(body), HttpStatus.CREATED);
    }

    @GetMapping("/correr")
    public ResponseEntity<?> listarRegistrosCorrer(@RequestParam int usuarioId) {
        return run(() -> trainingAppService.listarRegistrosCorrerPorUsuario(usuarioId), HttpStatus.OK);
    }

    @GetMapping("/correr/{registroExtraId}")
    public ResponseEntity<?> getRegistroCorrer(@PathVariable int registroExtraId) {
        return run(() -> trainingAppService.obtenerRegistroCorrer(registroExtraId), HttpStatus.OK);
    }

    @PutMapping("/correr/{registroExtraId}")
    public ResponseEntity<?> actualizarRegistroCorrer(@PathVariable int registroExtraId, @RequestBody RegistroCorrerRequest body) {
        return run(() -> trainingAppService.actualizarRegistroCorrer(registroExtraId, body), HttpStatus.OK);
    }

    @DeleteMapping("/correr/{registroExtraId}")
    public ResponseEntity<?> eliminarRegistroCorrer(@PathVariable int registroExtraId) {
        return run(() -> {
            trainingAppService.eliminarRegistroCorrer(registroExtraId);
            return new OperacionResponse("ok", "DELETE /training/correr/{registroExtraId}", "Registro de correr eliminado");
        }, HttpStatus.OK);
    }

    @GetMapping("/ejercicios")
    public ResponseEntity<?> getCatalogoEjercicios() {
        return run(() -> trainingAppService.getCatalogoEjercicios(), HttpStatus.OK);
    }

    @GetMapping("/estadisticas/{usuarioId}")
    public ResponseEntity<?> getEstadisticas(@PathVariable int usuarioId) {
        return run(() -> trainingAppService.getEstadisticas(usuarioId), HttpStatus.OK);
    }

    @PostMapping("/cumplimiento-meta")
    public ResponseEntity<?> procesarCumplimientoMeta(@RequestBody CumplimientoMetaRequest body) {
        return run(() -> trainingAppService.procesarCumplimientoMeta(body), HttpStatus.OK);
    }

    private ResponseEntity<?> run(Supplier<Object> action, HttpStatus successStatus) {
        try {
            return ResponseEntity.status(successStatus).body(action.get());
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(new OperacionResponse("error", "validation", e.getMessage()));
        } catch (NoSuchElementException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(new OperacionResponse("error", "not_found", e.getMessage()));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new OperacionResponse("error", "server", e.getMessage()));
        }
    }
}