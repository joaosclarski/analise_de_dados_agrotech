# Análise de Dados — AgroTech Solutions

Auditoria de dados e indicadores gerenciais da base de vendas consolidada das filiais da AgroTech Solutions, empresa que comercializa produtos agrícolas.

| Item | Conteúdo |
|---|---|
| Integrante | João Vitor Sclarski |
| Disciplina | Linguagem e Projeto de Banco de Dados |
| SGBD | MySQL 8.0 (testado no 8.0.46) |
| Script único | [`AgroTech_Joao_Vitor_Sclarski.sql`](AgroTech_Joao_Vitor_Sclarski.sql) |
| Slides | [`AgroTech_KPIs_Joao_Vitor_Sclarski.pptx`](AgroTech_KPIs_Joao_Vitor_Sclarski.pptx) |

---

## 1. Visão geral

A integração das filiais gerou uma base com registros duplicados, erros de digitação, valores e quantidades impossíveis, datas fora do período operacional e dados de teste. O objetivo do trabalho é tornar essa base confiável e, a partir dela, produzir informação para a diretoria.

| Parte | O que foi feito | Resultado principal |
|---|---|---|
| **Parte 1 — Limpeza e tratamento** | 10 comandos de `UPDATE`/`DELETE`, cada um precedido por um `SELECT` de conferência com o mesmo filtro e seguido de um `SELECT` de verificação. | 75 → **68 registros** válidos; 7 excluídos e 18 corrigidos. |
| **Parte 2 — Relatório gerencial** | 10 consultas com `WHERE`, `GROUP BY`, `ORDER BY`, `COUNT`, `AVG`, `SUM`, `HAVING`, `BETWEEN`, `LIMIT` e subqueries. | 48 registros disponíveis; R$ 769.784,00 de valor potencial disponível. |
| **Parte 3 — KPIs** | 10 indicadores com objetivo, regra de cálculo, consulta, resultado e interpretação gerencial. | 6 percentuais, 4 em reais, 5 comparativos, 6 com subquery. |
| **Parte 4 — Documentação** | Este README e a publicação no GitHub. | — |

Convenções usadas em todo o projeto:

- **Registros** = linhas da tabela (`COUNT(*)`, sem `DISTINCT`).
- **Unidades** = soma da coluna `quantidade` (`SUM(quantidade)`).
- **Valor potencial do estoque** = `quantidade × valor_unitario`. Não é faturamento nem lucro: a base não informa custos nem a quantidade efetivamente vendida em cada operação.

---

## 2. Como executar

### Pré-requisitos

- MySQL Server **8.0 ou superior**.
- Um cliente: MySQL Workbench ou o cliente de linha de comando `mysql`.
- Usuário com permissão para `CREATE DATABASE`.
- O banco `agropecuaria_db` **não pode existir** antes da execução.

### Execução

O arquivo [`AgroTech_Joao_Vitor_Sclarski.sql`](AgroTech_Joao_Vitor_Sclarski.sql) faz tudo, na ordem:

1. **Seção 0:** cria o banco `agropecuaria_db`, cria a tabela `tb_vendas_agro` e carrega os 75 registros originais.
2. **Parte 1:** aplica o tratamento (Q01 a Q10).
3. **Parte 2:** executa as consultas do relatório gerencial (Q01 a Q10).
4. **Parte 3:** executa as consultas dos KPIs (KPI 01 a KPI 10).

**MySQL Workbench:** `File > Open SQL Script…`, abrir o arquivo e executar tudo com o raio (`Ctrl+Shift+Enter`). Cada `SELECT` aparece em uma aba de resultado.

**Linha de comando:**

```bash
mysql -u root -p --default-character-set=utf8mb4 --table < AgroTech_Joao_Vitor_Sclarski.sql
```

### Detalhes do script

- `SET NAMES utf8mb4` garante que acentos (`ã`, `ç`) sejam enviados corretamente.
- `SET SQL_SAFE_UPDATES = 0` desativa o *safe update mode* do Workbench, que bloquearia `UPDATE`/`DELETE` filtrados por colunas que não são a chave primária.
- O banco e a tabela usam a collation **`utf8mb4_0900_as_cs`** (sensível a acento e a maiúsculas). Na collation padrão do MySQL 8 (`utf8mb4_0900_ai_ci`), `'Racão'` é considerado igual a `'Ração'` e `'Graos'` igual a `'Grãos'`. Com ela, os filtros de limpeza atingiriam também registros corretos.
- Para executar de novo, remova o banco antes: `DROP DATABASE agropecuaria_db;`.

