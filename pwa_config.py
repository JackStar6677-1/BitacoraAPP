"""
Configuración PWA para BitacoraAPP
Incluye configuración HTTPS y optimizaciones para PWA
"""

import os
import ssl
from flask import Flask, send_from_directory, jsonify, request

def configure_pwa(app):
    """Configura la aplicación Flask para PWA"""
    
    # Configurar headers para PWA
    @app.after_request
    def after_request(response):
        # Headers para PWA
        response.headers['X-Content-Type-Options'] = 'nosniff'
        response.headers['X-Frame-Options'] = 'DENY'
        response.headers['X-XSS-Protection'] = '1; mode=block'
        response.headers['Referrer-Policy'] = 'strict-origin-when-cross-origin'
        
        # Headers para Service Worker
        if hasattr(request, 'endpoint') and request.endpoint and 'sw.js' in str(request.endpoint):
            response.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate'
            response.headers['Pragma'] = 'no-cache'
            response.headers['Expires'] = '0'
        
        return response
    
    # Solo agregar rutas si no existen
    try:
        # Ruta para el Service Worker
        @app.route('/sw.js')
        def service_worker():
            return send_from_directory('static', 'sw.js', mimetype='application/javascript')
    except AssertionError:
        # La ruta ya existe, no hacer nada
        pass
    
    try:
        # Ruta para el manifest
        @app.route('/manifest.json')
        def manifest():
            return send_from_directory('static', 'manifest.json', mimetype='application/json')
    except AssertionError:
        # La ruta ya existe, no hacer nada
        pass
    
    try:
        # Ruta para iconos PWA
        @app.route('/static/imagenes/pwa_icons/<path:filename>')
        def pwa_icons(filename):
            return send_from_directory('static/imagenes/pwa_icons', filename)
    except AssertionError:
        # La ruta ya existe, no hacer nada
        pass
    
    try:
        # Ruta para verificar estado de PWA
        @app.route('/pwa-status')
        def pwa_status():
            return jsonify({
                'status': 'active',
                'version': '1.0.0',
                'features': {
                    'offline': True,
                    'installable': True,
                    'notifications': True,
                    'background_sync': True
                }
            })
    except AssertionError:
        # La ruta ya existe, no hacer nada
        pass
    
    return app

def create_ssl_context():
    """Crea contexto SSL para HTTPS (desarrollo)"""
    try:
        # Generar certificado autofirmado para desarrollo
        from cryptography import x509
        from cryptography.x509.oid import NameOID
        from cryptography.hazmat.primitives import hashes, serialization
        from cryptography.hazmat.primitives.asymmetric import rsa
        import datetime
        
        # Generar clave privada
        private_key = rsa.generate_private_key(
            public_exponent=65537,
            key_size=2048,
        )
        
        # Crear certificado
        subject = issuer = x509.Name([
            x509.NameAttribute(NameOID.COUNTRY_NAME, "CL"),
            x509.NameAttribute(NameOID.STATE_OR_PROVINCE_NAME, "Santiago"),
            x509.NameAttribute(NameOID.LOCALITY_NAME, "Santiago"),
            x509.NameAttribute(NameOID.ORGANIZATION_NAME, "Colegio Polivalente San Cristóbal Apóstol"),
            x509.NameAttribute(NameOID.COMMON_NAME, "localhost"),
        ])
        
        cert = x509.CertificateBuilder().subject_name(
            subject
        ).issuer_name(
            issuer
        ).public_key(
            private_key.public_key()
        ).serial_number(
            x509.random_serial_number()
        ).not_valid_before(
            datetime.datetime.utcnow()
        ).not_valid_after(
            datetime.datetime.utcnow() + datetime.timedelta(days=365)
        ).add_extension(
            x509.SubjectAlternativeName([
                x509.DNSName("localhost"),
                x509.IPAddress("127.0.0.1"),
            ]),
            critical=False,
        ).sign(private_key, hashes.SHA256())
        
        # Guardar certificado y clave
        with open("cert.pem", "wb") as f:
            f.write(cert.public_bytes(serialization.Encoding.PEM))
        
        with open("key.pem", "wb") as f:
            f.write(private_key.private_bytes(
                encoding=serialization.Encoding.PEM,
                format=serialization.PrivateFormat.PKCS8,
                encryption_algorithm=serialization.NoEncryption()
            ))
        
        # Crear contexto SSL
        context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
        context.load_cert_chain("cert.pem", "key.pem")
        
        return context
        
    except ImportError:
        print("⚠️  cryptography no está instalado. HTTPS no disponible.")
        print("Para habilitar HTTPS, instala: pip install cryptography")
        return None
    except Exception as e:
        print(f"⚠️  Error creando certificado SSL: {e}")
        return None

def run_pwa_server(app, host='0.0.0.0', port=5000, debug=False):
    """Ejecuta el servidor con configuración PWA"""
    
    # Configurar PWA
    app = configure_pwa(app)
    
    # Intentar crear contexto SSL
    ssl_context = create_ssl_context()
    
    if ssl_context:
        print("🔒 Servidor HTTPS iniciado en: https://localhost:5000")
        print("⚠️  Certificado autofirmado - aceptar advertencia de seguridad")
        app.run(host=host, port=port, debug=debug, ssl_context=ssl_context)
    else:
        print("🌐 Servidor HTTP iniciado en: http://localhost:5000")
        print("⚠️  PWA requiere HTTPS en producción")
        app.run(host=host, port=port, debug=debug)

if __name__ == "__main__":
    print("🚀 Iniciando servidor PWA...")
    print("📱 La aplicación será instalable como PWA")
    print("🔧 Configurando Service Worker y manifest...")
