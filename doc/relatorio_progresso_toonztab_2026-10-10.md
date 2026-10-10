# Relatório de progresso — ToonzTab
**Data do relatório:** 10 de outubro de 2026  
**Repositório:** [Open-toonz-mobile-](https://github.com/layouter787-source/Open-toonz-mobile-)  
**Branch de trabalho:** `mobile/android-foundation`  
**Objetivo:** adaptar o OpenToonz original para tablets Android em orientação horizontal, mantendo o motor C++/Qt e a estrutura nativa do projeto.

## 1. Resumo executivo

O trabalho avançou da auditoria inicial para uma tentativa real de configurar o projeto original com Qt 5.15 para Android, NDK ARM64 e dependências nativas. Também foi criado e validado um teste isolado das bibliotecas de compatibilidade gráfica.

**Estado real:** ainda não existe um APK verificado do OpenToonz completo para Android, nem foi confirmado que o editor arranca num tablet. A compilação isolada das bibliotecas gráficas passou; a configuração do projeto completo já chega à configuração das dependências, mas atualmente falha por um conflito de assinatura em `target_link_libraries` no CMake. A barreira de segurança/opt-in mantém o build Android experimental e não deve ser removida até o caminho completo compilar.

## 2. Direção técnica preservada

- O projeto continua baseado no código original em `toonz/sources/`, e não numa aplicação nova em Kotlin/Jetpack Compose.
- O nome de trabalho é **ToonzTab**.
- O alvo inicial são **tablets Android**, com interface horizontal; telemóveis não são o foco inicial.
- O código do motor, cenas, níveis, Xsheet/timeline, ferramentas e renderização originais devem ser mantidos e adaptados onde possível.
- A distribuição deverá preservar os avisos de copyright e as licenças do OpenToonz e das dependências.

## 3. Alterações feitas no repositório

### 3.1 Identidade e arranque Android

- Adaptado `toonz/sources/toonz/main.cpp` para separar parte da configuração gráfica do desktop e definir um formato de superfície OpenGL ES no Android.
- No caminho Android, a identidade Qt passa a usar organização/nome ToonzTab e o identificador `com.toonz.tab`; o desktop mantém o comportamento original.
- Adaptado o título da janela principal em `mainwindow.cpp`.
- Atualizado o manifesto Android nativo para o pacote `com.toonz.tab`, rótulo ToonzTab e orientação horizontal, mantendo a estrutura de integração Qt/Android.
- Mantido o estilo Fusion para a interface Qt no Android.
- Estas alterações são de arranque/identidade, não uma prova de compatibilidade de todo o renderer.

### 3.2 Dados e ficheiros do motor

- Preparado o CMake do alvo nativo para copiar a árvore original `stuff/` para os assets do pacote Android e gerar um manifesto de ficheiros.
- Adaptado `TEnv` para, no primeiro arranque Android, copiar os assets para o armazenamento privado gravável da aplicação.
- Separados os caminhos de dados da aplicação e de configuração do sistema através de `QStandardPaths`.
- Criada a preparação da pasta de configuração antes de escrever o `SystemVar.ini`.
- A cópia dos assets ainda **não foi validada dentro de um APK instalado**; depende da conclusão do build nativo.

### 3.3 Limpeza do protótipo que não correspondia ao objetivo

- Removidos os ficheiros da scaffold Android independente em `mobile-android/`, incluindo a Activity Kotlin, manifesto, Gradle files e README.
- Removido o workflow `.github/workflows/android-mobile.yml` que tentava construir esse protótipo separado.
- A intenção é construir o alvo original C++/Qt, não substituir o OpenToonz por um editor simplificado.

### 3.4 Portabilidade de plataforma e dependências

- Adicionada deteção explícita do ambiente Android no CMake, separada das configurações de desktop.
- Adicionados caminhos Android experimentais para o alvo nativo original.
- Separados ou desativados em Android alguns módulos/fluxos desktop que não estão disponíveis ou não se aplicam, incluindo partes de Serial Port, Print Support e Multimedia Widgets.
- Adicionada uma alternativa Android sem dispositivo serial para o código de stop-motion, preservando a implementação desktop.
- Mantida a necessidade de validar OpenCV Android para a funcionalidade de câmara/stop-motion.
- Preparado um script para obter o SDK Android do OpenCV com verificação SHA-256.

### 3.5 Compatibilidade gráfica experimental

Foi criado `toonz/sources/cmake/AndroidLegacyGL.cmake`, com dependências fixadas em commits específicos:

- **GL4ES**, para fornecer uma camada de compatibilidade para chamadas OpenGL antigas sobre GLES.
- **GLU para Android**, incluindo as fontes de tesselação de polígonos usadas pelo código original.
- **FreeGLUT/fontes**, limitado às geometrias de fontes de traço, sem criar uma janela GLUT própria.
- Criado um adaptador de fontes GLUT Android e código experimental para inicializar GL4ES quando o contexto EGL do Qt já estiver ativo.
- Iniciada a seleção Android do backend offline baseado em Qt/FBO e a exclusão do caminho desktop `QGLPixelBuffer`.

**Limite importante:** a existência destas bibliotecas não significa que todas as chamadas gráficas, efeitos, shaders, transform feedback ou renderização offline do OpenToonz já funcionem em OpenGL ES. Essa compatibilidade ainda requer compilação e testes.

### 3.6 Documentação adicionada/atualizada

- `README.md`: direção do projeto e estado real.
- `doc/tablet_port_roadmap.md`: roteiro de port nativo para tablets.
- `doc/android_tablet_dependency_matrix.md`: matriz de dependências e bloqueios.
- `doc/android_tablet_port_audit.md`: auditoria estática do código e das condições Android.
- Este relatório: `doc/relatorio_progresso_toonztab_2026-10-10.md`.

### 3.7 CI / GitHub Actions

- `.github/workflows/android-tablet-audit.yml`: verifica condições de plataforma, identidade, manifesto, dados e documentação. É uma auditoria de código, não uma compilação de APK.
- `.github/workflows/android-native-graphics.yml`: compila e liga um executável de teste com NDK ARM64 e as bibliotecas gráficas de compatibilidade.
- Adicionado um workflow experimental de configuração do alvo C++/Qt original para Android, com Qt 5.15.2, SDK/NDK e OpenCV Android.
- A configuração experimental é o ponto atual de depuração; ainda não é um workflow de APK release.

## 4. Testes e resultados verificados

| Teste | Resultado observado | O que comprova |
|---|---|---|
| Auditoria estática Android | Passou em execuções recentes | Algumas regras de código, manifesto, estrutura e documentação estão coerentes. Não compila o editor. |
| Cross-build gráfico isolado | Passou: [Android Native Graphics Compatibility](https://github.com/layouter787-source/Open-toonz-mobile-/actions/runs/38082816120) | As bibliotecas e o pequeno executável de teste podem ser compilados/ligados para Android ARM64. Não comprova o funcionamento gráfico em dispositivo. |
| Preparação de Qt 5.15.2 para Android | Passou no workflow experimental | O CI consegue instalar o kit Qt usado na tentativa de configuração. |
| Transferência e verificação do OpenCV Android | Passou no workflow experimental | O SDK OpenCV Android 4.14.0 foi obtido e a soma de verificação foi validada. |
| Configuração CMake do OpenToonz original | **Falhou na etapa atual**: [última execução](https://github.com/layouter787-source/Open-toonz-mobile-/actions/runs/38082939717) | A configuração chega a carregar GL4ES/GLU/FreeGLUT e detetar OpenCV, mas pára num erro de CMake antes de compilar o editor. |
| APK Android completo | Ainda não produzido/verificado | Não há confirmação de instalação, arranque ou operação do editor completo num tablet. |

## 5. Bloqueio atual identificado

O log mais recente da configuração CMake indica:

`The keyword signature for target_link_libraries has already been used with the target "OpenToonz". All uses ... must be either all-keyword or all-plain.`

A chamada Android em `toonz/sources/toonz/CMakeLists.txt` usa a assinatura `PRIVATE` para uma chamada a `target_link_libraries(OpenToonz ...)`, mas outra chamada para o mesmo alvo usa a assinatura simples. O próximo passo é uniformizar as chamadas para o mesmo alvo e voltar a executar a configuração.

Também apareceram avisos de políticas CMake e aviso de Boost não encontrado. Depois de corrigir o erro de assinatura, os erros seguintes deverão ser tratados um de cada vez — não se deve assumir que este é o único bloqueio.

## 6. Trabalho ainda necessário

1. Corrigir o conflito de assinatura de `target_link_libraries` e repetir a configuração Android.
2. Resolver os erros de dependências e ligação que surgirem depois disso, sem desativar a barreira de segurança prematuramente.
3. Conseguir compilar o executável original `OpenToonz` e todas as bibliotecas necessárias para `arm64-v8a`.
4. Gerar o pacote Android com manifesto, assets `stuff/`, bibliotecas nativas e Qt deployment correto.
5. Instalar o APK num tablet físico e testar o arranque, desenho, caneta/toque, ferramentas, timeline/Xsheet, abertura e gravação de cenas, níveis, efeitos, renderização e exportação.
6. Corrigir os problemas específicos de interface horizontal, permissões, armazenamento e desempenho em tablet.
7. Só depois produzir um build de distribuição e declarar funcionalidades como prontas.

## 7. Links de acompanhamento

- [Branch `mobile/android-foundation`](https://github.com/layouter787-source/Open-toonz-mobile-/tree/mobile/android-foundation)
- [Histórico de commits](https://github.com/layouter787-source/Open-toonz-mobile-/commits/mobile/android-foundation/)
- [Workflow de auditoria Android](https://github.com/layouter787-source/Open-toonz-mobile-/actions/workflows/android-tablet-audit.yml)
- [Workflow de compatibilidade gráfica](https://github.com/layouter787-source/Open-toonz-mobile-/actions/workflows/android-native-graphics.yml)
- [Última tentativa de configuração do OpenToonz Android](https://github.com/layouter787-source/Open-toonz-mobile-/actions/runs/38082939717)
- [Matriz de dependências](android_tablet_dependency_matrix.md)
- [Roteiro do port](tablet_port_roadmap.md)

---
**Conclusão:** foi preparado trabalho real no código original, na identidade Android, na preparação dos dados, nas dependências gráficas e na automação de testes. O teste gráfico isolado passou, mas o editor completo ainda não compila. O próximo marco objetivo é corrigir o erro CMake atual, continuar até obter um build nativo completo e validar o APK num tablet real.
