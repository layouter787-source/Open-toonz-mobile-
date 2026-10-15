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


---

# ANEXO — SAÍDA BRUTA DOS ERROS DOS WORKFLOWS

Este anexo complementa os relatórios anteriores com as linhas de erro recolhidas diretamente dos logs dos jobs. Os links abaixo abrem as execuções originais no GitHub Actions, referência para o contexto integral, incluindo comandos e linhas imediatamente anteriores/posteriores. Abaixo estão as linhas relevantes para os erros encontrados nos quatro jobs listados, sem remover ocorrências repetidas nem símbolos indefinidos.

- Run 38699134024 (CMake Android): https://github.com/layouter787-source/Open-toonz-mobile-/actions/runs/38699134024
- Run 38699134202 (CMake compatibilidade gráfica): https://github.com/layouter787-source/Open-toonz-mobile-/actions/runs/38699134202
- Run 38208792779 (compilação/ligação C++): https://github.com/layouter787-source/Open-toonz-mobile-/actions/runs/38208792779
- Run 38208331733 (erros de compilação anteriores): https://github.com/layouter787-source/Open-toonz-mobile-/actions/runs/38208331733

### Android Native OpenToonz Configure — run 38699134024
Linhas de erro relevantes extraídas do log do job (repetições e símbolos `undefined reference` mantidos):

```text
Call Stack (most recent call first):
Call Stack (most recent call first):
Call Stack (most recent call first):
Call Stack (most recent call first):
Call Stack (most recent call first):
Call Stack (most recent call first):
Call Stack (most recent call first):
Call Stack (most recent call first):
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
  The following keywords are not supported when using
Call Stack (most recent call first):
CMake Error at cmake/AndroidLegacyGL.cmake:254 (list):
  list index: 1 out of range (-1, 0)
Call Stack (most recent call first):
  cmake/AndroidLegacyGL.cmake:269 (opentoonz_android_link_module_graph)
  CMakeLists.txt:DEFERRED
CMake Error at cmake/AndroidLegacyGL.cmake:254 (list):
  list index: 1 out of range (-1, 0)
Call Stack (most recent call first):
  cmake/AndroidLegacyGL.cmake:269 (opentoonz_android_link_module_graph)
  CMakeLists.txt:DEFERRED
CMake Error at cmake/AndroidLegacyGL.cmake:254 (list):
  list index: 1 out of range (-1, 0)
Call Stack (most recent call first):
  cmake/AndroidLegacyGL.cmake:269 (opentoonz_android_link_module_graph)
  CMakeLists.txt:DEFERRED
CMake Error at cmake/AndroidLegacyGL.cmake:254 (list):
  list index: 1 out of range (-1, 0)
Call Stack (most recent call first):
  cmake/AndroidLegacyGL.cmake:269 (opentoonz_android_link_module_graph)
  CMakeLists.txt:DEFERRED
CMake Error at cmake/AndroidLegacyGL.cmake:254 (list):
  list index: 1 out of range (-1, 0)
Call Stack (most recent call first):
  cmake/AndroidLegacyGL.cmake:269 (opentoonz_android_link_module_graph)
  CMakeLists.txt:DEFERRED
-- Configuring incomplete, errors occurred!
##[error]Process completed with exit code 1.
```

### Android Native Graphics Compatibility — run 38699134202
Linhas de erro relevantes extraídas do log do job (repetições e símbolos `undefined reference` mantidos):

```text
Call Stack (most recent call first):
Call Stack (most recent call first):
Call Stack (most recent call first):
Call Stack (most recent call first):
Call Stack (most recent call first):
Call Stack (most recent call first):
Call Stack (most recent call first):
Call Stack (most recent call first):
Call Stack (most recent call first):
Call Stack (most recent call first):
Call Stack (most recent call first):
Call Stack (most recent call first):
Call Stack (most recent call first):
Call Stack (most recent call first):
Call Stack (most recent call first):
Call Stack (most recent call first):
Call Stack (most recent call first):
Call Stack (most recent call first):
Call Stack (most recent call first):
Call Stack (most recent call first):
Call Stack (most recent call first):
CMake Error at /home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/cmake/AndroidLegacyGL.cmake:254 (list):
  list index: 1 out of range (-1, 0)
Call Stack (most recent call first):
  /home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/cmake/AndroidLegacyGL.cmake:269 (opentoonz_android_link_module_graph)
  CMakeLists.txt:DEFERRED
CMake Error at /home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/cmake/AndroidLegacyGL.cmake:254 (list):
  list index: 1 out of range (-1, 0)
Call Stack (most recent call first):
  /home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/cmake/AndroidLegacyGL.cmake:269 (opentoonz_android_link_module_graph)
  CMakeLists.txt:DEFERRED
CMake Error at /home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/cmake/AndroidLegacyGL.cmake:254 (list):
  list index: 1 out of range (-1, 0)
Call Stack (most recent call first):
  /home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/cmake/AndroidLegacyGL.cmake:269 (opentoonz_android_link_module_graph)
  CMakeLists.txt:DEFERRED
CMake Error at /home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/cmake/AndroidLegacyGL.cmake:254 (list):
  list index: 1 out of range (-1, 0)
Call Stack (most recent call first):
  /home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/cmake/AndroidLegacyGL.cmake:269 (opentoonz_android_link_module_graph)
  CMakeLists.txt:DEFERRED
CMake Error at /home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/cmake/AndroidLegacyGL.cmake:254 (list):
  list index: 1 out of range (-1, 0)
Call Stack (most recent call first):
  /home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/cmake/AndroidLegacyGL.cmake:269 (opentoonz_android_link_module_graph)
  CMakeLists.txt:DEFERRED
-- Configuring incomplete, errors occurred!
##[error]Process completed with exit code 1.
```

### Android native build/link — run 38208792779
Linhas de erro relevantes extraídas do log do job (repetições e símbolos `undefined reference` mantidos):

