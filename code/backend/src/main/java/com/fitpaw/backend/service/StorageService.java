package com.fitpaw.backend.service;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Connection;

import org.springframework.stereotype.Service;
import com.fitpaw.backend.repository.ConexionDB;


@Service
public class StorageService {

    private final ConexionDB conexionDB;

    public StorageService(ConexionDB conexionDB) {
        this.conexionDB = conexionDB;
    }

    // Configuración de Supabase
    private static final String SUPABASE_URL = "https://qymbwyvmudplnyvwmkkp.supabase.co";
    private static final String SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF5bWJ3eXZtdWRwbG55dndta2twIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NDc1Mjk1MiwiZXhwIjoyMDkwMzI4OTUyfQ.qwJGQE873b3jV7sLD2OoC17iXhRRHi0ilDwF8a3Z9Nc";
    private static final String BUCKET_NAME = "Fotos";

   
    public String subirFotoProgreso(int usuarioId, String rutaFoto) {
        try {
            // Generamos un nombre único para la foto
            String nombreArchivo = "usuario_" + usuarioId + "_" + System.currentTimeMillis() + ".jpg";
            
            // Subimos la foto a Supabase
            String urlFoto = uploadToSupabase(BUCKET_NAME, rutaFoto, nombreArchivo);
            
            if (urlFoto != null) {
                // Guardamos la URL en la base de datos
                guardarUrlEnBaseDatos(usuarioId, urlFoto);
            }
            
            return urlFoto;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public String subirFoto(int usuarioId, String rutaFoto) {
        try {
            String nombreArchivo = "foto_" + usuarioId + ".jpg";
            String urlFoto = uploadToSupabase(BUCKET_NAME, rutaFoto, nombreArchivo);
            
            if (urlFoto != null) {
                guardarUrlEnBaseDatos(usuarioId, urlFoto);
            }
            
            return urlFoto;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }


    private String uploadToSupabase(String bucket, String rutaArchivoLocal, String nombreArchivoSupabase) {
        try {
            // 1. Leemos los bytes de la foto desde la ruta local
            Path path = Paths.get(rutaArchivoLocal);
            if (!Files.exists(path)) {
                System.err.println("Archivo no encontrado: " + path.toString());
                return null;
            }
            byte[] fileBytes = Files.readAllBytes(path);

            // 2. Construimos la URL de la API de Storage
            String uploadUrl = SUPABASE_URL + "/storage/v1/object/" + bucket + "/" + nombreArchivoSupabase;

            // 3. Preparamos el cliente HTTP y la petición
            HttpClient client = HttpClient.newHttpClient();
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(uploadUrl))
                    .header("Authorization", "Bearer " + SUPABASE_KEY)
                    .header("apikey", SUPABASE_KEY)
                    .header("Content-Type", "image/jpg")
                    .POST(HttpRequest.BodyPublishers.ofByteArray(fileBytes))
                    .build();

            // 4. Enviamos la petición
            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

            // 5. Validamos la respuesta
            if (response.statusCode() == 200 || response.statusCode() == 201) {
                System.out.println("Foto subida correctamente al bucket: " + bucket);
                // Retornamos la URL pública
                return SUPABASE_URL + "/storage/v1/object/public/" + bucket + "/" + nombreArchivoSupabase;
            } else {
                System.out.println("Error al subir foto. Código: " + response.statusCode());
                System.out.println("Detalles: " + response.body());
                return null;
            }

             } catch (IOException | InterruptedException e) {
             e.printStackTrace();
                return null;
         }
    }

    private void guardarUrlEnBaseDatos(int usuarioId, String url) {
        if (url == null) {
            System.err.println("URL nula: no se guardará en la base de datos.");
            return;
        }

        String sql = "INSERT INTO prueba_eve (\"Foto\") VALUES (?)";
        try (Connection conn = conexionDB.conectar();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, url);
            int filasAfectadas = pstmt.executeUpdate();
            if (filasAfectadas > 0) {
                System.out.println("Registro insertado exitosamente en la tabla prueba_eve");
            }
        } catch (SQLException e) {
            System.err.println("Error al guardar URL en BD:");
            e.printStackTrace();
        } finally {
            conexionDB.desconectar();
        }
    }

}
