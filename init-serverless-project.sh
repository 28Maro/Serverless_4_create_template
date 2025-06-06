#!/bin/bash
#Versión nueva
# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Generador de Proyecto Serverless v4 con TypeScript${NC}"
echo -e "${BLUE}====================================================${NC}"

# Verificar si Serverless Framework está instalado
if ! command -v serverless &>/dev/null; then
  echo -e "${RED}❌ Serverless Framework no está instalado.${NC}"
  echo -e "${YELLOW}Instálalo con: npm install -g serverless@^4${NC}"
  exit 1
fi

# Verificar si Node.js está instalado
if ! command -v node &>/dev/null; then
  echo -e "${RED}❌ Node.js no está instalado.${NC}"
  echo -e "${YELLOW}Instálalo con: nvm install 22 && nvm use 22${NC}"
  exit 1
fi

# Verificar si npm está instalado
if ! command -v npm &>/dev/null; then
  echo -e "${RED}❌ npm no está instalado.${NC}"
  exit 1
fi

# ————————————————————————————————————————————————
# 1️⃣ Validación de versión mínima de Node.js (22.x)
NODE_VER=$(node -v) 
NODE_MAJOR=$(echo "$NODE_VER" | sed -E 's/^v([0-9]+).*/\1/')
if [ "$NODE_MAJOR" -lt 22 ]; then
  echo -e "${RED}❌ Tu versión de Node.js es $NODE_VER pero se requiere >= v22.x${NC}"
  echo -e "${YELLOW}Actualízala con: nvm install 22 && nvm use 22${NC}"
  exit 1
else
  echo -e "${GREEN}✔ Node.js $NODE_VER cumple el requisito${NC}"
fi

# 2️⃣ Validación de versión mínima de Serverless Framework (4.x)
# Intentar múltiples métodos para obtener la versión
SL_VER=""