---

## 3. Dicionário de dados

### Tabela `tb_vendas_agro`

Base consolidada das operações comerciais das filiais. **Cada linha representa um registro de produto em uma filial (estado), em uma data de venda**, com a quantidade de unidades associada, o preço unitário de cadastro e a indicação de disponibilidade para comercialização. O mesmo produto pode aparecer em mais de uma linha (outras datas, estados ou condições comerciais).

| Coluna | Tipo | Descrição | Restrições e regras aplicadas | Exemplo (base tratada, id 2) |
|---|---|---|---|---|
| `id` | `INT` | Identificador único do registro. | Chave primária (`PRIMARY KEY`): não se repete e não é nulo. Na Q01, o menor `id` identifica o registro original. | `2` |
| `produto` | `VARCHAR(100)` | Nome comercial do produto. | Grafia oficial com acentuação (Q02). Comparação sensível a acento. Valores de teste (`XXXXX`, `TESTE PRODUTO`) não são aceitos (Q09). | `Soja Premium` |
| `categoria` | `VARCHAR(50)` | Segmento do produto. | Domínio na base tratada: `Defensivos`, `Fertilizantes`, `Grãos`, `Minerais`, `Rações`, `Sementes` (Q07). `ERRO` e `TESTE` são inválidos (Q09). | `Grãos` |
| `fornecedor` | `VARCHAR(100)` | Empresa que fornece o produto. | Domínio na base tratada: `AgroMax`, `AgroSul`, `BioPlant`, `Campo Verde`, `NutriCampo`, `Solo Forte` (Q03). `DESCONHECIDO` e `TESTE` são inválidos (Q09). | `Campo Verde` |
| `estado` | `VARCHAR(50)` | UF da filial onde está o registro. | Sigla de 2 letras maiúsculas (Q06). Domínio na base tratada: `GO`, `MG`, `MS`, `MT`, `PR`, `RS`, `SC`, `SP`. | `MT` |
| `quantidade` | `INT` | Unidades do produto associadas ao registro. | Deve ser maior que zero (Q05 corrigiu `-10` e `0`). Na base tratada varia de 12 a 340. | `200` |
| `valor_unitario` | `DECIMAL(10,2)` | Preço de uma unidade, em reais. | Deve ser maior que zero e compatível com o produto (Q04 corrigiu R$ 1,99, R$ 99.999,99, negativo e zero). Na base tratada varia de R$ 42,00 a R$ 980,00. | `145.50` |
| `data_venda` | `DATE` | Data da operação comercial do registro. | Formato `AAAA-MM-DD`. Não pode ser posterior a `2025-12-31` (Q08). Na base tratada vai de `2025-01-10` a `2025-05-17`. | `2025-01-15` |
| `estoque` | `BOOLEAN` | Indica se o registro está disponível para comercialização. | `true` (1) = disponível; `false` (0) = indisponível ou bloqueado. Defensivos com `valor_unitario > 800` ficam `false` (Q10). | `1` (true) |

### Como interpretar as colunas principais

- **`quantidade`** é o número de **unidades** do registro (sacas, embalagens, toneladas, conforme o produto). Somar `quantidade` dá unidades; contar linhas dá registros. As duas medidas não se confundem: PR tem 12 registros e 2.107 unidades, enquanto MT tem 14 registros e 1.561 unidades.
- **`estoque`** não é uma quantidade: é um **indicador de disponibilidade** (`true`/`false`). Um registro com `estoque = false` continua cadastrado e com unidades, mas não pode ser ofertado (por falta, reserva ou bloqueio comercial, como na Q10).
- **`data_venda`** é a data da operação registrada, usada para recortes de período (P2-Q10). A base não traz a quantidade efetivamente vendida em cada data, por isso `quantidade × valor_unitario` é tratado como **valor potencial**, e não como faturamento.

---

## 4. Resultados do tratamento (Parte 1)

### Antes e depois

| Medida | Antes | Depois |
|---|---:|---:|
| Registros | 75 | **68** |
| Fornecedores distintos | 11 (com grafias erradas e de teste) | 6 |
| Estados distintos | 12 (com `PARANA`, `SÃO PAULO`, `XX`, `TT`) | 8 |
| Categorias distintas | 10 (com `Graos`, `Racao`, `ERRO`, `TESTE`) | 6 |
| Registros disponíveis (`estoque = true`) | — | 48 |

