# CLAUDE.md

## Resumo dos erros do GitHub Actions

Data da análise: 2026-10-15
Repositório: `layouter787-source/Open-toonz-mobile-`

### Workflows com falha hoje

- `Android Native OpenToonz Configure` — run `38700817117` — https://github.com/layouter787-source/Open-toonz-mobile-/actions/runs/38700817117
- `Android Native Graphics Compatibility` — run `38699134202` — https://github.com/layouter787-source/Open-toonz-mobile-/actions/runs/38699134202
- `Android Native OpenToonz Configure` — run `38699134024` — https://github.com/layouter787-source/Open-toonz-mobile-/actions/runs/38699134024
- `Android Native Graphics Compatibility` — run `38696291683` — https://github.com/layouter787-source/Open-toonz-mobile-/actions/runs/38696291683
- `Android Native OpenToonz Configure` — run `38696291583` — https://github.com/layouter787-source/Open-toonz-mobile-/actions/runs/38696291583

## Erros observados

### 1) Action customizada não compilada

Mensagem recorrente:

> `This TypeScript action cannot be used before building within Node.js environment.`
> `Maybe you are currently using non-tagging branches, for example, the "master" branch.`
> `Only v* branches have built JavaScript action file.`

Contexto:
- O workflow falha no step que verifica a existência da action JavaScript buildada.
- Isso indica que a action customizada (`install-qt-action` ou equivalente) foi criada em TypeScript, mas o arquivo `action/lib/main.js` não foi gerado/commitado.

Ação recomendada:
- Compilar a action antes do uso.
- ou usar uma branch/tag que já contenha o build gerado.
- ou ajustar o workflow para rodar `npm install && npm run build` antes de usar a action.

### 2) Erro de CMake em `AndroidLegacyGL.cmake`

Mensagem principal:

> `CMake Error at .../AndroidLegacyGL.cmake:204 (list): list index: 1 out of range (-1, 0)`
> `CMake Error at .../AndroidLegacyGL.cmake:254 (list): list index: 1 out of range (-1, 0)`

Contexto:
- A função `opentoonz_android_link_module_graph` está acessando `list GET ... 1` em uma lista vazia ou incompleta.
- Isso indica que a variável usada para montar o graph de módulos Android está vazia.

Causa provável:
- Lista de módulos/links não preenchida.
- Condição de geração do gráfico de módulos não verificada antes do `list GET`.
- Diferença de comportamento entre versões do CMake / NDK / Android toolchain.

Correção sugerida:
- Verificar se a lista existe e tem pelo menos 2 itens antes de usar índice 1.
- Exemplo de guard:

```cmake
if(DEFINED _modules AND NOT "${_modules}" STREQUAL "")
  list(LENGTH _modules _module_count)
  if(_module_count GREATER 1)
    list(GET _modules 1 _second_module)
  endif()
endif()
```

- Também revisar a função `opentoonz_android_link_module_graph` e confirmar as variáveis populadas antes do uso.

### 3) Header de Linux inexistente no Android: `sys/dir.h`

Mensagem principal:

> `/home/runner/work/Open-toonz-mobile-/Open-toonz-mobile-/toonz/sources/common/tsystem/tpluginmanager.cpp:24:10: fatal error: 'sys/dir.h' file not found`
> `#include <sys/dir.h>`

Contexto:
- O código usa um header UNIX/Linux que não existe no ambiente Android/NDK.

Causa provável:
- Código portado para Android sem condicional por plataforma.
- Header correto em Android seria `dirent.h` ou outra abstração equivalente.

Correção sugerida:
- Adicionar proteção por plataforma:

```cpp
#if defined(__ANDROID__)
  #include <dirent.h>
#else
  #include <sys/dir.h>
#endif
```

- ou usar um wrapper de abstração `tfilesystem`/`tfile` caso o projeto já tenha um equivalente.

### 4) Linker do Android falha por `undefined reference`

Mensagem principal:

> `CMakeFiles/tfarm.dir/ttcpipserver.cpp.o:(.data.rel.ro._ZTV12DataReceiver+0xa0): undefined reference to 'TThread::Runnable::onException(...)'`
> `... undefined reference to 'TThread::Runnable::onCanceled(...)'`
> `... undefined reference to 'TThread::Runnable::onTerminated(...)'`
> `... typeinfo for TThread::Runnable`
> `clang++: error: linker command failed with exit code 1`

Contexto:
- O linker não encontra a implementação da classe `TThread::Runnable` ou o objeto que define esses métodos não está sendo incluído no target correto.

Causa provável:
- Arquivos de implementação não estão incluídos no target de build do Android.
- Diferença no CMake/Android toolchain.
- Membros virtuais não implementados em classe base/derivada.

Correção sugerida:
- Verificar se a implementação de `TThread::Runnable` está em um alvo CMake que realmente entra no build Android.
- Confirmar se a classe `DataReceiver` herda corretamente da interface e se os métodos virtuais são implementados.
- Revisar `toonzfarm` e o target `tfarm` para garantir ligação correta.

## Diagnóstico principal

Os erros hoje não são isolados: eles convergem para quatro problemas principais:

1. Action customizada não buildada.
2. `AndroidLegacyGL.cmake` acessando índice inválido de lista.
3. Código Android usando `sys/dir.h` incompatível.
4. Linker com `TThread::Runnable` não resolvido.

## Ordem de correção recomendada

1. Corrigir a action customizada do workflow.
2. Corrigir a lógica do CMake em `AndroidLegacyGL.cmake`.
3. Ajustar `sys/dir.h` para plataforma Android.
4. Resolver link / target `tfarm` / `TThread::Runnable`.
5. Rodar novamente os workflows específicos do Android.

## Observação

O problema mais crítico e imediato para compilar no Android é o CMake/NDK e o `sys/dir.h` — esses dois bloqueiam a configuração do build antes mesmo de terminar a compilação.

## Próximo passo

Se quiser, a seguir eu posso:
- 1) aplicar a correção direta no repositório, ou
- 2) criar uma segunda versão deste arquivo com patches exatos para cada arquivo afetado.
