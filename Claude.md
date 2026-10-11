# Claude.md — Passagem de trabalho do ToonzTab

Este ficheiro existe para que Claude/um agente seguinte continue o port real já iniciado, sem recomeçar do zero nem inventar que existe um APK funcional.

## Objetivo obrigatório

- Repositório: https://github.com/layouter787-source/Open-toonz-mobile-
- Branch: `mobile/android-foundation`
- Nome da aplicação: **ToonzTab**
- Package: `com.toonz.tab`
- Destino inicial: tablets Android em landscape; telemóveis fora do alvo inicial.
- Portar o **OpenToonz original completo**, mantendo o código C++/Qt e o motor original em `toonz/sources/`. Não substituir por um editor novo, mockup ou protótipo separado.
- Preservar cenas, levels, Xsheet/timeline, ferramentas, renderização e importação/exportação sempre que forem portáveis.

## Regras de trabalho

1. Começar por ler este ficheiro, `README.md`, `doc/android_tablet_dependency_matrix.md` e `doc/android_tablet_port_audit.md`.
2. Trabalhar na branch existente e inspecionar commits/Actions antes de modificar.
3. Não remover `OPEN_TOONZ_ANDROID_EXPERIMENTAL_NATIVE_BUILD` para forçar uma configuração verde. O bloqueio existe porque dependências e renderização completas ainda não estão validadas.
4. Não confundir auditoria Python/XML ou build Linux/macOS com compilação Android. Não afirmar que há APK funcional sem build Android real e teste em tablet.
5. Resolver falhas com base nos logs completos. Fazer mudanças pequenas, determinísticas, com CI e documentação atualizada.
6. Não usar bibliotecas host Linux no target Android/ARM64.
7. Preservar os alvos desktop: os builds Linux e macOS passaram no commit de referência abaixo.
8. Atualizar este ficheiro quando o bloqueio real mudar, incluindo commit e resultado dos testes.

## Estado confirmado (referência: 2026-10-11)

Commit de referência: `63dcc1b2b4b484f5dc897bad4265bf0250c5bc0b`  
https://github.com/layouter787-source/Open-toonz-mobile-/commit/63dcc1b2b4b484f5dc897bad4265bf0250c5bc0b

Workflows:
- Auditoria Android: passou — https://github.com/layouter787-source/Open-toonz-mobile-/actions/runs/38089575381
- Build Linux: passou — https://github.com/layouter787-source/Open-toonz-mobile-/actions/runs/38089575355
- Build macOS: passou — https://github.com/layouter787-source/Open-toonz-mobile-/actions/runs/38089575345
- Configuração CMake nativa Android: falhou — https://github.com/layouter787-source/Open-toonz-mobile-/actions/runs/38089575300

**Ainda não há compilação Android completa bem-sucedida nem APK verificado num tablet.**

## Próximo bloqueio confirmado: Boost não encontrado

O workflow Android conseguiu instalar Android SDK/NDK/CMake, Qt 5.15.2 para Android e SDK Android do OpenCV com checksum. A etapa `Configure the original C++/Qt application (experimental)` falhou durante a geração CMake.

Erro real no log:
```
Found relative path while evaluating include directories of "tnzcore":
  "Boost_INCLUDE_DIR-NOTFOUND"
...
CMake Generate step failed. Build files cannot be regenerated correctly.
```
O erro aparece em vários targets originais, incluindo `tnzcore`, `tnzbase`, `tnzext`, `toonzlib`, `tnzstdfx`, `image`, `toonzqt` e `OpenToonz`.

### Ação imediata
1. Inspecionar a secção Boost em `toonz/sources/CMakeLists.txt` (aproximadamente linhas 650–690 no commit de referência) e confirmar a versão/forma de obtenção esperada pelo repositório.
2. Verificar no próprio repo se existe pasta, submódulo ou script Boost; não presumir.
3. Garantir headers Boost adequados para a compilação cruzada Android. Descobrir se os componentes usados são só headers ou se algum requer bibliotecas Boost compiladas.
4. Configurar `BOOST_ROOT`/`Boost_INCLUDE_DIR` explicitamente na workflow Android com fonte/versionamento reprodutível. **Não apontar para Boost host Linux como dependência Android.**
5. Reexecutar https://github.com/layouter787-source/Open-toonz-mobile-/actions/workflows/android-native-configure.yml e corrigir o próximo erro conforme o log.
6. Sucesso de configuração CMake não é sucesso de compilação C++ nem prova de APK.

## O que já existe — inspecionar antes de duplicar