### Registros afetados por questão

| Questão | Ação | Registros afetados | IDs |
|---|---|---:|---|
| Q01 | Exclusão de duplicatas de Milho Safrinha, Soja Premium e Ração Bovina 25kg (mantido o menor ID) | 3 excluídos | 51, 52, 53 |
| Q02 | Correção de 5 nomes de produto (ex.: `Sojjja Premium` → `Soja Premium`) | 5 atualizados | 54 a 58 |
| Q03 | Correção de fornecedores (`Campo Vrede`, `NutriCamp`, `Bio Planti`) | 3 atualizados | 59, 60, 61 |
| Q04 | Correção de valores unitários (R$ 1,99 → 160,00; R$ 99.999,99 → 950,00; −45,00 → 55,50; 0,00 → 275,00) | 4 atualizados | 62 a 65 |
| Q05 | Correção de quantidades (−10 → 170; 0 → 66) | 2 atualizados | 66, 67 |
| Q06 | Estados por extenso (`PARANA` → `PR`; `SÃO PAULO` → `SP`) | 2 atualizados | 68, 69 |
| Q07 | Categorias (`Graos` → `Grãos`; `Racao` → `Rações`) | 2 atualizados | 70, 71 |
| Q08 | Exclusão de `data_venda` posterior a 31/12/2025 | 4 excluídos | 72, 73, 74, 75 |
| Q09 | Exclusão de registros de teste | 0 (já removidos na Q08) | — |
| Q10 | Bloqueio de Defensivos com `valor_unitario > 800` | 6 no filtro, 5 alterados (o id 25 já era `false`) | 25, 30, 44, 49, 63, 69 |

Os registros com nome incorreto (Q02) foram preservados na Q01: a duplicata só é excluída quando repete produto, categoria, fornecedor, estado, quantidade e valor de um registro com ID menor.

---

## 5. Resultados do relatório gerencial (Parte 2)

| Questão | Resultado principal |
|---|---|
| Q01 — Produtos disponíveis | **48** registros com `estoque = true` (de 68). |
| Q02 — Registros por fornecedor | Campo Verde 16 · NutriCampo 14 · AgroSul 11 · Solo Forte 10 · BioPlant 9 · AgroMax 8. |
| Q03 — 10 maiores valores unitários | Todos são **Defensivos**, de R$ 980,00 (Herbicida Platinum, SP) a R$ 599,00 (Inseticida Power, MT). |
| Q04 — Valor unitário médio por categoria | Defensivos R$ 739,91 · Fertilizantes R$ 296,74 · Grãos R$ 136,02 · Sementes R$ 117,44 · Rações R$ 113,68 · Minerais R$ 58,17. |
| Q05 — Registros por estado | MT 14 · PR 12 · GO 11 · MS 8 · SC 7 · SP 7 · RS 6 · MG 3. |
| Q06 — Sementes e Grãos disponíveis | 18 registros (13 de Grãos e 5 de Sementes). |
| Q07 — Quantidade acima de 200 unidades | 11 registros; o maior é Calcário Fino (340 un., PR). Os 5 primeiros são calcários do PR. |
| Q08 — Valor potencial do estoque disponível | **R$ 769.784,00**. |
| Q09 — Indisponíveis por categoria | Defensivos 7 · Sementes 4 · Fertilizantes 3 · Grãos 3 · Rações 2 · Minerais 1 (total 20). |
| Q10 — Vendas de 01/03 a 31/05/2025 | 51 registros, de 2025-03-01 (Milho Híbrido) a 2025-05-17. |

Destaques:

- **Fornecedores:** a Campo Verde concentra o maior número de registros (16, ou 23,53%) e, no KPI 07, 43,52% do valor potencial disponível.
- **Estados:** MT tem mais registros (14), mas PR tem mais unidades (2.107), puxado pelos calcários.
- **Defensivos:** ocupam as 10 primeiras posições em valor unitário e, depois do bloqueio da Q10, são a categoria com mais registros indisponíveis (7 de 14).

---

## 6. Catálogo e resultados dos 10 KPIs (Parte 3)