# Método 1: serverless --version (formato "Serverless Framework X.Y.Z")
if [ -z "$SL_VER" ]; then
  SL_VER=$(serverless --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
fi

# Método 2: sls --version 
if [ -z "$SL_VER" ]; then
  SL_VER=$(sls --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
fi

# Método 3: Extraer de "Framework" específicamente
if [ -z "$SL_VER" ]; then
  SL_VER=$(serverless --version 2>/dev/null | sed -n 's/.*Framework \([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\).*/\1/p')
fi

# Método 4: npm list global como fallback
if [ -z "$SL_VER" ]; then
  SL_VER=$(npm list -g serverless --depth=0 2>/dev/null | grep serverless@ | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
fi

echo -e "${BLUE}🔍 Debug: Versión detectada de Serverless: '$SL_VER'${NC}"

if [ -n "$SL_VER" ]; then
  SL_MAJOR=$(echo "$SL_VER" | cut -d. -f1)
  if [ "$SL_MAJOR" -lt 4 ]; then
    echo -e "${RED}❌ Tu Serverless CLI es v$SL_VER y se requiere v4.x${NC}"
    echo -e "${YELLOW}Actualízala con: npm install -g serverless@^4${NC}"
    exit 1
  else
    echo -e "${GREEN}✔ Serverless Framework $SL_VER cumple el requisito${NC}"
  fi
else
  echo -e "${RED}❌ No se pudo detectar la versión de Serverless Framework${NC}"
  echo -e "${YELLOW}Verifica que esté instalado con: serverless --version${NC}"
  echo -e "${YELLOW}Output completo del comando:${NC}"
  serverless --version 2>/dev/null || echo "Error ejecutando comando"
  exit 1
fi

# ————————————————————————————————————————————————
# 3️⃣ Chequeo de versiones globales contra npm

# Serverless Framework - usar la versión ya detectada
INSTALLED_SL="$SL_VER"

LATEST_SL=$(npm view serverless version 2>/dev/null)
if [ -n "$INSTALLED_SL" ] && [ -n "$LATEST_SL" ] && [ "$INSTALLED_SL" != "$LATEST_SL" ]; then
  echo -e "${YELLOW}⚠️  Tu Serverless CLI está en v$INSTALLED_SL, pero la última es v$LATEST_SL${NC}"
  echo -e "${YELLOW}   Para actualizar: npm install -g serverless@^4${NC}"
elif [ -n "$INSTALLED_SL" ] && [ -n "$LATEST_SL" ]; then
  echo -e "${GREEN}✔ Serverless CLI v$INSTALLED_SL está al día (última: v$LATEST_SL)${NC}"
else
  echo -e "${YELLOW}⚠️  No se pudo verificar la versión de Serverless CLI contra npm${NC}"
fi

# serverless-offline (plugin)
if command -v npm &>/dev/null; then
  INSTALLED_OFFLINE=$(npm ls -g serverless-offline --depth=0 2>/dev/null | grep serverless-offline@ | cut -d@ -f2)
  LATEST_OFFLINE=$(npm view serverless-offline version 2>/dev/null)
  if [ -n "$INSTALLED_OFFLINE" ] && [ "$INSTALLED_OFFLINE" != "$LATEST_OFFLINE" ]; then
    echo -e "${YELLOW}⚠️  Tienes serverless-offline v$INSTALLED_OFFLINE, pero la última es v$LATEST_OFFLINE${NC}"
    echo -e "${YELLOW}   Para actualizar: npm install -g serverless-offline@^14${NC}"
  else
    echo -e "${GREEN}✔ serverless-offline v$INSTALLED_OFFLINE está al día (última: v$LATEST_OFFLINE)${NC}"
  fi
fi
# ————————————————————————————————————————————————

# ————————————————————————————————————————————————
# Chequeo de serverless-offline en el proyecto (no global)
if [ -f package.json ]; then
  INST_OFFLINE=$(npm ls serverless-offline --depth=0 2>/dev/null \
    | grep serverless-offline@ | cut -d@ -f2)
  LATEST_OFF=$(npm view serverless-offline version 2>/dev/null)
  if [ -n "$INST_OFFLINE" ] && [ "$INST_OFFLINE" != "$LATEST_OFF" ]; then
    echo -e "${YELLOW}⚠️  Tu proyecto usa serverless-offline v$INST_OFFLINE, pero la última es v$LATEST_OFF${NC}"
    echo -e "${YELLOW}   Actualízalo con: npm install --save-dev serverless-offline@^14${NC}"
  else
    echo -e "${GREEN}✔ serverless-offline v${INST_OFFLINE:-"no instalado local"} está al día (última: v$LATEST_OFF)${NC}"
  fi
fi
# ————————————————————————————————————————————————

# Obtener nombre del proyecto (parámetro o input interactivo)
if [ -n "$1" ]; then
  PROJECT_NAME="$1"
  echo -e "${GREEN}📝 Usando nombre del proyecto: ${YELLOW}$PROJECT_NAME${NC}"
elif [ -n "$PROJECT_NAME" ]; then
  # Variable de entorno (para uso con curl)
  echo -e "${GREEN}📝 Usando nombre del proyecto: ${YELLOW}$PROJECT_NAME${NC}"
else
  # Input interactivo
  echo -e "${YELLOW}📝 Ingresa el nombre de tu proyecto:${NC}"
  read -p "Nombre del proyecto: " PROJECT_NAME
fi

# Validar que el nombre no esté vacío
if [ -z "$PROJECT_NAME" ]; then
  echo -e "${RED}❌ El nombre del proyecto no puede estar vacío.${NC}"
  exit 1
fi

# Limpiar el nombre del proyecto para que sea válido para Serverless
PROJECT_NAME_CLEAN=$(echo "$PROJECT_NAME" | sed 's/[^a-zA-Z0-9-]//g' | sed 's/^[^a-zA-Z]*//' | sed 's/--*/-/g')
if [ -z "$PROJECT_NAME_CLEAN" ]; then
  PROJECT_NAME_CLEAN="my-serverless-project"
  echo -e "${YELLOW}⚠️ Nombre corregido a: $PROJECT_NAME_CLEAN${NC}"
fi

# Verificar si el directorio ya existe
if [ -d "$PROJECT_NAME" ]; then
  echo -e "${RED}❌ El directorio '$PROJECT_NAME' ya existe.${NC}"
  exit 1
fi

echo -e "${GREEN}📂 Creando directorio del proyecto...${NC}"
mkdir "$PROJECT_NAME"
cd "$PROJECT_NAME"

echo -e "${GREEN}📦 Inicializando package.json...${NC}"
cat >package.json <<EOF
{
  "name": "$PROJECT_NAME_CLEAN",
  "version": "1.0.0",
  "description": "Serverless v4 TypeScript project",
  "main": "handler.js",
  "scripts": {
    "predev": "cp .env.dev .env || true",
    "dev": "npm run predev && npx serverless offline",
    "invoke:local:scheduledExample": "npx serverless invoke local -f scheduledExample --stage dev",
    "predeploy:dev": "cp .env.dev .env || true",
    "deploy:dev": "npm run predeploy:dev && npx serverless deploy --stage dev",
    "deploy:prod": "npx serverless deploy --stage prod",
    "remove": "npx serverless remove",
    "logs": "npx serverless logs -f",
    "invoke": "npx serverless invoke -f",
    "invoke:local": "npx serverless invoke local -f",
    "type-check": "npx tsc --noEmit",
    "test": "npx jest",
    "test:watch": "npx jest --watch",
    "sls": "npx serverless"
  },
  "devDependencies": {
    "serverless": "^4.14.4",
    "@serverless/typescript": "^4.14.1", 
    "@types/aws-lambda": "^8.10.145",
    "@types/jest": "^29.5.8",
    "@types/node": "^22.10.0",
    "jest": "^29.7.0",
    "serverless-offline": "^14.4.0",
    "ts-jest": "^29.2.0",
    "tsconfig-paths": "^4.2.0",
    "typescript": "^5.7.0",
    "@middy/http-json-body-parser": "^5.5.0",
    "@middy/validator": "^5.5.0"
  },
  "dependencies": {
    "@middy/core": "^5.5.0",
    "@middy/http-json-body-parser": "^5.5.0",
    "json-schema-to-ts": "^3.1.0"
  },
  "author": "OLC",
  "license": "MIT"
}
EOF

echo -e "${GREEN}⚙️ Creando configuración de TypeScript...${NC}"
cat >tsconfig.json <<EOF
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
    "coverage",
    "*.test.ts",
    "*.spec.ts",
    "eslint.config.js",
    "jest.config.js"
  ]
}
EOF


echo -e "${GREEN}🧪 Creando configuración de Jest...${NC}"
cat >jest.config.js <<EOF
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/src'],
  testMatch: ['**/__tests__/**/*.ts', '**/?(*.)+(spec|test).ts'],
  transform: {
    '^.+\\.ts$': 'ts-jest',
  },
  collectCoverageFrom: [
    'src/**/*.ts',
    '!src/**/*.d.ts',
    '!src/**/__tests__/**',
    '!src/**/*.test.ts',
    '!src/**/*.spec.ts'
  ],
  moduleNameMapping: {
    '^@/(.*)$': '<rootDir>/src/$1',
    '^@functions/(.*)$': '<rootDir>/src/functions/$1',
    '^@libs/(.*)$': '<rootDir>/src/libs/$1'
  }
};
EOF

