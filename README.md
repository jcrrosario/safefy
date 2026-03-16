# SafeFy

Cofre de senhas seguro desenvolvido em Flutter.

SafeFy é um aplicativo mobile focado em armazenar credenciais de forma criptografada no dispositivo do usuário. Todo o conteúdo do cofre é protegido por senha mestra e criptografia forte.

---

# Objetivo do projeto

Criar um gerenciador de senhas simples, seguro e totalmente offline.

O aplicativo permite:

* armazenar logins
* guardar senhas
* salvar notas seguras
* manter URLs e conteúdos sensíveis
* exportar backup criptografado
* restaurar backup criptografado

Todos os dados são protegidos por criptografia antes de serem armazenados.

---

# Tecnologias utilizadas

## Framework

Flutter

## Linguagem

Dart

## Banco de dados

SQLite utilizando Drift ORM

## Criptografia

AES‑256‑GCM

## Derivação de chave

PBKDF2 com SHA‑256

## Armazenamento seguro

flutter_secure_storage

---

# Arquitetura do projeto

Estrutura utilizada no projeto:

```
lib/

core/
  app_colors.dart
  app_theme.dart
  app_navigator.dart

pages/
  app_entry_page.dart
  dashboard_page.dart
  unlock_vault_page.dart
  splash_page.dart
  manual_sync_page.dart

models/
  backup_preview.dart

repositories/
  vault_repository.dart

services/
  backup_service.dart
  crypto_service.dart
  master_password_service.dart
  vault_lock_service.dart
  vault_state_service.dart

db/
  app_database.dart
  database_provider.dart
  tables.dart

widgets/
  componentes reutilizáveis
```

Arquitetura baseada em separação de responsabilidades:

UI → Pages

Lógica → Services

Persistência → Repository

Banco → Drift

---

# Dependências do projeto

Adicionar no pubspec.yaml

```
dependencies:
  flutter:
    sdk: flutter

  drift: ^2.16.0
  drift_flutter: ^0.1.0
  sqlite3_flutter_libs: ^0.5.20

  path_provider: ^2.1.2
  path: ^1.9.0

  flutter_secure_storage: ^9.0.0

  cryptography: ^2.7.0

  file_picker: ^8.0.0

  intl: ^0.19.0
```

Dev dependencies

```
dev_dependencies:
  flutter_test:
    sdk: flutter

  drift_dev: ^2.16.0
  build_runner: ^2.4.8

  flutter_lints: ^3.0.0
```

---

# Requisitos de ambiente

Para rodar o projeto é necessário:

Flutter SDK 3.x ou superior

Android Studio ou VSCode

Android SDK instalado

Emulador Android ou dispositivo físico

---

# Configuração inicial

1. Clone o repositório

```
git clone <repo>
```

2. Entre na pasta do projeto

```
cd safefy
```

3. Instale as dependências

```
flutter pub get
```

4. Gerar arquivos do Drift

Sempre que alterar tabelas do banco execute:

```
flutter pub run build_runner build --delete-conflicting-outputs
```

---

# Executar o projeto

Para rodar em modo debug:

```
flutter run
```

Para rodar em um dispositivo específico:

```
flutter devices

flutter run -d <device_id>
```

---

# Build do aplicativo

## APK

```
flutter build apk --release
```

Arquivo gerado:

```
build/app/outputs/flutter-apk/app-release.apk
```

## AppBundle (Google Play)

```
flutter build appbundle
```

Arquivo gerado:

```
build/app/outputs/bundle/release/app-release.aab
```

---

# Segurança do SafeFy

O projeto implementa múltiplas camadas de segurança.

## Senha mestra

A senha mestra não é armazenada.

Apenas o hash SHA‑256 é salvo.

## Derivação de chave

A chave criptográfica é gerada usando:

PBKDF2

Configuração:

* SHA‑256
* 100000 iterações
* salt aleatório

## Criptografia

Algoritmo utilizado:

AES‑256‑GCM

Cada campo sensível é criptografado individualmente.

## Sessão do cofre

A senha mestra fica apenas em memória durante a sessão.

Ao bloquear o app:

* sessão é limpa
* senha é removida da memória

---

# Backup

SafeFy suporta backup criptografado.

Formato do arquivo:

```
.json
```

Conteúdo:

* payload criptografado
* dados exportados

A restauração exige a mesma senha mestra usada na exportação.

---

# Fluxo do aplicativo

Inicialização:

Splash

↓

AppEntryPage

↓

Verifica se cofre existe

↓

Criar senha mestra

ou

Desbloquear cofre

↓

Dashboard

---

# Assets do projeto

Localização:

```
assets/images/
```

Arquivos principais:

```
splash.png
logo.png
```

Configuração no pubspec.yaml:

```
flutter:
  assets:
    - assets/images/
```

---

# Boas práticas adotadas

Separação clara de responsabilidades

Criptografia antes de persistência

Nenhuma senha armazenada em texto puro

Sessão protegida em memória

Backup criptografado

---

# Roadmap futuro

Possíveis melhorias para versões futuras:

Biometria

Gerador de senhas

Categorias avançadas

Sincronização segura

Backup automático

Integração com cloud

---

# Licença

Projeto desenvolvido pela Serenyo.

Todos os direitos reservados.
