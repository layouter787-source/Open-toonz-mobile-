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


## Atualização de continuação — 2026-10-12: primeira configuração Android passou

O run 38136927081 terminou com sucesso na etapa de configuração CMake. O log confirmou:
- `-- Configuring done`
- `-- Generating done`
- `-- Build files have been written to: build/android-opentoonz-arm64`
- Os headers Boost foram obtidos e validados, e o SDK Android OpenCV também foi preparado.
- A configuração reportou warnings CMake de `add_custom_command(... DEPENDS)` sob CMP0175. São warnings, não impediram a geração.

Resultado: **configuração CMake concluída; isto ainda não é compilação C++ nem APK**.

### Próxima etapa: compilar o alvo original
Foi alterado `.github/workflows/android-native-configure.yml` para executar depois da configuração:
```bash
cmake --build build/android-opentoonz-arm64 --target OpenToonz --parallel 2
```
A workflow agora tem timeout de 90 minutos, observa alterações em `toonz/sources/**` nos eventos push e pull_request e carrega logs de compilação se falhar.

Commit que introduziu a etapa de compilação: https://github.com/layouter787-source/Open-toonz-mobile-/commit/747e14c640da3c26cd5d7caedb7aded0b4425195
Run de compilação em curso no momento da atualização: https://github.com/layouter787-source/Open-toonz-mobile-/actions/runs/38205813101

A alteração seguinte de filtro foi registada no commit `32edc41fb613ce6ad65e01d39ee7b0a8df690fa8`.

**Instrução de continuação:** verificar primeiro o run 38205813101; ler o erro real se a compilação falhar e corrigir um bloqueio de cada vez. Não declarar APK pronto, não remover a guarda experimental e não confundir configuração com build.


## Atualização de continuação — 2026-10-12: primeiro erro de compilação corrigido

A execução `38205813101` chegou à compilação do código C++ original, mas falhou dentro da biblioteca `toonzlib`. O primeiro erro raiz foi em `toonz/sources/include/tnztypes.h`: no Android ARM64, a seleção de tipos caía num ramo legado com `__int32`/`__int64`, que não são tipos do Clang/NDK; daí vieram erros em cascata como `TUINT32` desconhecido. `tmachine.h` também não reconhecia Android como uma plataforma com ordem de canais definida.

Correções registadas:
- `toonz/sources/include/tnztypes.h`: Android usa `<stdint.h>` e tipos portáveis `int32_t`/`uint32_t`/`int64_t`/`uint64_t`.
- `toonz/sources/include/tmachine.h`: Android usa a mesma seleção de ordem de canais BGRM já utilizada para Linux/BSD/Haiku.

Commits:
- `880312f0e37e51877410a516356670c5b0c055fa` — https://github.com/layouter787-source/Open-toonz-mobile-/commit/880312f0e37e51877410a516356670c5b0c055fa
- `569a1f98aa80789ebf5f290f5b23d92e374dd015` — https://github.com/layouter787-source/Open-toonz-mobile-/commit/569a1f98aa80789ebf5f290f5b23d92e374dd015

A nova execução automática está em fila: https://github.com/layouter787-source/Open-toonz-mobile-/actions/runs/38208119259. É necessário aguardar e ler o próximo erro real; o build ainda não terminou com sucesso e nenhum APK foi validado.


## Atualização de continuação — 2026-10-12: corrigida precedência do ramo LP64

A compilação do run 38208121480 falhou novamente com `__int32`/`__int64` em `tnztypes.h`. A inspeção do ficheiro na branch revelou a causa específica: embora existisse um ramo posterior com `__ANDROID__` e `<stdint.h>`, Android ARM64 define `__LP64__`, e o ramo LP64 anterior era selecionado primeiro. Portanto, a primeira correção não era suficiente.

Correção adicional aplicada em `tnztypes.h`: acrescentado `defined(__ANDROID__)` à lista de exceções da condição LP64, para Android cair no ramo de tipos portáveis. Commit: https://github.com/layouter787-source/Open-toonz-mobile-/commit/cb45931fb482268a0f4ac240a849934911e72334

Nova execução Android Native iniciada para esse commit: https://github.com/layouter787-source/Open-toonz-mobile-/actions/runs/38208331733

Estado no início desta atualização: checkout a decorrer; a configuração e compilação deste novo commit ainda não foram confirmadas. Quando a compilação avançar, recolher o próximo erro raiz do log e corrigir o código original por etapas. Não declarar APK nem editor funcional até build, empacotamento e teste em tablet.


## Relatório de erros verificados — 2026-10-12 (handoff obrigatório)

### Estado exato observado

