#!/bin/bash

# 🚀 Script para ejecutar FitPaw en modo OFFLINE

echo "╔════════════════════════════════════════════════════════════╗"
echo "║        FitPaw - OFFLINE MODE (Sin Backend)                ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "📱 Selecciona cómo ejecutar:"
echo ""
echo "  [1] Web (Recomendado) - http://127.0.0.1:8085"
echo "  [2] Android Emulator"
echo "  [3] iOS Simulator"
echo "  [4] Dispositivo físico"
echo ""
read -p "Selecciona una opción [1-4]: " option

case $option in
  1)
    echo ""
    echo "🌐 Iniciando en WEB..."
    echo "   URL: http://127.0.0.1:8085"
    echo ""
    flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8085
    ;;
  2)
    echo ""
    echo "🤖 Iniciando en ANDROID..."
    flutter run -d android
    ;;
  3)
    echo ""
    echo "🍎 Iniciando en iOS..."
    flutter run -d ios
    ;;
  4)
    echo ""
    echo "📱 Iniciando en DISPOSITIVO FÍSICO..."
    flutter run
    ;;
  *)
    echo "❌ Opción inválida"
    exit 1
    ;;
esac

echo ""
echo "✅ Aplicación iniciada en modo OFFLINE"
echo "📝 Ver README_OFFLINE.md para más detalles"
