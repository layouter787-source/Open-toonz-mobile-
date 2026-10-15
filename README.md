# ToonzTab — OpenToonz para tablets Android

**ToonzTab** é o nome de trabalho desta adaptação do OpenToonz para tablets Android em orientação horizontal. A base do produto deve continuar a ser o código original C++/Qt e o motor de animação do OpenToonz — não uma aplicação redesenhada do zero.

> **Estado real (15 de outubro de 2026):** a configuração CMake Android já passou num run recente, mas a ligação C++ e a criação do APK ainda estão em validação. Não há APK verificado neste momento.

## Direção do projeto

- **Dispositivo:** tablets Android; telemóveis ficam fora do alvo inicial.
- **Base técnica:** manter o código nativo em `toonz/sources/`, incluindo cenas, levels, Xsheet/timeline, ferramentas e renderização sempre que for possível portá-los.
- **Interface:** adaptar a interface original para ecrã horizontal, toque e caneta digital. A adaptação deve acontecer na aplicação nativa existente.
- **Identidade Android:** ToonzTab, pacote `com.toonz.tab`, com orientação horizontal definida no manifesto Qt.
- **Dados do motor:** o caminho CMake nativo prepara o `stuff/` original como assets e `TEnv` copia esses ficheiros para o armazenamento privado no primeiro arranque. Essa parte ainda não foi validada num APK porque o bloqueio de dependências continua ativo.
- **Compilação:** o projeto usa CMake/Qt e já contém deteção de Android e algumas seleções de código específicas da plataforma. O CMake mantém a opção Android experimental desativada por padrão; o workflow de CI ativa-a explicitamente para encontrar e corrigir os bloqueios restantes.

## Trabalho nativo já iniciado

- A entrada original `toonz/sources/toonz/main.cpp` começa a separar a configuração gráfica de Android (EGL/OpenGL ES) da inicialização desktop que usa GLUT/legacy `QGLFormat`.
- A identidade ToonzTab é aplicada ao processo Qt Android e ao título da janela nativa.
- O manifesto Android nativo define o pacote `com.toonz.tab`, orientação horizontal e configuração de ecrãs de tablet.
- Existem auditorias e uma matriz de dependências para acompanhar os pontos que ainda bloqueiam a compilação.

Estas alterações **não significam** que o motor compile ou já funcione no Android. O código de renderização tem outras dependências e APIs OpenGL de desktop que ainda precisam de ser auditadas, portadas e testadas.

## Bloqueios principais

1. Criar um ambiente reproduzível com Qt for Android, SDK/NDK, JDK, CMake e ABI ARM64.
2. Preparar versões Android das bibliotecas nativas exigidas pelo motor e introduzir uma configuração de ligação específica para Android.
3. Adaptar e validar a renderização para OpenGL ES e resolver dependências desktop que não existem no NDK.
4. Adaptar o acesso a ficheiros/projetos e a interação do editor a tablets Android.
5. Compilar a aplicação nativa, instalar num tablet físico e testar desenho com caneta, cenas, gravação/abertura, timeline, efeitos e exportação antes de declarar funcionalidades como prontas.

## Auditoria e documentação

- [Roteiro do port nativo](./doc/tablet_port_roadmap.md)
- [Matriz de dependências Android](./doc/android_tablet_dependency_matrix.md)
- [Auditoria de código-fonte Android](./doc/android_tablet_port_audit.md)

A auditoria estática verifica condições do código e do manifesto; não é uma compilação do APK.

## Origem e licença

Este projeto deriva do [OpenToonz](https://github.com/opentoonz/opentoonz), um programa de animação 2D de código aberto. Esta é uma adaptação independente, não uma versão oficial do OpenToonz. Preservar `LICENSE.txt`, os avisos de direitos de autor e as licenças dos componentes de terceiros ao distribuir código ou binários.


## Estado da compilação Android — 15 de outubro de 2026

**Estado: validação em curso; não existe APK gerado/validado confirmado.** O workflow instala Android SDK/NDK, Qt 5.15.2, OpenCV Android e headers Boost verificados, compila o alvo original e tenta empacotar um APK debug para ARM64. O resultado final ainda depende do CI.

- [Workflow de APK tablet ARM64 (em validação)](https://github.com/layouter787-source/Open-toonz-mobile-/actions/runs/38707636719)
- [Run anterior de compilação, falha na ligação](https://github.com/layouter787-source/Open-toonz-mobile-/actions/runs/38704535097)
- [Run mais antigo, falha na ligação](https://github.com/layouter787-source/Open-toonz-mobile-/actions/runs/38208792779)
- [Run anterior, erros iniciais de compilação](https://github.com/layouter787-source/Open-toonz-mobile-/actions/runs/38208331733)
- O workflow guarda os logs como artefactos da execução. O relatório completo de diagnóstico e as tarefas para o próximo agente estão em [Claude.md](./Claude.md).

### Erros encontrados nos logs

1. **Conflito de declaração OpenGL ES:** o NDK GLES2/gl2.h acusa typedef redefinition with different types e conflicting types for glShaderSource. A assinatura com const GLchar *const * entra em conflito com outra que usa const GLchar **. Investigar a mistura de headers GLES2/GL desktop/GL4ES e a ordem/condições de inclusão.
2. **Ligação de tnzbase falha com muitos símbolos não resolvidos:** entre eles TIStream, TOStream, TFilePath, TEnv, TSystem, TProperty, TRaster, TRop, TImageCache, TPalette, TToonzImage, TPixelRGBM32/64 e funções de conversão de pixels. O erro final é clang++: error: linker command failed; o target libtnzbase_arm64-v8a.so falha e, em cascata, falha o target OpenToonz. Investigar fontes omitidas dos targets, bibliotecas e dependências entre targets, definições condicionais de plataforma e visibilidade/exportação de símbolos.
3. **Possível código de scanner desktop no alvo Android:** o log contém objetos de tscanner e tscannertwain.cpp. Confirmar quais drivers são suportados no Android e excluir/portar os que dependem de plataformas desktop, sem remover funcionalidades essenciais sem decisão explícita.
4. **Avisos não fatais:** sdkmanager está deprecated; fontes GL4ES emitem avisos de dangling-else e precedência lógica; o CMake reportou avisos de política CMP0175 na configuração anterior. Não são a causa fatal atual, mas devem ser registados e avaliados separadamente.
5. **Problemas anteriores que não aparecem como erros fatais no run mais recente:** QMutex file not found e ausência de construtor de TPixelRGBM64 apareceram no run 38208331733. O run 38208792779 passou por essas unidades e avançou até à ligação; confirmar que continuam resolvidos em builds seguintes.

Não declarar sucesso com base apenas em configuração CMake ou compilação parcial. O critério continua a ser: C++ original ligado para ARM64, APK Qt empacotado, instalação e teste num tablet Android real.


### Workflow para obter o APK

Executar manualmente [Android Tablet APK (OpenToonz ARM64)](https://github.com/layouter787-source/Open-toonz-mobile-/actions/workflows/android-native-configure.yml) em **Actions → Android Tablet APK (OpenToonz ARM64) → Run workflow**. Se todos os passos passarem, descarregar o artefacto `ToonzTab-tablet-arm64-debug-apk`. A presença do workflow não garante que o build já passou; conferir o estado da execução e o artefacto.
