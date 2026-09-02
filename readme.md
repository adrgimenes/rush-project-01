# Anglo Show Night

> **Gênero:** Survival Horror / Furtividade / Terror Psicológico  
> **Engine:** Unity  
> **Plataforma Inicial:** PC  
> **Cenário:** Campus Anglo – Universidade Federal de Pelotas (UFPel), Pelotas/RS  

---

## 1. Visão Geral do Projeto

**Anglo Show Night** é um jogo de sobrevivência e terror em primeira pessoa ambientado no complexo do Campus Anglo da UFPel. O jogador assume o controle de um estudante universitário que acabou ficando até tarde estudando nas salas de aula e laboratórios. Ao tentar ir embora, descobre que os portões foram trancados, as luzes gerais foram cortadas e os corredores estão tomados por uma figura aterradora: um açougueiro implacável armado com uma serra mecânica pesada.

O foco do projeto é entregar uma experiência com alta tensão psicológica, exploração vertical labiríntica, gerenciamento de estamina e mecânicas de evasão no estilo *Outlast*, combinadas com a estética retrô *low-poly* inspirada no início da era 3D (estilo PS1 / *Puppet Combo*).

---

## 2. Ambientação e Lore

### 2.1 O Campus Anglo (UFPel)
- **Histórico Industrial:** O prédio abrigou o histórico Frigorífico Anglo, às margens do Canal São Gonçalo. Esse passado de abate e processamento de carne fundamenta a atmosfera pesada do jogo.
- **Arquitetura Labiríntica:** Paredes maciças de tijolo à vista, colunas e vigas de ferro expostas, pés-direitos altos, pisos frios de cimento e escadarias ecoantes.
- **Clima Atmosférico:** A noite úmida e fria característica de Pelotas, com nevoeiro denso cobrindo as janelas e a área externa junto ao canal.

### 2.2 O Vilão: O Açougueiro
- Uma figura corpulenta trajando avental de couro encharcado, botas de borracha pesadas e portando uma serra mecânica industrial.
- **Regra de Sobrevivência:** Não há combate direto. O jogador não tem armas para enfrentá-lo; a sobrevivência depende exclusivamente de furtividade, observação de rotas e uso inteligente de esconderijos e distrações.

---

## 3. Mecânicas Principais de Gameplay

* **Furtividade e Detecção Sonora:**
  * Andar agachado silencia os passos em pisos de cimento e cerâmica.
  * Correr consome a barra de estamina rapidamente e deixa o estudante com respiração ofegante, o que atrai o assassino de longas distâncias.
* **Esconderijos Interativos:**
  * Armários de estudantes nos corredores, cabines sanitárias e áreas sob bancadas de laboratório.
* **Iluminação Limitada:**
  * Uso de lanterna ou tela de celular com bateria finita, exigindo a coleta de pilhas ou o uso estratégico da penumbra.
  * O feixe de luz pode alertar o açougueiro caso seja direcionado diretamente a ele.
* **Distrações Acústicas:**
  * Acionamento de painéis elétricos para atrair o monstro para longe de portas e rotas bloqueadas.

---

## 4. Estrutura do Mapa e Progressão

O jogador inicia a jornada nos andares superiores e precisa descer em direção ao nível térreo para alcançar as saídas:

1. **Andares Superiores (Salas de Aula e Prédio Acadêmico):**
   - Apresentação da atmosfera e das primeiras mecânicas de esconderijo.
   - Primeiros vislumbres e ecos distantes da motosserra nas escadas.
2. **Andares Intermediários (Departamentos e Laboratórios):**
   - Portões gradeados trancados, portas com trincos magnéticos que exigem fusíveis, crachás de acesso ou chaves mestras.
   - Escadarias centrais que atuam como pontos críticos de estrangulamento (gargalos sonoros).
3. **Térreo e Acessos Externos:**
   - Ponto de convergência onde o jogador decide e executa a rota de fuga com base no item-chave que conseguiu coletar.

---

## 5. Itens e Coletáveis

* **Alicate Corta-Frio:** Ferramenta pesada necessária para romper a corrente grossa que fecha as grades do portão principal da frente.
* **Chave do Barco:** Chave náutica com flutuador, escondida em uma sala secreta ou de acesso restrito (como o antigo arquivo morto ou setor de caldeiras).
* **Cartões de Acesso / Chaves Comuns:** Liberam atalhos e portas trancadas entre blocos do prédio.
* **Pilhas / Baterias:** Mantêm a lanterna funcional ao longo da exploração.
* **Documentos e Bilhetes:** Pedaços de lore espalhados que revelam a história macabra ligada ao passado do frigorífico.

---

## 6. Finais Alternativos

O jogo possui exatamente **dois finais de sobrevivência**:

1. **Final 1: Portão Principal da Frente**  
   O estudante localiza o **Alicate Corta-Frio**, desce até o portão principal, corta a corrente de aço que tranca o portão de ferro e escapa em direção às ruas iluminadas da cidade.

2. **Final 2: O Barco dos Fundos (Acesso pelo Canal São Gonçalo)**  
   O estudante encontra a **Chave do Barco** escondida em uma área remota do prédio, destranca a saída dos fundos voltada para o píer do Canal São Gonçalo e foge de barco pelas águas escuras sob a neblina.

---

## 7. Diretrizes Técnicas na Unity

* **Estilo Visual:** Texturas *low-res*, modelos *low-poly* estilo anos 90 (estética PS1), sombreamento pontual de alto contraste e efeito de névoa volumétrica suave.
* **Áudio Espacial (3D Sound):** Uso do sistema nativo de áudio da Unity com *Spatial Blend* em 3D total e curvas de atenuação customizadas para a motosserra e ruídos de passos em diferentes pisos.
* **Inteligência Artificial:** Implementada via *Unity NavMesh* e máquina de estados finitos (`Patrulha` → `Investigação de Ruído` → `Perseguição` → `Varredura de Esconderijo`).