#!/bin/bash

# Script para migrar proyecto Serverless v3 a v4
# Ejecutar desde la raíz del proyecto existente

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔄 Migración de Serverless v3 a v4${NC}"
echo -e "${BLUE}====================================${NC}"

# Verificar si estamos en un proyecto Serverless
if [ ! -f "serverless.yml" ] && [ ! -f "serverless.ts" ]; then
    echo -e "${RED}❌ No se encontró serverless.yml o serverless.ts${NC}"
    echo -e "${YELLOW}Asegúrate de estar en la raíz de tu proyecto Serverless${NC}"
    exit 1
fi

# Backup del proyecto actual
echo -e "${YELLOW}📋 Creando backup del proyecto actual...${NC}"
BACKUP_DIR="backup-$(date +%Y%m%d-%H%M%S)"
mkdir "$BACKUP_DIR"
cp -r . "$BACKUP_DIR/" 2>/dev/null || true
echo -e "${GREEN}✅ Backup creado en: $BACKUP_DIR${NC}"

# Actualizar Serverless Framework
echo -e "${YELLOW}📦 Actualizando Serverless Framework a v4...${NC}"
npm install -g serverless@latest

# Actualizar package.json
echo -e "${YELLOW}🔧 Actualizando package.json...${NC}"

# Remover plugins que ya no son necesarios en v4
npm uninstall serverless-webpack serverless-plugin-typescript serverless-esbuild 2>/dev/null || true

# Instalar dependencias necesarias para v4
npm install --save-dev typescript@latest @types/aws-lambda@latest @types/node@latest

# Actualizar serverless-offline si existe
if npm list serverless-offline &>/dev/null; then
    npm install --save-dev serverless-offline@latest
fi

# Convertir serverless.yml a serverless.ts si no existe
if [ -f "serverless.yml" ] && [ ! -f "serverless.ts" ]; then
    echo -e "${YELLOW}🔄 Detectado serverless.yml. Considera convertir a serverless.ts para mejor tipado${NC}"
    echo -e "${BLUE}Ejemplo de serverless.ts:${NC}"
    cat << 'EOF'
import type { AWS } from '@serverless/typescript';

const serverlessConfiguration: AWS = {
  service: 'tu-servicio',
  frameworkVersion: '4',
  
  provider: {
    name: 'aws',
    runtime: 'nodejs22.x',
    architecture: 'arm64',
    // ... resto de tu configuración
  },
  
  // ¡ESBuild ahora es nativo!
  build: {
    esbuild: {
      bundle: true,
      minify: false,
      sourcemap: true,
      exclude: ['@aws-sdk/*'],
      target: 'node22',
    },
  },
  
  functions: {
    // tus funciones
  },
  
  plugins: ['serverless-offline'], // Solo los plugins que realmente necesitas
};

module.exports = serverlessConfiguration;
EOF
fi

# Actualizar tsconfig.json
echo -e "${YELLOW}📝 Actualizando configuración de TypeScript...${NC}"
cat > tsconfig.json << EOF
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "commonjs",
    "lib": ["ES2022"],
    "moduleResolution": "node",
    "rootDir": "./",
    "outDir": "./.build",
    "removeComments": true,
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "noImplicitThis": true,
    "noImplicitReturns": true,
    "allowSyntheticDefaultImports": true,
    "esModuleInterop": true,
    "experimentalDecorators": true,
    "emitDecoratorMetadata": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": false,
    "sourceMap": true,
    "baseUrl": "./",
    "paths": {
      "@/*": ["./src/*"],
      "@functions/*": ["./src/functions/*"],
      "@libs/*": ["./src/libs/*"]
    }
  },
  "include": [
    "src/**/*",
    "serverless.ts"
  ],
  "exclude": [
    "node_modules",
    ".serverless",
    ".build",
    "dist",
    "coverage"
  ]
}
EOF

# Actualizar .gitignore
echo -e "${YELLOW}📝 Actualizando .gitignore...${NC}"
cat >> .gitignore << EOF

# Serverless v4 specific
.build/
EOF

# Verificar estructura de funciones
echo -e "${YELLOW}🔍 Verificando estructura de funciones...${NC}"
if [ -d "src/functions" ]; then
    echo -e "${GREEN}✅ Estructura de funciones detectada en src/functions/${NC}"
    
    # Verificar si las funciones tienen la estructura correcta
    for func_dir in src/functions/*/; do
        func_name=$(basename "$func_dir")
        if [ -f "${func_dir}handler.ts" ] && [ -f "${func_dir}index.ts" ]; then
            echo -e "${GREEN}  ✅ $func_name tiene estructura correcta${NC}"
        else
            echo -e "${YELLOW}  ⚠️  $func_name podría necesitar ajustes de estructura${NC}"
            echo -e "${BLUE}     Estructura recomendada:${NC}"
            echo -e "${BLUE}     - handler.ts (lógica de la función)${NC}"
            echo -e "${BLUE}     - index.ts (configuración serverless)${NC}"
            echo -e "${BLUE}     - schema.ts (validación JSON schema)${NC}"
        fi
    done
else
    echo -e "${YELLOW}⚠️  No se detectó estructura src/functions/. Considera reorganizar tu código.${NC}"
fi

# Consejos para la migración
echo -e "${BLUE}📋 Pasos siguientes para completar la migración:${NC}"
echo -e "${YELLOW}1. Actualizar serverless.yml a serverless.ts (recomendado)${NC}"
echo -e "${YELLOW}2. Remover configuraciones de webpack/esbuild plugins del serverless config${NC}"
echo -e "${YELLOW}3. Agregar configuración 'build.esbuild' nativa de v4${NC}"
echo -e "${YELLOW}4. Actualizar runtime a 'nodejs22.x' y architecture a 'arm64'${NC}"
echo -e "${YELLOW}5. Probar localmente: npm run dev o serverless offline${NC}"
echo -e "${YELLOW}6. Hacer deploy de prueba: serverless deploy${NC}"

echo -e "${GREEN}🔧 Cambios principales de v4:${NC}"
echo -e "${GREEN}✅ ESBuild nativo (no necesitas serverless-webpack)${NC}"
echo -e "${GREEN}✅ TypeScript out-of-the-box${NC}"
echo -e "${GREEN}✅ Better performance con Node.js 22${NC}"
echo -e "${GREEN}✅ Arquitectura ARM64 por defecto (mejor costo)${NC}"

echo -e "${BLUE}📚 Documentación útil:${NC}"
echo -e "${BLUE}https://www.serverless.com/framework/docs/guides/upgrading-v4${NC}"

echo -e "${GREEN}✅ Migración base completada. Revisa y ajusta según tus necesidades.${NC}"
echo -e "${YELLOW}💡 Backup disponible en: $BACKUP_DIR${NC}"