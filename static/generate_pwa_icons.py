#!/usr/bin/env python3
"""
Script para generar iconos PWA desde el logo existente
Requiere: pip install Pillow
"""

from PIL import Image, ImageDraw
import os

def create_pwa_icons():
    """Genera iconos PWA en diferentes tamaños"""
    
    # Tamaños estándar para PWA
    sizes = [
        (16, 16),
        (32, 32),
        (48, 48),
        (72, 72),
        (96, 96),
        (128, 128),
        (144, 144),
        (152, 152),
        (192, 192),
        (384, 384),
        (512, 512)
    ]
    
    # Crear directorio para iconos PWA
    pwa_icons_dir = "static/imagenes/pwa_icons"
    os.makedirs(pwa_icons_dir, exist_ok=True)
    
    try:
        # Cargar imagen base
        base_image = Image.open("static/imagenes/logo2.jpg")
        
        # Convertir a RGBA si es necesario
        if base_image.mode != 'RGBA':
            base_image = base_image.convert('RGBA')
        
        for size in sizes:
            width, height = size
            
            # Crear imagen con fondo transparente
            icon = Image.new('RGBA', (width, height), (0, 0, 0, 0))
            
            # Redimensionar imagen base manteniendo aspecto
            resized = base_image.resize((width, height), Image.Resampling.LANCZOS)
            
            # Pegar imagen redimensionada
            icon.paste(resized, (0, 0), resized)
            
            # Guardar como PNG
            icon_path = f"{pwa_icons_dir}/icon-{width}x{height}.png"
            icon.save(icon_path, 'PNG')
            print(f"Generado: {icon_path}")
            
            # También generar versión con fondo blanco para maskable
            if width >= 192:  # Solo para iconos grandes
                icon_with_bg = Image.new('RGBA', (width, height), (255, 255, 255, 255))
                icon_with_bg.paste(resized, (0, 0), resized)
                
                maskable_path = f"{pwa_icons_dir}/icon-{width}x{height}-maskable.png"
                icon_with_bg.save(maskable_path, 'PNG')
                print(f"Generado (maskable): {maskable_path}")
        
        print("\n✅ Iconos PWA generados exitosamente!")
        print(f"📁 Ubicación: {pwa_icons_dir}")
        
    except FileNotFoundError:
        print("❌ Error: No se encontró el archivo logo2.jpg")
        print("Asegúrate de que existe en static/imagenes/logo2.jpg")
    except Exception as e:
        print(f"❌ Error generando iconos: {e}")

if __name__ == "__main__":
    create_pwa_icons()
