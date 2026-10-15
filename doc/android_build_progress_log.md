# Registo curto do progresso do build Android (ToonzTab)

Complemento ao `Claude.md`, que ja tem cerca de 250 KB (inclui o anexo com logs brutos) e e demasiado grande para ser editado com seguranca por ferramentas de API. Entradas novas curtas ficam aqui; resumir/arquivar o anexo bruto do `Claude.md` seria uma boa limpeza.

## 2026-10-15

### Run 38699134024 / 38699134202 (commit `f2b6e8a6`): falha de configuracao CMake

Erro: `list index: 1 out of range (-1, 0)` em `AndroidLegacyGL.cmake:254`, dentro de `opentoonz_android_link_module_graph`.

Causa (erro meu, introduzido no commit `1de325d`): a lista `_edges` guardava dependencias como `"tnzext|tnzcore;tnzbase"`. Em CMake `;` separa elementos de lista mesmo dentro de aspas, por isso a lista exterior era partida e `list(GET _parts 1 ...)` falhava.

Correcao (commit `53d606b`): a funcao passou a receber as dependencias como argumentos separados (`opentoonz_android_link_siblings(toonzlib tnzcore tnzbase tnzext)`), sem listas aninhadas. Ainda sem resultado de CI para este commit no `Claude.md`.

### Evidencia sobre o conflito `glShaderSource` (run 38208792779)

O log mostra que o GL4ES (`include/GL/glext.h`) declara o typedef `PFNGLSHADERSOURCEPROC` (linha 5594) e o prototipo `glShaderSource` (linha 5500) com `const GLchar **`, em conflito com `GLES2/gl2.h` do NDK (`const GLchar *const *`). O patch condicional em `AndroidLegacyGL.cmake` (copia corrigida do include do GL4ES no diretorio de build) visa exatamente isto. Ainda nao foi possivel confirmar se resolve, porque a configuracao falhava antes da compilacao.

### Avisos `The following keywords are not supported when using`

Aparecem cerca de 70 vezes no anexo do run 38699134024. Pela redacao padrao do CMake e pelo que o `Claude.md` ja regista, correspondem ao aviso CMP0175 de `add_custom_command(TARGET ...)` com `DEPENDS`. Sao avisos, nao a causa de nenhuma falha. (Inferencia pela mensagem: o anexo corta o texto completo do aviso.)

### Por verificar nos proximos logs

- Linha de configuracao `ToonzTab: GL4ES glShaderSource declarations: ...` e a mensagem seguinte (`patched` ou `needs no patch`).
- Se `libtnzbase` liga depois do grafo de ligacoes (`tnzbase -> tnzcore`, etc.).
- Proximos bloqueios previsiveis (por analise do codigo, nao por log): bibliotecas de terceiros para ARM64 (JPEG, LZ4, zlib, TIFF, PNG, SuperLU, OpenBLAS, MyPaint), porque `tnzcore`, `tnzext`, `image` e outros so as ligam em ramos desktop; `toonzqt` ainda nao foi revisto.

Nenhum APK existe; a auditoria estatica aprovada nao e compilacao Android.


## 2026-10-15 — correções e workflow de APK

- Corrigido o include de `sys/dir.h` em Android e o reconhecimento de extensões de plugins `.so` em `tpluginmanager.cpp` (commit `55f108f`).
- Adicionada ligação de `tfarm` a targets nativos OpenToonz no ramo Android para tratar símbolos não resolvidos vistos em CI (commit `98f2129`).
- O workflow principal foi convertido em `Android Tablet APK (OpenToonz ARM64)`: compila o target original e tenta empacotar com `androiddeployqt`, verificando e publicando o APK como artefacto (commit `5b1f659`).
- Execução a acompanhar: https://github.com/layouter787-source/Open-toonz-mobile-/actions/runs/38707636719 . No momento deste registo, a compilação C++ estava em curso; APK ainda não confirmado.
- Bloqueio separado: clang-format falhou em `toonz/sources/common/tapptools/tenv.cpp` (linhas 688, 697 e 745), com mensagens `code should be clang-formatted`. Ainda por corrigir.


## 2026-10-15 — erro de plataforma GL e correção

- A compilação do run 38707636719 parou em toonz/sources/common/tgl/tgl.cpp:665 com error: "unknown platform!", porque o bloco de implementação do contexto GL não incluía Android. Correção aplicada no commit 319fbfc adicionando Q_OS_ANDROID / __ANDROID__ ao ramo de contexto Qt.
- Foram ajustadas duas quebras de linha em tenv.cpp para resolver clang-format (commit 12cc2de); o resultado da nova verificação ainda está pendente.
- Novo workflow APK: https://github.com/layouter787-source/Open-toonz-mobile-/actions/runs/38708126068 . Nenhum APK verificado até este registo.


- Clang-format: o segundo run encontrou desalinhamento em tenv.cpp:744 por AlignConsecutiveAssignments; corrigido no commit b486cf1. Verificar o novo run de formatação.
- Workflow APK em execução: https://github.com/layouter787-source/Open-toonz-mobile-/actions/runs/38708230263 . Ainda não há APK verificado.