echo -e "${GREEN}📝 Creando archivo .gitignore...${NC}"
cat >.gitignore <<EOF
# Logs
logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Directory for instrumented libs generated by jscoverage/JSCover
lib-cov

# Coverage directory used by tools like istanbul
coverage
*.lcov

# nyc test coverage
.nyc_output

# Grunt intermediate storage (https://gruntjs.com/creating-plugins#storing-task-files)
.grunt

# Bower dependency directory (https://bower.io/)
bower_components

# node-waf configuration
.lock-wscript

# Compiled binary addons (https://nodejs.org/api/addons.html)
build/Release

# Dependency directories
node_modules/
jspm_packages/

# TypeScript cache
*.tsbuildinfo

# Optional npm cache directory
.npm

# Optional eslint cache
.eslintcache

# Microbundle cache
.rpt2_cache/
.rts2_cache_cjs/
.rts2_cache_es/
.rts2_cache_umd/

# Optional REPL history
.node_repl_history

# Output of 'npm pack'
*.tgz

# Yarn Integrity file
.yarn-integrity

# dotenv environment variables file
.env
.env.test
.env.local
.env.prod

# parcel-bundler cache (https://parceljs.org/)
.cache
.parcel-cache

# Next.js build output
.next

# Nuxt.js build / generate output
.nuxt
dist