- Manifesto Android orientado a landscape, identidade ToonzTab e requisitos de toque/tablet.
- Auditoria automática source-level em `.github/workflows/android-tablet-audit.yml`.
- `toonz/sources/cmake/AndroidLegacyGL.cmake`: primeira camada de compatibilidade GL4ES, GLU e fontes GLUT.
- `qtofflinegl.cpp`: caminho Android com `QOffscreenSurface`/FBO; declarações `QGLPixelBuffer` excluídas no Android.
- `shadingcontext.cpp`: correção para configurar formato GLES consistente no surface/context.
- Primeira passagem de link Android em `toonz/sources/toonz/CMakeLists.txt`, ainda não validada por build completo.
- Guarda OpenCV para exigir o SDK Android/ABI correto e evitar OpenCV desktop.
- Probe gráfico Android ARM64 passou, mas cobre apenas componentes gráficos, não o editor completo: https://github.com/layouter787-source/Open-toonz-mobile-/actions/runs/38082427304

Commits úteis:
- Política tablet: https://github.com/layouter787-source/Open-toonz-mobile-/commit/6f17b919d97ce0415239be5903dd91e40c2c030c
- Compatibilidade de contexto shader: https://github.com/layouter787-source/Open-toonz-mobile-/commit/f933acb67d0a7a218521148c43c6ddfe9c17c3dd
- Primeira ligação Android: https://github.com/layouter787-source/Open-toonz-mobile-/commit/f163ac4081884ea3af12674745375e5441757a94
- Guarda OpenCV: https://github.com/layouter787-source/Open-toonz-mobile-/commit/221b15b9b04f9403ee20f1a9aecefeaff25dd4a9
- Auditoria da guarda OpenCV: https://github.com/layouter787-source/Open-toonz-mobile-/commit/2acc91bc8f1103fb7f957db57d66afbe6d109a22
- Documentação da guarda OpenCV: https://github.com/layouter787-source/Open-toonz-mobile-/commit/63dcc1b2b4b484f5dc897bad4265bf0250c5bc0b

## Bloqueios conhecidos após Boost

Consultar/atualizar `doc/android_tablet_dependency_matrix.md`. Entre os riscos já conhecidos:
- Dependências Android/ARM64 reais: TIFF, PNG, JPEG, LZ4, SuperLU, MyPaint, Boost, OpenCV e outras usadas pelos targets originais.
- Bibliotecas ainda condicionadas apenas para Windows/macOS/Unix desktop.
- Módulos e plugins Qt no kit Android escolhido.
- APIs OpenGL desktop/fixed-function, GLEW e compatibilidade real GLES/GL4ES.
- Renderização offline, shaders, contexts e estabilidade no dispositivo.
- Empacotamento Qt, recursos `stuff/`, permissões e armazenamento de projetos.
- APK/instalação e execução no tablet.

## Critérios para declarar concluído

1. CMake configura o target original Android ARM64 sem dependências host.
2. O C++ original compila e liga para Android ARM64.
3. APK empacota corretamente bibliotecas e plugins Qt.
4. APK instala e abre num tablet real em landscape.
5. Testar desenho com toque/caneta, edição de levels/cenas e Xsheet/timeline/playback.
6. Guardar, fechar e reabrir projeto sem perder dados.
7. Testar importação/exportação e renderização offline.
8. Rever crashes/logs; registar provas reais e atualizar README e este ficheiro.

## Pontos de entrada

- Workflow de configuração: `.github/workflows/android-native-configure.yml`
- Auditoria: `.github/workflows/android-tablet-audit.yml`
- CMake principal: `toonz/sources/CMakeLists.txt`
- Target app: `toonz/sources/toonz/CMakeLists.txt`
- Matriz: `doc/android_tablet_dependency_matrix.md`
- Auditoria: `doc/android_tablet_port_audit.md`
- Actions: https://github.com/layouter787-source/Open-toonz-mobile-/actions

**Instrução para Claude:** continua a partir do bloqueio Boost acima. Não recomeçar o projeto, não criar substituto simplificado e não declarar o port completo sem build e teste Android comprovados.

## Atualização de continuação — 2026-10-11 (commit `8e886c49f098b98bbf19bc681f8d0751af6e8a1c`)

Foi integrado ao workflow `.github/workflows/android-native-configure.yml` o script já criado `ci/android/fetch-boost-headers.sh`:
- O script foi acrescentado aos filtros de `push` e `pull_request`.
- O workflow agora descarrega os headers Boost verificados por SHA-256 antes da configuração CMake.
- A configuração passa `BOOST_ROOT`, `Boost_INCLUDE_DIR`, `Boost_NO_SYSTEM_PATHS=ON`, `Boost_NO_BOOST_CMAKE=ON` e `CMAKE_POLICY_DEFAULT_CMP0167=OLD`.
- Commit da integração: https://github.com/layouter787-source/Open-toonz-mobile-/commit/8e886c49f098b98bbf19bc681f8d0751af6e8a1c

O workflow Android foi iniciado e, na última consulta, ainda estava **em execução**:
https://github.com/layouter787-source/Open-toonz-mobile-/actions/runs/38136927081

**Não registar sucesso ainda.** Aguardar o resultado do run 38136927081. Se falhar, ler o log da etapa exata; confirmar primeiro se o script baixou/extraiu Boost corretamente e depois corrigir o próximo bloqueio real. O APK e a compilação completa Android continuam sem comprovação.
