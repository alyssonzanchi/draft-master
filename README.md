# Draft Master

Aplicativo mobile desenvolvido em Flutter para auxiliar coachs e analistas de League of Legends na gestão de times e jogadores. O app permite criar times, buscar dados reais de jogadores via API da Riot Games e salvar as informações na nuvem.

## 🚀 Funcionalidades Implementadas

### 1. Autenticação Segura
* **Login Social:** Integração com **Google Sign-In** para acesso rápido e seguro.
* **Persistência:** O app mantém o usuário logado entre sessões.
* **Privacidade:** Dados filtrados por usuário (cada coach vê apenas seus próprios times no banco de dados).

### 2. Gestão de Times (CRUD Completo)
* **Criar:** Montagem de times com 5 jogadores, definindo suas rotas (Top, Jungle, Mid, ADC, Support).
* **Ler:** Listagem de times em tempo real na tela inicial, sincronizada com o Firestore.
* **Atualizar:** Edição de nome do time e substituição de jogadores em times existentes.
* **Deletar:** Remoção de times com confirmação visual (SnackBar) e feedback imediato.

### 3. Integração com API da Riot Games
* **Busca por Riot ID:** Suporte completo ao formato moderno `Nome#TAG` (ex: `Faker#BR1`).
* **Dados em Tempo Real:**
    * Nível do Invocador.
    * Elo/Rank na fila Ranqueada Solo/Duo.
    * Top 3 Campeões (Maestria) com conversão de IDs para Nomes.
* **Tratamento de Erros:** Mensagens amigáveis para jogadores não encontrados, chaves expiradas ou erros de conexão.

### 4. Banco de Dados na Nuvem (Firebase Firestore)
* **Sincronização em Tempo Real:** Alterações refletem instantaneamente em todos os dispositivos logados.
* **Estrutura NoSQL:** Dados salvos na coleção `teams`, com documentos contendo arrays de jogadores.
* **Segurança:** Regras de segurança configuradas para proteger a leitura e escrita.

### 5. Interface Moderna (UI/UX)
* **Material Design 3:** Uso de cores temáticas (Deep Purple) e componentes modernos do Flutter.
* **Imagens Oficiais:** Exibição de ícones e Splash Arts (telas de carregamento) dos campeões direto dos servidores da Riot (Data Dragon).
* **Feedback Visual:** Indicadores de carregamento, SnackBars de sucesso/erro e tratamentos de estado vazio.

### 6. Detalhes do Jogador e Histórico
* **Tela Imersiva:** Header expansível (`SliverAppBar`) com a arte do campeão principal do jogador.
* **Histórico de Partidas:** Visualização das últimas 5 partidas com:
    * Resultado colorido (Vitória em Verde / Derrota em Vermelho).
    * Campeão jogado (Ícone).
    * KDA (Kill/Death/Assist) calculado.
    * Modo de jogo (ARAM, Solo/Duo, etc).

---

## 🛠 Tecnologias Utilizadas

* **Linguagem:** Dart
* **Framework:** Flutter (versão 3.x+)
* **Backend as a Service:** Firebase
    * `firebase_auth`: Gestão de usuários e sessão.
    * `cloud_firestore`: Banco de dados NoSQL em tempo real.
    * `google_sign_in`: Provedor de autenticação social.
* **Rede:** `http` para comunicação REST com a API da Riot.
* **Gerenciamento de Estado:** `provider` (Padrão `ChangeNotifier`).

---
