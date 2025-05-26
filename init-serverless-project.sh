#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Colores para console
const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  magenta: '\x1b[35m',
  cyan: '\x1b[36m'
};

const log = (color, message) => console.log(`${colors[color]}${message}${colors.reset}`);

// Obtener argumentos
const projectName = process.argv[2];

if (!projectName) {
  log('red', '❌ Error: Debes proporcionar un nombre para el proyecto');
  log('yellow', '💡 Uso: npx create-serverless-v4-ts mi-proyecto');
  process.exit(1);
}

// Verificar si el directorio ya existe
if (fs.existsSync(projectName)) {
  log('red', `❌ Error: El directorio '${projectName}' ya existe`);
  process.exit(1);
}

log('blue', '🚀 Creando proyecto Serverless v4 con TypeScript...');
log('blue', '=' .repeat(50));

try {
  // Descargar template desde GitHub
  log('cyan', '📥 Descargando template...');
  execSync(`git clone https://github.com/28Maro/Serverless_4_create_template.git ${projectName}`, { 
    stdio: 'inherit' 
  });

  // Cambiar al directorio del proyecto
  process.chdir(projectName);

  // Remover .git del template
  log('cyan', '🧹 Limpiando archivos del template...');
  if (fs.existsSync('.git')) {
    execSync('rm -rf .git', { stdio: 'inherit' });
  }

  // Hacer ejecutable el script
  execSync('chmod +x init-serverless-project.sh', { stdio: 'inherit' });

  // Ejecutar el script de inicialización
  log('cyan', '⚙️ Inicializando proyecto...');
  execSync('./init-serverless-project.sh', { 
    stdio: 'inherit',
    input: `${projectName}\n`
  });

  log('green', '✅ ¡Proyecto creado exitosamente!');
  log('blue', `📁 Directorio: ${projectName}`);
  log('yellow', '🚀 Para empezar:');
  log('yellow', `  cd ${projectName}`);
  log('yellow', '  npm run dev');
  log('yellow', '🧪 Para probar:');
  log('yellow', '  curl -X POST http://localhost:3000/hello -H "Content-Type: application/json" -d \'{"name": "Mundo"}\'');
  log('green', '🎉 ¡Happy coding!');

} catch (error) {
  log('red', '❌ Error creando el proyecto:');
  console.error(error.message);
  process.exit(1);
}