```text
/usr/local/lib/android/sdk/ndk/21.3.6528147/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/include/GLES2/gl2.h:481:28: error: typedef redefinition with different types ('void (*)(GLuint, GLsizei, const GLchar *const *, const GLint *)' (aka 'void (*)(unsigned int, int, const char *const *, const int *)') vs 'void (*)(GLuint, GLsizei, const GLchar **, const GLint *)' (aka 'void (*)(unsigned int, int, const char **, const int *)'))
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/build/android-opentoonz-arm64/_deps/opentoonz_gl4es-src/include/GL/glext.h:5594:25: note: previous definition is here
/usr/local/lib/android/sdk/ndk/21.3.6528147/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/include/GLES2/gl2.h:624:29: error: conflicting types for 'glShaderSource'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/build/android-opentoonz-arm64/_deps/opentoonz_gl4es-src/include/GL/glext.h:5500:21: note: previous declaration is here
gmake[3]: *** [toonzlib/CMakeFiles/toonzlib.dir/build.make:511: toonzlib/CMakeFiles/toonzlib.dir/imagebuilders.cpp.o] Error 1
gmake[2]: *** [CMakeFiles/Makefile2:828: toonzlib/CMakeFiles/toonzlib.dir/all] Error 2
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/permissionsmanager.cpp:96: undefined reference to `TIStream::TIStream(TFilePath const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/permissionsmanager.cpp:97: undefined reference to `TIStream::operator bool() const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/permissionsmanager.cpp:100: undefined reference to `TIStream::matchTag(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/permissionsmanager.cpp:132: undefined reference to `TIStream::~TIStream()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/permissionsmanager.cpp:102: undefined reference to `TIStream::matchTag(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/permissionsmanager.cpp:129: undefined reference to `TIStream::skipCurrentTag()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/permissionsmanager.cpp:104: undefined reference to `TIStream::matchTag(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/permissionsmanager.cpp:107: undefined reference to `TIStream::getTagParam(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >, std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/permissionsmanager.cpp:110: undefined reference to `TIStream::matchTag(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/permissionsmanager.cpp:113: undefined reference to `TIStream::skipCurrentTag()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/permissionsmanager.cpp:116: undefined reference to `TIStream::getTagParam(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >, std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/permissionsmanager.cpp:118: undefined reference to `TIStream::getTagParam(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >, std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/permissionsmanager.cpp:124: undefined reference to `TIStream::matchEndTag()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/permissionsmanager.cpp:126: undefined reference to `TIStream::matchEndTag()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/permissionsmanager.cpp:132: undefined reference to `TIStream::~TIStream()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/permissionsmanager.cpp:87: undefined reference to `TEnv::getConfigDir()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tfilepath.h:304: undefined reference to `TFilePath::TFilePath(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tfilepath.h:304: undefined reference to `TFilePath::operator+(TFilePath const&) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/permissionsmanager.cpp:53: undefined reference to `TSystem::getUserName()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/permissionsmanager.cpp:73: undefined reference to `TSystem::getUserName()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/permissionsmanager.cpp:80: undefined reference to `TSystem::getUserName()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/stringtable.cpp:302: undefined reference to `to_wstring(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/stringtable.cpp:60: undefined reference to `TEnv::getConfigDir()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tfilepath.h:304: undefined reference to `TFilePath::TFilePath(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tfilepath.h:304: undefined reference to `TFilePath::operator+(TFilePath const&) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/stringtable.cpp:230: undefined reference to `TFileStatus::TFileStatus(TFilePath const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/stringtable.cpp:232: undefined reference to `TIStream::TIStream(TFilePath const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/stringtable.cpp:233: undefined reference to `TIStream::operator bool() const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/stringtable.cpp:236: undefined reference to `TIStream::matchTag(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/stringtable.cpp:239: undefined reference to `TIStream::matchEndTag()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/stringtable.cpp:240: undefined reference to `TIStream::matchTag(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/stringtable.cpp:243: undefined reference to `TIStream::operator>>(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/stringtable.cpp:243: undefined reference to `TIStream::operator>>(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/stringtable.cpp:244: undefined reference to `TIStream::matchEndTag()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/stringtable.cpp:245: undefined reference to `TIStream::operator>>(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/stringtable.cpp:246: undefined reference to `TIStream::matchEndTag()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/stringtable.cpp:247: undefined reference to `TIStream::operator>>(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/stringtable.cpp:248: undefined reference to `TIStream::matchEndTag()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/stringtable.cpp:258: undefined reference to `TIStream::operator>>(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/stringtable.cpp:258: undefined reference to `TIStream::operator>>(int&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/stringtable.cpp:259: undefined reference to `TIStream::matchEndTag()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/stringtable.cpp:263: undefined reference to `TIStream::operator>>(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/stringtable.cpp:264: undefined reference to `TIStream::matchEndTag()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/stringtable.cpp:252: undefined reference to `to_wstring(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/stringtable.cpp:253: undefined reference to `to_wstring(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/stringtable.cpp:254: undefined reference to `to_wstring(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/stringtable.cpp:270: undefined reference to `TIStream::~TIStream()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/stringtable.cpp:267: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/stringtable.cpp:240: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/stringtable.cpp:259: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/stringtable.cpp:264: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/stringtable.cpp:237: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/stringtable.cpp:270: undefined reference to `TIStream::~TIStream()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tcubicbezier.cpp:25: undefined reference to `cubicRoot(double, double, double, double)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tcubicbezier.cpp:25: undefined reference to `cubicRoot(double, double, double, double)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tdoublekeyframe.h:42: undefined reference to `TFilePath::TFilePath(char const*)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:41: undefined reference to `TOStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >, std::__ndk1::map<std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >, std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >, std::__ndk1::less<std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > >, std::__ndk1::allocator<std::__ndk1::pair<std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const, std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > > > > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:47: undefined reference to `TOStream::child(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:47: undefined reference to `TOStream::operator<<(double)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:47: undefined reference to `TOStream::operator<<(double)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:47: undefined reference to `TOStream::operator<<(double)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:47: undefined reference to `TOStream::~TOStream()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:51: undefined reference to `TOStream::child(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:51: undefined reference to `TOStream::operator<<(double)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:51: undefined reference to `TOStream::operator<<(double)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:51: undefined reference to `TOStream::~TOStream()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:44: undefined reference to `TOStream::child(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:44: undefined reference to `TOStream::operator<<(double)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:44: undefined reference to `TOStream::~TOStream()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:65: undefined reference to `TOStream::operator<<(double)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:65: undefined reference to `TOStream::operator<<(double)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:72: undefined reference to `TOStream::operator<<(double)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:72: undefined reference to `TOStream::operator<<(double)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:72: undefined reference to `TOStream::operator<<(double)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:81: undefined reference to `TOStream::operator<<(TFilePath const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:81: undefined reference to `TOStream::operator<<(int)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:75: undefined reference to `TOStream::operator<<(double)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:75: undefined reference to `TOStream::operator<<(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:78: undefined reference to `TOStream::operator<<(double)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:78: undefined reference to `TOStream::operator<<(double)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:78: undefined reference to `TOStream::operator<<(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:78: undefined reference to `TOStream::operator<<(double)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:68: undefined reference to `TOStream::operator<<(double)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:68: undefined reference to `TOStream::operator<<(double)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:68: undefined reference to `TOStream::operator<<(double)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:68: undefined reference to `TOStream::operator<<(double)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:82: undefined reference to `TOStream::operator<<(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:75: undefined reference to `TOStream::operator<<(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:87: undefined reference to `TOStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:44: undefined reference to `TOStream::~TOStream()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:47: undefined reference to `TOStream::~TOStream()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:51: undefined reference to `TOStream::~TOStream()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:106: undefined reference to `TIStream::matchTag(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:113: undefined reference to `TIStream::getTagParam(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >, int&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:115: undefined reference to `TIStream::getTagParam(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >, std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:117: undefined reference to `TIStream::matchTag(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:120: undefined reference to `TIStream::operator>>(double&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:121: undefined reference to `TIStream::eos()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:122: undefined reference to `TIStream::operator>>(double&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:123: undefined reference to `TIStream::eos()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:123: undefined reference to `TIStream::operator>>(double&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:125: undefined reference to `TIStream::matchEndTag()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:132: undefined reference to `TIStream::operator>>(double&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:132: undefined reference to `TIStream::operator>>(double&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:142: undefined reference to `TIStream::operator>>(double&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:142: undefined reference to `TIStream::operator>>(double&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:142: undefined reference to `TIStream::operator>>(double&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:143: undefined reference to `TIStream::eos()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:144: undefined reference to `TIStream::operator>>(double&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:153: undefined reference to `TIStream::operator>>(double&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:153: undefined reference to `TIStream::operator>>(TFilePath&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:153: undefined reference to `TIStream::operator>>(int&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:153: undefined reference to `TIStream::operator>>(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:147: undefined reference to `TIStream::operator>>(double&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:147: undefined reference to `TIStream::operator>>(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:147: undefined reference to `TIStream::operator>>(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:150: undefined reference to `TIStream::operator>>(double&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:150: undefined reference to `TIStream::operator>>(double&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:150: undefined reference to `TIStream::operator>>(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:150: undefined reference to `TIStream::operator>>(double&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:135: undefined reference to `TIStream::operator>>(double&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:135: undefined reference to `TIStream::operator>>(double&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:135: undefined reference to `TIStream::operator>>(double&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:135: undefined reference to `TIStream::operator>>(double&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:136: undefined reference to `TIStream::eos()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:137: undefined reference to `TIStream::operator>>(double&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:137: undefined reference to `TIStream::operator>>(double&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:159: undefined reference to `TIStream::matchEndTag()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:110: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:118: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:159: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoublekeyframe.cpp:125: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoubleparam.cpp:479: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoubleparam.cpp:58: undefined reference to `to_wstring(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoubleparam.cpp:1056: undefined reference to `TIStream::matchTag(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoubleparam.cpp:1072: undefined reference to `TIStream::operator>>(double&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoubleparam.cpp:1072: undefined reference to `TIStream::operator>>(double&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoubleparam.cpp:1072: undefined reference to `TIStream::operator>>(double&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoubleparam.cpp:1072: undefined reference to `TIStream::operator>>(double&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoubleparam.cpp:1072: undefined reference to `TIStream::operator>>(double&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoubleparam.cpp:1073: undefined reference to `TIStream::operator>>(int&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoubleparam.cpp:1061: undefined reference to `TIStream::operator>>(double&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoubleparam.cpp:1149: undefined reference to `TIStream::operator>>(int&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoubleparam.cpp:1064: undefined reference to `TIStream::operator>>(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoubleparam.cpp:1153: undefined reference to `TIStream::eos()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoubleparam.cpp:1059: undefined reference to `TIStream::operator>>(int&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoubleparam.cpp:1093: undefined reference to `TIStream::getTagAttribute(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoubleparam.cpp:1094: undefined reference to `TIStream::getTagAttribute(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoubleparam.cpp:1169: undefined reference to `TIStream::matchEndTag()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tdoublekeyframe.h:42: undefined reference to `TFilePath::TFilePath(char const*)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoubleparam.cpp:1123: undefined reference to `TIStream::getTagAttribute(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoubleparam.cpp:1123: undefined reference to `TFilePath::TFilePath(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoubleparam.cpp:1124: undefined reference to `TIStream::getTagAttribute(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoubleparam.cpp:1171: undefined reference to `TIStream::eos()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoubleparam.cpp:1173: undefined reference to `TIStream::eos()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoubleparam.cpp:1175: undefined reference to `TIStream::operator>>(double&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoubleparam.cpp:1175: undefined reference to `TIStream::operator>>(double&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoubleparam.cpp:1167: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoubleparam.cpp:1169: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoubleparam.cpp:1192: undefined reference to `TOStream::child(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoubleparam.cpp:1192: undefined reference to `TOStream::operator<<(double)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoubleparam.cpp:1192: undefined reference to `TOStream::~TOStream()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoubleparam.cpp:1193: undefined reference to `TOStream::child(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoubleparam.cpp:1193: undefined reference to `TOStream::operator<<(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoubleparam.cpp:1193: undefined reference to `TOStream::~TOStream()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoubleparam.cpp:1197: undefined reference to `TOStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoubleparam.cpp:1201: undefined reference to `TOStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoubleparam.cpp:1193: undefined reference to `TOStream::~TOStream()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoubleparam.cpp:1192: undefined reference to `TOStream::~TOStream()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoubleparam.cpp:1212: undefined reference to `to_string(double, int)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpersist.h:125: undefined reference to `TPersistDeclaration::TPersistDeclaration(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tdoublekeyframe.h:42: undefined reference to `TFilePath::TFilePath(char const*)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoubleparamfile.cpp:102: undefined reference to `Tifstream::Tifstream(TFilePath const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoubleparamfile.cpp:115: undefined reference to `Tifstream::~Tifstream()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoubleparamfile.cpp:115: undefined reference to `Tifstream::~Tifstream()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tproperty.h:76: undefined reference to `vtable for TProperty'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tproperty.h:76: undefined reference to `vtable for TProperty'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tstringid.h:45: undefined reference to `TStringId::genIter(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tproperty.h:78: undefined reference to `vtable for TProperty'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tproperty.h:78: undefined reference to `vtable for TProperty'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tproperty.h:78: undefined reference to `vtable for TProperty'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tproperty.h:78: undefined reference to `vtable for TProperty'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tproperty.h:46: undefined reference to `vtable for TProperty'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoubleparamrelayproperty.cpp:92: undefined reference to `TProperty::notifyListeners() const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tdoubleparamrelayproperty.cpp:92: undefined reference to `TProperty::notifyListeners() const'
CMakeFiles/tnzbase.dir/__/common/tparam/tdoubleparamrelayproperty.cpp.o:(.data.rel.ro._ZTV25TDoubleParamRelayProperty+0x28): undefined reference to `TProperty::assignUIName(TProperty*)'
CMakeFiles/tnzbase.dir/__/common/tparam/tdoubleparamrelayproperty.cpp.o:(.data.rel.ro._ZTI25TDoubleParamRelayProperty+0x18): undefined reference to `typeinfo for TProperty'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tnotanimatableparam.cpp:20: undefined reference to `TIStream::operator>>(int&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tnotanimatableparam.cpp:21: undefined reference to `TIStream::eos()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tnotanimatableparam.cpp:28: undefined reference to `TIStream::operator>>(int&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tnotanimatableparam.cpp:20: undefined reference to `TIStream::operator>>(int&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tnotanimatableparam.cpp:21: undefined reference to `TIStream::eos()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tnotanimatableparam.cpp:28: undefined reference to `TIStream::operator>>(int&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tnotanimatableparam.cpp:35: undefined reference to `TOStream::operator<<(int)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tnotanimatableparam.cpp:36: undefined reference to `TOStream::operator<<(int)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tnotanimatableparam.cpp:35: undefined reference to `TOStream::operator<<(int)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tnotanimatableparam.cpp:36: undefined reference to `TOStream::operator<<(int)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tnotanimatableparam.cpp:49: undefined reference to `TIStream::operator>>(int&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tnotanimatableparam.cpp:49: undefined reference to `TIStream::operator>>(int&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tnotanimatableparam.cpp:49: undefined reference to `TIStream::operator>>(int&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tnotanimatableparam.cpp:49: undefined reference to `TIStream::operator>>(int&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tnotanimatableparam.cpp:57: undefined reference to `TOStream::operator<<(int)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tnotanimatableparam.cpp:57: undefined reference to `TOStream::operator<<(int)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tnotanimatableparam.cpp:57: undefined reference to `TOStream::operator<<(int)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tnotanimatableparam.cpp:57: undefined reference to `TOStream::operator<<(int)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tnotanimatableparam.cpp:63: undefined reference to `TFilePath::TFilePath(char const*)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tnotanimatableparam.cpp:63: undefined reference to `TFilePath::TFilePath(char const*)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tnotanimatableparam.cpp:64: undefined reference to `TIStream::operator>>(TFilePath&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tnotanimatableparam.cpp:64: undefined reference to `TIStream::operator>>(TFilePath&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tnotanimatableparam.h:119: undefined reference to `TFilePath::operator==(TFilePath const&) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tnotanimatableparam.cpp:72: undefined reference to `TOStream::operator<<(TFilePath const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tnotanimatableparam.cpp:73: undefined reference to `TOStream::operator<<(TFilePath const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tnotanimatableparam.cpp:79: undefined reference to `TIStream::operator>>(std::__ndk1::basic_string<wchar_t, std::__ndk1::char_traits<wchar_t>, std::__ndk1::allocator<wchar_t> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tnotanimatableparam.cpp:79: undefined reference to `TIStream::operator>>(std::__ndk1::basic_string<wchar_t, std::__ndk1::char_traits<wchar_t>, std::__ndk1::allocator<wchar_t> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tnotanimatableparam.cpp:84: undefined reference to `TOStream::operator<<(std::__ndk1::basic_string<wchar_t, std::__ndk1::char_traits<wchar_t>, std::__ndk1::allocator<wchar_t> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tnotanimatableparam.cpp:85: undefined reference to `TOStream::operator<<(std::__ndk1::basic_string<wchar_t, std::__ndk1::char_traits<wchar_t>, std::__ndk1::allocator<wchar_t> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tnotanimatableparam.cpp:90: undefined reference to `TIStream::operator>>(double&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tnotanimatableparam.cpp:90: undefined reference to `TIStream::operator>>(double&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tnotanimatableparam.cpp:90: undefined reference to `TIStream::operator>>(double&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tnotanimatableparam.cpp:90: undefined reference to `TIStream::operator>>(double&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tnotanimatableparam.cpp:95: undefined reference to `TOStream::operator<<(double)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tnotanimatableparam.cpp:96: undefined reference to `TOStream::operator<<(double)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tnotanimatableparam.cpp:95: undefined reference to `TOStream::operator<<(double)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tnotanimatableparam.cpp:96: undefined reference to `TOStream::operator<<(double)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tnotanimatableparam.cpp:103: undefined reference to `TIStream::operator>>(std::__ndk1::basic_string<wchar_t, std::__ndk1::char_traits<wchar_t>, std::__ndk1::allocator<wchar_t> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tnotanimatableparam.cpp:107: undefined reference to `TOStream::operator<<(std::__ndk1::basic_string<wchar_t, std::__ndk1::char_traits<wchar_t>, std::__ndk1::allocator<wchar_t> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tnotanimatableparam.cpp:107: undefined reference to `TOStream::operator<<(std::__ndk1::basic_string<wchar_t, std::__ndk1::char_traits<wchar_t>, std::__ndk1::allocator<wchar_t> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tnotanimatableparam.cpp:154: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tnotanimatableparam.h:136: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tnotanimatableparam.cpp:189: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tnotanimatableparam.cpp:209: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tnotanimatableparam.cpp:236: undefined reference to `TIStream::operator>>(int&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tnotanimatableparam.cpp:248: undefined reference to `TOStream::operator<<(int)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tnotanimatableparam.cpp:248: undefined reference to `TOStream::operator<<(int)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tnotanimatableparam.h:136: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tnotanimatableparam.h:136: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tnotanimatableparam.h:170: undefined reference to `to_string(TFilePath const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tnotanimatableparam.h:136: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tnotanimatableparam.h:170: undefined reference to `to_string(std::__ndk1::basic_string<wchar_t, std::__ndk1::char_traits<wchar_t>, std::__ndk1::allocator<wchar_t> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tnotanimatableparam.h:136: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpersist.h:131: undefined reference to `TFilePath::TFilePath(char const*)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpersist.h:125: undefined reference to `TPersistDeclaration::TPersistDeclaration(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpersist.h:125: undefined reference to `TPersistDeclaration::TPersistDeclaration(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpersist.h:125: undefined reference to `TPersistDeclaration::TPersistDeclaration(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpersist.h:125: undefined reference to `TPersistDeclaration::TPersistDeclaration(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpersist.h:125: undefined reference to `TPersistDeclaration::TPersistDeclaration(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tparamset.cpp:458: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tparamset.cpp:472: undefined reference to `TIStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tparamset.cpp:473: undefined reference to `TIStream::eos()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tparamset.cpp:475: undefined reference to `TIStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tparamset.cpp:477: undefined reference to `TIStream::operator>>(TPersist*&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tparamset.cpp:481: undefined reference to `TIStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tparamset.cpp:483: undefined reference to `TIStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tparamset.cpp:489: undefined reference to `TOStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tparamset.cpp:497: undefined reference to `TOStream::operator<<(TPersist*)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tparamset.cpp:498: undefined reference to `TOStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tparamset.cpp:495: undefined reference to `TOStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tparamset.cpp:501: undefined reference to `TOStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpersist.h:125: undefined reference to `TPersistDeclaration::TPersistDeclaration(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tpixelparam.cpp:64: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tpixelparam.cpp:87: undefined reference to `toPixel32(TPixelD const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tpixelparam.cpp:93: undefined reference to `toPixelD(TPixelRGBM32 const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tpixelparam.cpp:110: undefined reference to `toPixel32(TPixelD const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tpixelparam.cpp:118: undefined reference to `toLinear(TPixelD const&, double)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tpixelparam.cpp:(.text._ZNK11TPixelParam8getValueEdbd+0x124): undefined reference to `toPixel32(TPixelD const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tpixelparam.cpp:124: undefined reference to `toPixel64(TPixelD const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tpixelparam.cpp:110: undefined reference to `toPixel32(TPixelD const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tpixelparam.cpp:148: undefined reference to `toPixelD(TPixelRGBM32 const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tpixelparam.cpp:154: undefined reference to `toPixelD(TPixelRGBM64 const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tpixelparam.cpp:172: undefined reference to `TIStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tpixelparam.cpp:161: undefined reference to `TIStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tpixelparam.cpp:171: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tpixelparam.cpp:179: undefined reference to `TOStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tpixelparam.cpp:181: undefined reference to `TOStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tpixelparam.cpp:182: undefined reference to `TOStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tpixelparam.cpp:184: undefined reference to `TOStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tpixelparam.cpp:185: undefined reference to `TOStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tpixelparam.cpp:187: undefined reference to `TOStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tpixelparam.cpp:188: undefined reference to `TOStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tpixelparam.cpp:190: undefined reference to `TOStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpersist.h:131: undefined reference to `TPixelRGBM32::Black'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpersist.h:131: undefined reference to `TPixelRGBM32::Black'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpersist.h:125: undefined reference to `TPersistDeclaration::TPersistDeclaration(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tpointparam.cpp:49: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tpointparam.cpp:96: undefined reference to `TIStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tpointparam.cpp:89: undefined reference to `TIStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tpointparam.cpp:95: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tpointparam.cpp:103: undefined reference to `TOStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tpointparam.cpp:105: undefined reference to `TOStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tpointparam.cpp:106: undefined reference to `TOStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tpointparam.cpp:108: undefined reference to `TOStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpersist.h:125: undefined reference to `TPersistDeclaration::TPersistDeclaration(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/trangeparam.cpp:47: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/trangeparam.cpp:95: undefined reference to `TIStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/trangeparam.cpp:88: undefined reference to `TIStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/trangeparam.cpp:94: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/trangeparam.cpp:102: undefined reference to `TOStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/trangeparam.cpp:104: undefined reference to `TOStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/trangeparam.cpp:105: undefined reference to `TOStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/trangeparam.cpp:107: undefined reference to `TOStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpersist.h:125: undefined reference to `TPersistDeclaration::TPersistDeclaration(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpixel.h:86: undefined reference to `TPixelRGBM32::Black'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpixel.h:86: undefined reference to `TPixelRGBM32::Black'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpixel.h:86: undefined reference to `TPixelRGBM32::White'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpixel.h:86: undefined reference to `TPixelRGBM32::White'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tspectrumparam.cpp:146: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tspectrumparam.cpp:179: undefined reference to `toPixel64(TPixelRGBM32 const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tspectrumparam.cpp:194: undefined reference to `toPixelF(TPixelRGBM32 const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tspectrumparam.cpp:240: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tspectrumparam.cpp:311: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tspectrumparam.cpp:378: undefined reference to `TIStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tspectrumparam.cpp:(.text._ZN14TSpectrumParam8loadDataER8TIStream+0xd0): undefined reference to `TPixelRGBM32::Black'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tspectrumparam.cpp:(.text._ZN14TSpectrumParam8loadDataER8TIStream+0xd4): undefined reference to `TPixelRGBM32::Black'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tspectrumparam.cpp:380: undefined reference to `TIStream::eos()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tspectrumparam.cpp:383: undefined reference to `TIStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tspectrumparam.cpp:385: undefined reference to `TIStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tspectrumparam.cpp:386: undefined reference to `TIStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tspectrumparam.cpp:388: undefined reference to `TIStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tspectrumparam.cpp:392: undefined reference to `TIStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tspectrumparam.cpp:400: undefined reference to `TOStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tspectrumparam.cpp:403: undefined reference to `TOStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tspectrumparam.cpp:405: undefined reference to `TOStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tspectrumparam.cpp:406: undefined reference to `TOStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tspectrumparam.cpp:408: undefined reference to `TOStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tspectrumparam.cpp:410: undefined reference to `TOStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tspectrumparam.cpp:445: undefined reference to `to_string(double, int)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/tspectrumparam.cpp:549: undefined reference to `TIStream::operator>>(TPersist*&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpixel.h:80: undefined reference to `TPixelRGBM32::maxChannelValue'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpixel.h:80: undefined reference to `TPixelRGBM32::maxChannelValue'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpixel.h:(.text._ZNSt6__ndk16vectorINS_4pairI12TPixelRGBM32S2_EENS_9allocatorIS3_EEE8__appendEm[_ZNSt6__ndk16vectorINS_4pairI12TPixelRGBM32S2_EENS_9allocatorIS3_EEE8__appendEm]+0x7c): undefined reference to `TPixelRGBM32::maxChannelValue'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpixel.h:(.text._ZNSt6__ndk16vectorINS_4pairI12TPixelRGBM32S2_EENS_9allocatorIS3_EEE8__appendEm[_ZNSt6__ndk16vectorINS_4pairI12TPixelRGBM32S2_EENS_9allocatorIS3_EEE8__appendEm]+0x80): undefined reference to `TPixelRGBM32::maxChannelValue'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpixel.h:(.text._ZNSt6__ndk16vectorINS_4pairI12TPixelRGBM32S2_EENS_9allocatorIS3_EEE8__appendEm[_ZNSt6__ndk16vectorINS_4pairI12TPixelRGBM32S2_EENS_9allocatorIS3_EEE8__appendEm]+0x138): undefined reference to `TPixelRGBM32::maxChannelValue'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpixel.h:190: undefined reference to `TPixelRGBM64::maxChannelValue'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpixel.h:190: undefined reference to `TPixelRGBM64::maxChannelValue'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpixel.h:(.text._ZNSt6__ndk16vectorINS_4pairI12TPixelRGBM64S2_EENS_9allocatorIS3_EEE8__appendEm[_ZNSt6__ndk16vectorINS_4pairI12TPixelRGBM64S2_EENS_9allocatorIS3_EEE8__appendEm]+0x7c): undefined reference to `TPixelRGBM64::maxChannelValue'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpixel.h:(.text._ZNSt6__ndk16vectorINS_4pairI12TPixelRGBM64S2_EENS_9allocatorIS3_EEE8__appendEm[_ZNSt6__ndk16vectorINS_4pairI12TPixelRGBM64S2_EENS_9allocatorIS3_EEE8__appendEm]+0x80): undefined reference to `TPixelRGBM64::maxChannelValue'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpixel.h:(.text._ZNSt6__ndk16vectorINS_4pairI12TPixelRGBM64S2_EENS_9allocatorIS3_EEE8__appendEm[_ZNSt6__ndk16vectorINS_4pairI12TPixelRGBM64S2_EENS_9allocatorIS3_EEE8__appendEm]+0x138): undefined reference to `TPixelRGBM64::maxChannelValue'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpersist.h:125: undefined reference to `TPersistDeclaration::TPersistDeclaration(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/ttonecurveparam.cpp:81: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/ttonecurveparam.cpp:408: undefined reference to `TIStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/ttonecurveparam.cpp:422: undefined reference to `TIStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/ttonecurveparam.cpp:424: undefined reference to `TIStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/ttonecurveparam.cpp:425: undefined reference to `TIStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/ttonecurveparam.cpp:431: undefined reference to `TOStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/ttonecurveparam.cpp:438: undefined reference to `TOStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/ttonecurveparam.cpp:440: undefined reference to `TOStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tparam/ttonecurveparam.cpp:441: undefined reference to `TOStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpersist.h:125: undefined reference to `TPersistDeclaration::TPersistDeclaration(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/binaryFx.cpp:142: undefined reference to `TRaster::clear()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/binaryFx.cpp:199: undefined reference to `TTile::~TTile()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/binaryFx.cpp:199: undefined reference to `TTile::~TTile()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/ttile.h:38: undefined reference to `TImageCache::instance()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/ttile.h:38: undefined reference to `TImageCache::get(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&, bool) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tsmartpointer.h:281: undefined reference to `typeinfo for TImage'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tsmartpointer.h:281: undefined reference to `typeinfo for TRasterImage'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tsmartpointer.h:281: undefined reference to `typeinfo for TImage'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tsmartpointer.h:281: undefined reference to `typeinfo for TRasterImage'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tsmartpointer.h:281: undefined reference to `typeinfo for TImage'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tsmartpointer.h:281: undefined reference to `typeinfo for TToonzImage'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tsmartpointer.h:281: undefined reference to `typeinfo for TImage'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tsmartpointer.h:281: undefined reference to `typeinfo for TToonzImage'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/ttoonzimage.h:106: undefined reference to `TToonzImage::getCMapped() const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/ttoonzimage.h:106: undefined reference to `TToonzImage::getCMapped() const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/ttoonzimage.h:106: undefined reference to `TToonzImage::getCMapped() const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/binaryFx.cpp:268: undefined reference to `TRop::over(TSmartPointerT<TRaster> const&, TSmartPointerT<TRaster> const&, TPointT<int> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/binaryFx.cpp:287: undefined reference to `TRop::add(TSmartPointerT<TRaster> const&, TSmartPointerT<TRaster> const&, TSmartPointerT<TRaster> const&, double)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/binaryFx.cpp:289: undefined reference to `TRop::add(TSmartPointerT<TRaster> const&, TSmartPointerT<TRaster> const&, TSmartPointerT<TRaster> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/binaryFx.cpp:351: undefined reference to `TRop::sub(TSmartPointerT<TRaster> const&, TSmartPointerT<TRaster> const&, TSmartPointerT<TRaster> const&, bool)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/binaryFx.cpp:375: undefined reference to `TRop::mult(TSmartPointerT<TRaster> const&, TSmartPointerT<TRaster> const&, TSmartPointerT<TRaster> const&, int, bool)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/binaryFx.cpp:395: undefined reference to `TRop::ropmin(TSmartPointerT<TRaster> const&, TSmartPointerT<TRaster> const&, TSmartPointerT<TRaster> const&, bool)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/binaryFx.cpp:465: undefined reference to `TRop::crossDissolve(TSmartPointerT<TRaster> const&, TSmartPointerT<TRaster> const&, TSmartPointerT<TRaster> const&, unsigned char)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/binaryFx.cpp:521: undefined reference to `TRop::ropin(TSmartPointerT<TRaster> const&, TSmartPointerT<TRaster> const&, TSmartPointerT<TRaster> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/binaryFx.cpp:522: undefined reference to `TTile::~TTile()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/binaryFx.cpp:522: undefined reference to `TTile::~TTile()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tgeometry.h:637: undefined reference to `TConsts::infiniteRectD'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tgeometry.h:637: undefined reference to `TConsts::infiniteRectD'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/binaryFx.cpp:585: undefined reference to `TRop::ropout(TSmartPointerT<TRaster> const&, TSmartPointerT<TRaster> const&, TSmartPointerT<TRaster> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/binaryFx.cpp:586: undefined reference to `TTile::~TTile()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/binaryFx.cpp:586: undefined reference to `TTile::~TTile()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/binaryFx.cpp:665: undefined reference to `TRop::atop(TSmartPointerT<TRaster> const&, TSmartPointerT<TRaster> const&, TSmartPointerT<TRaster> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/binaryFx.cpp:666: undefined reference to `TTile::~TTile()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/binaryFx.cpp:666: undefined reference to `TTile::~TTile()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/binaryFx.cpp:409: undefined reference to `TRop::ropmax(TSmartPointerT<TRaster> const&, TSmartPointerT<TRaster> const&, TSmartPointerT<TRaster> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/binaryFx.cpp:303: undefined reference to `TRop::colordodge(TSmartPointerT<TRaster> const&, TSmartPointerT<TRaster> const&, TSmartPointerT<TRaster> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/binaryFx.cpp:317: undefined reference to `TRop::colorburn(TSmartPointerT<TRaster> const&, TSmartPointerT<TRaster> const&, TSmartPointerT<TRaster> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/binaryFx.cpp:333: undefined reference to `TRop::screen(TSmartPointerT<TRaster> const&, TSmartPointerT<TRaster> const&, TSmartPointerT<TRaster> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tfx.h:102: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:35: undefined reference to `TFilePath::TFilePath(char const*)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:17: undefined reference to `TSystem::getBinDir()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tfilepath.h:304: undefined reference to `TFilePath::TFilePath(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tfilepath.h:304: undefined reference to `TFilePath::operator+(TFilePath const&) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tfilepath.h:304: undefined reference to `TFilePath::TFilePath(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tfilepath.h:304: undefined reference to `TFilePath::operator+(TFilePath const&) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tfilepath.h:304: undefined reference to `TFilePath::TFilePath(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tfilepath.h:304: undefined reference to `TFilePath::operator+(TFilePath const&) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:57: undefined reference to `TIStream::TIStream(TFilePath const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:58: undefined reference to `TIStream::operator bool() const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:61: undefined reference to `TIStream::matchTag(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:64: undefined reference to `TIStream::matchTag(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:79: undefined reference to `TIStream::getTagAttribute(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:81: undefined reference to `TIStream::getTagAttribute(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:66: undefined reference to `TIStream::getTagAttribute(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:66: undefined reference to `TFilePath::TFilePath(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:67: undefined reference to `TIStream::getTagAttribute(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:68: undefined reference to `TFilePath::TFilePath(char const*)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:68: undefined reference to `TFilePath::operator==(TFilePath const&) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:73: undefined reference to `TIStream::getTagAttribute(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:74: undefined reference to `TIStream::getTagAttribute(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:91: undefined reference to `TIStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:89: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:76: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:82: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:75: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:84: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:98: undefined reference to `TIStream::~TIStream()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:98: undefined reference to `TIStream::~TIStream()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:44: undefined reference to `TFilePath::TFilePath(char const*)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:203: undefined reference to `to_string(TFilePath const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:205: undefined reference to `TFilePath::TFilePath(char const*)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:209: undefined reference to `TSystem::getUniqueFile(QString)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:210: undefined reference to `TFilePath::withType(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:219: undefined reference to `TImageWriter::save(TFilePath const&, TSmartPointerT<TRaster>)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:251: undefined reference to `TFilePath::getWideString() const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:251: undefined reference to `to_string(std::__ndk1::basic_string<wchar_t, std::__ndk1::char_traits<wchar_t>, std::__ndk1::allocator<wchar_t> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:331: undefined reference to `TImageReader::load(TFilePath const&, TSmartPointerT<TRaster>&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:338: undefined reference to `TFileStatus::TFileStatus(TFilePath const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:339: undefined reference to `TSystem::deleteFile(TFilePath const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:343: undefined reference to `TFileStatus::TFileStatus(TFilePath const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:344: undefined reference to `TSystem::deleteFile(TFilePath const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:355: undefined reference to `TIStream::operator>>(TFilePath&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:391: undefined reference to `TIStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:353: undefined reference to `TIStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:359: undefined reference to `TIStream::operator>>(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:377: undefined reference to `TIStream::getTagAttribute(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:378: undefined reference to `TIStream::getTagAttribute(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:381: undefined reference to `TIStream::getTagAttribute(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:382: undefined reference to `TIStream::getTagAttribute(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:375: undefined reference to `TIStream::matchTag(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:362: undefined reference to `TIStream::matchTag(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:365: undefined reference to `TIStream::getTagAttribute(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:357: undefined reference to `TIStream::operator>>(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:370: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:385: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:390: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:396: undefined reference to `TOStream::child(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:396: undefined reference to `TOStream::operator<<(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:396: undefined reference to `TOStream::~TOStream()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:397: undefined reference to `TOStream::child(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:397: undefined reference to `TOStream::operator<<(TFilePath const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:397: undefined reference to `TOStream::~TOStream()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:398: undefined reference to `TOStream::child(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:398: undefined reference to `TOStream::operator<<(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:398: undefined reference to `TOStream::~TOStream()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:399: undefined reference to `TOStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:404: undefined reference to `TOStream::openCloseChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >, std::__ndk1::map<std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >, std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >, std::__ndk1::less<std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > >, std::__ndk1::allocator<std::__ndk1::pair<std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const, std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > > > > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:406: undefined reference to `TOStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:407: undefined reference to `TOStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:414: undefined reference to `TOStream::openCloseChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >, std::__ndk1::map<std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >, std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >, std::__ndk1::less<std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > >, std::__ndk1::allocator<std::__ndk1::pair<std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const, std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > > > > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:416: undefined reference to `TOStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:417: undefined reference to `TOStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:419: undefined reference to `TOStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:398: undefined reference to `TOStream::~TOStream()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:397: undefined reference to `TOStream::~TOStream()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/texternfx.cpp:396: undefined reference to `TOStream::~TOStream()'
/usr/local/lib/android/sdk/ndk/21.3.6528147/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/include/c++/v1/tuple:1376: undefined reference to `TFilePath::TFilePath(char const*)'
CMakeFiles/tnzbase.dir/texternfx.cpp.o:(.data.rel.ro._ZTI8TRasterTI12TPixelRGBM32E[_ZTI8TRasterTI12TPixelRGBM32E]+0x10): undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:24: undefined reference to `TIStream::operator>>(TPersist*&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:252: undefined reference to `TPersistDeclaration::TPersistDeclaration(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tfxattributes.h:20: undefined reference to `TAffine::operator=(TAffine const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tfxattributes.h:20: undefined reference to `TAffine::operator=(TAffine const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:721: undefined reference to `TIStream::getVersion() const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:725: undefined reference to `TIStream::getCurrentTagName()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:851: undefined reference to `TIStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:728: undefined reference to `TIStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:821: undefined reference to `TFilePath::TFilePath(char const*)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:822: undefined reference to `TIStream::operator>>(TFilePath&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:823: undefined reference to `TFilePath::getWideName() const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:826: undefined reference to `TIStream::operator>>(int&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:810: undefined reference to `TIStream::operator>>(int&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:830: undefined reference to `TIStream::operator>>(int&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:756: undefined reference to `TIStream::eos()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:797: undefined reference to `TIStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:757: undefined reference to `TIStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:758: undefined reference to `TIStream::getVersion() const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:790: undefined reference to `TIStream::eos()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:792: undefined reference to `TIStream::operator>>(TPersist*&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:846: undefined reference to `TIStream::operator>>(int&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:840: undefined reference to `TIStream::eos()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:841: undefined reference to `TIStream::operator>>(std::__ndk1::basic_string<wchar_t, std::__ndk1::char_traits<wchar_t>, std::__ndk1::allocator<wchar_t> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:834: undefined reference to `TIStream::eos()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:835: undefined reference to `TIStream::operator>>(int&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:750: undefined reference to `TIStream::operator>>(TPersist*&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:731: undefined reference to `TIStream::skipCurrentTag()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:734: undefined reference to `TIStream::eos()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:745: undefined reference to `TIStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:736: undefined reference to `TIStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:817: undefined reference to `TFilePath::TFilePath(char const*)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:818: undefined reference to `TIStream::operator>>(TFilePath&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:819: undefined reference to `TFilePath::getWideName() const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:802: undefined reference to `TIStream::operator>>(double&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:802: undefined reference to `TIStream::operator>>(double&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:806: undefined reference to `TIStream::operator>>(int&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:787: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:849: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:752: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:57: undefined reference to `TIStream::eos()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:57: undefined reference to `TIStream::eos()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:58: undefined reference to `TIStream::getString()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:63: undefined reference to `TIStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:60: undefined reference to `TIStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:62: undefined reference to `TIStream::isBeginEndTag()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:62: undefined reference to `TIStream::matchTag(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:65: undefined reference to `TIStream::isBeginEndTag()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:65: undefined reference to `TIStream::matchTag(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:870: undefined reference to `TOStream::getCurrentTagName()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:897: undefined reference to `TOStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:898: undefined reference to `TOStream::operator<<(TPersist*)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:884: undefined reference to `TOStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:890: undefined reference to `TOStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:892: undefined reference to `TOStream::closeChild()'
/usr/local/lib/android/sdk/ndk/21.3.6528147/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/include/c++/v1/new:(.text._ZN3TFx8saveDataER8TOStream+0x2b0): undefined reference to `TOStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:902: undefined reference to `TOStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:907: undefined reference to `TOStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:904: undefined reference to `TOStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:906: undefined reference to `TOStream::operator<<(TPersist*)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:909: undefined reference to `TOStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:912: undefined reference to `TOStream::child(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:912: undefined reference to `TOStream::operator<<(double)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:912: undefined reference to `TOStream::operator<<(double)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:912: undefined reference to `TOStream::~TOStream()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:914: undefined reference to `TOStream::child(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:914: undefined reference to `TOStream::operator<<(int)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:914: undefined reference to `TOStream::~TOStream()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:917: undefined reference to `TOStream::child(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:918: undefined reference to `TOStream::operator<<(int)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:917: undefined reference to `TOStream::~TOStream()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:920: undefined reference to `TOStream::child(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:920: undefined reference to `TFilePath::TFilePath(std::__ndk1::basic_string<wchar_t, std::__ndk1::char_traits<wchar_t>, std::__ndk1::allocator<wchar_t> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:920: undefined reference to `TOStream::operator<<(TFilePath const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:920: undefined reference to `TOStream::~TOStream()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:922: undefined reference to `TOStream::child(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:922: undefined reference to `TOStream::operator<<(std::__ndk1::basic_string<wchar_t, std::__ndk1::char_traits<wchar_t>, std::__ndk1::allocator<wchar_t> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:922: undefined reference to `TOStream::~TOStream()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:923: undefined reference to `TOStream::child(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:923: undefined reference to `TOStream::operator<<(int)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:923: undefined reference to `TOStream::~TOStream()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:924: undefined reference to `TOStream::child(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:924: undefined reference to `TOStream::operator<<(int)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:924: undefined reference to `TOStream::~TOStream()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:926: undefined reference to `TOStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:929: undefined reference to `TOStream::operator<<(int)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:930: undefined reference to `TOStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:931: undefined reference to `TOStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:934: undefined reference to `TOStream::operator<<(std::__ndk1::basic_string<wchar_t, std::__ndk1::char_traits<wchar_t>, std::__ndk1::allocator<wchar_t> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:935: undefined reference to `TOStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:937: undefined reference to `TOStream::child(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:937: undefined reference to `TOStream::operator<<(int)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:937: undefined reference to `TOStream::~TOStream()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:923: undefined reference to `TOStream::~TOStream()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:937: undefined reference to `TOStream::~TOStream()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:920: undefined reference to `TOStream::~TOStream()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:924: undefined reference to `TOStream::~TOStream()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:944: undefined reference to `TIStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:946: undefined reference to `TIStream::getTagAttribute(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:950: undefined reference to `TIStream::eos()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:958: undefined reference to `TIStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:952: undefined reference to `TIStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:962: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:948: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:974: undefined reference to `TOStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >, std::__ndk1::map<std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >, std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >, std::__ndk1::less<std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > >, std::__ndk1::allocator<std::__ndk1::pair<std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const, std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > > > > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:976: undefined reference to `TOStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:980: undefined reference to `TOStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:982: undefined reference to `TOStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:984: undefined reference to `TOStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfx.cpp:986: undefined reference to `TOStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfxcachemanager.cpp:169: undefined reference to `TImageCache::instance()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfxcachemanager.cpp:169: undefined reference to `TImageCache::remove(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfxcachemanager.cpp:182: undefined reference to `TImageCache::instance()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfxcachemanager.cpp:182: undefined reference to `TImageCache::add(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&, TSmartPointerT<TImage> const&, bool)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfxcachemanager.cpp:191: undefined reference to `TImageCache::instance()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tfxcachemanager.cpp:191: undefined reference to `TImageCache::remove(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/trasterfx.h:61: undefined reference to `TAffine::operator=(TAffine const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tcacheresource.cpp:264: undefined reference to `TFilePath::TFilePath(char const*)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tcacheresource.cpp:951: undefined reference to `TImageCache::instance()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tcacheresource.cpp:951: undefined reference to `TImageCache::remove(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tcacheresource.cpp:496: undefined reference to `TRop::copy(TSmartPointerT<TRaster>, TSmartPointerT<TRaster> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tcacheresource.cpp:881: undefined reference to `TImageCache::instance()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tcacheresource.cpp:881: undefined reference to `TImageCache::get(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&, bool) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tcacheresource.cpp:890: undefined reference to `TImageCache::instance()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/trasterimage.h:154: undefined reference to `TRasterImage::TRasterImage(TSmartPointerT<TRaster> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tcacheresource.cpp:890: undefined reference to `TImageCache::add(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&, TSmartPointerT<TImage> const&, bool)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tcacheresource.cpp:555: undefined reference to `TRop::copy(TSmartPointerT<TRaster>, TSmartPointerT<TRaster> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tcacheresource.cpp:611: undefined reference to `TRop::copy(TSmartPointerT<TRaster>, TSmartPointerT<TRaster> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tcacheresource.cpp:650: undefined reference to `TImageCache::instance()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tcacheresource.cpp:650: undefined reference to `TImageCache::remove(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tcacheresource.cpp:789: undefined reference to `TImageCache::instance()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tcacheresource.cpp:789: undefined reference to `TImageCache::remove(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tcacheresource.cpp:838: undefined reference to `TImageCache::instance()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tcacheresource.cpp:838: undefined reference to `TImageCache::get(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&, bool) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tcacheresource.cpp:843: undefined reference to `TFilePath::operator+(TFilePath const&) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tfilepath.h:304: undefined reference to `TFilePath::TFilePath(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tfilepath.h:304: undefined reference to `TFilePath::operator+(TFilePath const&) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tcacheresource.cpp:849: undefined reference to `TFilePath::withType(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tcacheresource.cpp:849: undefined reference to `TImageWriter::save(TFilePath const&, TSmartPointerT<TRaster>)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tsmartpointer.h:281: undefined reference to `typeinfo for TImage'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tsmartpointer.h:281: undefined reference to `typeinfo for TRasterImage'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tsmartpointer.h:281: undefined reference to `typeinfo for TImage'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tsmartpointer.h:281: undefined reference to `typeinfo for TRasterImage'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tsmartpointer.h:281: undefined reference to `typeinfo for TImage'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tsmartpointer.h:281: undefined reference to `typeinfo for TToonzImage'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tsmartpointer.h:281: undefined reference to `typeinfo for TImage'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tsmartpointer.h:281: undefined reference to `typeinfo for TToonzImage'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/ttoonzimage.h:106: undefined reference to `TToonzImage::getCMapped() const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tcacheresource.cpp:197: undefined reference to `Tofstream::Tofstream(TFilePath const&, bool)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tcacheresource.cpp:201: undefined reference to `Tofstream::~Tofstream()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tcacheresource.cpp:201: undefined reference to `Tofstream::~Tofstream()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tcacheresource.cpp:860: undefined reference to `TFilePath::operator+(TFilePath const&) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tcacheresource.cpp:861: undefined reference to `TFilePath::TFilePath(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tcacheresource.cpp:860: undefined reference to `TFilePath::operator+(TFilePath const&) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tcacheresource.cpp:207: undefined reference to `Tifstream::Tifstream(TFilePath const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tcacheresource.cpp:233: undefined reference to `Tifstream::~Tifstream()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tcacheresource.cpp:866: undefined reference to `TFilePath::withType(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tcacheresource.cpp:866: undefined reference to `TImageReader::load(TFilePath const&, TSmartPointerT<TRaster>&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tcacheresource.cpp:233: undefined reference to `Tifstream::~Tifstream()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/trasterimage.h:154: undefined reference to `TRasterImage::TRasterImage(TSmartPointerT<TRaster> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/trasterimage.h:154: undefined reference to `TRasterImage::TRasterImage(TSmartPointerT<TRaster> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/trasterimage.h:154: undefined reference to `TRasterImage::TRasterImage(TSmartPointerT<TRaster> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/ttoonzimage.h:132: undefined reference to `TToonzImage::TToonzImage(TRasterPT<TPixelCM32> const&, TRectT<int> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tcacheresource.cpp:410: undefined reference to `TImageCache::instance()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tcacheresource.cpp:410: undefined reference to `TImageCache::add(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&, TSmartPointerT<TImage> const&, bool)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tcacheresource.cpp:931: undefined reference to `TImageCache::instance()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tcacheresource.cpp:931: undefined reference to `TImageCache::get(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&, bool) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tcacheresource.cpp:936: undefined reference to `TFilePath::TFilePath(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tcacheresource.cpp:936: undefined reference to `TFilePath::operator+(TFilePath const&) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tcacheresource.cpp:941: undefined reference to `TFilePath::withType(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tcacheresource.cpp:941: undefined reference to `TImageWriter::save(TFilePath const&, TSmartPointerT<TRaster>)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:136: undefined reference to `TBigMemoryManager::instance()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:144: undefined reference to `TBigMemoryManager::instance()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:287: undefined reference to `TRaster::TRaster(int, int, int)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:298: undefined reference to `TRaster::~TRaster()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:319: undefined reference to `TRaster::copy(TSmartPointerT<TRaster> const&, TPointT<int> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:292: undefined reference to `TRaster::TRaster(int, int, int, int, unsigned char*, TRaster*, bool)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:287: undefined reference to `TRaster::TRaster(int, int, int)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:298: undefined reference to `TRaster::~TRaster()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:319: undefined reference to `TRaster::copy(TSmartPointerT<TRaster> const&, TPointT<int> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:292: undefined reference to `TRaster::TRaster(int, int, int, int, unsigned char*, TRaster*, bool)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:287: undefined reference to `TRaster::TRaster(int, int, int)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:298: undefined reference to `TRaster::~TRaster()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:319: undefined reference to `TRaster::copy(TSmartPointerT<TRaster> const&, TPointT<int> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:292: undefined reference to `TRaster::TRaster(int, int, int, int, unsigned char*, TRaster*, bool)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:287: undefined reference to `TRaster::TRaster(int, int, int)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:298: undefined reference to `TRaster::~TRaster()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:319: undefined reference to `TRaster::copy(TSmartPointerT<TRaster> const&, TPointT<int> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:292: undefined reference to `TRaster::TRaster(int, int, int, int, unsigned char*, TRaster*, bool)'
CMakeFiles/tnzbase.dir/__/common/tfx/tcacheresource.cpp.o:(.data.rel.ro._ZTI8TRasterTI12TPixelRGBM64E[_ZTI8TRasterTI12TPixelRGBM64E]+0x10): undefined reference to `typeinfo for TRaster'
CMakeFiles/tnzbase.dir/__/common/tfx/tcacheresource.cpp.o:(.data.rel.ro._ZTI8TRasterTI7TPixelFE[_ZTI8TRasterTI7TPixelFE]+0x10): undefined reference to `typeinfo for TRaster'
CMakeFiles/tnzbase.dir/__/common/tfx/tcacheresource.cpp.o:(.data.rel.ro._ZTI8TRasterTI10TPixelCM32E[_ZTI8TRasterTI10TPixelCM32E]+0x10): undefined reference to `typeinfo for TRaster'
CMakeFiles/tnzbase.dir/__/common/tfx/tcacheresource.cpp.o:(.data.rel.ro._ZTV8TRasterTI10TPixelCM32E[_ZTV8TRasterTI10TPixelCM32E]+0x10): undefined reference to `TRaster::~TRaster()'
CMakeFiles/tnzbase.dir/__/common/tfx/tcacheresource.cpp.o:(.data.rel.ro._ZTV8TRasterTI12TPixelRGBM32E[_ZTV8TRasterTI12TPixelRGBM32E]+0x10): undefined reference to `TRaster::~TRaster()'
CMakeFiles/tnzbase.dir/__/common/tfx/tcacheresource.cpp.o:(.data.rel.ro._ZTV8TRasterTI12TPixelRGBM64E[_ZTV8TRasterTI12TPixelRGBM64E]+0x10): undefined reference to `TRaster::~TRaster()'
CMakeFiles/tnzbase.dir/__/common/tfx/tcacheresource.cpp.o:(.data.rel.ro._ZTV8TRasterTI7TPixelFE[_ZTV8TRasterTI7TPixelFE]+0x10): undefined reference to `TRaster::~TRaster()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tcacheresourcepool.cpp:93: undefined reference to `TFilePath::TFilePath(char const*)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tcacheresourcepool.cpp:138: undefined reference to `TFilePath::TFilePath(char const*)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tfxutil.cpp:39: undefined reference to `TPixelRGBM32::maxChannelValue'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tfxutil.cpp:39: undefined reference to `TPixelRGBM32::maxChannelValue'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tfxutil.cpp:98: undefined reference to `TAffine::operator==(TAffine const&) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/trasterfx.h:430: undefined reference to `TAffine::operator=(TAffine const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tmacrofx.cpp:371: undefined reference to `to_string(std::__ndk1::basic_string<wchar_t, std::__ndk1::char_traits<wchar_t>, std::__ndk1::allocator<wchar_t> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tmacrofx.cpp:451: undefined reference to `to_wstring(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tmacrofx.cpp:475: undefined reference to `TIStream::getVersion() const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tmacrofx.cpp:547: undefined reference to `TIStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tmacrofx.cpp:477: undefined reference to `TIStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tmacrofx.cpp:483: undefined reference to `TIStream::operator>>(TPersist*&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tmacrofx.cpp:488: undefined reference to `TIStream::eos()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tmacrofx.cpp:490: undefined reference to `TIStream::operator>>(TPersist*&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tmacrofx.cpp:510: undefined reference to `TIStream::matchTag(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tmacrofx.cpp:512: undefined reference to `TIStream::getTagAttribute(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tmacrofx.cpp:517: undefined reference to `TIStream::getTagAttribute(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tmacrofx.cpp:533: undefined reference to `to_wstring(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tmacrofx.cpp:541: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tmacrofx.cpp:546: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tmacrofx.cpp:555: undefined reference to `TOStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tmacrofx.cpp:557: undefined reference to `TOStream::operator<<(TPersist*)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tmacrofx.cpp:558: undefined reference to `TOStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tmacrofx.cpp:559: undefined reference to `TOStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tmacrofx.cpp:563: undefined reference to `TOStream::operator<<(TPersist*)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tmacrofx.cpp:565: undefined reference to `TOStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tmacrofx.cpp:566: undefined reference to `TOStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tmacrofx.cpp:571: undefined reference to `TOStream::openCloseChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >, std::__ndk1::map<std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >, std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >, std::__ndk1::less<std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > >, std::__ndk1::allocator<std::__ndk1::pair<std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const, std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > > > > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tmacrofx.cpp:573: undefined reference to `TOStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tmacrofx.cpp:574: undefined reference to `TOStream::openChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/tmacrofx.cpp:576: undefined reference to `TOStream::closeChild()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:439: undefined reference to `TRaster::clear()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:445: undefined reference to `TTile::setRaster(TSmartPointerT<TRaster> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:472: undefined reference to `TTile::setRaster(TSmartPointerT<TRaster> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:507: undefined reference to `TTile::TTile(TSmartPointerT<TRaster> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:508: undefined reference to `TTile::~TTile()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:565: undefined reference to `TAffine::operator*(TRectT<double> const&) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/trasterfx.h:61: undefined reference to `TAffine::operator=(TAffine const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:692: undefined reference to `TAffine::operator==(TAffine const&) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:693: undefined reference to `TAffine::isIdentity(double) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:370: undefined reference to `TTile::~TTile()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:370: undefined reference to `TTile::~TTile()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:178: undefined reference to `to_string(double, int)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:179: undefined reference to `to_string(double, int)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:180: undefined reference to `to_string(double, int)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:181: undefined reference to `to_string(double, int)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:182: undefined reference to `to_string(double, int)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:370: undefined reference to `TTile::~TTile()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:810: undefined reference to `TTile::setRaster(TSmartPointerT<TRaster> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:813: undefined reference to `TTile::setRaster(TSmartPointerT<TRaster> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:816: undefined reference to `TTile::setRaster(TSmartPointerT<TRaster> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:806: undefined reference to `TTile::setRaster(TSmartPointerT<TRaster> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:882: undefined reference to `TAffine::operator==(TAffine const&) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:883: undefined reference to `TAffine::isIdentity(double) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:914: undefined reference to `TRop::convert(TSmartPointerT<TRaster>, TSmartPointerT<TRaster> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:915: undefined reference to `TTile::setRaster(TSmartPointerT<TRaster> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:910: undefined reference to `TRop::convert(TSmartPointerT<TRaster>, TSmartPointerT<TRaster> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:911: undefined reference to `TTile::setRaster(TSmartPointerT<TRaster> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:924: undefined reference to `TRop::tosRGB(TSmartPointerT<TRaster>, double, bool)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:926: undefined reference to `TRop::toLinearRGB(TSmartPointerT<TRaster>, double, bool)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:939: undefined reference to `TTile::setRaster(TSmartPointerT<TRaster> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:961: undefined reference to `TRop::toLinearRGB(TSmartPointerT<TRaster>, double, bool)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:963: undefined reference to `TRop::tosRGB(TSmartPointerT<TRaster>, double, bool)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:370: undefined reference to `TTile::~TTile()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:1024: undefined reference to `TTile::~TTile()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:972: undefined reference to `TRop::convert(TSmartPointerT<TRaster>, TSmartPointerT<TRaster> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:973: undefined reference to `TTile::setRaster(TSmartPointerT<TRaster> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:968: undefined reference to `TRop::convert(TSmartPointerT<TRaster>, TSmartPointerT<TRaster> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:969: undefined reference to `TTile::setRaster(TSmartPointerT<TRaster> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:975: undefined reference to `TRop::convert(TSmartPointerT<TRaster>, TSmartPointerT<TRaster> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:976: undefined reference to `TTile::setRaster(TSmartPointerT<TRaster> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:370: undefined reference to `TTile::~TTile()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:1024: undefined reference to `TTile::~TTile()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:1035: undefined reference to `TAffine::isTranslation(double) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:1064: undefined reference to `TAffine::operator*(TRectT<double> const&) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:1065: undefined reference to `TAffine::operator*(TRectT<double> const&) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:1066: undefined reference to `TAffine::operator*(TAffine const&) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:1126: undefined reference to `TRop::resample(TSmartPointerT<TRaster> const&, TSmartPointerT<TRaster> const&, TAffine const&, TRop::ResampleFilterType, double)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:1055: undefined reference to `TRop::copy(TSmartPointerT<TRaster>, TSmartPointerT<TRaster> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/trasterfx.h:61: undefined reference to `TAffine::operator=(TAffine const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:519: undefined reference to `TTile::setRaster(TSmartPointerT<TRaster> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:1216: undefined reference to `TAffine::operator!=(TAffine const&) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:510: undefined reference to `TTile::~TTile()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:282: undefined reference to `TAffine::operator=(TAffine const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:284: undefined reference to `TTile::~TTile()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:284: undefined reference to `TTile::~TTile()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:370: undefined reference to `TTile::~TTile()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:326: undefined reference to `TAffine::operator=(TAffine const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:327: undefined reference to `TAffine::inv() const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:327: undefined reference to `TAffine::operator*(TAffine const&) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:327: undefined reference to `TAffine::operator=(TAffine const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:334: undefined reference to `TAffine::det() const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:338: undefined reference to `TAffine::inv() const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:345: undefined reference to `TAffine::operator*(TRectT<double> const&) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/trasterfx.cpp:348: undefined reference to `TAffine::operator*(TRectT<double> const&) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/trenderer.cpp:142: undefined reference to `TImageCache::instance()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/trenderer.cpp:142: undefined reference to `TImageCache::remove(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/trenderer.cpp:142: undefined reference to `TImageCache::instance()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/trenderer.cpp:142: undefined reference to `TImageCache::remove(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/trenderer.cpp:235: undefined reference to `TRaster::clear()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/trenderer.cpp:148: undefined reference to `TImageCache::instance()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/trenderer.cpp:148: undefined reference to `TImageCache::get(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&, bool) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tsmartpointer.h:281: undefined reference to `typeinfo for TImage'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tsmartpointer.h:281: undefined reference to `typeinfo for TRasterImage'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tsmartpointer.h:281: undefined reference to `typeinfo for TImage'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tsmartpointer.h:281: undefined reference to `typeinfo for TRasterImage'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/trenderer.cpp:136: undefined reference to `TImageCache::instance()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/trenderer.cpp:136: undefined reference to `TImageCache::getUniqueId()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/trenderer.cpp:137: undefined reference to `TImageCache::instance()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/trasterimage.h:154: undefined reference to `TRasterImage::TRasterImage(TSmartPointerT<TRaster> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/trenderer.cpp:137: undefined reference to `TImageCache::add(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&, TSmartPointerT<TImage> const&, bool)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/trenderer.cpp:355: undefined reference to `TThread::Executor::setMaxActiveTasks(int)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/trenderer.cpp:689: undefined reference to `TThread::Executor::Executor()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/trenderer.cpp:693: undefined reference to `TThread::Executor::setMaxActiveTasks(int)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/trenderer.cpp:710: undefined reference to `TThread::Executor::~Executor()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/trenderer.cpp:722: undefined reference to `TThread::Executor::~Executor()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/trenderer.cpp:722: undefined reference to `TThread::Executor::~Executor()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/trenderer.cpp:920: undefined reference to `TThread::Runnable::Runnable()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/trenderer.cpp:946: undefined reference to `TTile::~TTile()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/trenderer.cpp:946: undefined reference to `TTile::~TTile()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/trenderer.cpp:946: undefined reference to `TThread::Runnable::~Runnable()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/trenderer.cpp:968: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/trenderer.cpp:989: undefined reference to `TStopWatch::StopWatch'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/trenderer.cpp:989: undefined reference to `TStopWatch::StopWatch'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/trenderer.cpp:989: undefined reference to `TStopWatch::start(bool)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/trenderer.cpp:1023: undefined reference to `TStopWatch::stop()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/trenderer.cpp:1029: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/trenderer.cpp:1049: undefined reference to `TTile::setRaster(TSmartPointerT<TRaster> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/trenderer.cpp:63: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/trenderer.cpp:1059: undefined reference to `TTile::setRaster(TSmartPointerT<TRaster> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/trenderer.cpp:1062: undefined reference to `TTile::setRaster(TSmartPointerT<TRaster> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/trenderer.cpp:1536: undefined reference to `TThread::Executor::addTask(TSmartPointerT<TThread::Runnable>)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/trenderer.cpp:409: undefined reference to `TTile::~TTile()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/trenderer.cpp:409: undefined reference to `TTile::~TTile()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/trenderer.cpp:409: undefined reference to `TThread::Runnable::~Runnable()'
CMakeFiles/tnzbase.dir/__/common/tfx/trenderer.cpp.o:(.data.rel.ro._ZTV10RenderTask+0x10): undefined reference to `TThread::Runnable::metaObject() const'
CMakeFiles/tnzbase.dir/__/common/tfx/trenderer.cpp.o:(.data.rel.ro._ZTV10RenderTask+0x18): undefined reference to `TThread::Runnable::qt_metacast(char const*)'
CMakeFiles/tnzbase.dir/__/common/tfx/trenderer.cpp.o:(.data.rel.ro._ZTV10RenderTask+0x20): undefined reference to `TThread::Runnable::qt_metacall(QMetaObject::Call, int, void**)'
CMakeFiles/tnzbase.dir/__/common/tfx/trenderer.cpp.o:(.data.rel.ro._ZTV10RenderTask+0x80): undefined reference to `TThread::Runnable::schedulingPriority()'
CMakeFiles/tnzbase.dir/__/common/tfx/trenderer.cpp.o:(.data.rel.ro._ZTV10RenderTask+0x88): undefined reference to `TThread::Runnable::runningPriority()'
CMakeFiles/tnzbase.dir/__/common/tfx/trenderer.cpp.o:(.data.rel.ro._ZTV10RenderTask+0x90): undefined reference to `TThread::Runnable::onStarted(TSmartPointerT<TThread::Runnable>)'
CMakeFiles/tnzbase.dir/__/common/tfx/trenderer.cpp.o:(.data.rel.ro._ZTV10RenderTask+0xa0): undefined reference to `TThread::Runnable::onException(TSmartPointerT<TThread::Runnable>)'
CMakeFiles/tnzbase.dir/__/common/tfx/trenderer.cpp.o:(.data.rel.ro._ZTV10RenderTask+0xa8): undefined reference to `TThread::Runnable::onCanceled(TSmartPointerT<TThread::Runnable>)'
CMakeFiles/tnzbase.dir/__/common/tfx/trenderer.cpp.o:(.data.rel.ro._ZTV10RenderTask+0xb0): undefined reference to `TThread::Runnable::onTerminated(TSmartPointerT<TThread::Runnable>)'
CMakeFiles/tnzbase.dir/__/common/tfx/trenderer.cpp.o:(.data.rel.ro._ZTI10RenderTask+0x10): undefined reference to `typeinfo for TThread::Runnable'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/ttzpimagefx.cpp:53: undefined reference to `isInt(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/ttzpimagefx.cpp:58: undefined reference to `isInt(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/ttzpimagefx.cpp:200: undefined reference to `to_string(std::__ndk1::basic_string<wchar_t, std::__ndk1::char_traits<wchar_t>, std::__ndk1::allocator<wchar_t> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/ttzpimagefx.cpp:192: undefined reference to `to_string(std::__ndk1::basic_string<wchar_t, std::__ndk1::char_traits<wchar_t>, std::__ndk1::allocator<wchar_t> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/ttzpimagefx.cpp:223: undefined reference to `to_string(std::__ndk1::basic_string<wchar_t, std::__ndk1::char_traits<wchar_t>, std::__ndk1::allocator<wchar_t> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/unaryFx.cpp:40: undefined reference to `TAffine::operator*(TAffine const&) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/unaryFx.cpp:40: undefined reference to `TAffine::operator=(TAffine const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/unaryFx.cpp:36: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/unaryFx.cpp:59: undefined reference to `TAffine::operator*(TRectT<double> const&) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/unaryFx.cpp:92: undefined reference to `to_string(double, int)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/unaryFx.cpp:94: undefined reference to `to_string(double, int)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/unaryFx.cpp:96: undefined reference to `to_string(double, int)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/unaryFx.cpp:98: undefined reference to `to_string(double, int)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/unaryFx.cpp:100: undefined reference to `to_string(double, int)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/trasterfx.h:61: undefined reference to `TAffine::operator=(TAffine const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/unaryFx.cpp:115: undefined reference to `TAffine::operator*(TAffine const&) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/unaryFx.cpp:115: undefined reference to `TAffine::operator=(TAffine const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/unaryFx.cpp:138: undefined reference to `TAffine::operator=(TAffine const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/unaryFx.cpp:154: undefined reference to `TAffine::operator=(TAffine const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/unaryFx.cpp:174: undefined reference to `TAffine::operator==(TAffine const&) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpixel.h:86: undefined reference to `TPixelRGBM32::Black'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpixel.h:86: undefined reference to `TPixelRGBM32::Black'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/unaryFx.cpp:205: undefined reference to `TRop::applyColorScale(TSmartPointerT<TRaster> const&, TPixelRGBM32 const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/unaryFx.cpp:200: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/unaryFx.cpp:282: undefined reference to `TRop::invert(TSmartPointerT<TRaster>, bool, bool, bool, bool)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/zeraryFx.cpp:59: undefined reference to `toLinear(TPixelRGBM32 const&, double)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:355: undefined reference to `TRaster::fillRawData(unsigned char const*)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:355: undefined reference to `TRaster::fillRawData(unsigned char const*)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/zeraryFx.cpp:62: undefined reference to `toPixel64(TPixelRGBM32 const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/zeraryFx.cpp:62: undefined reference to `toLinear(TPixelRGBM64 const&, double)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:355: undefined reference to `TRaster::fillRawData(unsigned char const*)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/zeraryFx.cpp:52: undefined reference to `toPixel64(TPixelRGBM32 const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:355: undefined reference to `TRaster::fillRawData(unsigned char const*)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/zeraryFx.cpp:65: undefined reference to `toPixelF(TPixelRGBM32 const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/zeraryFx.cpp:65: undefined reference to `toLinear(TPixelF const&, double)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:355: undefined reference to `TRaster::fillRawData(unsigned char const*)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/zeraryFx.cpp:54: undefined reference to `toPixelF(TPixelRGBM32 const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:355: undefined reference to `TRaster::fillRawData(unsigned char const*)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/zeraryFx.cpp:68: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/zeraryFx.cpp:56: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/zeraryFx.cpp:37: undefined reference to `TConsts::infiniteRectD'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/zeraryFx.cpp:37: undefined reference to `TConsts::infiniteRectD'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/zeraryFx.cpp:121: undefined reference to `TRop::checkBoard(TSmartPointerT<TRaster>, TPixelRGBM32 const&, TPixelRGBM32 const&, TDimensionT<double> const&, TPointT<double> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/zeraryFx.cpp:101: undefined reference to `TConsts::infiniteRectD'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/zeraryFx.cpp:101: undefined reference to `TConsts::infiniteRectD'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpixel.h:86: undefined reference to `TPixelRGBM32::Green'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpixel.h:86: undefined reference to `TPixelRGBM32::Green'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/zeraryFx.cpp:26: undefined reference to `TPixelRGBM32::Green'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/zeraryFx.cpp:26: undefined reference to `TPixelRGBM32::Green'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpixel.h:86: undefined reference to `TPixelRGBM32::Black'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpixel.h:86: undefined reference to `TPixelRGBM32::Black'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpixel.h:86: undefined reference to `TPixelRGBM32::White'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpixel.h:86: undefined reference to `TPixelRGBM32::White'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/zeraryFx.cpp:88: undefined reference to `TPixelRGBM32::Black'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/zeraryFx.cpp:88: undefined reference to `TPixelRGBM32::Black'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/zeraryFx.cpp:89: undefined reference to `TPixelRGBM32::White'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tfx/zeraryFx.cpp:89: undefined reference to `TPixelRGBM32::White'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tapptools/tcli.cpp:85: undefined reference to `isInt(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpixel.h:(.text._ZN7ClusterC2ERKS_+0x54): undefined reference to `TPixelRGBM32::maxChannelValue'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpixel.h:(.text._ZN7ClusterC2ERKS_+0x58): undefined reference to `TPixelRGBM32::maxChannelValue'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpixel.h:86: undefined reference to `TPixelRGBM32::Black'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpixel.h:86: undefined reference to `TPixelRGBM32::Black'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tapptools/tcolorutils.cpp:(.text._ZN11TColorUtils12buildPaletteERNSt6__ndk13setI12TPixelRGBM32NS0_4lessIS2_EENS0_9allocatorIS2_EEEERK9TRasterPTIS2_Ei+0x684): undefined reference to `TPixelRGBM32::maxChannelValue'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tapptools/tcolorutils.cpp:(.text._ZN11TColorUtils12buildPaletteERNSt6__ndk13setI12TPixelRGBM32NS0_4lessIS2_EENS0_9allocatorIS2_EEEERK9TRasterPTIS2_Ei+0x688): undefined reference to `TPixelRGBM32::maxChannelValue'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpixel.h:(.text._ZN11TColorUtils21buildColorChipPaletteER5QListI5QPairI12TPixelRGBM327TPointTIiEEERK9TRasterPTIS2_EiRKS2_ii+0x4b4): undefined reference to `TPixelRGBM32::maxChannelValue'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpixel.h:(.text._ZN11TColorUtils21buildColorChipPaletteER5QListI5QPairI12TPixelRGBM327TPointTIiEEERK9TRasterPTIS2_EiRKS2_ii+0x4b8): undefined reference to `TPixelRGBM32::maxChannelValue'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpixel.h:98: undefined reference to `TPixelRGBM32::Transparent'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpixel.h:98: undefined reference to `TPixelRGBM32::Transparent'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpixel.h:(.text._ZN5QListIN12_GLOBAL__N_19ColorChipEE6detachEv+0x50): undefined reference to `TPixelRGBM32::maxChannelValue'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpixel.h:(.text._ZN5QListIN12_GLOBAL__N_19ColorChipEE6detachEv+0x54): undefined reference to `TPixelRGBM32::maxChannelValue'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpixel.h:(.text._ZNSt6__ndk16__sortIRPFbRKN12_GLOBAL__N_19ColorChipES4_EN5QListIS2_E8iteratorEEEvT0_SB_T_+0x518): undefined reference to `TPixelRGBM32::maxChannelValue'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpixel.h:(.text._ZNSt6__ndk16__sortIRPFbRKN12_GLOBAL__N_19ColorChipES4_EN5QListIS2_E8iteratorEEEvT0_SB_T_+0x51c): undefined reference to `TPixelRGBM32::maxChannelValue'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpixel.h:(.text._ZNSt6__ndk127__insertion_sort_incompleteIRPFbRKN12_GLOBAL__N_19ColorChipES4_EN5QListIS2_E8iteratorEEEbT0_SB_T_+0x144): undefined reference to `TPixelRGBM32::maxChannelValue'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tlevel.h:22: undefined reference to `TLevel::m_classCode'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tlevel.h:22: undefined reference to `TLevel::m_classCode'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tlevel.h:22: undefined reference to `TSmartObject::getInstanceCount(short)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/timage.h:27: undefined reference to `TImage::m_classCode'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/timage.h:27: undefined reference to `TImage::m_classCode'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/timage.h:27: undefined reference to `TSmartObject::getInstanceCount(short)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:78: undefined reference to `TRaster::m_classCode'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:78: undefined reference to `TRaster::m_classCode'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:78: undefined reference to `TSmartObject::getInstanceCount(short)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/timage_io.h:81: undefined reference to `TImageReader::m_classCode'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/timage_io.h:81: undefined reference to `TImageReader::m_classCode'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/timage_io.h:81: undefined reference to `TSmartObject::getInstanceCount(short)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/timage_io.h:215: undefined reference to `TImageWriter::m_classCode'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/timage_io.h:215: undefined reference to `TImageWriter::m_classCode'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/timage_io.h:215: undefined reference to `TSmartObject::getInstanceCount(short)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tlevel_io.h:45: undefined reference to `TLevelReader::m_classCode'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tlevel_io.h:45: undefined reference to `TLevelReader::m_classCode'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tlevel_io.h:45: undefined reference to `TSmartObject::getInstanceCount(short)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tlevel_io.h:129: undefined reference to `TLevelWriter::m_classCode'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tlevel_io.h:129: undefined reference to `TLevelWriter::m_classCode'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tlevel_io.h:129: undefined reference to `TSmartObject::getInstanceCount(short)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tparam.h:30: undefined reference to `TSmartObject::getInstanceCount(short)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tfx.h:353: undefined reference to `TSmartObject::getInstanceCount(short)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/ttest/ttest.cpp:148: undefined reference to `Tifstream::Tifstream(TFilePath const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/ttest/ttest.cpp:150: undefined reference to `operator<<(std::__ndk1::basic_ostream<char, std::__ndk1::char_traits<char> >&, TFilePath const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/ttest/ttest.cpp:153: undefined reference to `operator<<(std::__ndk1::basic_ostream<char, std::__ndk1::char_traits<char> >&, TFilePath const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/ttest/ttest.cpp:183: undefined reference to `Tifstream::~Tifstream()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/ttest/ttest.cpp:183: undefined reference to `Tifstream::~Tifstream()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/ttest/ttest.cpp:190: undefined reference to `TFilePath::TFilePath(char const*)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/ttest/ttest.cpp:192: undefined reference to `TSystem::getBinDir()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/ttest/ttest.cpp:192: undefined reference to `TFilePath::getParentDir() const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/ttest/ttest.cpp:194: undefined reference to `TFilePath::getParentDir() const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/ttest/ttest.cpp:197: undefined reference to `TFilePath::TFilePath(char const*)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/ttest/ttest.cpp:202: undefined reference to `TFilePath::TFilePath(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/ttest/ttest.cpp:202: undefined reference to `TFilePath::withType(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/ttest/ttest.cpp:202: undefined reference to `TFilePath::operator+(TFilePath const&) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/ttest/ttest.cpp:204: undefined reference to `TFilePath::TFilePath(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/ttest/ttest.cpp:204: undefined reference to `TFilePath::withType(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/ttest/ttest.cpp:204: undefined reference to `TFilePath::operator+(TFilePath const&) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/ttest/ttest.cpp:208: undefined reference to `TFilePath::TFilePath(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/ttest/ttest.cpp:208: undefined reference to `TFilePath::withType(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/ttest/ttest.cpp:208: undefined reference to `TFilePath::operator+(TFilePath const&) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/ttest/ttest.cpp:206: undefined reference to `TFilePath::TFilePath(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/ttest/ttest.cpp:206: undefined reference to `TFilePath::withType(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/ttest/ttest.cpp:206: undefined reference to `TFilePath::operator+(TFilePath const&) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/ttest/ttest.cpp:357: undefined reference to `TVectorImage::getStrokeCount() const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/ttest/ttest.cpp:358: undefined reference to `TVectorImage::getStrokeCount() const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/ttest/ttest.cpp:365: undefined reference to `TVectorImage::getBBox() const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/ttest/ttest.cpp:372: undefined reference to `TVectorImage::getBBox() const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/ttest/ttest.cpp:381: undefined reference to `TVectorImage::getStroke(unsigned int) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/ttest/ttest.cpp:382: undefined reference to `TVectorImage::getStroke(unsigned int) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/ttest/ttest.cpp:383: undefined reference to `TStroke::getControlPointCount() const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/ttest/ttest.cpp:384: undefined reference to `TStroke::getControlPointCount() const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/ttest/ttest.cpp:395: undefined reference to `TStroke::getControlPoint(int) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/ttest/ttest.cpp:396: undefined reference to `TStroke::getControlPoint(int) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tsmartpointer.h:281: undefined reference to `typeinfo for TImage'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tsmartpointer.h:281: undefined reference to `typeinfo for TRasterImage'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tsmartpointer.h:281: undefined reference to `typeinfo for TImage'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tsmartpointer.h:281: undefined reference to `typeinfo for TRasterImage'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tsmartpointer.h:281: undefined reference to `typeinfo for TImage'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tsmartpointer.h:281: undefined reference to `typeinfo for TRasterImage'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tsmartpointer.h:281: undefined reference to `typeinfo for TImage'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tsmartpointer.h:281: undefined reference to `typeinfo for TRasterImage'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tsmartpointer.h:281: undefined reference to `typeinfo for TImage'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tsmartpointer.h:281: undefined reference to `typeinfo for TToonzImage'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tsmartpointer.h:281: undefined reference to `typeinfo for TImage'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tsmartpointer.h:281: undefined reference to `typeinfo for TToonzImage'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tsmartpointer.h:281: undefined reference to `typeinfo for TImage'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tsmartpointer.h:281: undefined reference to `typeinfo for TToonzImage'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tsmartpointer.h:281: undefined reference to `typeinfo for TImage'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tsmartpointer.h:281: undefined reference to `typeinfo for TToonzImage'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/ttoonzimage.h:106: undefined reference to `TToonzImage::getCMapped() const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/ttoonzimage.h:106: undefined reference to `TToonzImage::getCMapped() const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tsmartpointer.h:281: undefined reference to `typeinfo for TImage'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tsmartpointer.h:281: undefined reference to `typeinfo for TVectorImage'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tsmartpointer.h:281: undefined reference to `typeinfo for TImage'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tsmartpointer.h:281: undefined reference to `typeinfo for TVectorImage'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tsmartpointer.h:281: undefined reference to `typeinfo for TImage'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tsmartpointer.h:281: undefined reference to `typeinfo for TVectorImage'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tsmartpointer.h:281: undefined reference to `typeinfo for TImage'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tsmartpointer.h:281: undefined reference to `typeinfo for TVectorImage'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/ttest/ttest.cpp:487: undefined reference to `TPalette::getPageCount() const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/ttest/ttest.cpp:487: undefined reference to `TPalette::getPageCount() const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/ttest/ttest.cpp:493: undefined reference to `TPalette::getStyle(int) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/ttest/ttest.cpp:494: undefined reference to `TPalette::getStyle(int) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/ttest/ttest.cpp:509: undefined reference to `TLevel::getPalette()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/ttest/ttest.cpp:509: undefined reference to `TLevel::getPalette()'
CMakeFiles/tnzbase.dir/__/common/ttest/ttest.cpp.o:(.data.rel.ro._ZTI8TRasterTI9TPixelGR8E[_ZTI8TRasterTI9TPixelGR8E]+0x10): undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/expressions/tgrammar.cpp:669: undefined reference to `toLower(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/expressions/tgrammar.cpp:671: undefined reference to `toLower(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/expressions/tgrammar.cpp:50: undefined reference to `TRandom::getDouble()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/expressions/tgrammar.cpp:40: undefined reference to `TRandom::~TRandom()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/expressions/tgrammar.cpp:45: undefined reference to `TRandom::TRandom(unsigned int)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/expressions/tgrammar.cpp:50: undefined reference to `TRandom::getDouble()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/expressions/tgrammar.cpp:50: undefined reference to `TRandom::getDouble()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tunit/tunit.cpp:468: undefined reference to `to_wstring(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tunit/tunit.cpp:496: undefined reference to `to_wstring(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tunit/tunit.cpp:503: undefined reference to `to_wstring(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tunit/tunit.cpp:531: undefined reference to `to_string(double, int)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tunit/tunit.cpp:540: undefined reference to `to_wstring(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tunit/tunit.cpp:539: undefined reference to `to_wstring(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscannerutil.cpp:54: undefined reference to `TRaster::yMirror()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscannerutil.cpp:(.text._ZN12TScannerUtil25copyRGBBufferToTRasterGR8EPhiiiRK9TRasterPTI9TPixelGR8E+0x38): undefined reference to `TPixelRGBM32::maxChannelValue'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscannerutil.cpp:(.text._ZN12TScannerUtil25copyRGBBufferToTRasterGR8EPhiiiRK9TRasterPTI9TPixelGR8E+0x40): undefined reference to `TPixelRGBM32::maxChannelValue'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscannerutil.cpp:69: undefined reference to `TPixelGR8::from(TPixelRGBM32 const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscannerutil.cpp:95: undefined reference to `TRaster::yMirror()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscannerutil.cpp:122: undefined reference to `TRaster::yMirror()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscannerutil.cpp:150: undefined reference to `TRaster::yMirror()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscannerepson.cpp:134: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscannerepson.cpp:667: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscannerepson.cpp:686: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscannerepson.cpp:628: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscannerepson.cpp:632: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tsystem.h:187: undefined reference to `TSystem::sleep(long)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:355: undefined reference to `TPixelRGBM32::White'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:355: undefined reference to `TPixelRGBM32::White'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:355: undefined reference to `TRaster::fillRawData(unsigned char const*)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:355: undefined reference to `TPixelGR8::White'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:355: undefined reference to `TPixelGR8::White'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:355: undefined reference to `TRaster::fillRawData(unsigned char const*)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscannerepson.cpp:389: undefined reference to `TRaster::copy(TSmartPointerT<TRaster> const&, TPointT<int> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/trasterimage.h:154: undefined reference to `TRasterImage::TRasterImage(TSmartPointerT<TRaster> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscannerepson.cpp:307: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscannerepson.cpp:315: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscannerepson.cpp:236: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscannerepson.cpp:290: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscannerepson.cpp:372: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscannerepson.cpp:84: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscannerepson.cpp:85: undefined reference to `to_wstring(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscannerepson.cpp:87: undefined reference to `to_wstring(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:287: undefined reference to `TRaster::TRaster(int, int, int)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:392: undefined reference to `typeinfo for TRaster'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:298: undefined reference to `TRaster::~TRaster()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:319: undefined reference to `TRaster::copy(TSmartPointerT<TRaster> const&, TPointT<int> const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/traster.h:292: undefined reference to `TRaster::TRaster(int, int, int, int, unsigned char*, TRaster*, bool)'
CMakeFiles/tnzbase.dir/tscanner/tscannerepson.cpp.o:(.data.rel.ro._ZTV8TRasterTI9TPixelGR8E[_ZTV8TRasterTI9TPixelGR8E]+0x10): undefined reference to `TRaster::~TRaster()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscanner.cpp:204: undefined reference to `TOStream::openCloseChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >, std::__ndk1::map<std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >, std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >, std::__ndk1::less<std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > >, std::__ndk1::allocator<std::__ndk1::pair<std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const, std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > > > > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscanner.cpp:208: undefined reference to `TOStream::openCloseChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >, std::__ndk1::map<std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >, std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >, std::__ndk1::less<std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > >, std::__ndk1::allocator<std::__ndk1::pair<std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const, std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > > > > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscanner.cpp:213: undefined reference to `TOStream::openCloseChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >, std::__ndk1::map<std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >, std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >, std::__ndk1::less<std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > >, std::__ndk1::allocator<std::__ndk1::pair<std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const, std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > > > > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscanner.cpp:233: undefined reference to `TOStream::openCloseChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >, std::__ndk1::map<std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >, std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >, std::__ndk1::less<std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > >, std::__ndk1::allocator<std::__ndk1::pair<std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const, std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > > > > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscanner.cpp:239: undefined reference to `TOStream::openCloseChild(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >, std::__ndk1::map<std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >, std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >, std::__ndk1::less<std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > >, std::__ndk1::allocator<std::__ndk1::pair<std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const, std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > > > > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscanner.cpp:265: undefined reference to `TIStream::matchTag(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscanner.cpp:267: undefined reference to `TIStream::getTagAttribute(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscanner.cpp:273: undefined reference to `TIStream::getTagAttribute(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscanner.cpp:292: undefined reference to `TIStream::getTagAttribute(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscanner.cpp:276: undefined reference to `TIStream::getTagAttribute(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscanner.cpp:283: undefined reference to `TIStream::getTagAttribute(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscanner.cpp:274: undefined reference to `isDouble(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscanner.cpp:277: undefined reference to `isDouble(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscanner.cpp:268: undefined reference to `isDouble(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscanner.cpp:271: undefined reference to `isDouble(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscanner.cpp:559: undefined reference to `TEnv::getConfigDir()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tfilepath.h:304: undefined reference to `TFilePath::TFilePath(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tfilepath.h:304: undefined reference to `TFilePath::operator+(TFilePath const&) const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscanner.cpp:560: undefined reference to `TFileStatus::TFileStatus(TFilePath const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscanner.cpp:560: undefined reference to `TFileStatus::isDirectory() const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscanner.cpp:566: undefined reference to `TSystem::readDirectory(TFilePath const&, bool, bool, bool)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tfilepath.h:241: undefined reference to `TFilePath::getUndottedType() const'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscanner.cpp:515: undefined reference to `Tifstream::Tifstream(TFilePath const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscanner.cpp:544: undefined reference to `isDouble(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscanner.cpp:546: undefined reference to `isDouble(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> >)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscanner.cpp:553: undefined reference to `Tifstream::~Tifstream()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscanner.cpp:553: undefined reference to `Tifstream::~Tifstream()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscannertwain.cpp:17: undefined reference to `TException::TException(std::__ndk1::basic_string<char, std::__ndk1::char_traits<char>, std::__ndk1::allocator<char> > const&)'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscannertwain.cpp:32: undefined reference to `TRaster::xMirror()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/tnzbase/tscanner/tscannertwain.cpp:33: undefined reference to `TRaster::yMirror()'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/trasterimage.h:154: undefined reference to `TRasterImage::TRasterImage(TSmartPointerT<TRaster> const&)'
clang++: error: linker command failed with exit code 1 (use -v to see invocation)
gmake[3]: *** [tnzbase/CMakeFiles/tnzbase.dir/build.make:1038: android-build/libs/arm64-v8a/libtnzbase_arm64-v8a.so] Error 1
gmake[2]: *** [CMakeFiles/Makefile2:764: tnzbase/CMakeFiles/tnzbase.dir/all] Error 2
gmake[1]: *** [CMakeFiles/Makefile2:1290: toonz/CMakeFiles/OpenToonz.dir/rule] Error 2
gmake: *** [Makefile:411: OpenToonz] Error 2
```

### Android compile — run 38208331733
Linhas de erro relevantes extraídas do log do job (repetições e símbolos `undefined reference` mantidos):

```text
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpixel.h:199:43: error: no matching constructor for initialization of 'TPixelRGBM64'
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tpixel.h:199:3: note: candidate constructor not viable: requires single argument 'pix', but no arguments were provided
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/include/tthreadmessage.h:12:10: fatal error: 'QMutex' file not found
2 errors generated.
gmake[3]: *** [toonzlib/CMakeFiles/toonzlib.dir/build.make:203: toonzlib/CMakeFiles/toonzlib.dir/autoadjust.cpp.o] Error 1
gmake[2]: *** [CMakeFiles/Makefile2:828: toonzlib/CMakeFiles/toonzlib.dir/all] Error 2
gmake[1]: *** [CMakeFiles/Makefile2:1290: toonz/CMakeFiles/OpenToonz.dir/rule] Error 2
gmake: *** [Makefile:411: OpenToonz] Error 2
```

## Interpretação e cautelas

- O erro ativo mais recente é `list index: 1 out of range (-1, 0)` em `AndroidLegacyGL.cmake:254`; ambos os workflows Android atuais param durante a configuração.
- O conflito `glShaderSource` e os símbolos indefinidos de `tnzbase` pertencem ao log anterior que conseguiu avançar até à compilação/ligação. Como a configuração atual falha antes dessa fase, ainda não está demonstrado se esses problemas antigos foram resolvidos.
- `TPixelRGBM64` e `QMutex` aparecem no run anterior; o run posterior avançou além deles, pelo que devem ser tratados como erros históricos aparentemente ultrapassados, não como falhas atuais confirmadas.
- Warnings CMake/Node/NDK são distinguidos das mensagens fatais; nem todos os avisos provocam a falha.


## 2026-10-15 — correções aplicadas e workflow de APK

### Correções de código feitas nesta sessão

1. `toonz/sources/common/tsystem/tpluginmanager.cpp`: o include de `sys/dir.h` foi excluído para Android; o Android usa `dirent.h`. O identificador de extensão de plugin `.so` também passou a reconhecer `__ANDROID__`. Commit: `55f108fa12c17219935f0d652b31ce15859979cb`.
2. `toonz/sources/toonzfarm/tfarm/CMakeLists.txt`: foi adicionada uma ramificação Android que liga `tfarm` diretamente aos targets `tnzcore`, `tnzbase`, `toonzlib` e `tnzext`, em vez de depender de caminhos de bibliotecas do host. Isto visa os símbolos não resolvidos observados no run `38704535097`; só o novo CI poderá confirmar se resolve todos. Commit: `98f2129ef9e05e15b070c3dbcbc26d6e6e2186a3`.
3. `.github/workflows/android-native-configure.yml`: passou a chamar-se **Android Tablet APK (OpenToonz ARM64)** e, depois de compilar o target original, tenta empacotar com Qt 5.15 `androiddeployqt`, JDK 11, valida o ZIP do APK, recolhe metadados e publica o artefacto `ToonzTab-tablet-arm64-debug-apk`. Commit: `5b1f65975d37c35ffa9d3b3b22954e4ee54c9536`.

### Validação pendente

- Run do workflow de APK: https://github.com/layouter787-source/Open-toonz-mobile-/actions/runs/38707636719
- Run duplicado acionado por pull request: https://github.com/layouter787-source/Open-toonz-mobile-/actions/runs/38707630469
- No momento deste registo, o run principal estava a compilar o target C++ original; nenhum artefacto APK foi confirmado.
- A verificação clang-format falhou no commit `5b1f659` por alterações anteriores em `toonz/sources/common/tapptools/tenv.cpp`, linhas 688, 697 e 745. As mensagens são: `code should be clang-formatted [-Wclang-format-violations]`. Ainda não foi corrigido neste registo.
- O resultado da compilação deve ser revisto para verificar se desapareceram os erros anteriores de `tfarm`/símbolos indefinidos e `sys/dir.h`, e para registar os próximos erros reais caso apareçam.

Não marcar a portabilidade Android como concluída até o workflow gerar um APK, validar o artefacto e permitir instalação/teste num tablet ARM64 real.


## 2026-10-15 — segundo ciclo de compilação Android

### Erro fatal novo (run 38707636719)

```text
/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tgl/tgl.cpp:665:2: error: "unknown platform!"
gmake[3]: *** [tnzcore/CMakeFiles/tnzcore.dir/build.make:709: toonz/sources/common/tgl/tgl.cpp.o] Error 1
gmake[2]: *** [CMakeFiles/Makefile2:700: tnzcore/CMakeFiles/tnzcore.dir/all] Error 2
gmake[1]: *** [CMakeFiles/Makefile2:1312: toonz/CMakeFiles/OpenToonz.dir/rule] Error 2
gmake: *** [Makefile:411: OpenToonz] Error 2
```

Causa: tgl.cpp não incluía __ANDROID__ / Q_OS_ANDROID na seleção da implementação de contexto GL. O bloco terminava no #error "unknown platform!". Correção aplicada no commit 319fbfc745bc505141a94eab0b35e7e9d06fcf60: incluir Android na seleção do bloco Qt QGLContext e na seleção de plataforma que implementa tglGetCurrentContext, tglMakeCurrent e tglDoneCurrent. Ainda precisa de CI para confirmar que o próximo bloqueio é ultrapassado.

### Verificação de formatação

O run 38707636717 de clang-format falhou nas alterações anteriores de tenv.cpp com as mensagens code should be clang-formatted [-Wclang-format-violations] em 688, 697 e 745. Foram ajustadas as quebras de linha das expressões relativePath e sourcePath no commit 12cc2de7e027fe6dcac98e8b6ff532d6c1c35035. O novo workflow clang-format ainda está em execução; confirmar o resultado antes de fechar este item.

### Execução atual

- APK workflow no commit com as correções: https://github.com/layouter787-source/Open-toonz-mobile-/actions/runs/38708126068
- Run duplicado no mesmo commit: https://github.com/layouter787-source/Open-toonz-mobile-/actions/runs/38708129179
- No momento do registo, o run estava na preparação do Android SDK; nenhum APK foi produzido/confirmado.
- Os erros anteriores de ligação de tfarm e sys/dir.h ainda precisam de ser reavaliados depois que a compilação passar de tgl.cpp; a falha atual interrompeu o build antes de confirmar essas correções.


### Correção adicional de clang-format

O run 38708129106 ainda falhou apenas em tenv.cpp:744:9. A causa é a opção AlignConsecutiveAssignments do ficheiro .clang-format: os dois assignments consecutivos do ramo Android precisam alinhar o sinal de igual. Corrigido em b486cf1b459b58f80d905c843fce98bc534da64b com `copied      = copyAndroidStuffAssets(stagingDirStr);`. A verificação para o commit novo ainda precisa concluir.

Run Android APK após a correção do contexto GL: https://github.com/layouter787-source/Open-toonz-mobile-/actions/runs/38708230263 . No momento, o workflow ainda estava em execução; APK não confirmado.


### Erros de formatação do adaptador GLUT e correção

O run clang-format 38708376953 identificou as seguintes linhas em toonz/sources/common/tgl/android_glut_fonts.c:

```text
android_glut_fonts.c:57:22: error: code should be clang-formatted [-Wclang-format-violations]
android_glut_fonts.c:58:26: error: code should be clang-formatted [-Wclang-format-violations]
android_glut_fonts.c:59:22: error: code should be clang-formatted [-Wclang-format-violations]
android_glut_fonts.c:60:22: error: code should be clang-formatted [-Wclang-format-violations]
android_glut_fonts.c:61:29: error: code should be clang-formatted [-Wclang-format-violations]
android_glut_fonts.c:62:29: error: code should be clang-formatted [-Wclang-format-violations]
android_glut_fonts.c:63:28: error: code should be clang-formatted [-Wclang-format-violations]
android_glut_fonts.c:64:28: error: code should be clang-formatted [-Wclang-format-violations]
android_glut_fonts.c:65:28: error: code should be clang-formatted [-Wclang-format-violations]
##[error]Process completed with exit code 1.
```

Causa: a coluna de substituição das macros GLUT não estava alinhada. Foram corrigidos os formatos das declarações de structs, das variáveis globais, da chamada glBitmap e das macros. Commits: 4212631dd58da77e99b9dd32be4e278e3cfd38f2 e d4cff2f35d9f926521a2bc8d666b01deb3de8e0d. O novo check de clang-format está na fila (run 38708542375); ainda não confirmar como resolvido até ele passar.

### Estado no último registo

- Workflow Android Tablet APK para o commit d4cff2f: https://github.com/layouter787-source/Open-toonz-mobile-/actions/runs/38708542286 (queued).
- O último erro fatal de compilação observado foi o #error "unknown platform!" em tgl.cpp:665 no run 38707636719. O ramo Android foi adicionado no commit 319fbfc; ainda falta o resultado de um build completo no commit atual.
- Nenhum APK foi confirmado como artefacto. O workflow só publica o APK se a compilação C++ original e o empacotamento androiddeployqt forem bem-sucedidos.


## 2026-10-15 — novo erro C++ após ultrapassar tgl.cpp

### Run observado
- Workflow: https://github.com/layouter787-source/Open-toonz-mobile-/actions/runs/38708542286
- O CMake configurou com sucesso e a compilação do target original começou.
- A etapa C++ falhou em `toonz/sources/common/tvrender/qtofflinegl.cpp`; por isso as etapas de JDK, empacotamento e upload de APK foram ignoradas. O único artefacto publicado nesse run contém logs de diagnóstico, não um APK.

### Erros exatos
```text
qtofflinegl.cpp:193:32: error: incomplete type 'QThread' named in nested name specifier
qtofflinegl.cpp:203:29: error: incomplete type 'QThread' named in nested name specifier
qtofflinegl.cpp:241:50: error: calling 'toImage' with incomplete return type 'QImage'
```

### Correção aplicada
O ficheiro usava `QThread::currentThreadId()`, `QThread::currentThread()` e `QOpenGLFramebufferObject::toImage()` sem incluir as definições completas dos tipos. Foi acrescentado:
```cpp
#include <QImage>
#include <QThread>
```
Commit da correção: https://github.com/layouter787-source/Open-toonz-mobile-/commit/cf453afcf33c2c5a215b8f055c92db14122cce80

### Próxima ação obrigatória
A alteração dispara uma nova execução do workflow. Consultar o run novo e corrigir o próximo erro fatal real a partir dos logs. Ainda não há APK compilado, empacotado ou testado num tablet; não declarar sucesso até isso acontecer.