Todos os KPIs usam a tabela `tb_vendas_agro` depois da Parte 1. Percentuais e valores monetários têm duas casas decimais. **Divisão por zero:** todo denominador está em `NULLIF(denominador, 0)`. Se ele for zero, a divisão retorna `NULL` em vez de erro, e `COALESCE(..., 0)` exibe `0.00`. A identificação (KPI 01 a KPI 10) é a mesma dos comentários do SQL e dos slides.

### Resumo

| Código | Nome | Tema | Base | Unidade | Resultado |
|---|---|---|---|---|---|
| KPI 01 | Taxa de Disponibilidade Comercial | Disponibilidade | Todos | % | **70,59%** |
| KPI 02 | Valor Potencial Bloqueado | Disponibilidade / Financeiro | Todos | R$ e % | **R$ 326.690,50 (29,79%)** |
| KPI 03 | Distribuição de Unidades por Estado | Estoque e logística / Estados | Todos | % | **PR 28,52%** |
| KPI 04 | Volume Médio por Registro, por Categoria | Estoque e logística / Categorias | Todos | un./registro | **Minerais 254,29** |
| KPI 05 | Valor Potencial do Estoque Disponível | Valor financeiro | Disponíveis | R$ | **R$ 769.784,00** |
| KPI 06 | Participação das Categorias no Valor Disponível | Valor financeiro / Categorias | Disponíveis | R$ e % | **Grãos 43,91%** |
| KPI 07 | Fornecedores: Cadastro × Valor Disponível | Fornecedores | Todos / Disponíveis | % | **Campo Verde 43,52% do valor** |
| KPI 08 | Preço Médio Ponderado por Unidade | Valor financeiro / Categorias | Todos | R$/unidade | **Defensivos R$ 700,35** |
| KPI 09 | Índice de Concentração de Fornecedores (HHI) | Fornecedores | Todos | pontos | **1.769,03** |
| KPI 10 | Registros com Volume Baixo na Categoria | Estoque e logística | Disponíveis | % | **6,25%** |

Cumprimento das regras: percentuais em KPI 01, 02, 03, 06, 07 e 10; financeiros em reais em KPI 02, 05, 06 e 08; comparações entre estados, categorias ou fornecedores em KPI 03, 04, 06, 07 e 08; subqueries em KPI 03, 04, 06, 07, 09 e 10.

---

### KPI 01 — Taxa de Disponibilidade Comercial

- **Objetivo:** medir a parcela dos registros cadastrados liberada para venda, ou seja, quanto do portfólio a equipe comercial pode ofertar hoje.
- **Tabela e colunas:** `tb_vendas_agro` — `estoque`.
- **Regra de cálculo:** `registros com estoque = true ÷ total de registros × 100`.
  - Numerador: `SUM(estoque = true)` → 48.
  - Denominador: `COUNT(*)` → 68.
  - Divisão por zero: `NULLIF(COUNT(*), 0)`.
- **Filtros:** nenhum (todos os registros).
- **Unidade:** %.
- **Resultado:** **70,59%** (48 disponíveis, 20 indisponíveis).
- **Interpretação:** cerca de 7 em cada 10 registros podem ser ofertados. Os indisponíveis se concentram em Defensivos (7) e Sementes (4), conforme a P2-Q09. Metade dos defensivos está bloqueada, em parte pela decisão da Q10. **Decisão apoiada:** revisar primeiro os indisponíveis de Defensivos e Sementes. Meta *sugerida pelo grupo* (não fornecida pela empresa): 80% de disponibilidade.

### KPI 02 — Valor Potencial Bloqueado

- **Objetivo:** medir quanto do valor potencial do estoque está em registros indisponíveis, traduzindo a indisponibilidade em reais.
- **Tabela e colunas:** `tb_vendas_agro` — `quantidade`, `valor_unitario`, `estoque`, `categoria` (detalhe).
- **Regra de cálculo:** `Σ(quantidade × valor_unitario) com estoque = false ÷ Σ(quantidade × valor_unitario) de todos × 100`.
  - Numerador: valor potencial dos indisponíveis → R$ 326.690,50.
  - Denominador: valor potencial total → R$ 1.096.474,50.
  - Divisão por zero: `NULLIF(SUM(quantidade * valor_unitario), 0)`.
