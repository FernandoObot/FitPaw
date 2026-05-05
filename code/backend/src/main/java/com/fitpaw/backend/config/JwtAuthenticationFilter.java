package com.fitpaw.backend.config;

import java.io.IOException;
import java.util.List;

import org.springframework.http.HttpHeaders;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import com.fitpaw.backend.util.JwtUtil;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtUtil jwtUtil;

    public JwtAuthenticationFilter(JwtUtil jwtUtil) {
        this.jwtUtil = jwtUtil;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        String header = request.getHeader(HttpHeaders.AUTHORIZATION);

        if (header != null && header.startsWith("Bearer ")) {
            String token = header.substring(7);

            try {
                if (!jwtUtil.isTokenValid(token)) {
                    response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                    response.setContentType("application/json");
                    response.getWriter().write("{\"mensaje\":\"Token invalido o expirado\"}");
                    return;
                }
            } catch (com.auth0.jwt.exceptions.JWTVerificationException ex) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.setContentType("application/json;charset=UTF-8");
                String msg = ex.getMessage() != null ? ex.getMessage().replaceAll("\"","\\\"") : "Token invalido o expirado";
                response.getWriter().write("{\"mensaje\":\"Token invalido o expirado: " + msg + "\"}");
                return;
            }

            String telefono = jwtUtil.extractTelefono(token);
            int usuarioId = jwtUtil.extractUsuarioId(token);
            UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(
                    telefono,
                    null,
                    List.of(new SimpleGrantedAuthority("ROLE_USER")));
            authentication.setDetails(usuarioId);
            SecurityContextHolder.getContext().setAuthentication(authentication);
        }

        filterChain.doFilter(request, response);
    }
}
