package com.fitpaw.backend.util;

import java.util.Date;

import com.auth0.jwt.JWTVerifier;
import com.auth0.jwt.exceptions.JWTVerificationException;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;

@Component
public class JwtUtil {

    @Value("${jwt.secret:default_secret_change_me}")
    private String secret;

    @Value("${jwt.expiration-ms:3600000}")
    private long expirationMs;

    public String generateToken(int usuarioId, String telefono) {
        Algorithm algorithm = Algorithm.HMAC256(secret);
        Date now = new Date();
        Date exp = new Date(now.getTime() + expirationMs);

        return JWT.create()
                .withIssuer("fitpaw-backend")
                .withSubject(telefono)
                .withIssuedAt(now)
                .withExpiresAt(exp)
                .withClaim("usuarioId", usuarioId)
                .withClaim("telefono", telefono)
                .sign(algorithm);
    }

    public boolean isTokenValid(String token) {
        try {
            JWTVerifier verifier = JWT.require(Algorithm.HMAC256(secret))
                    .withIssuer("fitpaw-backend")
                    .build();
            verifier.verify(token);
            return true;
        } catch (JWTVerificationException ex) {
            System.err.println("JWT verification failed: " + ex.getMessage());
            throw ex;
        }
    }

    public String extractTelefono(String token) {
        return JWT.require(Algorithm.HMAC256(secret))
                .withIssuer("fitpaw-backend")
                .build()
                .verify(token)
                .getSubject();
    }

    public int extractUsuarioId(String token) {
        return JWT.require(Algorithm.HMAC256(secret))
                .withIssuer("fitpaw-backend")
                .build()
                .verify(token)
                .getClaim("usuarioId")
                .asInt();
    }
}