- **Filtros:** todos os registros (o filtro `estoque = false` fica dentro do `CASE` do numerador). O detalhe por categoria usa `WHERE estoque = false` e uma subquery para o total bloqueado.
- **Unidade:** R$ e %.
- **Resultado:** **R$ 326.690,50, ou 29,79%** do valor potencial total. Composição: Defensivos 33,35% (R$ 108.950,00) · Grãos 29,19% (R$ 95.359,00) · Fertilizantes 16,61% · Sementes 10,35% · Rações 5,56% · Minerais 4,94%.
- **Interpretação:** quase 30% do valor potencial está parado. 10 registros (7 defensivos e 3 de grãos) explicam 62,54% do valor travado. **Decisão apoiada:** definir prazo para reavaliar os defensivos bloqueados e liberar os grãos indisponíveis. Meta *sugerida*: menos de 20% bloqueado.

### KPI 03 — Distribuição de Unidades por Estado

- **Objetivo:** mostrar onde as unidades estão armazenadas, para orientar armazenagem, frete e alocação de estoque.
- **Tabela e colunas:** `tb_vendas_agro` — `estado`, `quantidade`.
- **Regra de cálculo:** `Σ quantidade do estado ÷ Σ quantidade total × 100`.
  - Numerador: `SUM(quantidade)` agrupado por `estado`.
  - Denominador: subquery `(SELECT SUM(quantidade) FROM tb_vendas_agro)` → 7.387.
  - Divisão por zero: `NULLIF(subquery, 0)`.
- **Filtros:** nenhum (unidades físicas, disponíveis ou não).
- **Unidade:** %.
- **Resultado:** PR 28,52% (2.107 un.) · MT 21,13% (1.561) · MS 16,61% (1.227) · GO 12,17% (899) · SC 8,31% (614) · RS 5,62% (415) · MG 4,33% (320) · SP 3,30% (244).
- **Interpretação:** PR e MT guardam 49,65% das unidades. PR lidera com menos registros que MT por concentrar o calcário, com 300 ou mais unidades por registro. SP e MG somam 7,63%. **Decisão apoiada:** priorizar armazenagem e frete em PR e MT e avaliar se SP e MG justificam estoque local.

### KPI 04 — Volume Médio por Registro, por Categoria

- **Objetivo:** comparar quantas unidades cada categoria movimenta por registro, separando itens de granel de itens em lotes pequenos, frente à média da empresa.
- **Tabela e colunas:** `tb_vendas_agro` — `categoria`, `quantidade`.
- **Regra de cálculo:** `média da categoria = Σ quantidade ÷ registros`; `média geral` (subquery) `= 7.387 ÷ 68 = 108,63`; `índice = média da categoria ÷ média geral × 100` (100 = igual à média). Divisões com `NULLIF`.
- **Filtros:** nenhum (todos os registros).
- **Unidade:** unidades por registro (e índice em %).
- **Resultado:** Minerais 254,29 (índice 234,08) · Grãos 190,00 (174,90) · Rações 77,77 (71,59) · Sementes 70,33 (64,74) · Fertilizantes 69,22 (63,72) · Defensivos 21,43 (19,73).
- **Interpretação:** "acima da média" significa índice maior que 100. Minerais e Grãos são itens de granel, que exigem espaço e transporte pesado. Defensivos operam com lotes pequenos (~21 un.) e alto valor unitário (KPI 08). **Decisão apoiada:** planejar armazenagem a granel para Minerais e Grãos e controle por lote e segurança para Defensivos.

### KPI 05 — Valor Potencial do Estoque Disponível

- **Objetivo:** estimar, a preço de cadastro, o valor das unidades que podem ser ofertadas agora.
- **Tabela e colunas:** `tb_vendas_agro` — `quantidade`, `valor_unitario`, `estoque`.
- **Regra de cálculo:** `Σ(quantidade × valor_unitario)`.
- **Filtros:** `WHERE estoque = true` (apenas disponíveis).
- **Unidade:** R$.
- **Resultado:** **R$ 769.784,00**, formado por 48 registros e 5.681 unidades.
- **Interpretação:** é o teto, a preço de tabela, do que o estoque liberado poderia gerar se vendido por inteiro. **Não é faturamento nem lucro**, porque a base não informa custos nem a quantidade efetivamente vendida. **Decisão apoiada:** usar como referência para metas comerciais e para dimensionar o capital imobilizado e o seguro do estoque.

### KPI 06 — Participação das Categorias no Valor Disponível

