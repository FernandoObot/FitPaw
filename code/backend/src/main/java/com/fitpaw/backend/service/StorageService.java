package com.fitpaw.backend.service;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import com.fitpaw.backend.DTOs.DailyProgressPhotosResponse;
import com.fitpaw.backend.DTOs.PhotoSlotResponse;
import com.fitpaw.backend.DTOs.ProgressPhotoResponse;
import com.fitpaw.backend.repository.ConexionDB;

@Service
public class StorageService {

    private static final int DAILY_LIMIT = 3;

    private final ConexionDB conexionDB;

    public StorageService(ConexionDB conexionDB) {
        this.conexionDB = conexionDB;
    }

    @Value("${SUPABASE_URL}")
    private String SUPABASE_URL;

    @Value("${SUPABASE_KEY}")
    private String SUPABASE_KEY;

    @Value("${BUCKET_NAME}")
    private String BUCKET_NAME;

    public DailyProgressPhotosResponse subirFotoProgreso(int usuarioId, MultipartFile foto) {
        return subirFotoProgreso(usuarioId, foto, null);
    }

    public DailyProgressPhotosResponse subirFotoProgreso(int usuarioId, MultipartFile foto, Integer posicionSolicitada) {
        validarArchivo(foto);

        try (Connection conn = conexionDB.conectar()) {
            List<ProgressPhotoResponse> fotosHoy = obtenerFotosPorRango(conn, usuarioId, inicioDelDia(), inicioDelSiguienteDia());
            if (fotosHoy.size() >= DAILY_LIMIT) {
                throw new ResponseStatusException(HttpStatus.TOO_MANY_REQUESTS, "Solo se permiten 3 fotos por dia");
            }

            int posicion = resolverPosicion(fotosHoy, posicionSolicitada);
            if (posicion == -1) {
                throw new ResponseStatusException(HttpStatus.CONFLICT, "La posicion solicitada ya fue usada hoy");
            }

            String extension = obtenerExtensionSegunArchivo(foto);
            String nombreArchivo = "progreso/" + usuarioId + "/" + LocalDate.now() + "/slot-" + posicion + "-" + System.currentTimeMillis() + extension;
            String urlFoto = uploadToSupabase(BUCKET_NAME, foto, nombreArchivo);
            if (urlFoto == null) {
                throw new ResponseStatusException(HttpStatus.BAD_GATEWAY, "No se pudo subir la foto a Supabase Storage");
            }

            Timestamp fecha = Timestamp.valueOf(LocalDateTime.now());
            int fotoId = insertarFoto(conn, usuarioId, urlFoto, String.valueOf(posicion), fecha);

            return construirResumen(conn, usuarioId, fotoId, urlFoto, String.valueOf(posicion), fecha);
        } catch (SQLException e) {
            throw new IllegalStateException("Error al guardar la foto de progreso: " + e.getMessage(), e);
        } catch (IOException e) {
            throw new IllegalStateException("No se pudo leer la imagen subida: " + e.getMessage(), e);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new IllegalStateException("La subida a Supabase fue interrumpida: " + e.getMessage(), e);
        }
    }

    public DailyProgressPhotosResponse obtenerFotosHoy(int usuarioId) {
        try (Connection conn = conexionDB.conectar()) {
            return construirResumen(conn, usuarioId, null, null, null, null);
        } catch (SQLException e) {
            throw new IllegalStateException("Error al obtener fotos de hoy: " + e.getMessage(), e);
        }
    }

    public List<ProgressPhotoResponse> obtenerTodasLasFotos(int usuarioId) {
        try (Connection conn = conexionDB.conectar()) {
            return obtenerFotosPorRango(conn, usuarioId, null, null);
        } catch (SQLException e) {
            throw new IllegalStateException("Error al obtener historial de fotos: " + e.getMessage(), e);
        }
    }

    private void validarArchivo(MultipartFile foto) {
        if (foto == null || foto.isEmpty()) {
            throw new IllegalArgumentException("La foto es obligatoria");
        }
    }

