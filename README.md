# Redator de Elite

App Flutter para o curso **Redação Elite** — permite que alunos enviem redações manuscritas via foto para correção por professores. Após corrigida, o aluno visualiza nota final, notas por competência, comentários e imagem da correção.

Projeto desenvolvido como PEX do curso de Desenvolvimento para Dispositivos Móveis.

## Stack

- **Flutter + Dart** (Material 3, tema dark)
- **Firebase Authentication** — login email/senha + Google Sign-In + vinculação de contas
- **Cloud Firestore** — coleções `users`, `essays`, `corrections`
- **Firebase Storage** — armazenamento de imagens (redações, correções, fotos de perfil)
- **Riverpod** — gerenciamento de estado e injeção de dependências
- **go_router** — navegação declarativa com redirect baseado em auth state
- **fl_chart** — gráficos de evolução de notas e correções por dia
- **image_picker** — captura e seleção de imagens

## Funcionalidades

### Autenticação
- Cadastro com nome, data de nascimento, foto opcional, e-mail e senha
- Validação de senha em tempo real (mínimo 8 chars, letra, número, especial) com barra de força
- Login email/senha
- Login com Google (com pré-preenchimento de cadastro pra novos usuários)
- Vinculação de conta Google a conta existente
- Esqueci a senha (recuperação por e-mail)

### Tipos de usuário
- **Aluno** — envia redações, acompanha correções, vê evolução das notas
- **Professor** — vê todas as redações enviadas (rascunhos ocultos), corrige

### Aluno
- Home com saudação por horário, créditos utilizados e gráfico de evolução
- Sistema de créditos: 10 por mês, renovação automática dia 10
- Cadastro de redação com tema, título, tipo de prova (ENEM/ACAFE), foto da câmera ou galeria
- Salvar como rascunho (sem validação, sem consumir crédito)
- Enviar para correção (validação completa, consome 1 crédito)
- Edição e exclusão de rascunhos
- Lista de redações com filtro por status e período
- Detalhes com imagem ampliável (zoom em tela cheia)

### Professor
- Home com gráfico de correções por dia (últimos 7 dias)
- Lista de todas as redações enviadas (não corrigidas primeiro)
- Correção com 5 competências ENEM (0-200, soma final 1000) OU 4 critérios ACAFE (0-2,5, soma final 10)
- Validação numérica em tempo real bloqueando valores fora do range
- Comentário e imagem opcional da correção
- Edição da correção após salva

## Arquitetura

Estrutura clean architecture com features:

```
lib/
├── main.dart
├── core/
│   ├── constants/      ← constantes e critérios de avaliação
│   ├── errors/         ← tradução de erros Firebase
│   └── utils/          ← formatadores, validadores, helpers
├── theme/              ← Material 3 dark (cores Redação Elite)
├── routes/             ← go_router centralizado
├── firebase/           ← bootstrap Firebase
├── services/           ← wrappers de SDKs (auth, storage, picker)
├── models/             ← entities imutáveis + enums
├── repositories/       ← acesso a dados (Firestore + Storage)
├── widgets/            ← componentes reutilizáveis
├── features/
│   ├── auth/{login,register}/
│   ├── home/           ← home aluno + professor
│   ├── essays/         ← lista, form, detalhes
│   ├── correction/     ← form de correção
│   ├── shell/          ← bottom nav + drawer
│   └── account/        ← informações da conta
└── dev/                ← seed de dados mock (debug only)
```

### Princípios
- Páginas **nunca** acessam Firestore/Storage diretamente — sempre via repositories
- Models **imutáveis** com `copiarCom`, `paraMapa()` e `factory deDocumento()`
- Estado via **Riverpod** providers (StreamProvider em cima de Firestore snapshots)
- Roteamento via **go_router** com redirect baseado em auth state
- Tema centralizado em `lib/theme/`

## Setup local

### Pré-requisitos
- Flutter SDK 3.12+
- Android Studio + plugins Flutter/Dart
- Conta Firebase (plano Blaze pra Storage)
- Conta Google (pra login Google Sign-In)

### Passos

1. Clonar o repositório:
   ```bash
   git clone <url-do-repo>
   cd redator_de_elite
   ```

2. Instalar dependências:
   ```bash
   flutter pub get
   ```

3. Criar projeto Firebase:
   - Console Firebase → criar projeto
   - Habilitar **Authentication** → métodos: E-mail/senha + Google
   - Habilitar **Cloud Firestore** em modo de teste
   - Habilitar **Storage** (requer plano Blaze) em modo de teste

4. Configurar FlutterFire (gera `lib/firebase_options.dart` e `android/app/google-services.json`):
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure --project=<seu-project-id> --platforms=android
   ```

5. Pegar SHA-1 debug e adicionar no Firebase:
   ```bash
   cd android && ./gradlew signingReport
   ```
   Cola o SHA-1 em **Console Firebase → Configurações do projeto → App Android → Adicionar impressão digital**.
   Depois re-rode `flutterfire configure` pra atualizar o `google-services.json`.

6. Rodar:
   ```bash
   flutter run
   ```

### Dados mock (apenas debug)
Na tela de login (em modo debug), o botão **"Dev: criar dados mock"** cria:
- Professor: `professor@redacaoelite.com` / `Senha@123`
- Aluno: `aluno@redacaoelite.com` / `Senha@123`
- 40 redações variadas (rascunhos, enviadas, corrigidas) com correções e gráficos populados

## Identidade visual

Extraída do site oficial https://ogeremias.hotmart.host/redacaoelite:
- Fundo preto `#000000`
- Verde primário `#22C55E` (CTA)
- Bege `#F3E5C0` (logo, destaques)
- Fontes: Galyon Book Italic (títulos), Century751 BoldItalic (subtítulos), Roboto (corpo)

## Build

APK release (sem keystore custom, usa chave debug):
```bash
flutter build apk --release --split-per-abi
```

Saída em `build/app/outputs/flutter-apk/`.

## Autor

Nikolas Geremias de Souza — ADS Católica SC
