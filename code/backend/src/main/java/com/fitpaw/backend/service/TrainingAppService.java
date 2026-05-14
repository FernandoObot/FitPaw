package com.fitpaw.backend.service;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.NoSuchElementException;
import java.util.Map;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Service;

import com.fitpaw.backend.DTOs.CreateEjercicioRequest;
import com.fitpaw.backend.DTOs.CompletarRutinaRequest;
import com.fitpaw.backend.DTOs.EjercicioCatalogoResponse;
import com.fitpaw.backend.DTOs.EstadisticasResponse;
import com.fitpaw.backend.DTOs.OperacionResponse;
import com.fitpaw.backend.DTOs.RegistroCorrerRequest;
import com.fitpaw.backend.DTOs.RegistroCorrerResponse;
import com.fitpaw.backend.DTOs.SerieFuerzaResponse;
import com.fitpaw.backend.DTOs.CumplimientoMetaRequest;
import com.fitpaw.backend.DTOs.SentadillasPlanRequest;
import com.fitpaw.backend.DTOs.SentadillasPlanResponse;
import com.fitpaw.backend.DTOs.RutinaCompletadaResponse;
import com.fitpaw.backend.DTOs.RegistrarDeporteExtraRequest;
import com.fitpaw.backend.DTOs.RegistrarSerieRequest;
import com.fitpaw.backend.DTOs.UpdateEjercicioRequest;
import com.fitpaw.backend.model.MetaUsuario;
import com.fitpaw.backend.model.RegistroActividad;
import com.fitpaw.backend.model.Racha;
import com.fitpaw.backend.repository.ConexionDB;

@Service
public class TrainingAppService {

    private static final String CORRER_NOMBRE = "Correr";
    private static final String DIFICULTAD_PREFIX = "DIFICULTAD:";
    private final ConexionDB conexionDB;
    private final MetaEvaluacionService metaEvaluacionService;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public TrainingAppService(ConexionDB conexionDB, MetaEvaluacionService metaEvaluacionService) {
        this.conexionDB = conexionDB;
        this.metaEvaluacionService = metaEvaluacionService;
    }

    public OperacionResponse registrarSerie(RegistrarSerieRequest request) {
        SerieFuerzaResponse creada = crearRegistroFuerza(request);
        return new OperacionResponse(
                "ok",
                "POST /training/series",
                "Serie registrada con id " + creada.getRegistroId()
        );
    }

    public OperacionResponse registrarDeporteExtra(RegistrarDeporteExtraRequest request) {
        RegistroCorrerRequest correrRequest = new RegistroCorrerRequest();
        correrRequest.setUsuarioId(request.getUsuarioId());
        correrRequest.setDificultad(request.getDificultad());
        correrRequest.setDistanciaKm(request.getDistanciaKm());
        correrRequest.setFecha(request.getFecha());

        RegistroCorrerResponse creada = crearRegistroCorrer(correrRequest);
        return new OperacionResponse(
                "ok",
                "POST /training/deporte-extra",
                "Registro de correr creado con id " + creada.getRegistroExtraId()
        );
    }