    private int resolverPosicion(List<ProgressPhotoResponse> fotosHoy, Integer posicionSolicitada) {
        boolean[] usadas = new boolean[DAILY_LIMIT + 1];
        for (ProgressPhotoResponse foto : fotosHoy) {
            if (foto.getPosicion() != null) {
                try {
                    int posicion = Integer.parseInt(foto.getPosicion());
                    if (posicion >= 1 && posicion <= DAILY_LIMIT) {
                        usadas[posicion] = true;
                    }
                } catch (NumberFormatException ignored) {
                }
            }
        }

        if (posicionSolicitada != null) {
            if (posicionSolicitada < 1 || posicionSolicitada > DAILY_LIMIT) {
                throw new IllegalArgumentException("La posicion debe estar entre 1 y 3");
            }
            return usadas[posicionSolicitada] ? -1 : posicionSolicitada;
        }

        for (int i = 1; i <= DAILY_LIMIT; i++) {
            if (!usadas[i]) {
                return i;
            }
        }
        return -1;
    }

    private Timestamp inicioDelDia() {
        return Timestamp.valueOf(LocalDate.now().atStartOfDay());
    }

    private Timestamp inicioDelSiguienteDia() {
        return Timestamp.valueOf(LocalDate.now().plusDays(1).atStartOfDay());
    }

    private Timestamp inicioDiaHace15Dias() {
        return Timestamp.valueOf(LocalDate.now().minusDays(15).atStartOfDay());
    }

    private Timestamp inicioDelDia15DiasAdelante() {
        return Timestamp.valueOf(LocalDate.now().minusDays(14).atStartOfDay());
    }

