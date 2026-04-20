package com.fitpaw.backend.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

//Ejemplo de test de api

@RestController
@RequestMapping("/test")
public class TestController {

    @GetMapping
    public String test() {
        return "Backend Java funcionando 🚀";
    }
}