    public SentadillasPlanResponse guardarSentadillasPlan(int usuarioId, SentadillasPlanRequest request) {
        validarUsuarioId(usuarioId);
        validarSentadillasRequest(request);

        try (Connection conn = conexionDB.conectar()) {
            asegurarCompatibilidadSentadillas(conn);
            validarUsuarioExiste(conn, usuarioId);

            String payload = serializarPlan(request);
            int rutinaId = obtenerRutinaSentadillasId(conn, usuarioId, request.getDiaSemana());

            if (rutinaId > 0) {
                String sql = "UPDATE public.progreso_rutinas_personalizadas SET nombre_rutina = ?, dia_semana = ?, completado = false, completado_en = NULL "
                        + "WHERE rutina_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, payload);
                    ps.setInt(2, request.getDiaSemana());
                    ps.setInt(3, rutinaId);
                    ps.executeUpdate();
                }
            } else {
                String sql = "INSERT INTO public.progreso_rutinas_personalizadas (usuario_id, nombre_rutina, dia_semana, completado) "
                    + "VALUES (?, ?, ?, false) RETURNING rutina_id";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, usuarioId);
                    ps.setString(2, payload);
                    ps.setInt(3, request.getDiaSemana());
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            rutinaId = rs.getInt("rutina_id");
                        }
                    }
                }
            }

            return obtenerSentadillasPlan(usuarioId, request.getDiaSemana());
        } catch (SQLException e) {
            throw new IllegalStateException("Error al guardar plan de sentadillas: " + e.getMessage());
        }
    }

    public SentadillasPlanResponse obtenerSentadillasPlan(int usuarioId, int diaSemana) {
        validarUsuarioId(usuarioId);
        validarDiaSemana(diaSemana);

        try (Connection conn = conexionDB.conectar()) {
            asegurarCompatibilidadSentadillas(conn);
            validarUsuarioExiste(conn, usuarioId);

                String sql = "SELECT rutina_id, usuario_id, nombre_rutina, dia_semana, COALESCE(completado, false) AS completado "
                    + "FROM public.progreso_rutinas_personalizadas "
                    + "WHERE usuario_id = ? AND dia_semana = ? ORDER BY rutina_id DESC LIMIT 1";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, usuarioId);
                ps.setInt(2, diaSemana);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return mapSentadillasPlan(rs);
                    }
                }
            }

            throw new NoSuchElementException("No existe plan de sentadillas para el dia " + diaSemana);
        } catch (SQLException e) {
            throw new IllegalStateException("Error al consultar plan de sentadillas: " + e.getMessage());
        }
    }

    public List<EjercicioCatalogoResponse> getCatalogoEjercicios() {
        try (Connection conn = conexionDB.conectar()) {
            String sql = "SELECT ejercicio_id, nombre, grupo_muscular, descripcion, url_media "
                    + "FROM public.entrenamiento_ejercicios ORDER BY ejercicio_id";
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                List<EjercicioCatalogoResponse> out = new ArrayList<>();
                while (rs.next()) {
                    out.add(mapEjercicio(rs));
                }
                return out;
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Error al consultar ejercicios: " + e.getMessage());
        }
    }

    public EstadisticasResponse getEstadisticas(int usuarioId) {
        validarUsuarioId(usuarioId);

        try (Connection conn = conexionDB.conectar()) {
            validarUsuarioExiste(conn, usuarioId);

            int rachaActual = 0;
            String sqlRacha = "SELECT conteo_dias FROM public.progreso_rachas "
                    + "WHERE usuario_id = ? ORDER BY racha_id DESC LIMIT 1";
            try (PreparedStatement ps = conn.prepareStatement(sqlRacha)) {
                ps.setInt(1, usuarioId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        rachaActual = rs.getInt("conteo_dias");
                    }
                }
            }

            int volumenTotal = 0;
            String sqlVolumen = "SELECT COALESCE(SUM(peso_kg * repeticiones), 0) AS volumen "
                    + "FROM public.progreso_bitacora_fuerza WHERE usuario_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlVolumen)) {
                ps.setInt(1, usuarioId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        volumenTotal = (int) Math.round(rs.getDouble("volumen"));
                    }
                }
            }

            List<String> prs = new ArrayList<>();
            String sqlPrs = "SELECT e.nombre, MAX(b.peso_kg) AS max_peso "
                    + "FROM public.progreso_bitacora_fuerza b "
                    + "JOIN public.entrenamiento_ejercicios e ON e.ejercicio_id = b.ejercicio_id "
                    + "WHERE b.usuario_id = ? "
                    + "GROUP BY e.nombre "
                    + "ORDER BY max_peso DESC LIMIT 5";
            try (PreparedStatement ps = conn.prepareStatement(sqlPrs)) {
                ps.setInt(1, usuarioId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        prs.add(rs.getString("nombre") + ": " + rs.getDouble("max_peso") + " kg");
                    }
                }
            }

            return new EstadisticasResponse(rachaActual, volumenTotal, prs);
        } catch (SQLException e) {
            throw new IllegalStateException("Error al consultar estadisticas: " + e.getMessage());
        }
    }

    public EjercicioCatalogoResponse crearEjercicio(CreateEjercicioRequest request) {
        if (request == null) {
            throw new IllegalArgumentException("El body para crear ejercicio es obligatorio");
        }

        String nombre = clean(request.getNombre());
        if (nombre.isEmpty()) {
            throw new IllegalArgumentException("El nombre del ejercicio es obligatorio");
        }

        try (Connection conn = conexionDB.conectar()) {
            String sql = "INSERT INTO public.entrenamiento_ejercicios "
                    + "(nombre, grupo_muscular, descripcion, instrucciones_json, url_media) "
                    + "VALUES (?, ?, ?, ?, ?) "
                    + "RETURNING ejercicio_id, nombre, grupo_muscular, descripcion, url_media";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, nombre);
                ps.setString(2, nullableTrim(request.getGrupoMuscular()));
                ps.setString(3, nullableTrim(request.getDescripcion()));
                ps.setString(4, nullableTrim(request.getInstruccionesJson()));
                ps.setString(5, nullableTrim(request.getUrlMedia()));
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return mapEjercicio(rs);
                    }
                }
            }
            throw new IllegalStateException("No fue posible crear el ejercicio");
        } catch (SQLException e) {
            throw new IllegalStateException("Error al crear ejercicio: " + e.getMessage());
        }
    }

    public EjercicioCatalogoResponse getEjercicioById(int ejercicioId) {
        validarId(ejercicioId, "ejercicioId");
        try (Connection conn = conexionDB.conectar()) {
            String sql = "SELECT ejercicio_id, nombre, grupo_muscular, descripcion, url_media "
                    + "FROM public.entrenamiento_ejercicios WHERE ejercicio_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, ejercicioId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return mapEjercicio(rs);
                    }
                }
            }
            throw new NoSuchElementException("No existe el ejercicio con id " + ejercicioId);
        } catch (SQLException e) {
            throw new IllegalStateException("Error al consultar ejercicio: " + e.getMessage());
        }
    }

    public EjercicioCatalogoResponse actualizarEjercicio(int ejercicioId, UpdateEjercicioRequest request) {
        validarId(ejercicioId, "ejercicioId");
        if (request == null) {
            throw new IllegalArgumentException("El body para actualizar ejercicio es obligatorio");
        }

        String nombre = clean(request.getNombre());
        if (nombre.isEmpty()) {
            throw new IllegalArgumentException("El nombre del ejercicio es obligatorio");
        }

        try (Connection conn = conexionDB.conectar()) {
            validarEjercicioExiste(conn, ejercicioId);

            String sql = "UPDATE public.entrenamiento_ejercicios "
                    + "SET nombre = ?, grupo_muscular = ?, descripcion = ?, instrucciones_json = ?, url_media = ? "
                    + "WHERE ejercicio_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, nombre);
                ps.setString(2, nullableTrim(request.getGrupoMuscular()));
                ps.setString(3, nullableTrim(request.getDescripcion()));
                ps.setString(4, nullableTrim(request.getInstruccionesJson()));
                ps.setString(5, nullableTrim(request.getUrlMedia()));
                ps.setInt(6, ejercicioId);
                ps.executeUpdate();
            }

            return getEjercicioById(ejercicioId);
        } catch (SQLException e) {
            throw new IllegalStateException("Error al actualizar ejercicio: " + e.getMessage());
        }
    }

    public void eliminarEjercicio(int ejercicioId) {
        validarId(ejercicioId, "ejercicioId");
        try (Connection conn = conexionDB.conectar()) {
            validarEjercicioExiste(conn, ejercicioId);

            String sql = "DELETE FROM public.entrenamiento_ejercicios WHERE ejercicio_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, ejercicioId);
                ps.executeUpdate();
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Error al eliminar ejercicio: " + e.getMessage());
        }
    }

    public SerieFuerzaResponse crearRegistroFuerza(RegistrarSerieRequest request) {
        validarRequestSerie(request);
        try (Connection conn = conexionDB.conectar()) {
            validarUsuarioExiste(conn, request.getUsuarioId());
            validarEjercicioExiste(conn, request.getEjercicioId());

            String sql = "INSERT INTO public.progreso_bitacora_fuerza "
                    + "(usuario_id, ejercicio_id, serie_numero, peso_kg, repeticiones, fecha) "
                    + "VALUES (?, ?, ?, ?, ?, ?) RETURNING registro_id";
            int registroId;
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, request.getUsuarioId());
                ps.setInt(2, request.getEjercicioId());
                ps.setInt(3, request.getSerieNumero());
                ps.setDouble(4, request.getPeso());
                ps.setInt(5, request.getRepeticiones());
                ps.setTimestamp(6, Timestamp.valueOf(LocalDateTime.now()));
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        throw new IllegalStateException("No se pudo crear registro de fuerza");
                    }
                    registroId = rs.getInt("registro_id");
                }
            }

            guardarRepeticionesEnEjercicio(conn, request.getEjercicioId(), request.getRepeticiones());
            return obtenerRegistroFuerza(registroId);
        } catch (SQLException e) {
            throw new IllegalStateException("Error al crear registro de fuerza: " + e.getMessage());
        }
    }

    public SerieFuerzaResponse obtenerRegistroFuerza(int registroId) {
        validarId(registroId, "registroId");
        try (Connection conn = conexionDB.conectar()) {
            String sql = "SELECT b.registro_id, b.usuario_id, b.ejercicio_id, e.nombre AS ejercicio_nombre, "
                    + "b.serie_numero, b.repeticiones, b.peso_kg, b.fecha, e.instrucciones_json "
                    + "FROM public.progreso_bitacora_fuerza b "
                    + "JOIN public.entrenamiento_ejercicios e ON e.ejercicio_id = b.ejercicio_id "
                    + "WHERE b.registro_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, registroId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return mapSerie(rs);
                    }
                }
            }
            throw new NoSuchElementException("No existe el registro de fuerza con id " + registroId);
        } catch (SQLException e) {
            throw new IllegalStateException("Error al consultar registro de fuerza: " + e.getMessage());
        }
    }

    public List<SerieFuerzaResponse> listarRegistrosFuerzaPorUsuario(int usuarioId) {
        validarUsuarioId(usuarioId);
        try (Connection conn = conexionDB.conectar()) {
            validarUsuarioExiste(conn, usuarioId);

            String sql = "SELECT b.registro_id, b.usuario_id, b.ejercicio_id, e.nombre AS ejercicio_nombre, "
                    + "b.serie_numero, b.repeticiones, b.peso_kg, b.fecha, e.instrucciones_json "
                    + "FROM public.progreso_bitacora_fuerza b "
                    + "JOIN public.entrenamiento_ejercicios e ON e.ejercicio_id = b.ejercicio_id "
                    + "WHERE b.usuario_id = ? ORDER BY b.fecha DESC, b.registro_id DESC";

            List<SerieFuerzaResponse> out = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, usuarioId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        out.add(mapSerie(rs));
                    }
                }
            }
            return out;
        } catch (SQLException e) {
            throw new IllegalStateException("Error al listar registros de fuerza: " + e.getMessage());
        }
    }

    public SerieFuerzaResponse actualizarRegistroFuerza(int registroId, RegistrarSerieRequest request) {
        validarId(registroId, "registroId");
        validarRequestSerie(request);
        try (Connection conn = conexionDB.conectar()) {
            validarRegistroFuerzaExiste(conn, registroId);
            validarUsuarioExiste(conn, request.getUsuarioId());
            validarEjercicioExiste(conn, request.getEjercicioId());

            String sql = "UPDATE public.progreso_bitacora_fuerza "
                    + "SET usuario_id = ?, ejercicio_id = ?, serie_numero = ?, peso_kg = ?, repeticiones = ?, fecha = ? "
                    + "WHERE registro_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, request.getUsuarioId());
                ps.setInt(2, request.getEjercicioId());
                ps.setInt(3, request.getSerieNumero());
                ps.setDouble(4, request.getPeso());
                ps.setInt(5, request.getRepeticiones());
                ps.setTimestamp(6, Timestamp.valueOf(LocalDateTime.now()));
                ps.setInt(7, registroId);
                ps.executeUpdate();
            }
            guardarRepeticionesEnEjercicio(conn, request.getEjercicioId(), request.getRepeticiones());
            return obtenerRegistroFuerza(registroId);
        } catch (SQLException e) {
            throw new IllegalStateException("Error al actualizar registro de fuerza: " + e.getMessage());
        }
    }

    public void eliminarRegistroFuerza(int registroId) {
        validarId(registroId, "registroId");
        try (Connection conn = conexionDB.conectar()) {
            validarRegistroFuerzaExiste(conn, registroId);
            String sql = "DELETE FROM public.progreso_bitacora_fuerza WHERE registro_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, registroId);
                ps.executeUpdate();
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Error al eliminar registro de fuerza: " + e.getMessage());
        }
    }

    public RegistroCorrerResponse crearRegistroCorrer(RegistroCorrerRequest request) {
        validarRequestCorrer(request);
        String dificultad = normalizarDificultad(request.getDificultad());

        try (Connection conn = conexionDB.conectar()) {
            validarUsuarioExiste(conn, request.getUsuarioId());
            int ejercicioId = obtenerOCrearEjercicioCorrer(conn, dificultad);

            guardarDificultadEnEjercicio(conn, ejercicioId, dificultad);

            // Registrar en progreso_bitacora_fuerza como ejercicio cardio
            String sql = "INSERT INTO public.progreso_bitacora_fuerza "
                    + "(usuario_id, ejercicio_id, serie_numero, distancia_km, peso_kg, repeticiones, fecha) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?) RETURNING registro_id";

            int registroId;
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, request.getUsuarioId());
                ps.setInt(2, ejercicioId);
                ps.setInt(3, Math.max(1, (int) Math.round(request.getDistanciaKm() * 1000.0)));
                ps.setDouble(4, request.getDistanciaKm());
                ps.setDouble(5, 0.0); // peso_kg = 0 (no aplica para correr)
                ps.setInt(6, 0); // repeticiones = 0 (no aplica para correr)
                ps.setTimestamp(7, Timestamp.valueOf(LocalDateTime.now()));
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        throw new IllegalStateException("No se pudo crear registro de correr");
                    }
                    registroId = rs.getInt("registro_id");
                }
            }
            return obtenerRegistroCorrer(registroId);
        } catch (SQLException e) {
            throw new IllegalStateException("Error al crear registro de correr: " + e.getMessage());
        }
    }

    public RegistroCorrerResponse obtenerRegistroCorrer(int registroId) {
        validarId(registroId, "registroId");
        try (Connection conn = conexionDB.conectar()) {
                String sql = "SELECT b.registro_id, b.usuario_id, b.ejercicio_id, b.serie_numero, "
                    + "COALESCE(b.distancia_km, b.serie_numero / 1000.0) AS distancia_km, e.descripcion, "
                    + "b.fecha "
                    + "FROM public.progreso_bitacora_fuerza b "
                    + "JOIN public.entrenamiento_ejercicios e ON e.ejercicio_id = b.ejercicio_id "
                    + "WHERE b.registro_id = ? AND e.nombre = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, registroId);
                ps.setString(2, CORRER_NOMBRE);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return mapCorrer(rs);
                    }
                }
            }
            throw new NoSuchElementException("No existe el registro de correr con id " + registroId);
        } catch (SQLException e) {
            throw new IllegalStateException("Error al consultar registro de correr: " + e.getMessage());
        }
    }

    public List<RegistroCorrerResponse> listarRegistrosCorrerPorUsuario(int usuarioId) {
        validarUsuarioId(usuarioId);
        try (Connection conn = conexionDB.conectar()) {
            validarUsuarioExiste(conn, usuarioId);

                String sql = "SELECT b.registro_id, b.usuario_id, b.ejercicio_id, b.serie_numero, "
                    + "COALESCE(b.distancia_km, b.serie_numero / 1000.0) AS distancia_km, e.descripcion, b.fecha "
                    + "FROM public.progreso_bitacora_fuerza b "
                    + "JOIN public.entrenamiento_ejercicios e ON e.ejercicio_id = b.ejercicio_id "
                    + "WHERE b.usuario_id = ? AND e.nombre = ? "
                    + "ORDER BY b.fecha DESC, b.registro_id DESC";

            List<RegistroCorrerResponse> out = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, usuarioId);
                ps.setString(2, CORRER_NOMBRE);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        out.add(mapCorrer(rs));
                    }
                }
            }
            return out;
        } catch (SQLException e) {
            throw new IllegalStateException("Error al listar registros de correr: " + e.getMessage());
        }
    }

    public RegistroCorrerResponse actualizarRegistroCorrer(int registroId, RegistroCorrerRequest request) {
        validarId(registroId, "registroId");
        validarRequestCorrer(request);
        String dificultad = normalizarDificultad(request.getDificultad());

        try (Connection conn = conexionDB.conectar()) {
            validarRegistroCorrerExiste(conn, registroId);
            validarUsuarioExiste(conn, request.getUsuarioId());
            int ejercicioId = obtenerOCrearEjercicioCorrer(conn, dificultad);

            guardarDificultadEnEjercicio(conn, ejercicioId, dificultad);

            String sql = "UPDATE public.progreso_bitacora_fuerza "
                    + "SET usuario_id = ?, ejercicio_id = ?, serie_numero = ?, distancia_km = ?, peso_kg = ?, repeticiones = ?, fecha = ? "
                    + "WHERE registro_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, request.getUsuarioId());
                ps.setInt(2, ejercicioId);
                ps.setInt(3, Math.max(1, (int) Math.round(request.getDistanciaKm() * 1000.0)));
                ps.setDouble(4, request.getDistanciaKm());
                ps.setDouble(5, 0.0);
                ps.setInt(6, 0);
                ps.setTimestamp(7, Timestamp.valueOf(LocalDateTime.now()));
                ps.setInt(8, registroId);
                ps.executeUpdate();
            }

            return obtenerRegistroCorrer(registroId);
        } catch (SQLException e) {
            throw new IllegalStateException("Error al actualizar registro de correr: " + e.getMessage());
        }
    }

    public void eliminarRegistroCorrer(int registroId) {
        validarId(registroId, "registroId");
        try (Connection conn = conexionDB.conectar()) {
            validarRegistroCorrerExiste(conn, registroId);
            String sql = "DELETE FROM public.progreso_bitacora_fuerza WHERE registro_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, registroId);
                ps.executeUpdate();
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Error al eliminar registro de correr: " + e.getMessage());
        }
    }

    public OperacionResponse procesarCumplimientoMeta(CumplimientoMetaRequest request) {
        if (request == null) {
            throw new IllegalArgumentException("request no puede ser nulo");
        }

        MetaUsuario meta = request.getMeta();
        RegistroActividad registro = request.getRegistro();
        Racha racha = request.getRacha();

        if (meta == null || registro == null || racha == null) {
            throw new IllegalArgumentException("meta, registro y racha son obligatorios");
        }

        boolean cumplio = metaEvaluacionService.cumpleMeta(meta, registro);
        metaEvaluacionService.aplicarCumplimiento(meta, registro);

        if (!cumplio) {
            return new OperacionResponse(
                    "ok",
                    "POST /training/cumplimiento-meta",
                    "Meta no cumplida. No se actualiza racha."
            );
        }

        metaEvaluacionService.actualizarRacha(racha, registro);
        String recompensa = metaEvaluacionService.determinarRecompensa(racha);

        if (!metaEvaluacionService.recompensaYaAsignada(registro)) {
            metaEvaluacionService.marcarRecompensaAsignada(registro);
        }

        return new OperacionResponse(
                "ok",
                "POST /training/cumplimiento-meta",
                "Meta cumplida. Racha actual: " + racha.getConteoDias() + ". Recompensa: " + recompensa
        );
    }

    private void validarRequestSerie(RegistrarSerieRequest request) {
        if (request == null) {
            throw new IllegalArgumentException("El body de serie de fuerza es obligatorio");
        }
        validarUsuarioId(request.getUsuarioId());
        validarId(request.getEjercicioId(), "ejercicioId");
        if (request.getSerieNumero() <= 0) {
            throw new IllegalArgumentException("serieNumero debe ser mayor a 0");
        }
        if (!repeticionesValidas(request.getRepeticiones())) {
            throw new IllegalArgumentException("Las repeticiones deben estar en los rangos: 4-8, 8-12 o 12-16");
        }
        if (request.getPeso() < 0 || request.getPeso() > 25) {
            throw new IllegalArgumentException("El peso debe estar entre 0 y 25 kg");
        }
    }

    private void validarRequestCorrer(RegistroCorrerRequest request) {
        if (request == null) {
            throw new IllegalArgumentException("El body para correr es obligatorio");
        }
        validarUsuarioId(request.getUsuarioId());
        normalizarDificultad(request.getDificultad());
        if (request.getDistanciaKm() <= 0) {
            throw new IllegalArgumentException("La distancia corrida debe ser mayor a 0");
        }
    }

    private void validarUsuarioId(int usuarioId) {
        if (usuarioId <= 0) {
            throw new IllegalArgumentException("usuarioId invalido");
        }
    }

    private void validarDiaSemana(int diaSemana) {
        if (diaSemana < 1 || diaSemana > 7) {
            throw new IllegalArgumentException("diaSemana debe estar entre 1 y 7");
        }
    }

    private void validarSentadillasRequest(SentadillasPlanRequest request) {
        if (request == null) {
            throw new IllegalArgumentException("El body para sentadillas es obligatorio");
        }

        validarDiaSemana(request.getDiaSemana());
        if (request.getHora() <= 0 || request.getHora() > 12) {
            throw new IllegalArgumentException("La hora debe estar entre 1 y 12");
        }
        if (request.getMinuto() < 0 || request.getMinuto() > 59) {
            throw new IllegalArgumentException("El minuto debe estar entre 0 y 59");
        }
        if (clean(request.getPeriodo()).isEmpty()) {
            throw new IllegalArgumentException("El periodo es obligatorio");
        }
    }

    private void validarRutinaCompletadaRequest(CompletarRutinaRequest request) {
        if (request == null) {
            throw new IllegalArgumentException("El body para completar rutina es obligatorio");
        }
        validarDiaSemana(request.getDiaSemana());
        if (clean(request.getEjercicioEtiqueta()).isEmpty()) {
            throw new IllegalArgumentException("El ejercicio es obligatorio");
        }
    }

    private void validarId(int id, String nombreCampo) {
        if (id <= 0) {
            throw new IllegalArgumentException(nombreCampo + " invalido");
        }
    }

    private boolean repeticionesValidas(int repeticiones) {
        return (repeticiones >= 4 && repeticiones <= 8)
                || (repeticiones >= 8 && repeticiones <= 12)
                || (repeticiones >= 12 && repeticiones <= 16);
    }

    private String normalizarDificultad(String dificultad) {
        String value = clean(dificultad).toLowerCase(Locale.ROOT)
                .replace('á', 'a')
                .replace('é', 'e')
                .replace('í', 'i')
                .replace('ó', 'o')
                .replace('ú', 'u');

        if (value.equals("facil")) {
            return "Facil";
        }
        if (value.equals("media")) {
            return "Media";
        }
        if (value.equals("dificil")) {
            return "Dificil";
        }
        throw new IllegalArgumentException("Dificultad invalida. Opciones: Facil, Media, Dificil");
    }

    private int obtenerOCrearEjercicioCorrer(Connection conn, String dificultad) throws SQLException {
        String buscar = "SELECT ejercicio_id FROM public.entrenamiento_ejercicios "
                + "WHERE nombre = ? LIMIT 1";
        try (PreparedStatement ps = conn.prepareStatement(buscar)) {
            ps.setString(1, CORRER_NOMBRE);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("ejercicio_id");
                }
            }
        }

        String insert = "INSERT INTO public.entrenamiento_ejercicios (nombre, grupo_muscular, descripcion, instrucciones_json) "
                + "VALUES (?, ?, ?, ?) RETURNING ejercicio_id";
        try (PreparedStatement ps = conn.prepareStatement(insert)) {
            ps.setString(1, CORRER_NOMBRE);
            ps.setString(2, "Cardio");
            ps.setString(3, DIFICULTAD_PREFIX + dificultad);
            ps.setString(4, null);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("ejercicio_id");
                }
            }
        }

        throw new IllegalStateException("No fue posible crear o resolver ejercicio 'Correr'");
    }

    private void validarUsuarioExiste(Connection conn, int usuarioId) throws SQLException {
        String sql = "SELECT 1 FROM public.usuarios_cuenta WHERE usuario_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, usuarioId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    throw new NoSuchElementException("No existe usuario con id " + usuarioId);
                }
            }
        }
    }

    private void validarEjercicioExiste(Connection conn, int ejercicioId) throws SQLException {
        String sql = "SELECT 1 FROM public.entrenamiento_ejercicios WHERE ejercicio_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, ejercicioId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    throw new NoSuchElementException("No existe ejercicio con id " + ejercicioId);
                }
            }
        }
    }

    private void validarRegistroFuerzaExiste(Connection conn, int registroId) throws SQLException {
        String sql = "SELECT 1 FROM public.progreso_bitacora_fuerza WHERE registro_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, registroId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    throw new NoSuchElementException("No existe registro de fuerza con id " + registroId);
                }
            }
        }
    }

    private void validarRegistroCorrerExiste(Connection conn, int registroId) throws SQLException {
        String sql = "SELECT 1 "
                + "FROM public.progreso_bitacora_fuerza b "
                + "JOIN public.entrenamiento_ejercicios e ON e.ejercicio_id = b.ejercicio_id "
                + "WHERE b.registro_id = ? AND e.nombre = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, registroId);
            ps.setString(2, CORRER_NOMBRE);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    throw new NoSuchElementException("No existe registro de correr con id " + registroId);
                }
            }
        }
    }

    private EjercicioCatalogoResponse mapEjercicio(ResultSet rs) throws SQLException {
        return new EjercicioCatalogoResponse(
                rs.getInt("ejercicio_id"),
                rs.getString("nombre"),
                rs.getString("grupo_muscular"),
                rs.getString("descripcion"),
                rs.getString("url_media")
        );
    }

    private SerieFuerzaResponse mapSerie(ResultSet rs) throws SQLException {
        SerieFuerzaResponse out = new SerieFuerzaResponse();
        out.setRegistroId(rs.getInt("registro_id"));
        out.setUsuarioId(rs.getInt("usuario_id"));
        out.setEjercicioId(rs.getInt("ejercicio_id"));
        out.setEjercicioNombre(rs.getString("ejercicio_nombre"));
        out.setSerieNumero(rs.getInt("serie_numero"));
        
        // Leer repeticiones desde instrucciones_json del ejercicio
        String instruccionesJson = clean(rs.getString("instrucciones_json"));
        int repeticiones = 8; // valor por defecto
        if (!instruccionesJson.isEmpty()) {
            try {
                int startIdx = instruccionesJson.indexOf("repeticiones") + 14;
                int endIdx = instruccionesJson.indexOf("}", startIdx);
                if (startIdx > 13 && endIdx > startIdx) {
                    String repStr = instruccionesJson.substring(startIdx, endIdx).trim();
                    repeticiones = Integer.parseInt(repStr);
                }
            } catch (Exception e) {
                // Si falla el parseo, usar default
            }
        }
        out.setRepeticiones(repeticiones);
        out.setPesoKg(rs.getDouble("peso_kg"));
        Timestamp ts = rs.getTimestamp("fecha");
        if (ts != null) {
            out.setFecha(ts.toLocalDateTime());
        }
        return out;
    }

    private RegistroCorrerResponse mapCorrer(ResultSet rs) throws SQLException {
        RegistroCorrerResponse out = new RegistroCorrerResponse();
        out.setRegistroExtraId(rs.getInt("registro_id"));
        out.setUsuarioId(rs.getInt("usuario_id"));
        out.setDeporteId(rs.getInt("ejercicio_id"));

        Date fecha = rs.getDate("fecha");
        if (fecha != null) {
            out.setFecha(fecha.toLocalDate());
        }

        // Leer dificultad desde descripcion
        String descripcion = clean(rs.getString("descripcion"));
        String dificultad = "Media";
        if (descripcion.startsWith(DIFICULTAD_PREFIX)) {
            dificultad = descripcion.substring(DIFICULTAD_PREFIX.length());
        }
        out.setDificultad(dificultad);
        
        double distanciaKm = 0.0;
        try {
            distanciaKm = rs.getDouble("distancia_km");
        } catch (SQLException ignored) {
            distanciaKm = rs.getInt("serie_numero") / 1000.0;
        }
        out.setDistanciaKm(distanciaKm);
        return out;
    }

    private String clean(String value) {
        return value == null ? "" : value.trim();
    }

    private String nullableTrim(String value) {
        String cleaned = clean(value);
        return cleaned.isEmpty() ? null : cleaned;
    }

    private String serializarPlan(SentadillasPlanRequest request) {
        return String.join("|",
                "S",
                "h=" + request.getHora(),
                "m=" + String.format(Locale.ROOT, "%02d", request.getMinuto()),
                "p=" + clean(request.getPeriodo()),
                "d=" + clean(request.getDificultad()),
                "r=" + clean(request.getRepeticiones()),
                "w=" + clean(request.getPeso())
        );
    }

    private int obtenerRutinaSentadillasId(Connection conn, int usuarioId, int diaSemana) throws SQLException {
        String sql = "SELECT rutina_id FROM public.progreso_rutinas_personalizadas "
                + "WHERE usuario_id = ? AND dia_semana = ? ORDER BY rutina_id DESC LIMIT 1";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, usuarioId);
            ps.setInt(2, diaSemana);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("rutina_id");
                }
            }
        }
        return -1;
    }

    private SentadillasPlanResponse mapSentadillasPlan(ResultSet rs) throws SQLException {
        SentadillasPlanResponse response = new SentadillasPlanResponse();
        response.setRutinaId(rs.getInt("rutina_id"));
        response.setUsuarioId(rs.getInt("usuario_id"));
        response.setDiaSemana(rs.getInt("dia_semana"));
        response.setCompletado(rs.getBoolean("completado"));

        String raw = rs.getString("nombre_rutina");
        if (raw != null && !raw.isBlank()) {
            try {
                if (raw.startsWith("S|")) {
                    Map<String, String> data = parseCompactSentadillasPlan(raw);
                    response.setHora(asInt(data.get("h"), 9));
                    response.setMinuto(asInt(data.get("m"), 0));
                    response.setPeriodo(asString(data.get("p"), "AM"));
                    response.setDificultad(asString(data.get("d"), "Media"));
                    response.setRepeticiones(asString(data.get("r"), "8 - 12"));
                    response.setPeso(asString(data.get("w"), "12 kg"));
                } else {
                    @SuppressWarnings("unchecked")
                    Map<String, Object> data = objectMapper.readValue(raw, Map.class);
                    response.setHora(asInt(data.get("hora"), 9));
                    response.setMinuto(asInt(data.get("minuto"), 0));
                    response.setPeriodo(asString(data.get("periodo"), "AM"));
                    response.setDificultad(asString(data.get("dificultad"), "Media"));
                    response.setRepeticiones(asString(data.get("repeticiones"), "8 - 12"));
                    response.setPeso(asString(data.get("peso"), "12 kg"));
                }
            } catch (Exception e) {
                response.setHora(9);
                response.setMinuto(0);
                response.setPeriodo("AM");
                response.setDificultad("Media");
                response.setRepeticiones("8 - 12");
                response.setPeso("12 kg");
            }
        }

        return response;
    }

    public SentadillasPlanResponse marcarSentadillasCompletada(int usuarioId, int diaSemana) {
        validarUsuarioId(usuarioId);
        validarDiaSemana(diaSemana);

        try (Connection conn = conexionDB.conectar()) {
            asegurarCompatibilidadSentadillas(conn);
            validarUsuarioExiste(conn, usuarioId);

            String sql = "UPDATE public.progreso_rutinas_personalizadas "
                    + "SET completado = true, completado_en = NOW() "
                    + "WHERE usuario_id = ? AND dia_semana = ? RETURNING rutina_id";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, usuarioId);
                ps.setInt(2, diaSemana);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        throw new NoSuchElementException("No existe plan de sentadillas para el dia " + diaSemana);
                    }
                }
            }

            return obtenerSentadillasPlan(usuarioId, diaSemana);
        } catch (SQLException e) {
            throw new IllegalStateException("Error al marcar sentadillas como completadas: " + e.getMessage());
        }
    }

    public Map<String, Object> guardarEjercicio(int usuarioId, Map<String, Object> body) {
        validarUsuarioId(usuarioId);
        
        try (Connection conn = conexionDB.conectar()) {
            asegurarCompatibilidadSentadillas(conn);
            validarUsuarioExiste(conn, usuarioId);

            int diaSemana = ((Number) body.getOrDefault("diaSemana", 1)).intValue();
            String ejercicio = (String) body.getOrDefault("ejercicio", "Ejercicio");
            int hora = ((Number) body.getOrDefault("hora", 9)).intValue();
            int minuto = ((Number) body.getOrDefault("minuto", 0)).intValue();
            String periodo = (String) body.getOrDefault("periodo", "AM");
            String dificultad = (String) body.getOrDefault("dificultad", "Media");
            String repeticiones = (String) body.getOrDefault("repeticiones", "8 - 12");
            String peso = (String) body.getOrDefault("peso", "12 kg");

            validarDiaSemana(diaSemana);
            
            String payload = String.join("|",
                    "E",
                    "nombre=" + clean(ejercicio),
                    "h=" + hora,
                    "m=" + String.format(Locale.ROOT, "%02d", minuto),
                    "p=" + clean(periodo),
                    "d=" + clean(dificultad),
                    "r=" + clean(repeticiones),
                    "w=" + clean(peso)
            );
            
            // Buscar si ya existe un registro para este ejercicio en este día
            String sqlBuscar = "SELECT rutina_id FROM public.progreso_rutinas_personalizadas "
                    + "WHERE usuario_id = ? AND dia_semana = ? AND nombre_rutina LIKE ?";
            int rutinaId = -1;
            String buscarPattern = "E|nombre=" + clean(ejercicio) + "|%";
            
            try (PreparedStatement ps = conn.prepareStatement(sqlBuscar)) {
                ps.setInt(1, usuarioId);
                ps.setInt(2, diaSemana);
                ps.setString(3, buscarPattern);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        rutinaId = rs.getInt("rutina_id");
                    }
                }
            }

            if (rutinaId > 0) {
                // Actualizar el registro existente
                String sql = "UPDATE public.progreso_rutinas_personalizadas SET nombre_rutina = ?, completado = false, completado_en = NULL "
                        + "WHERE rutina_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, payload);
                    ps.setInt(2, rutinaId);
                    ps.executeUpdate();
                }
            } else {
                // Crear nuevo registro
                String sql = "INSERT INTO public.progreso_rutinas_personalizadas (usuario_id, nombre_rutina, dia_semana, completado) "
                    + "VALUES (?, ?, ?, false) RETURNING rutina_id";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, usuarioId);
                    ps.setString(2, payload);
                    ps.setInt(3, diaSemana);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            rutinaId = rs.getInt("rutina_id");
                        }
                    }
                }
            }

            return obtenerEjercicio(usuarioId, ejercicio, diaSemana);
        } catch (SQLException e) {
            throw new IllegalStateException("Error al guardar ejercicio: " + e.getMessage());
        }
    }

    public Map<String, Object> obtenerEjercicio(int usuarioId, String nombreEjercicio, int diaSemana) {
        validarUsuarioId(usuarioId);
        validarDiaSemana(diaSemana);

        try (Connection conn = conexionDB.conectar()) {
            asegurarCompatibilidadSentadillas(conn);
            validarUsuarioExiste(conn, usuarioId);

            // Primero busca en todos los registros del día para encontrar el que coincida con el nombre
            String sql = "SELECT rutina_id, usuario_id, nombre_rutina, dia_semana, COALESCE(completado, false) AS completado "
                    + "FROM public.progreso_rutinas_personalizadas "
                    + "WHERE usuario_id = ? AND dia_semana = ? "
                    + "ORDER BY rutina_id DESC";
            
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, usuarioId);
                ps.setInt(2, diaSemana);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        String raw = rs.getString("nombre_rutina");
                        if (raw != null && !raw.isBlank()) {
                            // Verifica si es un ejercicio genérico (E|)
                            if (raw.startsWith("E|")) {
                                Map<String, String> data = parseCompactExercisePlan(raw);
                                String nombreGuardado = asString(data.get("nombre"), nombreEjercicio);
                                
                                // Solo retorna si el nombre coincide exactamente
                                if (nombreGuardado.equalsIgnoreCase(nombreEjercicio)) {
                                    Map<String, Object> response = new HashMap<>();
                                    response.put("rutinaId", rs.getInt("rutina_id"));
                                    response.put("usuarioId", rs.getInt("usuario_id"));
                                    response.put("diaSemana", rs.getInt("dia_semana"));
                                    response.put("completado", rs.getBoolean("completado"));
                                    
                                    response.put("hora", asInt(data.get("h"), 9));
                                    response.put("minuto", asInt(data.get("m"), 0));
                                    response.put("periodo", asString(data.get("p"), "AM"));
                                    response.put("dificultad", asString(data.get("d"), "Media"));
                                    response.put("repeticiones", asString(data.get("r"), "8 - 12"));
                                    response.put("peso", asString(data.get("w"), "12 kg"));
                                    response.put("nombre", nombreGuardado);
                                    
                                    return response;
                                }
                            } else if (raw.startsWith("S|") && nombreEjercicio.toLowerCase().contains("sentad")) {
                                // Es una sentadilla
                                Map<String, String> data = parseCompactSentadillasPlan(raw);
                                Map<String, Object> response = new HashMap<>();
                                response.put("rutinaId", rs.getInt("rutina_id"));
                                response.put("usuarioId", rs.getInt("usuario_id"));
                                response.put("diaSemana", rs.getInt("dia_semana"));
                                response.put("completado", rs.getBoolean("completado"));
                                
                                response.put("hora", asInt(data.get("h"), 9));
                                response.put("minuto", asInt(data.get("m"), 0));
                                response.put("periodo", asString(data.get("p"), "AM"));
                                response.put("dificultad", asString(data.get("d"), "Media"));
                                response.put("repeticiones", asString(data.get("r"), "8 - 12"));
                                response.put("peso", asString(data.get("w"), "12 kg"));
                                response.put("nombre", nombreEjercicio);
                                
                                return response;
                            }
                        }
                    }
                }
            }

            throw new NoSuchElementException("No existe plan para el ejercicio " + nombreEjercicio + " en el día " + diaSemana);
        } catch (SQLException e) {
            throw new IllegalStateException("Error al consultar plan de ejercicio: " + e.getMessage());
        }
    }

    public RutinaCompletadaResponse completarRutina(int usuarioId, CompletarRutinaRequest request) {
        validarUsuarioId(usuarioId);
        validarRutinaCompletadaRequest(request);

        try (Connection conn = conexionDB.conectar()) {
            asegurarCompatibilidadRutinasCompletadas(conn);
            validarUsuarioExiste(conn, usuarioId);

            String etiqueta = clean(request.getEjercicioEtiqueta());
            String deleteSql = "DELETE FROM public.progreso_rutinas_completadas "
                    + "WHERE usuario_id = ? AND dia_semana = ? AND ejercicio_etiqueta = ?";
            try (PreparedStatement ps = conn.prepareStatement(deleteSql)) {
                ps.setInt(1, usuarioId);
                ps.setInt(2, request.getDiaSemana());
                ps.setString(3, etiqueta);
                ps.executeUpdate();
            }

            String insertSql = "INSERT INTO public.progreso_rutinas_completadas "
                    + "(usuario_id, dia_semana, ejercicio_etiqueta, detalle, completado_en) "
                    + "VALUES (?, ?, ?, ?, NOW()) RETURNING completado_id, completado_en";

            int completadoId;
            Timestamp completadoEn;
            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setInt(1, usuarioId);
                ps.setInt(2, request.getDiaSemana());
                ps.setString(3, etiqueta);
                ps.setString(4, nullableTrim(request.getDetalle()));
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        throw new IllegalStateException("No se pudo completar la rutina");
                    }
                    completadoId = rs.getInt("completado_id");
                    completadoEn = rs.getTimestamp("completado_en");
                }
            }

            RutinaCompletadaResponse response = new RutinaCompletadaResponse();
            response.setCompletadoId(completadoId);
            response.setUsuarioId(usuarioId);
            response.setDiaSemana(request.getDiaSemana());
            response.setEjercicioEtiqueta(etiqueta);
            response.setDetalle(nullableTrim(request.getDetalle()));
            if (completadoEn != null) {
                response.setCompletadoEn(completadoEn.toLocalDateTime());
            }
            return response;
        } catch (SQLException e) {
            throw new IllegalStateException("Error al completar rutina: " + e.getMessage());
        }
    }

    public List<RutinaCompletadaResponse> listarRutinasCompletadas(int usuarioId, int diaSemana) {
        validarUsuarioId(usuarioId);
        validarDiaSemana(diaSemana);

        try (Connection conn = conexionDB.conectar()) {
            asegurarCompatibilidadRutinasCompletadas(conn);
            validarUsuarioExiste(conn, usuarioId);

            String sql = "SELECT completado_id, usuario_id, dia_semana, ejercicio_etiqueta, detalle, completado_en "
                    + "FROM public.progreso_rutinas_completadas "
                    + "WHERE usuario_id = ? AND dia_semana = ? ORDER BY completado_en DESC, completado_id DESC";
            List<RutinaCompletadaResponse> out = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, usuarioId);
                ps.setInt(2, diaSemana);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        out.add(mapRutinaCompletada(rs));
                    }
                }
            }
            return out;
        } catch (SQLException e) {
            throw new IllegalStateException("Error al listar rutinas completadas: " + e.getMessage());
        }
    }

    private int asInt(Object value, int fallback) {
        if (value instanceof Number number) {
            return number.intValue();
        }
        if (value instanceof String text) {
            try {
                return Integer.parseInt(text);
            } catch (NumberFormatException ignored) {
            }
        }
        return fallback;
    }

    private String asString(Object value, String fallback) {
        return value == null ? fallback : value.toString();
    }

    private void asegurarCompatibilidadSentadillas(Connection conn) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(
                "ALTER TABLE public.progreso_rutinas_personalizadas "
                        + "ADD COLUMN IF NOT EXISTS completado boolean NOT NULL DEFAULT false")) {
            ps.execute();
        }

        try (PreparedStatement ps = conn.prepareStatement(
                "ALTER TABLE public.progreso_rutinas_personalizadas "
                        + "ADD COLUMN IF NOT EXISTS completado_en timestamp NULL")) {
            ps.execute();
        }
    }

    private void asegurarCompatibilidadRutinasCompletadas(Connection conn) throws SQLException {
        String sql = "CREATE TABLE IF NOT EXISTS public.progreso_rutinas_completadas ("
                + "completado_id integer NOT NULL DEFAULT nextval('progreso_rutinas_completadas_completado_id_seq'::regclass),"
                + "usuario_id integer,"
                + "dia_semana integer,"
                + "ejercicio_etiqueta character varying(120),"
                + "detalle character varying(160),"
                + "completado_en timestamp without time zone,"
                + "CONSTRAINT progreso_rutinas_completadas_pkey PRIMARY KEY (completado_id),"
                + "CONSTRAINT progreso_rutinas_completadas_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuarios_cuenta(usuario_id)"
                + ")";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.execute();
        }
    }

    private RutinaCompletadaResponse mapRutinaCompletada(ResultSet rs) throws SQLException {
        RutinaCompletadaResponse response = new RutinaCompletadaResponse();
        response.setCompletadoId(rs.getInt("completado_id"));
        response.setUsuarioId(rs.getInt("usuario_id"));
        response.setDiaSemana(rs.getInt("dia_semana"));
        response.setEjercicioEtiqueta(rs.getString("ejercicio_etiqueta"));
        response.setDetalle(rs.getString("detalle"));
        Timestamp timestamp = rs.getTimestamp("completado_en");
        if (timestamp != null) {
            response.setCompletadoEn(timestamp.toLocalDateTime());
        }
        return response;
    }

    private Map<String, String> parseCompactSentadillasPlan(String raw) {
        Map<String, String> data = new HashMap<>();
        String[] parts = raw.split("\\|");
        for (int i = 1; i < parts.length; i++) {
            String[] keyValue = parts[i].split("=", 2);
            if (keyValue.length == 2) {
                data.put(keyValue[0], keyValue[1]);
            }
        }
        return data;
    }

    private Map<String, String> parseCompactExercisePlan(String raw) {
        Map<String, String> data = new HashMap<>();
        String[] parts = raw.split("\\|");
        for (int i = 1; i < parts.length; i++) {
            String[] keyValue = parts[i].split("=", 2);
            if (keyValue.length == 2) {
                data.put(keyValue[0], keyValue[1]);
            }
        }
        return data;
    }

    private void guardarRepeticionesEnEjercicio(Connection conn, int ejercicioId, int repeticiones) throws SQLException {
        String jsonReps = "{\"repeticiones\": " + repeticiones + "}";
        String sql = "UPDATE public.entrenamiento_ejercicios SET instrucciones_json = ? WHERE ejercicio_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, jsonReps);
            ps.setInt(2, ejercicioId);
            ps.executeUpdate();
        }
    }

    private void guardarDificultadEnEjercicio(Connection conn, int ejercicioId, String dificultad) throws SQLException {
        String sql = "UPDATE public.entrenamiento_ejercicios SET descripcion = ? WHERE ejercicio_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, DIFICULTAD_PREFIX + dificultad);
            ps.setInt(2, ejercicioId);
            ps.executeUpdate();
        }
    }
}
