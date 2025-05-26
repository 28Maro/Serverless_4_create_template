# 🚀 Serverless v4 TypeScript Template

Template optimizado para **Serverless Framework v4** con **TypeScript** y **Node.js 22**. 

Este template genera automáticamente proyectos serverless con todas las mejores prácticas y configuraciones optimizadas para desarrollo moderno.

## ✨ Características

- **Serverless Framework v4** con bundling nativo ESBuild
- **TypeScript** con configuración estricta y path mapping
- **Node.js 22.x** con arquitectura ARM64
- **Estructura modular** para funciones Lambda
- **Validación JSON Schema** automática
- **Testing** con Jest preconfigurado
- **Linting** con ESLint y reglas TypeScript
- **Desarrollo local** con serverless-offline
- **Source maps** habilitados para debugging
- **CI/CD ready** con scripts npm optimizados

## 🎯 Diferencias Clave con Serverless v3

### ✅ Ventajas de v4:
- **Bundling nativo**: No necesitas `serverless-webpack` o `serverless-esbuild`
- **TypeScript out-of-the-box**: Soporte nativo sin plugins adicionales
- **Mejor performance**: ESBuild integrado es más rápido que Webpack
- **Configuración simplificada**: Menos dependencias y plugins
- **Node.js 22 por defecto**: Última versión LTS soportada

### 📁 Estructura Generada:
```
mi-proyecto/
├── src/
│   ├── functions/               # 📂 Funciones Lambda
│   │   └── hello/              # 📂 Función de ejemplo
│   │       ├── handler.ts       # 🔧 Lógica de la función
│   │       ├── index.ts         # ⚙️ Configuración Serverless
│   │       ├── schema.ts        # 📋 Validación JSON Schema
│   │       └── mock.json        # 🧪 Datos de prueba
│   └── libs/                   # 📚 Librerías compartidas
├── serverless.ts               # ⚡ Configuración principal (TypeScript)
├── tsconfig.json              # 🔧 Config TypeScript con path mapping
├── jest.config.js             # 🧪 Config de testing
└── package.json               # 📦 Dependencias optimizadas
```

## 🚀 Uso Rápido

### Opción 1: Usar directamente desde este repositorio

```bash
# Clonar template
git clone https://github.com/tu-usuario/serverless-v4-typescript-template.git
cd serverless-v4-typescript-template

# Ejecutar script de creación
chmod +x init-serverless-project.sh
./init-serverless-project.sh
```

### Opción 2: Usar con npx (cuando subas a npm)

```bash
npx create-serverless-v4-ts mi-proyecto
```

### Opción 3: Usar con Serverless CLI

```bash
serverless create --template-url https://github.com/tu-usuario/serverless-v4-typescript-template --path mi-proyecto
cd mi-proyecto
chmod +x init-serverless-project.sh
./init-serverless-project.sh
```

## 🛠️ Prerequisitos

- **Node.js** >= 18.0.0 (recomendado 22.x)
- **npm** o **yarn**
- **Serverless Framework**: `npm install -g serverless`
- **AWS CLI** configurado (para deploy)

## 📋 Lo que incluye el proyecto generado

### 🔧 Configuraciones
- **serverless.ts**: Configuración en TypeScript (no YAML)
- **tsconfig.json**: TypeScript estricto con path mapping
- **jest.config.js**: Testing con cobertura
- **.eslintrc.json**: Linting con reglas TypeScript
- **.gitignore**: Archivos ignorados optimizados

### 📦 Scripts NPM
```json
{
  "dev": "serverless offline",           // 🚀 Desarrollo local
  "deploy": "serverless deploy",         // 🚀 Deploy a AWS
  "deploy:prod": "serverless deploy --stage prod", // 🏭 Deploy producción
  "remove": "serverless remove",         // 🗑️ Eliminar stack
  "logs": "serverless logs -f",          // 📊 Ver logs
  "invoke": "serverless invoke -f",      // ⚡ Ejecutar función
  "invoke:local": "serverless invoke local -f", // 🏠 Ejecutar local
  "lint": "eslint . --ext .ts",         // 🔍 Linting
  "lint:fix": "eslint . --ext .ts --fix", // 🔧 Fix automático
  "type-check": "tsc --noEmit",         // ✅ Verificar tipos
  "test": "jest",                       // 🧪 Ejecutar tests
  "test:watch": "jest --watch"          // 👀 Tests en modo watch
}
```

### 🏗️ Funciones de Ejemplo
- **Hello Function**: Función POST con validación JSON Schema
- **Middlewares**: Middy preconfigurado para parsing JSON
- **Type Safety**: Tipos completamente tipados con TypeScript
- **Testing**: Tests unitarios con Jest

### 📚 Librerías Incluidas
- **API Gateway Helpers**: Formateo de respuestas HTTP
- **Handler Resolver**: Resolución de paths de funciones
- **Lambda Middlewares**: Middy con parsers JSON

## 🎯 Flujo de Desarrollo

1. **Crear proyecto**: `./init-serverless-project.sh`
2. **Desarrollo local**: `npm run dev`
3. **Escribir tests**: `npm test`
4. **Verificar código**: `npm run lint && npm run type-check`
5. **Deploy**: `npm run deploy`