# Gatsby files
.cache/
public

# Vuepress build output
.vuepress/dist

# Serverless directories
.serverless/
.build/

# FuseBox cache
.fusebox/

# DynamoDB Local files
.dynamodb/

# TernJS port file
.tern-port

# AWS credentials
.aws/

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Build outputs
dist/
build/

# Environment files
.env*
EOF

echo -e "${GREEN}⚡ Creando configuración principal de Serverless (serverless.ts)...${NC}"
cat >serverless.ts <<'EOF'
import 'tsconfig-paths/register'; 
import type { AWS } from '@serverless/typescript';
import { hello, scheduledExample } from './src/functions/index';

const serverlessConfiguration: AWS = {
  service: '$PROJECT_NAME_CLEAN',
  frameworkVersion: '4',
  useDotenv: true,
  plugins: ['serverless-offline'],
  provider: {
    name: 'aws',
    runtime: 'nodejs22.x',
    architecture: 'arm64',
    region: 'us-east-1',
    stage: '${opt:stage, "dev"}',
    memorySize: 1024,
    timeout: 30,
    logRetentionInDays: 14,
    deploymentMethod: 'direct',
    apiGateway: {
      minimumCompressionSize: 1024,
      shouldStartNameWithService: true,
    },
    environment: {
      AWS_NODEJS_CONNECTION_REUSE_ENABLED: '1',
      NODE_OPTIONS: '--enable-source-maps --stack-trace-limit=1000',
      STAGE: '${self:provider.stage}',
      MY_API_KEY: '${env:MY_API_KEY}',
      LOG_LEVEL: '${env:LOG_LEVEL}',
    },
    iam: {
      role: {
        statements: [
          {
            Effect: 'Allow',
            Action: [
              'logs:CreateLogGroup',
              'logs:CreateLogStream',
              'logs:PutLogEvents',
            ],
            Resource: 'arn:aws:logs:*:*:*',
          },
        ],
      },
    },
  },

  build: {
    esbuild: {
      bundle: true,
      minify: false,
      sourcemap: true,
      exclude: ['@aws-sdk/*'],
      target: 'node22',
      define: {
        'require.resolve': undefined,
      },
      platform: 'node',
    },
  },

  stages: {
    dev: {
      params: {
        logLevel: 'debug',
      },
    },
    prod: {
      params: {
        logLevel: 'warn',
      },
    },
  },

  functions: {
    hello,
    scheduledExample
  },

  package: {
    individually: true,
    excludeDevDependencies: true,
  },

  custom: {
    'serverless-offline': {
      httpPort: 3000,
      babelOptions: {
        presets: ['env'],
      },
    },
  },
};

module.exports = serverlessConfiguration;
EOF

# Reemplazar el placeholder con el nombre limpio del proyecto
sed -i '' "s/\\\$PROJECT_NAME_CLEAN/$PROJECT_NAME_CLEAN/g" serverless.ts

echo -e "${GREEN}📁 Creando estructura de directorios...${NC}"
mkdir -p src/{functions,libs}
mkdir -p src/functions/hello

echo -e "${GREEN}🔧 Creando función de ejemplo 'hello'...${NC}"
cat > src/functions/hello/handler.ts <<EOF
import type { ValidatedEventAPIGatewayProxyEvent } from '@libs/api-gateway';
import { formatJSONResponse } from '@libs/api-gateway';
import { middyfy } from '@libs/lambda';
import schema from './schema';