- **Objetivo:** mostrar quais categorias sustentam o valor potencial que pode ser vendido.
- **Tabela e colunas:** `tb_vendas_agro` — `categoria`, `quantidade`, `valor_unitario`, `estoque`.
- **Regra de cálculo:** `Σ valor potencial da categoria ÷ Σ valor potencial disponível × 100`.
  - Numerador: `SUM(quantidade * valor_unitario)` por categoria, com `estoque = true`.
  - Denominador: subquery do valor potencial disponível → R$ 769.784,00.
  - Divisão por zero: `NULLIF(subquery, 0)`.
- **Filtros:** `WHERE estoque = true` (apenas disponíveis).
- **Unidade:** R$ e %.
- **Resultado:** Grãos R$ 338.018,00 (43,91%) · Fertilizantes R$ 120.755,00 (15,69%) · Defensivos R$ 101.155,00 (13,14%) · Rações R$ 92.089,20 (11,96%) · Minerais R$ 77.968,00 (10,13%) · Sementes R$ 39.798,80 (5,17%).
- **Interpretação:** Grãos sustentam quase metade do valor ofertável, então uma oscilação no preço de grãos afeta quase metade do estoque comercializável. Sementes têm a menor fatia, com 4 dos seus 9 registros indisponíveis. **Decisão apoiada:** acompanhar o preço de grãos como prioridade e estudar a liberação de Sementes.

### KPI 07 — Fornecedores: Cadastro × Valor Disponível

- **Objetivo:** comparar o peso de cada fornecedor no número de registros com o peso no valor potencial disponível, revelando dependência que a contagem esconde.
- **Tabela e colunas:** `tb_vendas_agro` — `fornecedor`, `quantidade`, `valor_unitario`, `estoque`.
- **Regra de cálculo:**
  - `% registros`: numerador `COUNT(*)` do fornecedor; denominador subquery `COUNT(*)` total (68).
  - `% valor disponível`: numerador `Σ(quantidade × valor_unitario)` do fornecedor com `estoque = true`; denominador subquery do valor disponível total (R$ 769.784,00).
  - Divisão por zero: `NULLIF` nos dois denominadores.
- **Filtros:** todos os registros para `% registros`; apenas disponíveis (`CASE WHEN estoque = true`) para `% valor`.
- **Unidade:** % (e R$ no valor absoluto).
- **Resultado:**

  | Fornecedor | Registros | % registros | Valor disponível | % valor disponível |
  |---|---:|---:|---:|---:|
  | Campo Verde | 16 | 23,53% | R$ 334.995,00 | **43,52%** |
  | NutriCampo | 14 | 20,59% | R$ 98.492,20 | 12,79% |
  | AgroSul | 11 | 16,18% | R$ 69.396,80 | 9,02% |
  | Solo Forte | 10 | 14,71% | R$ 140.840,00 | 18,30% |
  | BioPlant | 9 | 13,24% | R$ 67.782,20 | 8,81% |
  | AgroMax | 8 | 11,76% | R$ 58.277,80 | 7,57% |

- **Interpretação:** pela contagem a base parece equilibrada, mas a Campo Verde detém 43,52% do valor disponível, quase o dobro da sua fatia em registros. Uma falha desse fornecedor afetaria quase metade do valor ofertável. **Decisão apoiada:** negociar contrato com a Campo Verde e qualificar um segundo fornecedor de grãos. Meta *sugerida*: nenhum fornecedor acima de 35% do valor disponível.

### KPI 08 — Preço Médio Ponderado por Unidade

- **Objetivo:** mostrar quanto vale, em média, cada unidade armazenada de cada categoria. Diferente da média simples (P2-Q04), registros com mais unidades pesam mais.
- **Tabela e colunas:** `tb_vendas_agro` — `categoria`, `quantidade`, `valor_unitario`.
- **Regra de cálculo:** `Σ(quantidade × valor_unitario) ÷ Σ quantidade`, por categoria, com `NULLIF(SUM(quantidade), 0)`.
- **Filtros:** nenhum (todos os registros).
- **Unidade:** R$ por unidade.
- **Resultado:** Defensivos R$ 700,35 · Fertilizantes R$ 280,95 · Grãos R$ 142,56 · Sementes R$ 116,29 · Rações R$ 109,04 · Minerais R$ 52,87.
- **Interpretação:** uma unidade de defensivo vale cerca de 13 vezes uma unidade de mineral. Perda, avaria ou bloqueio de poucas unidades de Defensivos e Fertilizantes pesa muito mais no valor do estoque. **Decisão apoiada:** inventário frequente, armazenagem segura e cobertura de seguro para Defensivos e Fertilizantes.

