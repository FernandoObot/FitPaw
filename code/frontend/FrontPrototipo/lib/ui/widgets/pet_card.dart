import 'package:flutter/material.dart';

class PetCard extends StatelessWidget {
  final int diasRacha;

  const PetCard({super.key, required this.diasRacha});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Degradado de tu diseño (Verde menta a Celeste)
        gradient: const LinearGradient(
          colors: [Color(0xFF98FFD9), Color(0xFF70E1F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Icono o Imagen de la Mascota (El Pingüino)
          Positioned(
            right: 20,
            bottom: 20,
            child: Icon(Icons.pets, size: 80, color: Colors.black.withOpacity(0.2)),
          ),
          // Texto de Racha
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_fire_department, color: Colors.white, size: 40),
                Text(
                  "$diasRacha",
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const Text(
                  "Días de racha",
                  style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}