const hello: ValidatedEventAPIGatewayProxyEvent<typeof schema> = async (event) => {
  const { name } = event.body;
  
  return formatJSONResponse({
    message: \`Hello \${name}! Welcome to the exciting Serverless world!\`,
    event,
  });
};

export const main = middyfy(hello);
EOF

cat >src/functions/hello/index.ts <<EOF
import schema from './schema';
import { handlerPath } from '@libs/handler-resolver';

export default {
  handler: \`\${handlerPath(__dirname)}/handler.main\`,
  events: [
    {
      http: {
        method: 'post',
        path: 'hello',
        request: {
          schemas: {
            'application/json': schema,
          },
        },
      },
    },
  ],
};
EOF

cat >src/functions/hello/schema.ts <<EOF
export default {
  type: 'object',
  properties: {
    name: { type: 'string' },
  },
  required: ['name'],
  additionalProperties: false,
} as const;
EOF

cat >src/functions/hello/mock.json <<EOF
{
  "headers": {
    "Content-Type": "application/json"
  },
  "body": "{\"name\": \"Serverless Developer\"}"
}
EOF

echo -e "${GREEN}📁 Creando función de ejemplo 'scheduledExample'...${NC}"
mkdir -p src/functions/scheduled

cat >src/functions/scheduled/handler.ts <<EOF
import type { Handler } from 'aws-lambda';

export const main: Handler = async (_event, _context) => {
  const apiKey = process.env.MY_API_KEY;
  const level = process.env.LOG_LEVEL;
  console.log(\`🔑 Key=\${apiKey} · Level=\${level} · triggered at \${new Date().toISOString()}\`);
  return {
    statusCode: 200,
    body: JSON.stringify({ message: 'scheduledExample ejecutada con éxito' }),
  };
};
EOF

cat >src/functions/scheduled/index.ts <<EOF
export default {
  handler: 'src/functions/scheduled/handler.main',
  events: [
    {
      schedule: {
        rate: ['rate(5 minutes)'],
        enabled: true,
        name: '\${self:service}-\${self:provider.stage}-scheduledExample',
        description: 'Invocación programada cada 5 min para ejemplo',
      },
    },
  ],
};
EOF

echo -e "${GREEN}🧪 Creando test para 'scheduledExample'...${NC}"
mkdir -p src/functions/scheduled/__tests__

cat >src/functions/scheduled/__tests__/handler.test.ts <<EOF
import { main } from '../handler';
import { Context } from 'aws-lambda';

describe('scheduledExample Handler', () => {
  const mockContext: Context = {} as any;

  it('debe responder con statusCode 200 y mensaje correcto', async () => {
    const result = await main({}, mockContext, () => {});
    expect(result.statusCode).toBe(200);
    const body = JSON.parse(result.body as string);
    expect(body.message).toBe('scheduledExample ejecutada con éxito');
  });
});
EOF

echo -e "${GREEN}📋 Creando archivo de índice de funciones...${NC}"
cat >src/functions/index.ts <<EOF
export { default as hello } from './hello';
export { default as scheduledExample } from './scheduled';
EOF

echo -e "${GREEN}🛠️ Creando librerías auxiliares...${NC}"
cat >src/libs/api-gateway.ts <<EOF
import type { APIGatewayProxyEvent, APIGatewayProxyResult, Handler } from 'aws-lambda';
import type { FromSchema } from 'json-schema-to-ts';

type ValidatedAPIGatewayProxyEvent<S> = Omit<APIGatewayProxyEvent, 'body'> & { body: FromSchema<S> };
export type ValidatedEventAPIGatewayProxyEvent<S> = Handler<ValidatedAPIGatewayProxyEvent<S>, APIGatewayProxyResult>;

export const formatJSONResponse = (response: Record<string, unknown>): APIGatewayProxyResult => {
  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Credentials': true,
    },
    body: JSON.stringify(response),
  };
};

export const formatErrorResponse = (statusCode: number, message: string): APIGatewayProxyResult => {
  return {
    statusCode,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Credentials': true,
    },
    body: JSON.stringify({
      error: true,
      message,
    }),
  };
};
EOF

cat >src/libs/handler-resolver.ts <<EOF
export const handlerPath = (context: string): string => {
  return \`\${context.split(process.cwd())[1].substring(1).replace(/\\\\/g, '/')}\`;
};
EOF

cat >src/libs/lambda.ts <<'EOF'
import middy from '@middy/core';
import jsonBodyParser from '@middy/http-json-body-parser';
import validator from '@middy/validator';

export const middyfy = (handler: any, schema?: object) => {
  let m = middy(handler)
    .use(jsonBodyParser());

  if (schema) {
    m = m.use(validator({ 
      inputSchema: schema, 
      ajvOptions: { strict: false } 
    }));
  }

  return m;
};
EOF

echo -e "${GREEN}🧪 Creando pruebas de ejemplo...${NC}"
mkdir -p src/functions/hello/__tests__
cat >src/functions/hello/__tests__/handler.test.ts <<EOF
import { main } from '../handler';
import { APIGatewayProxyEvent, Context } from 'aws-lambda';

describe('Hello Handler', () => {
  const mockContext: Context = {
    callbackWaitsForEmptyEventLoop: false,
    functionName: 'test',
    functionVersion: '1',
    invokedFunctionArn: 'arn:aws:lambda:us-east-1:123456789012:function:test',
    memoryLimitInMB: '128',
    awsRequestId: '1234567890',
    logGroupName: '/aws/lambda/test',
    logStreamName: '2021/01/01/[\$LATEST]abcdef123456',
    getRemainingTimeInMillis: () => 30000,
    done: () => {},
    fail: () => {},
    succeed: () => {},
  };

  it('should return a successful response', async () => {
    const event: Partial<APIGatewayProxyEvent> = {
      body: JSON.stringify({ name: 'Test User' }),
      headers: { 'Content-Type': 'application/json' },
    };

    const result = await main(event as APIGatewayProxyEvent, mockContext, () => {});
    
    expect(result.statusCode).toBe(200);
    const body = JSON.parse(result.body);
    expect(body.message).toContain('Hello Test User!');
  });
});
EOF

echo -e "${GREEN}📖 Creando archivo README...${NC}"
cat >README.md <<EOF
# $PROJECT_NAME

Proyecto Serverless Framework v4 con TypeScript y Node.js 22

## 🚀 Características

- **Serverless Framework v4** con soporte nativo para TypeScript
- **Node.js 22** con arquitectura ARM64
- **ESBuild** integrado para bundling ultrarrápido
- **TypeScript** con configuración estricta
- **ESLint** y **Jest** preconfigurados
- **Serverless Offline** para desarrollo local
- **API Gateway** con validación de schemas JSON
- **AWS Lambda** optimizado con source maps

## 📁 Estructura del Proyecto

\`\`\`
$PROJECT_NAME/
├── src/
│   ├── functions/           # Funciones Lambda
│   │   ├── hello/          # Función de ejemplo
│   │   │   ├── handler.ts   # Lógica de la función
│   │   │   ├── index.ts     # Configuración de la función
│   │   │   ├── schema.ts    # Schema de validación JSON
│   │   │   └── mock.json    # Datos de prueba
│   │   └── index.ts        # Exportaciones de funciones
│   └── libs/               # Librerías compartidas
│       ├── api-gateway.ts  # Helpers para API Gateway
│       ├── handler-resolver.ts
│       └── lambda.ts       # Middlewares de Lambda
├── serverless.ts           # Configuración principal
├── tsconfig.json          # Configuración de TypeScript
├── jest.config.js         # Configuración de Jest
└── package.json
\`\`\`

## 🛠️ Comandos Disponibles

### Desarrollo
\`\`\`bash
# Instalar dependencias
npm install

# Ejecutar en modo desarrollo (local)
npm run dev

# Verificar tipos de TypeScript
npm run type-check

# Ejecutar linter
npm run lint
npm run lint:fix
\`\`\`

### Testing
\`\`\`bash
# Ejecutar tests
npm test

# Ejecutar tests en modo watch
npm run test:watch
\`\`\`

### Deployment
\`\`\`bash
# Deploy a desarrollo
npm run deploy

# Deploy a producción
npm run deploy:prod

# Remover stack
npm run remove
\`\`\`

### Lambda Functions
\`\`\`bash
# Invocar función localmente
npm run invoke:local hello -- --path src/functions/hello/mock.json

# Invocar función en AWS
npm run invoke hello

# Ver logs de función
npm run logs hello
\`\`\`

## 🔧 Configuración

### Variables de Entorno

El proyecto soporta múltiples stages con configuraciones específicas:

- **dev**: Configuración de desarrollo
- **prod**: Configuración de producción

### API Gateway

Las funciones están configuradas para ser accesibles vía HTTP:

- **POST** \`/hello\` - Función de saludo que requiere \`{ "name": "string" }\`

### TypeScript

El proyecto incluye:
- Configuración estricta de TypeScript
- Path mapping para imports limpios (\`@/\`, \`@functions/\`, \`@libs/\`)
- Source maps habilitados para debugging

## 📝 Ejemplo de Uso

### Desarrollo Local

1. Inicia el servidor local:
   \`\`\`bash
   npm run dev
   \`\`\`

2. Prueba la función hello:
   \`\`\`bash
   curl -X POST http://localhost:3000/dev/hello \\
     -H "Content-Type: application/json" \\
     -d '{"name": "Mundo"}'
   \`\`\`

### Agregar Nueva Función

1. Crea una nueva carpeta en \`src/functions/\`
2. Agrega los archivos: \`handler.ts\`, \`index.ts\`, \`schema.ts\`
3. Exporta la función en \`src/functions/index.ts\`
4. Actualiza \`serverless.ts\` para incluir la nueva función

## 🏗️ Arquitectura

- **Runtime**: Node.js 22.x
- **Arquitectura**: ARM64 (mejor costo-beneficio)
- **Bundler**: ESBuild nativo de Serverless v4
- **Validación**: JSON Schema para requests
- **Middlewares**: Middy para manejo de eventos Lambda
- **Testing**: Jest con soporte para TypeScript

## 📦 Dependencias Principales

- \`@types/aws-lambda\` - Tipos para AWS Lambda
- \`serverless-offline\` - Desarrollo local
- \`typescript\` - Transpilación
- \`jest\` - Testing framework
- \`eslint\` - Linting de código

## 🚀 Deploy

El proyecto está configurado para deployar a AWS usando Serverless Framework v4:

\`\`\`bash
# Deploy con stage por defecto (dev)
serverless deploy

# Deploy a producción
serverless deploy --stage prod
\`\`\`

## 📄 Licencia

MIT
EOF

echo -e "${GREEN}🔐 Creando archivo de variables de entorno .env.dev...${NC}"
cat > .env.dev <<EOF
# Variables de entorno para desarrollo
MY_API_KEY=your_api_key_here
LOG_LEVEL=info
EOF

echo -e "${GREEN}📦 Instalando dependencias...${NC}"
npm install

echo -e "${GREEN}✅ ¡Proyecto creado exitosamente!${NC}"
echo ""
echo -e "${BLUE}📁 Directorio: ${YELLOW}$PROJECT_NAME${NC}"
echo -e "${BLUE}🚀 Para empezar:${NC}"
echo -e "  ${YELLOW}cd $PROJECT_NAME${NC}"
echo -e "  ${YELLOW}npm run dev${NC}"
echo ""
echo -e "${BLUE}🧪 Para probar la función HTTP "hello":${NC}"
echo -e "  ${YELLOW}curl -X POST http://localhost:3000/dev/hello \\"
echo -e "    -H \"Content-Type: application/json\" \\"
echo -e "    -d '{\"name\": \"Mundo\"}'${NC}"
echo ""
echo -e "${BLUE}🧪 Para invocar localmente la función programada "scheduledExample":${NC}"
echo -e "  ${YELLOW}npm run invoke:local:scheduledExample${NC}"
echo ""
echo -e "${GREEN}🎉 ¡Happy coding!${NC}"