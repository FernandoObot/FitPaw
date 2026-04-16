package db;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

public class StorageFoto {
    // La URL base de tu proyecto en Supabase (usamos la misma URL web de la primera vez)
    private static final String SUPABASE_URL = "https://qymbwyvmudplnyvwmkkp.supabase.co";
    
    // IMPORTANTE: Necesitas pegar aquí tu API Key de Supabase (anon/public o service_role)
    private static final String SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF5bWJ3eXZtdWRwbG55dndta2twIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NDc1Mjk1MiwiZXhwIjoyMDkwMzI4OTUyfQ.qwJGQE873b3jV7sLD2OoC17iXhRRHi0ilDwF8a3Z9Nc"; 
    
    private static final String BUCKET_NAME = "Fotos";

    public String subirFoto(String rutaArchivoLocal, String nombreArchivoSupabase) {
        try {
            // 1. Leemos los bytes de la foto desde tu computadora
            Path path = Paths.get(rutaArchivoLocal);
            byte[] fileBytes = Files.readAllBytes(path);

            // 2. Construimos la URL de la API de Storage a donde subiremos el archivo
            String uploadUrl = SUPABASE_URL + "/storage/v1/object/" + BUCKET_NAME + "/" + nombreArchivoSupabase;

            // 3. Preparamos el cliente y la petición HTTP
            HttpClient client = HttpClient.newHttpClient();
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(uploadUrl))
                    .header("Authorization", "Bearer " + SUPABASE_KEY)
                    .header("apikey", SUPABASE_KEY)
                    .header("Content-Type", "image/jpeg") // Asumimos que subes un .png
                    .POST(HttpRequest.BodyPublishers.ofByteArray(fileBytes))
                    .build();

            // 4. Enviamos la petición
            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

            // 200 es éxito (OK)
            if (response.statusCode() == 200 || response.statusCode() == 201) { 
                System.out.println("Foto subida correctamente al bucket.");
                // Retornamos la URL pública (Asumiendo que hiciste el bucket público en Supabase)
                return SUPABASE_URL + "/storage/v1/object/public/" + BUCKET_NAME + "/" + nombreArchivoSupabase;
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
}
