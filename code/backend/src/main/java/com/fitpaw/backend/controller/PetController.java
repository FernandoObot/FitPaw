package com.fitpaw.backend.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fitpaw.backend.model.Pet;
import com.fitpaw.backend.service.PetService;

@RestController
@RequestMapping("/pet")
public class PetController {

    @Autowired
    private PetService petService;

    @PostMapping("/actualizar")
    public Pet actualizar(@RequestBody Pet pet) {
        return petService.actualizarEstado(pet);
    }

}
