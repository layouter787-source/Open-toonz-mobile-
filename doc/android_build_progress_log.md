# Registo curto do progresso do build Android (ToonzTab)

Complemento ao `Claude.md`, que ja tem cerca de 250 KB (inclui o anexo com logs brutos) e e demasiado grande para ser editado com seguranca por ferramentas de API. Entradas novas curtas ficam aqui; resumir/arquivar o anexo bruto do `Claude.md` seria uma boa limpeza.

## 2026-10-15

### Run 38699134024 / 38699134202 (commit `f2b6e8a6`): falha de configuracao CMake

Erro: `list index: 1 out of range (-1, 0)` em `AndroidLegacyGL.cmake:254`, dentro de `opentoonz_android_link_module_graph`.

Causa (erro meu, introduzido no commit `1de325d`): a lista `_edges` guardava dependencias como `"tnzext|tnzcore;tnzbase"`. Em CMake `;` separa elementos de lista mesmo dentro de aspas, por isso a lista exterior era partida e `list(GET _parts 1 ...)` falhava.

Correcao: a funcao passou a receber as dependencias como argumentos separados (`opentoonz_android_link_siblings(toonzlib tnzcore tnzbase tnzext)`), sem listas aninhadas. Nao verificado por CI ate este registo.

### Evidencia sobre o conflito `glShaderSource` (run 38208792779)

O log mostra que o GL4ES (`include/GL/glext.h`) declara o typedef `PFNGLSHADERSOURCEPROC` (linha 5594) e o prototipo `glShaderSource` (linha 5500) com `const GLchar **`, em conflito com `GLES2/gl2.h` do NDK (`const GLchar *const *`). O patch condicional em `AndroidLegacyGL.cmake` (copia corrigida do include do GL4ES no diretorio de build) visa exatamente isto. Ainda nao foi possivel confirmar se resolve, porque a configuracao falhava antes da compilacao.

### Por verificar nos proximos logs

- Linha de configuracao `ToonzTab: GL4ES glShaderSource declarations: ...` e a mensagem seguinte (`patched` ou `needs no patch`).
- Se `libtnzbase` liga depois do grafo de ligacoes (`tnzbase -> tnzcore`, etc.).
- Avisos repetidos `The following keywords are not supported when using ...` na configuracao: origem ainda nao identificada; nao tratar como causa ate haver o texto completo.
- Proximos bloqueios previsiveis (por analise do codigo, nao por log): bibliotecas de terceiros para ARM64 (JPEG, LZ4, zlib, TIFF, PNG, SuperLU, OpenBLAS, MyPaint), porque `tnzcore`, `tnzext`, `image` e outros so as ligam em ramos desktop; `toonzqt` ainda nao foi revisto.

Nenhum APK existe; a auditoria estatica aprovada nao e compilacao Android.