O workflow de compilação do código original está em:
- Run que chegou à ligação e falhou: https://github.com/layouter787-source/Open-toonz-mobile-/actions/runs/38208792779
- Run anterior, que falhou na compilação de unidades C++: https://github.com/layouter787-source/Open-toonz-mobile-/actions/runs/38208331733
- Commit com as últimas alterações CMake/cabeçalhos antes desta documentação: https://github.com/layouter787-source/Open-toonz-mobile-/commit/68e9f55891882ca689ba8c49b6fc2dfdf3a18e18

No run 38208792779, checkout, instalação de SDK/NDK/CMake, Qt 5.15.2, obtenção do SDK OpenCV Android, obtenção dos headers Boost e configuração CMake concluíram com sucesso. A falha está na compilação/ligação do target original. O job terminou em failure; o artefacto existente é de logs, não APK. Não existe APK funcional confirmado.

### Erro A — conflito de headers e declaração de OpenGL ES

No run 38208792779, a primeira falha C++ fatal registada foi:

- NDK: sysroot/usr/include/GLES2/gl2.h:481 — typedef redefinition with different types para o ponteiro de função de glShaderSource.
- NDK: sysroot/usr/include/GLES2/gl2.h:624 — conflicting types for glShaderSource.
- A assinatura conflitante usa const GLchar *const * versus const GLchar **.
- Unidade que falhou: toonzlib/imagebuilders.cpp.o.

Hipótese a investigar, ainda não comprovada: mistura de headers GLES2 do NDK com headers OpenGL desktop/GL4ES ou declarações duplicadas/ordem de include incompatível. Localizar a declaração concorrente e corrigir a seleção de headers/macros para Android; não resolver com casts ou silenciamento indiscriminado.

### Erro B — centenas de símbolos indefinidos ao ligar libtnzbase

O mesmo run continuou em paralelo e falhou ao ligar:

- Target: tnzbase/android-build/libs/arm64-v8a/libtnzbase_arm64-v8a.so.
- Erro final: clang++: error: linker command failed with exit code 1.
- A falha propaga-se por gmake para o target OpenToonz.

Famílias de símbolos que aparecem como undefined reference nos logs:
- Serialização/XML: TIStream, TOStream e os respetivos métodos/construtores/destrutores.
- Caminhos e sistema: TFilePath, TFileStatus, TSystem, TEnv, Tifstream, to_string/to_wstring e isDouble.
- Propriedades/persistência: TProperty, TPersistDeclaration, TStringId e TSmartObject.
- Raster/imagem: TRaster, TRasterImage, TToonzImage, TVectorImage, TStroke, TPalette, TLevel e TRop.
- Pixels e conversões: TPixelRGBM32/64, TPixelGR8, toPixel32, toPixel64, toPixelD, toPixelF e toLinear.
- Cache e efeitos: TImageCache, TTile, TConsts e funções de geometria como cubicRoot.
- RTTI/vtables: typeinfo para TRaster, TImage, TRasterImage, TToonzImage, TVectorImage e vtable/typeinfo de TProperty.

Isto é uma falha ampla de ligação, não um único símbolo isolado. Investigar os targets CMake e a sua composição:
1. Verificar se os .cpp que definem esses símbolos entram nos targets Android correspondentes.
2. Comparar a lista de fontes e dependências de tnzbase/tnzcore/tnzlib com um target desktop que compila, sem copiar dependências desktop indisponíveis.
3. Verificar dependências transitivas, ordem/visibilidade de link, macros de export/import e definições condicionais de plataforma.
4. Verificar compatibilidade de ABI/compilador e flags C++ entre as bibliotecas que são compiladas separadamente.
5. Confirmar se algum source file está excluído por macros Android ou se uma seleção de fontes específica de plataforma deixou implementações de fora.
6. Só depois de corrigir a causa estrutural, voltar a compilar; não adicionar stubs vazios para fazer o link passar.

### Erro C — fontes de scanner que precisam de decisão de portabilidade

O log inclui unidades em toonz/sources/tnzbase/tscanner, incluindo tscanner.cpp, tscannerutil.cpp, tscannerepson.cpp e tscannertwain.cpp. A compilação de código associado a scanner pode ser específico de desktop/hardware. Auditar CMake e macros de plataforma: decidir explicitamente o que deve ser desativado no Android e o que precisa de uma implementação Android. Não afirmar que isto causa todos os símbolos indefinidos sem provar a ligação.

### Erros anteriores e situação após a última tentativa

No run 38208331733 foram observados:
- toonz/sources/include/tpixel.h:199 — no matching constructor for initialization of TPixelRGBM64.
- toonz/sources/include/tthreadmessage.h:12 — fatal error: QMutex file not found.

