import 'package:flutter/material.dart';
import '../widgets/main_button.dart';

class StepperRegister extends StatefulWidget {
  const StepperRegister({super.key});

  @override
  State<StepperRegister> createState() => _StepperRegisterState();
}

class _StepperRegisterState extends State<StepperRegister> {
  int currentStep = 0;

  // 1. EL MÉTODO BUILD (EL CORAZÓN)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            Expanded(child: _buildCurrentStep()), // Aquí se infla el paso actual
            MainButton(
              text: currentStep == 2 ? "CONFIRMAR" : "SIGUIENTE",
              onPressed: () {
                setState(() {
                  if (currentStep < 2) {
                    currentStep++;
                  } else {
                    print("Llamando a Java Backend...");
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  // 2. EL "SELECTOR" DE PASOS
  Widget _buildCurrentStep() {
    switch (currentStep) {
      case 0:
        return Column(
          children: [
            const Text("Hola,\nCrea una cuenta", textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            _buildInput("Nombre completo", Icons.person_outline),
            _buildInput("Número de teléfono", Icons.phone_android_outlined),
            _buildInput("Email", Icons.email_outlined),
            _buildInput("Contraseña", Icons.lock_outline),
          ],
        );
      case 1:
        return Column(
          children: [
            const Text("Completa tu perfil", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildInput("Selecciona tu género", Icons.people_outline),
            _buildInput("Año de nacimiento", Icons.calendar_month_outlined),
            _buildInput("Peso", Icons.monitor_weight_outlined, suffix: "KG"),
            _buildInput("Estatura", Icons.height_outlined, suffix: "CM"),
          ],
        );
      case 2:
        return const Center(child: Text("¿Cuál es tu meta?"));
      default:
        return const SizedBox();
    }
  }

  // 3. LA HERRAMIENTA PARA CREAR INPUTS (MÉTELA AQUÍ ABAJO)
  Widget _buildInput(String label, IconData icon, {String? suffix}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey),
          suffixText: suffix,
          filled: true,
          fillColor: const Color(0xFFF7F8F8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
} // <--- ESTA ES LA LLAVE QUE CIERRA TODA LA CLASE