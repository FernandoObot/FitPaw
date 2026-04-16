package db;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class MainPrueba {
    public static void main(String[] args) {
        
        // 1. Iniciamos StorageFoto para agarrar la foto de la computadora y subirla al bucket
        StorageFoto storage = new StorageFoto();
        
        // Reemplaza ESTO con la ruta real de una foto de prueba que tengas en tu computadora:
        // Asegúrate de crear o tener una imagen con este nombre en tu proyecto o cambia la ruta
        String rutaImagenEnTuLinux = "/home/evelyn/Descargas/TicTacToe.jpeg";
        
        // El nombre con el que se guardará el archivo en Supabase Storage (podrías generar un nombre único aquí)
        String nombreArchivoEnSupabase = "tictactoe.jpeg";
        
        System.out.println(">>> Intentando subir la foto...");
        String urlFotoSupabase = storage.subirFoto(rutaImagenEnTuLinux, nombreArchivoEnSupabase);

        // Si la URL es null significa que falló, cancelamos la inserción a BD
        if (urlFotoSupabase == null) {
            System.err.println("No se pudo obtener la URL de la imagen. Inserción a base de datos cancelada.");
            return;
        }

        System.out.println("¡URL obtenida con éxito!: " + urlFotoSupabase);
        System.out.println(">>> Guardando la URL en la tabla prueba_eve ...");

        // 2. Si la foto se subió con éxito, guardamos la URL en la BD
        ConexionSupabase conexionSupabase = new ConexionSupabase();

        try (Connection conn = conexionSupabase.conectar()) {
            if (conn != null) {
                String sql = "INSERT INTO prueba_eve (\"Foto\") VALUES (?)";
                
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    // Colocamos el String generado de Supabase Storage
                    pstmt.setString(1, urlFotoSupabase);
                    
                    int filasAfectadas = pstmt.executeUpdate();
                    
                    if (filasAfectadas > 0) {
                        System.out.println("¡Registro insertado exitosamente en la tabla prueba_eve!");
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("Error de base de datos:");
            e.printStackTrace();
        }
    }
}