## 📝 Ejemplo de Nueva Función

Para crear una nueva función, simplemente crea la estructura:

```bash
mkdir src/functions/mi-funcion
```

**src/functions/mi-funcion/handler.ts**:
```typescript
import type { ValidatedEventAPIGatewayProxyEvent } from '@libs/api-gateway';
import { formatJSONResponse } from '@libs/api-gateway';
import { middyfy } from '@libs/lambda';
import schema from './schema';

const miFuncion: ValidatedEventAPIGatewayProxyEvent<typeof schema> = async (event) => {
  // Tu lógica aquí
  return formatJSONResponse({
    message: 'Mi función funciona!',
    data: event.body,
  });
};

export const main = middyfy(miFuncion);
```

**src/functions/mi-funcion/index.ts**:
```typescript
import schema from './schema';
import { handlerPath } from '@libs/handler-resolver';

export default {
  handler: `${handlerPath(__dirname)}/handler.main`,
  events: [
    {
      http: {
        method: 'post',
        path: 'mi-funcion',
        request: {
          schemas: {
            'application/json': schema,
          },
        },
      },
    },
  ],
};
```

**src/functions/mi-funcion/schema.ts**:
```typescript
export default {
  type: 'object',
  properties: {
    // Define tu schema aquí
    nombre: { type: 'string' },
    edad: { type: 'number' },
  },
  required: ['nombre'],
  additionalProperties: false,
} as const;
```

Luego exporta en **src/functions/index.ts**:
```typescript
export { default as hello } from './hello';
export { default as miFuncion } from './mi-funcion';  // ← Agregar aquí
```

Y agrega a **serverless.ts**:
```typescript
import { hello, miFuncion } from '@functions/index';

const serverlessConfiguration: AWS = {
  // ...
  functions: { hello, miFuncion },  // ← Agregar aquí
  // ...
};
```

## 🔧 Configuración Avanzada

### Variables de Entorno por Stage
```typescript
// En serverless.ts
stages: {
  dev: {
    params: {
      dbUrl: 'dev-database-url',
      logLevel: 'debug',
    },
  },
  prod: {
    params: {
      dbUrl: 'prod-database-url',
      logLevel: 'warn',
    },
  },
},
```

### ESBuild Personalizado
```typescript
// En serverless.ts
build: {
  esbuild: {
    bundle: true,
    minify: true,        // Minificar en producción
    sourcemap: true,     // Source maps habilitados
    target: 'node22',    // Target específico
    exclude: [           // Excluir dependencias
      '@aws-sdk/*',
      'aws-sdk'
    ],
    external: [          // Dependencias externas
      'pg-native'
    ],
  },
},
```

## 🚀 Deploy y CI/CD

### Deploy Manual
```bash
# Desarrollo
npm run deploy

# Producción
npm run deploy:prod

# Con variables específicas
serverless deploy --stage prod --region us-west-2
```

### GitHub Actions (Ejemplo)
```yaml
name: Deploy Serverless

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: actions/setup-node@v3
      with:
        node-version: '22'
    - run: npm ci
    - run: npm run lint
    - run: npm run type-check
    - run: npm test
    - run: npm run deploy:prod
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

## 🆚 Comparación con Templates Existentes

| Característica | Este Template | aws-nodejs-typescript | Otros |
|----------------|---------------|----------------------|-------|
| Serverless v4 | ✅ Nativo | ❌ v3 | ❌ v3 |
| Node.js 22 | ✅ Por defecto | ❌ 18/20 | ❌ Variado |
| ESBuild nativo | ✅ Sin plugins | ❌ Requiere plugins | ❌ Webpack |
| TypeScript config | ✅ Estricto + paths | ✅ Básico | ❌ Mínimo |
| Estructura modular | ✅ Completa | ❌ Básica | ❌ Básica |
| Testing setup | ✅ Jest + coverage | ❌ Sin config | ❌ Sin config |
| Linting | ✅ ESLint + TS rules | ❌ Sin config | ❌ Sin config |
| Source maps | ✅ Habilitado | ❌ Manual | ❌ Manual |
| ARM64 | ✅ Por defecto | ❌ x86 | ❌ x86 |

## 🤝 Contribuciones

¡Contribuciones son bienvenidas! Por favor:

1. Fork el repositorio
2. Crea una rama feature (`git checkout -b feature/nueva-caracteristica`)
3. Commit tus cambios (`git commit -am 'Agregar nueva característica'`)
4. Push a la rama (`git push origin feature/nueva-caracteristica`)
5. Crea un Pull Request

## 📄 Licencia

MIT License - consulta el archivo [LICENSE](LICENSE) para más detalles.

## 🙏 Agradecimientos

- [Serverless Framework](https://www.serverless.com/) por la increíble herramienta
- [AWS Lambda](https://aws.amazon.com/lambda/) por el servicio serverless
- [TypeScript](https://www.typescriptlang.org/) por el tipado estático
- [ESBuild](https://esbuild.github.io/) por el bundling ultrarrápido

---

⭐ **¡Si te gusta este template, dale una estrella en GitHub!** ⭐