As alterações dos commits dd0288ecb8162aa5e65578596038cb5120058a34 e 68e9f55891882ca689ba8c49b6fc2dfdf3a18e18 ajustaram a seleção de pixel para Android e expuseram diretórios de include do Qt para targets Android. O run 38208792779 ultrapassou estas falhas iniciais e chegou à ligação. Registar como aparentemente ultrapassadas no último log, mas confirmar que não reaparecem; não confundir com sucesso de build.

Também foi corrigida a precedência do ramo LP64 em tnztypes.h para que Android ARM64 não selecione os tipos legados __int32/__int64. A seleção de ordem de canais de pixel para Android foi ajustada em tmachine.h.

### Avisos observados, não fatais no run atual

- Aviso de depreciação do Android SDK Manager/sdmanager.
- GL4ES: avisos de dangling else e de precedência lógica.
- Configuração CMake anterior: avisos da política CMP0175 associados a add_custom_command DEPENDS.
- Avisos Node de depreciação punycode e url.parse vindos de ações/scripts de CI.

Não confundir estes avisos com as falhas fatais de glShaderSource e da ligação de tnzbase.

### Ordem de trabalho recomendada para o próximo agente (Claude)

1. Ler este relatório, README.md, doc/android_tablet_dependency_matrix.md e doc/android_tablet_port_audit.md.
2. Abrir o artefacto android-native-build-logs do run 38208792779 e obter o log completo; usar o primeiro erro fatal real, não as mensagens finais em cascata.
3. Resolver primeiro o conflito de declaração glShaderSource, verificando todos os headers de GL incluídos por imagebuilders.cpp e a configuração GL4ES/Android.
4. Em seguida investigar a composição de tnzbase e dependências dos símbolos indefinidos, comparando com a configuração desktop e com a matriz de dependências.
5. Fazer uma correção pequena por vez e deixar o workflow reproduzir o resultado. Não substituir implementações por stubs, não usar bibliotecas host Linux, não remover a guarda OPEN_TOONZ_ANDROID_EXPERIMENTAL_NATIVE_BUILD.
6. Se necessário, ajustar apenas o workflow de CI para capturar diagnósticos mais úteis; o responsável pelo port deve corrigir o C++/CMake original.
7. Atualizar este relatório e README após cada run com o commit, link, fase atingida e erro novo.
8. Só criar/afirmar APK quando existir artefacto APK real; a seguir, instalar e testar num tablet Android físico.

### Artefactos e logs

O workflow .github/workflows/android-native-configure.yml atualmente faz upload de android-native-build-logs quando falha. O artefacto do run 38208792779 foi confirmado com esse nome. O workflow não cria APK: compila apenas o target CMake OpenToonz. É necessário desenvolver uma fase separada de empacotamento Qt Android depois de o target original compilar e ligar corretamente.

**Instrução explícita:** o trabalho prioritário é corrigir os erros reais descritos acima no OpenToonz original. Não redesenhar a aplicação, não criar editor substituto, não declarar o projeto pronto por ter configurado CMake.


## Erros encontrados nos workflows — 2026-10-15

Este registo contém apenas falhas e avisos vistos no GitHub Actions. Não atribui autoria às alterações.

### Android Native OpenToonz Configure — falha CMake
Run: https://github.com/layouter787-source/Open-toonz-mobile-/actions/runs/38696291583
Job: Configure original OpenToonz target for Android ARM64.

Erro reportado:
```text
CMake Error at cmake/AndroidLegacyGL.cmake:204 (list):
  list index: 1 out of range (-1, 0)
Call Stack (most recent call first):
  cmake/AndroidLegacyGL.cmake:219 (opentoonz_android_link_module_graph)
  CMakeLists.txt:DEFERRED
```

**Significado:** o CMake tenta ler o segundo elemento de uma lista que não tem um segundo elemento válido. A configuração/generação falha antes da compilação completa do editor. Investigar a lista usada na linha 204 e os dados passados pela chamada na linha 219; os logs confirmam o índice inválido, mas não identificam por si só qual módulo originou a lista incompleta.

### Android Native Graphics Compatibility — mesma falha
Run: https://github.com/layouter787-source/Open-toonz-mobile-/actions/runs/38696291683
O workflow gráfico reproduziu o mesmo erro em `AndroidLegacyGL.cmake:204`, com stack na linha 219 e em `CMakeLists.txt:DEFERRED`. Como ambos falham na mesma função, investigar primeiro essa função partilhada, não tratar os resultados como causas independentes.