    private int insertarFoto(Connection conn, int usuarioId, String urlFoto, String posicion, Timestamp fecha) throws SQLException {
        String sql = "INSERT INTO public.usuarios_fotos_progreso (usuario_id, url_foto, posicion, fecha) VALUES (?, ?, ?, ?) RETURNING foto_id";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, usuarioId);
            pstmt.setString(2, urlFoto);
            pstmt.setString(3, posicion);
            pstmt.setTimestamp(4, fecha);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        throw new SQLException("No se pudo obtener el id de la foto insertada");
    }

    private DailyProgressPhotosResponse construirResumen(Connection conn, int usuarioId, Integer fotoId, String urlFoto, String posicion, Timestamp fecha) throws SQLException {
        // Obtener fotos de hoy
        List<ProgressPhotoResponse> fotosHoy = obtenerFotosPorRango(conn, usuarioId, inicioDelDia(), inicioDelSiguienteDia());
        List<PhotoSlotResponse> slots = construirSlots(fotosHoy);

        // Obtener fotos de hace 15 días
        List<ProgressPhotoResponse> fotosHace15Dias = obtenerFotosPorRango(conn, usuarioId, inicioDiaHace15Dias(), inicioDelDia15DiasAdelante());
        List<PhotoSlotResponse> slotsHace15Dias = construirSlots(fotosHace15Dias);

        DailyProgressPhotosResponse response = new DailyProgressPhotosResponse();
        response.setLimiteDiario(DAILY_LIMIT);
        response.setSubidasHoy(fotosHoy.size());
        response.setRestantesHoy(Math.max(0, DAILY_LIMIT - fotosHoy.size()));
        response.setPuedeSubirHoy(fotosHoy.size() < DAILY_LIMIT);
        response.setSlots(slots);
        response.setSlotsHace15Dias(slotsHace15Dias);
        if (fotoId != null && urlFoto != null) {
            ProgressPhotoResponse fotoGuardada = new ProgressPhotoResponse();
            fotoGuardada.setFotoId(fotoId);
            fotoGuardada.setUsuarioId(usuarioId);
            fotoGuardada.setUrlFoto(urlFoto);
            fotoGuardada.setPosicion(posicion);
            fotoGuardada.setFecha(fecha != null ? fecha.toLocalDateTime() : null);
            response.setFotoGuardada(fotoGuardada);
        }
        return response;
    }

    private List<PhotoSlotResponse> construirSlots(List<ProgressPhotoResponse> fotosHoy) {
        List<PhotoSlotResponse> slots = new ArrayList<>();
        for (int slot = 1; slot <= DAILY_LIMIT; slot++) {
            PhotoSlotResponse slotResponse = new PhotoSlotResponse();
            slotResponse.setSlot(slot);
            slotResponse.setFoto(null);
            for (ProgressPhotoResponse foto : fotosHoy) {
                if (foto.getPosicion() != null && Objects.equals(foto.getPosicion(), String.valueOf(slot))) {
                    slotResponse.setFoto(foto);
                    break;
                }
            }
            slots.add(slotResponse);
        }
        return slots;
    }

    private List<ProgressPhotoResponse> obtenerFotosPorRango(Connection conn, int usuarioId, Timestamp inicio, Timestamp fin) throws SQLException {
        StringBuilder sql = new StringBuilder(
                "SELECT foto_id, usuario_id, url_foto, posicion, fecha FROM public.usuarios_fotos_progreso WHERE usuario_id = ?");
        if (inicio != null && fin != null) {
            sql.append(" AND fecha >= ? AND fecha < ?");
        }
        sql.append(" ORDER BY fecha DESC, foto_id DESC");

        try (PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {
            pstmt.setInt(1, usuarioId);
            if (inicio != null && fin != null) {
                pstmt.setTimestamp(2, inicio);
                pstmt.setTimestamp(3, fin);
            }

            List<ProgressPhotoResponse> fotos = new ArrayList<>();
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    ProgressPhotoResponse foto = new ProgressPhotoResponse();
                    foto.setFotoId(rs.getInt("foto_id"));
                    foto.setUsuarioId(rs.getInt("usuario_id"));
                    foto.setUrlFoto(rs.getString("url_foto"));
                    foto.setPosicion(rs.getString("posicion"));
                    Timestamp fecha = rs.getTimestamp("fecha");
                    foto.setFecha(fecha != null ? fecha.toLocalDateTime() : null);
                    fotos.add(foto);
                }
            }
            return fotos;
        }
    }

    private String obtenerExtensionSegunArchivo(MultipartFile foto) {
        String contentType = foto.getContentType();
        if (contentType == null) {
            return ".jpg";
        }

        return switch (contentType.toLowerCase()) {
            case "image/png" -> ".png";
            case "image/webp" -> ".webp";
            case "image/jpeg", "image/jpg" -> ".jpg";
            default -> ".jpg";
        };
    }

    private String uploadToSupabase(String bucket, MultipartFile foto, String nombreArchivoSupabase) throws IOException, InterruptedException {
        byte[] fileBytes = foto.getBytes();
        String contentType = foto.getContentType() != null ? foto.getContentType() : "image/jpeg";
        String uploadUrl = SUPABASE_URL + "/storage/v1/object/" + bucket + "/" + nombreArchivoSupabase;

        HttpClient client = HttpClient.newHttpClient();
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(uploadUrl))
                .header("Authorization", "Bearer " + SUPABASE_KEY)
                .header("apikey", SUPABASE_KEY)
                .header("Content-Type", contentType)
                .POST(HttpRequest.BodyPublishers.ofByteArray(fileBytes))
                .build();

        HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
        if (response.statusCode() == 200 || response.statusCode() == 201) {
            return SUPABASE_URL + "/storage/v1/object/public/" + bucket + "/" + nombreArchivoSupabase;
        }

        System.out.println("Error al subir foto. Código: " + response.statusCode());
        System.out.println("Detalles: " + response.body());
        return null;
    }

    public String subirFotoProgreso(int usuarioId, String rutaFoto) {
        throw new UnsupportedOperationException("Usa subirFotoProgreso con MultipartFile desde el controlador");
    }

    public String subirFoto(int usuarioId, String rutaFoto) {
        throw new UnsupportedOperationException("Usa subirFotoProgreso con MultipartFile desde el controlador");
    }
}
