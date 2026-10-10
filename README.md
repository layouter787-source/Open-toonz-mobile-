# ToonzTab — OpenToonz para tablets Android

**ToonzTab** é o nome de trabalho desta adaptação do OpenToonz para tablets Android em orientação horizontal. A base do produto deve continuar a ser o código original C++/Qt e o motor de animação do OpenToonz — não uma aplicação redesenhada do zero.

> **Estado real (10 de outubro de 2026):** a adaptação nativa está em desenvolvimento. Ainda não há compilação Android bem-sucedida do OpenToonz completo nem APK verificado com o motor original.

## Direção do projeto

- **Dispositivo:** tablets Android; telemóveis ficam fora do alvo inicial.
- **Base técnica:** manter o código nativo em `toonz/sources/`, incluindo cenas, levels, Xsheet/timeline, ferramentas e renderização sempre que for possível portá-los.
- **Interface:** adaptar a interface original para ecrã horizontal, toque e caneta digital. A adaptação deve acontecer na aplicação nativa existente.
- **Identidade Android:** ToonzTab, pacote `com.toonz.tab`, com orientação horizontal definida no manifesto Qt.
- **Dados do motor:** o caminho CMake nativo prepara o `stuff/` original como assets e `TEnv` copia esses ficheiros para o armazenamento privado no primeiro arranque. Essa parte ainda não foi validada num APK porque o bloqueio de dependências continua ativo.
- **Compilação:** o projeto usa CMake/Qt e já contém deteção de Android e algumas seleções de código específicas da plataforma. O CMake mantém deliberadamente uma barreira de segurança porque a ligação das dependências nativas e o caminho gráfico Android ainda não estão concluídos.

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