### Timeout ao descarregar ação Android — aviso de rede separado
Nos logs de preparação apareceu:
```text
Failed to download action 'https://codeload.github.com/android-actions/setup-android/tar.gz/be39fa834029ff78f1a44aa3bb0819b8fc2bd8fd'.
Error: The request was canceled due to the configured HttpClient.Timeout of 100 seconds elapsing.
```
O runner excedeu 100 segundos ao descarregar `android-actions/setup-android`. Isto indica um timeout de transferência/rede; não há evidência de que tenha causado o erro CMake de índice inválido. Se reaparecer, verificar a repetição do job e a disponibilidade do download.

### Android Tablet Port Audit — passou, mas não é build
Run: https://github.com/layouter787-source/Open-toonz-mobile-/actions/runs/38696291630
A auditoria estática passou. Isso não comprova configuração CMake, compilação/ligação C++ nem geração de APK.

### Estado confirmado nesta verificação
- Configure Android: falhou com índice de lista inválido em `AndroidLegacyGL.cmake:204`.
- Compatibilidade gráfica Android: falhou com o mesmo erro.
- Auditoria Android: passou, apenas auditoria estática.
- Timeout de download da ação Android: observado, separado do erro CMake.
- Nenhum APK foi confirmado por estes workflows.

**Próxima ação:** corrigir a causa da lista incompleta em `AndroidLegacyGL.cmake`, repetir os dois workflows Android e registar os novos resultados. Não declarar sucesso sem confirmação dos jobs.


## Reverificação dos workflows — 2026-10-15 (commit `f2b6e8a6`)

Commit testado: https://github.com/layouter787-source/Open-toonz-mobile-/commit/f2b6e8a6
Título reportado: `fix(android): make GL4ES glShaderSource prototype compatible with NDK…`.

### Resultados novos
- Android Native OpenToonz Configure: **falhou** — https://github.com/layouter787-source/Open-toonz-mobile-/actions/runs/38699134024
- Android Native Graphics Compatibility: **falhou** — https://github.com/layouter787-source/Open-toonz-mobile-/actions/runs/38699134202
- Android Tablet Port Audit: **passou** — https://github.com/layouter787-source/Open-toonz-mobile-/actions/runs/38699134067
- Linux Build e macOS Build: estavam **em execução** na última consulta — https://github.com/layouter787-source/Open-toonz-mobile-/actions/runs/38699134078 e https://github.com/layouter787-source/Open-toonz-mobile-/actions/runs/38699133904. Voltar a consultar antes de declarar resultado final.

### Erro CMake reproduzido, agora na linha 254
Ambos os workflows Android falharam com:
```text
CMake Error at cmake/AndroidLegacyGL.cmake:254 (list):
  list index: 1 out of range (-1, 0)
```
No workflow principal, a etapa falhada foi `Configure the original C++/Qt application (experimental)`; no workflow gráfico, foi `Configure compatibility libraries with the NDK`.

### Causa identificada ao inspecionar o código atual
Na função `opentoonz_android_link_module_graph`, a lista `_edges` contém entradas como `"tnzext|tnzcore;tnzbase"` e `"toonzlib|tnzcore;tnzbase;tnzext"`. Em CMake, ponto e vírgula é separador de elementos de lista mesmo dentro de uma string entre aspas. Assim, essas entradas são divididas em vários elementos antes do `foreach(_edge IN LISTS _edges)`. Quando o loop recebe um elemento sem o separador `|`, `string(REPLACE "|" ";" _parts "${_edge}")` produz uma lista com apenas um elemento; o `list(GET _parts 1 _deps)` da linha 254 tenta obter um segundo elemento inexistente e falha.

Esta é a causa técnica indicada pelo código atual e coincide com o erro observado no log. A correção deve representar cada aresta sem permitir que os separadores de dependências dividam prematuramente a lista exterior (por exemplo, usar uma representação/estrutura de dados que não dependa de listas CMake aninhadas com o mesmo delimitador, ou processar as arestas individualmente). Depois, executar de novo ambos os workflows Android. Esta documentação não altera o CMake.

A alteração de protótipo `glShaderSource` indicada no título do commit não foi suficiente para deixar os workflows Android verdes: a configuração para antes da compilação completa e volta a parar no processamento de `_edges`. Estes logs não confirmam se o conflito anterior de `glShaderSource` foi resolvido numa fase de compilação, porque a configuração falha antes disso.

### Aviso de download
O log anterior também mostrou timeout de 100 segundos ao descarregar `android-actions/setup-android`. É um problema de rede separado; não é a causa do erro CMake de lista inválida.

**Estado:** nenhum APK foi confirmado. A auditoria estática aprovada não equivale a compilação Android. Atualizar esta secção depois de consultar novamente Linux/macOS e depois de Claude corrigir a representação de `_edges` e repetir os workflows Android.