### KPI 09 — Índice de Concentração de Fornecedores (HHI)

- **Objetivo:** resumir em um número o quanto a base depende de poucos fornecedores (Índice Herfindahl-Hirschman).
- **Tabela e colunas:** `tb_vendas_agro` — `fornecedor`.
- **Regra de cálculo:** `participação = registros do fornecedor ÷ total × 100` (tabela derivada com subquery); `HHI = Σ participação²`, de 0 a 10.000. Divisões com `NULLIF`.
  - Critério de comparação (faixas de referência usadas em análise de concentração de mercado): abaixo de 1.500 = baixa; 1.500 a 2.500 = moderada; acima de 2.500 = alta.
  - Referência de equilíbrio: com N fornecedores iguais, `HHI = 10.000 ÷ N` (1.666,67 para 6).
- **Filtros:** nenhum (todos os registros).
- **Unidade:** pontos HHI.
- **Resultado:** **1.769,03** (6 fornecedores; maior participação 23,53%).
- **Interpretação:** pela faixa a concentração é moderada, mas o índice está perto do mínimo possível com 6 fornecedores (1.666,67). Em registros a divisão é equilibrada: o risco vem do número pequeno de fornecedores, e não da distribuição entre eles. **Decisão apoiada:** ampliar a base de fornecedores. Com 8 parceiros equilibrados, o HHI cairia para 1.250 (faixa baixa).

### KPI 10 — Registros com Volume Baixo na Categoria

- **Objetivo:** sinalizar registros disponíveis com poucas unidades em relação ao padrão da própria categoria, ou seja, candidatos a reposição.
- **Tabela e colunas:** `tb_vendas_agro` — `categoria`, `quantidade`, `estoque`.
- **Regra de cálculo:** `registros disponíveis com volume baixo ÷ registros disponíveis × 100`.
  - Critério de "volume baixo" (*sugestão do grupo*, não fornecido pela empresa): `quantidade < 50% da média de unidades da mesma categoria`, calculada por subquery correlacionada sobre todos os registros da categoria.
  - Numerador: 3. Denominador: 48. Divisão por zero: `NULLIF(COUNT(*), 0)`.
- **Filtros:** `WHERE estoque = true` (apenas disponíveis).
- **Unidade:** %.
- **Resultado:** **6,25%**: Sal Mineral Bovino (MG, 95 un.; média de Minerais 254,29), Sal Mineral Premium (MG, 105 un.) e Ração Equina (SP, 38 un.; média de Rações 77,77).
- **Interpretação:** poucos registros estão abaixo do critério, e os três ficam em MG e SP, os estados com menos unidades (KPI 03). Os sais minerais aparecem porque a média de Minerais é puxada pelo calcário, armazenado em grande volume. **Decisão apoiada:** programar a reposição desses itens e revisar o critério com a logística (por exemplo, média por subtipo de produto).

---

## 7. Conclusão gerencial

Os três KPIs mais relevantes para a diretoria:

1. **KPI 02 — Valor Potencial Bloqueado (29,79%, R$ 326.690,50).** É o maior problema financeiro encontrado: quase um terço do valor potencial não pode ser ofertado, e Defensivos e Grãos somam 62,54% desse valor. **Apoia** a definição de prazos para reavaliar os bloqueios da Q10 e liberar os grãos indisponíveis.
2. **KPI 07 — Fornecedores: Cadastro × Valor (Campo Verde com 43,52% do valor disponível).** Revela um risco que a contagem de registros (23,53%) esconde: quase metade do valor ofertável depende de um único fornecedor. **Apoia** a negociação de contrato com a Campo Verde e a qualificação de um segundo fornecedor de grãos.
3. **KPI 03 — Distribuição de Unidades por Estado (PR + MT = 49,65%).** É a maior oportunidade operacional: metade do volume físico está em dois estados. **Apoia** a priorização de armazenagem a granel e de contratos de frete em PR e MT.

Recomendação complementar: os 25 registros problemáticos da base original (duplicatas, grafias, valores, quantidades, datas e testes) mostram a necessidade de validar os dados na entrada, com `quantidade ≥ 0`, `valor_unitario > 0`, data dentro do período e listas fixas de UF, categoria e fornecedor. As metas citadas neste documento são sugestões do autor, pois a empresa não forneceu metas oficiais.
