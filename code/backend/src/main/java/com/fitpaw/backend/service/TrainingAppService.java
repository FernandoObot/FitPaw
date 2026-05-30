package com.fitpaw.backend.service;

import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Service;
import com.fitpaw.backend.DTOs.*;
import com.fitpaw.backend.repository.ConexionDB;

/**
 * ⚠️ DEPRECATED SERVICE - DESACTIVADO
 * 
 * Este servicio estaba vinculado a tablas NO AUTORIZADAS:
 * - entrenamiento_ejercicios (NO EXISTE en BD real)
 * - progreso_bitacora_fuerza (NO EXISTE en BD real)
 * - progreso_rachas (NO EXISTE en BD real)
 * 
 * ALTERNATIVAS ACTIVAS:
 * ✅ ExerciseService: Usa tablas reales (ejercicio_cardio, ejercicio_fuerza, usuarios_racha, mascota_alimento)
 * ✅ StreakService: Usa tabla real (usuarios_racha)
 * ✅ PetService: Usa tablas reales (mascota_estado, mascota_ropa, mascota_alimento)
 * 
 * Se mantiene solo para compatibilidad de inyección de dependencias en TrainingController.
 * Todos los métodos lanzan UnsupportedOperationException.
 */
@Service
@Deprecated(since = "2.0", forRemoval = true)
public class TrainingAppService {
    private final ConexionDB conexionDB;

    public TrainingAppService(ConexionDB conexionDB, MetaEvaluacionService metaEvaluacionService) {
        this.conexionDB = conexionDB;
    }

    private UnsupportedOperationException deprecated(String tabla) {
        return new UnsupportedOperationException(
            "❌ TrainingAppService DESACTIVADO - Tabla no autorizada: " + tabla);
    }

    // ============= Métodos requeridos por TrainingController =============
    // Todos lanzan UnsupportedOperationException ya que las tablas no existen
    
    public EjercicioCatalogoResponse crearEjercicio(CreateEjercicioRequest request) {
        throw deprecated("entrenamiento_ejercicios");
    }

    public EjercicioCatalogoResponse getEjercicioById(int ejercicioId) {
        throw deprecated("entrenamiento_ejercicios");
    }

    public EjercicioCatalogoResponse actualizarEjercicio(int ejercicioId, UpdateEjercicioRequest request) {
        throw deprecated("entrenamiento_ejercicios");
    }

    public void eliminarEjercicio(int ejercicioId) {
        throw deprecated("entrenamiento_ejercicios");
    }

    public OperacionResponse registrarSerie(RegistrarSerieRequest request) {
        throw deprecated("progreso_bitacora_fuerza");
    }

    public List<?> listarRegistrosFuerzaPorUsuario(int usuarioId) {
        throw deprecated("progreso_bitacora_fuerza");
    }

    public SerieFuerzaResponse obtenerRegistroFuerza(int registroId) {
        throw deprecated("progreso_bitacora_fuerza");
    }

    public SerieFuerzaResponse actualizarRegistroFuerza(int registroId, RegistrarSerieRequest request) {
        throw deprecated("progreso_bitacora_fuerza");
    }

    public void eliminarRegistroFuerza(int registroId) {
        throw deprecated("progreso_bitacora_fuerza");
    }

    public OperacionResponse registrarDeporteExtra(RegistrarDeporteExtraRequest request) {
        throw deprecated("progreso_bitacora_fuerza");
    }

    public RegistroCorrerResponse crearRegistroCorrer(RegistroCorrerRequest request) {
        throw deprecated("progreso_bitacora_fuerza");
    }

    public List<?> listarRegistrosCorrerPorUsuario(int usuarioId) {
        throw deprecated("progreso_bitacora_fuerza");
    }

    public RegistroCorrerResponse obtenerRegistroCorrer(int registroId) {
        throw deprecated("progreso_bitacora_fuerza");
    }

    public RegistroCorrerResponse actualizarRegistroCorrer(int registroId, RegistroCorrerRequest request) {
        throw deprecated("progreso_bitacora_fuerza");
    }

    public void eliminarRegistroCorrer(int registroId) {
        throw deprecated("progreso_bitacora_fuerza");
    }

    public List<?> getCatalogoEjercicios() {
        throw deprecated("entrenamiento_ejercicios");
    }

    public EstadisticasResponse getEstadisticas(int usuarioId) {
        throw deprecated("progreso_bitacora_fuerza, entrenamiento_ejercicios");
    }

    public OperacionResponse procesarCumplimientoMeta(CumplimientoMetaRequest request) {
        throw deprecated("progreso_rachas");
    }

    public SentadillasPlanResponse guardarSentadillasPlan(int usuarioId, SentadillasPlanRequest request) {
        throw deprecated("progreso_rutinas_personalizadas");
    }

    public SentadillasPlanResponse obtenerSentadillasPlan(int usuarioId, int diaSemana) {
        throw deprecated("progreso_rutinas_personalizadas");
    }

    public SentadillasPlanResponse marcarSentadillasCompletada(int usuarioId, int diaSemana) {
        throw deprecated("progreso_rutinas_personalizadas");
    }

    public Map<String, Object> guardarEjercicio(int usuarioId, Map<String, Object> body) {
        throw deprecated("entrenamiento_ejercicios");
    }

    public Map<String, Object> obtenerEjercicio(int usuarioId, String nombre, int diaSemana) {
        throw deprecated("entrenamiento_ejercicios");
    }

    public RutinaCompletadaResponse completarRutina(int usuarioId, CompletarRutinaRequest request) {
        throw deprecated("progreso_rutinas_personalizadas");
    }

    public List<?> listarRutinasCompletadas(int usuarioId, int diaSemana) {
        throw deprecated("progreso_rutinas_personalizadas");
    }

    public OperacionResponse limpiarCompletadosDelUsuario(int usuarioId) {
        throw deprecated("progreso_rutinas_personalizadas");
    }
}
