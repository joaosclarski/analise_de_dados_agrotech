-- =====================================================================
-- ATIVIDADE PRÁTICA — AUDITORIA DE DADOS E INDICADORES GERENCIAIS
-- Empresa: AgroTech Solutions
-- Integrante: João Vitor Sclarski
-- SGBD: MySQL 8.0
--
-- Ordem de execução: este arquivo deve ser executado do início ao fim,
-- em um ambiente em que o banco agropecuaria_db ainda não exista.
--   Seção 0 — Preparação da base (banco, tabela e carga)
--   Parte 1 — Limpeza e tratamento de dados (Q01 a Q10)
--   Parte 2 — Relatório gerencial (Q01 a Q10)
--   Parte 3 — KPIs (KPI 01 a KPI 10)
--
-- Convenções usadas nos resultados:
--   * "registros"  = linhas da tabela (COUNT(*), sem DISTINCT);
--   * "unidades"   = soma da coluna quantidade (SUM(quantidade));
--   * "valor potencial do estoque" = quantidade × valor_unitario
--     (NÃO é faturamento nem lucro).
-- =====================================================================


-- =====================================================================
-- SEÇÃO 0 — PREPARAÇÃO DA BASE
-- =====================================================================

-- Garante que acentos (ã, ç, é...) sejam enviados corretamente ao servidor.
SET NAMES utf8mb4;

-- O MySQL Workbench ativa por padrão o "safe update mode", que bloqueia
-- UPDATE/DELETE sem filtro pela chave primária. Os filtros desta atividade
-- usam outras colunas, por isso o modo é desativado nesta sessão.
SET SQL_SAFE_UPDATES = 0;

CREATE DATABASE agropecuaria_db
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_0900_as_cs;

USE agropecuaria_db;

-- Collation utf8mb4_0900_as_cs (sensível a acento e a maiúsculas):
-- com a collation padrão do MySQL 8 (utf8mb4_0900_ai_ci), 'Racão' seria
-- considerado IGUAL a 'Ração' e 'Graos' IGUAL a 'Grãos'. Isso faria os
-- filtros de limpeza atingirem registros corretos. Com _as_cs cada grafia
-- é comparada exatamente como foi digitada.
CREATE TABLE tb_vendas_agro (
    id              INT PRIMARY KEY,
    produto         VARCHAR(100),
    categoria       VARCHAR(50),
    fornecedor      VARCHAR(100),
    estado          VARCHAR(50),
    quantidade      INT,
    valor_unitario  DECIMAL(10,2),
    data_venda      DATE,
    estoque         BOOLEAN
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_cs;

INSERT INTO tb_vendas_agro
(id, produto, categoria, fornecedor, estado, quantidade, valor_unitario, data_venda, estoque)
VALUES
(1, 'Milho Safrinha', 'Grãos', 'AgroSul', 'PR', 120, 89.90, '2025-01-10', true),
(2, 'Soja Premium', 'Grãos', 'Campo Verde', 'MT', 200, 145.50, '2025-01-15', true),
(3, 'Ração Bovina 25kg', 'Rações', 'NutriCampo', 'SC', 80, 110.00, '2025-01-18', true),
(4, 'Fertilizante NPK', 'Fertilizantes', 'AgroMax', 'GO', 50, 320.75, '2025-01-22', false),
(5, 'Herbicida ForteMax', 'Defensivos', 'BioPlant', 'MS', 30, 450.00, '2025-01-25', true),
(6, 'Calcário Agrícola', 'Minerais', 'Solo Forte', 'PR', 300, 45.90, '2025-01-27', true),
(7, 'Semente de Trigo', 'Sementes', 'AgroSul', 'RS', 90, 99.99, '2025-02-01', false),
(8, 'Inseticida Power', 'Defensivos', 'Campo Verde', 'MT', 25, 599.00, '2025-02-03', true),
(9, 'Farelo de Soja', 'Rações', 'NutriCampo', 'SC', 110, 76.50, '2025-02-05', true),
(10, 'Adubo Orgânico', 'Fertilizantes', 'BioPlant', 'SP', 60, 180.00, '2025-02-08', true),
(11, 'Milheto', 'Sementes', 'AgroSul', 'GO', 70, 88.80, '2025-02-10', false),
(12, 'Sal Mineral Bovino', 'Minerais', 'NutriCampo', 'MG', 95, 67.40, '2025-02-12', true),
(13, 'Soja Convencional', 'Grãos', 'Campo Verde', 'MT', 180, 139.00, '2025-02-15', true),
(14, 'Ração Suína 20kg', 'Rações', 'NutriCampo', 'SC', 55, 98.00, '2025-02-17', false),
(15, 'Fungicida Max', 'Defensivos', 'AgroMax', 'PR', 22, 799.90, '2025-02-20', true),
(16, 'Semente de Aveia', 'Sementes', 'AgroSul', 'RS', 65, 72.30, '2025-02-22', true),
(17, 'Ureia Agrícola', 'Fertilizantes', 'Solo Forte', 'GO', 140, 210.00, '2025-02-25', true),
(18, 'Milho Híbrido', 'Grãos', 'Campo Verde', 'MS', 210, 155.90, '2025-03-01', false),
(19, 'Ração Equina', 'Rações', 'NutriCampo', 'SP', 40, 132.75, '2025-03-04', true),
(20, 'Herbicida Select', 'Defensivos', 'BioPlant', 'MT', 28, 499.90, '2025-03-06', true),
(21, 'Calcário Premium', 'Minerais', 'Solo Forte', 'PR', 310, 55.50, '2025-03-08', true),
(22, 'Semente de Pastagem', 'Sementes', 'AgroSul', 'GO', 85, 120.00, '2025-03-10', false),
(23, 'Soja Exportação', 'Grãos', 'Campo Verde', 'MT', 260, 160.00, '2025-03-12', true),
(24, 'Fertilizante Potássico', 'Fertilizantes', 'AgroMax', 'MS', 48, 420.00, '2025-03-14', true),
(25, 'Inseticida Ultra', 'Defensivos', 'BioPlant', 'SP', 18, 890.00, '2025-03-16', false),
(26, 'Ração Avícola', 'Rações', 'NutriCampo', 'SC', 130, 89.50, '2025-03-18', true),
(27, 'Milho Orgânico', 'Grãos', 'AgroSul', 'PR', 95, 110.00, '2025-03-20', true),
(28, 'Adubo Nitrogenado', 'Fertilizantes', 'Solo Forte', 'GO', 75, 275.00, '2025-03-22', true),
(29, 'Semente de Arroz', 'Sementes', 'Campo Verde', 'RS', 60, 140.00, '2025-03-24', false),
(30, 'Fungicida Premium', 'Defensivos', 'AgroMax', 'MT', 15, 950.00, '2025-03-26', true),
(31, 'Farelo Bovino', 'Rações', 'NutriCampo', 'MG', 120, 82.30, '2025-03-28', true),
(32, 'Soja Safra 2025', 'Grãos', 'Campo Verde', 'MS', 230, 150.00, '2025-03-30', false),
(33, 'Calcário Fino', 'Minerais', 'Solo Forte', 'PR', 340, 42.00, '2025-04-01', true),
(34, 'Herbicida AgroPlus', 'Defensivos', 'BioPlant', 'GO', 26, 620.00, '2025-04-03', true),
(35, 'Ração Premium Bovina', 'Rações', 'NutriCampo', 'SC', 88, 145.00, '2025-04-05', false),
(36, 'Semente de Feijão', 'Sementes', 'AgroSul', 'PR', 77, 115.90, '2025-04-07', true),
(37, 'Milho Tradicional', 'Grãos', 'Campo Verde', 'MT', 170, 100.00, '2025-04-10', true),
(38, 'Fertilizante Especial', 'Fertilizantes', 'AgroMax', 'SP', 54, 380.00, '2025-04-12', true),
(39, 'Inseticida Verde', 'Defensivos', 'BioPlant', 'MS', 19, 720.00, '2025-04-15', false),
(40, 'Sal Mineral Premium', 'Minerais', 'Solo Forte', 'MG', 105, 92.00, '2025-04-18', true),
(41, 'Ração Ovina', 'Rações', 'NutriCampo', 'RS', 66, 118.00, '2025-04-20', true),
(42, 'Soja Natural', 'Grãos', 'Campo Verde', 'GO', 190, 148.00, '2025-04-22', false),
(43, 'Semente Especial', 'Sementes', 'AgroSul', 'PR', 59, 132.50, '2025-04-24', true),
(44, 'Fungicida Rural', 'Defensivos', 'AgroMax', 'MT', 24, 845.00, '2025-04-26', true),
(45, 'Adubo Premium', 'Fertilizantes', 'Solo Forte', 'SC', 81, 299.90, '2025-04-28', false),
(46, 'Milho Exportação', 'Grãos', 'Campo Verde', 'MS', 250, 170.00, '2025-05-01', true),
(47, 'Ração Campo Forte', 'Rações', 'NutriCampo', 'GO', 74, 136.40, '2025-05-03', true),
(48, 'Calcário Rural', 'Minerais', 'Solo Forte', 'PR', 330, 48.90, '2025-05-05', false),
(49, 'Herbicida Platinum', 'Defensivos', 'BioPlant', 'SP', 17, 980.00, '2025-05-07', true),
(50, 'Semente Premium', 'Sementes', 'AgroSul', 'RS', 68, 155.00, '2025-05-10', true),

-- REGISTROS COM PROBLEMAS PARA LIMPEZA E TRATAMENTO DE DADOS

-- PRODUTOS DUPLICADOS
(51, 'Milho Safrinha', 'Grãos', 'AgroSul', 'PR', 120, 89.90, '2025-05-12', true),
(52, 'Soja Premium', 'Grãos', 'Campo Verde', 'MT', 200, 145.50, '2025-05-12', true),
(53, 'Ração Bovina 25kg', 'Rações', 'NutriCampo', 'SC', 80, 110.00, '2025-05-12', true),

-- NOMES INCORRETOS DE PRODUTOS
(54, 'Milhho Safrinha', 'Grãos', 'AgroSul', 'PR', 95, 88.00, '2025-05-13', true),
(55, 'Sojjja Premium', 'Grãos', 'Campo Verde', 'MT', 180, 140.00, '2025-05-13', true),
(56, 'Racão Bovina 25kg', 'Rações', 'NutriCampo', 'SC', 70, 105.00, '2025-05-13', true),
(57, 'Fertilizanti NPK', 'Fertilizantes', 'AgroMax', 'GO', 45, 310.00, '2025-05-13', false),
(58, 'Insetcida Power', 'Defensivos', 'Campo Verde', 'MT', 20, 580.00, '2025-05-13', true),

-- FORNECEDORES ESCRITOS ERRADOS
(59, 'Milho Híbrido', 'Grãos', 'Campo Vrede', 'MS', 190, 150.00, '2025-05-14', true),
(60, 'Ração Equina', 'Rações', 'NutriCamp', 'SP', 38, 130.00, '2025-05-14', true),
(61, 'Herbicida Select', 'Defensivos', 'Bio Planti', 'MT', 27, 495.00, '2025-05-14', true),

-- PREÇOS INCORRETOS / SUSPEITOS
(62, 'Soja Exportação', 'Grãos', 'Campo Verde', 'MT', 250, 1.99, '2025-05-15', true),
(63, 'Fungicida Premium', 'Defensivos', 'AgroMax', 'MT', 12, 99999.99, '2025-05-15', true),
(64, 'Calcário Premium', 'Minerais', 'Solo Forte', 'PR', 300, -45.00, '2025-05-15', true),
(65, 'Adubo Nitrogenado', 'Fertilizantes', 'Solo Forte', 'GO', 70, 0.00, '2025-05-15', true),

-- QUANTIDADES INCORRETAS
(66, 'Milho Tradicional', 'Grãos', 'Campo Verde', 'MT', -10, 100.00, '2025-05-16', true),
(67, 'Ração Ovina', 'Rações', 'NutriCampo', 'RS', 0, 118.00, '2025-05-16', true),

-- ESTADOS INCORRETOS
(68, 'Semente Especial', 'Sementes', 'AgroSul', 'PARANA', 59, 132.50, '2025-05-16', true),
(69, 'Herbicida Platinum', 'Defensivos', 'BioPlant', 'SÃO PAULO', 17, 980.00, '2025-05-16', true),

-- CATEGORIAS INCORRETAS
(70, 'Milho Exportação', 'Graos', 'Campo Verde', 'MS', 250, 170.00, '2025-05-17', true),
(71, 'Ração Campo Forte', 'Racao', 'NutriCampo', 'GO', 74, 136.40, '2025-05-17', true),

-- DATAS INCONSISTENTES
(72, 'Calcário Rural', 'Minerais', 'Solo Forte', 'PR', 330, 48.90, '2035-01-01', false),
(73, 'Semente Premium', 'Sementes', 'AgroSul', 'RS', 68, 155.00, '2028-12-30', true),

-- REGISTROS COMPLETAMENTE INCONSISTENTES
(74, 'XXXXX', 'ERRO', 'DESCONHECIDO', 'XX', -999, -500.00, '2040-01-01', false),
(75, 'TESTE PRODUTO', 'TESTE', 'TESTE', 'TT', 99999, 999999.99, '2099-01-01', true);

-- Conferência da carga: quantidade de registros ANTES da limpeza (esperado: 75).
SELECT COUNT(*) AS total_registros_antes_da_limpeza FROM tb_vendas_agro;


-- =====================================================================
-- PARTE 1 — LIMPEZA E TRATAMENTO DE DADOS
-- Padrão de cada questão:
--   (a) SELECT de conferência com o mesmo filtro do comando;
--   (b) comando UPDATE/DELETE;
--   (c) SELECT de verificação após a alteração.
-- =====================================================================

-- ---------------------------------------------------------------------
-- P1-Q01. Remoção de registros duplicados
-- Produtos: Milho Safrinha, Soja Premium e Ração Bovina 25kg.
-- Regra: um registro é duplicado quando repete produto, categoria,
-- fornecedor, estado, quantidade e valor_unitario de um registro com ID
-- menor. O registro de menor ID (original) é preservado.
-- Registros com nome incorreto (IDs 54 e 56) não entram no filtro, pois
-- a comparação é exata (collation _as_cs) e as quantidades são diferentes.
-- Esperado: excluir os IDs 51, 52 e 53.
-- ---------------------------------------------------------------------

-- (a) Conferência: todos os registros desses produtos, marcando o original.
SELECT id, produto, categoria, fornecedor, estado, quantidade, valor_unitario, data_venda,
       CASE WHEN id = (SELECT MIN(t2.id)
                         FROM tb_vendas_agro t2
                        WHERE t2.produto = t1.produto)
            THEN 'ORIGINAL' ELSE 'DUPLICADO' END AS situacao
  FROM tb_vendas_agro t1
 WHERE produto IN ('Milho Safrinha', 'Soja Premium', 'Ração Bovina 25kg')
 ORDER BY produto, id;

-- (a) Conferência: exatamente os registros que serão excluídos.
SELECT d.*
  FROM tb_vendas_agro d
  JOIN tb_vendas_agro o
    ON  o.produto        = d.produto
    AND o.categoria      = d.categoria
    AND o.fornecedor     = d.fornecedor
    AND o.estado         = d.estado
    AND o.quantidade     = d.quantidade
    AND o.valor_unitario = d.valor_unitario
    AND o.id             < d.id
 WHERE d.produto IN ('Milho Safrinha', 'Soja Premium', 'Ração Bovina 25kg');

-- (b) Exclusão das duplicatas (o MySQL permite DELETE com JOIN na própria tabela).
DELETE d
  FROM tb_vendas_agro d
  JOIN tb_vendas_agro o
    ON  o.produto        = d.produto
    AND o.categoria      = d.categoria
    AND o.fornecedor     = d.fornecedor
    AND o.estado         = d.estado
    AND o.quantidade     = d.quantidade
    AND o.valor_unitario = d.valor_unitario
    AND o.id             < d.id
 WHERE d.produto IN ('Milho Safrinha', 'Soja Premium', 'Ração Bovina 25kg');

-- (c) Verificação: deve restar 1 registro de cada produto (IDs 1, 2 e 3).
SELECT id, produto, quantidade, valor_unitario
  FROM tb_vendas_agro
 WHERE produto IN ('Milho Safrinha', 'Soja Premium', 'Ração Bovina 25kg')
 ORDER BY id;


-- ---------------------------------------------------------------------
-- P1-Q02. Padronização dos nomes dos produtos
-- Esperado: 5 registros atualizados (IDs 54 a 58).
-- ---------------------------------------------------------------------

-- (a) Conferência
SELECT id, produto
  FROM tb_vendas_agro
 WHERE produto IN ('Milhho Safrinha', 'Sojjja Premium', 'Racão Bovina 25kg',
                   'Fertilizanti NPK', 'Insetcida Power');

-- (b) Atualização
UPDATE tb_vendas_agro
   SET produto = CASE produto
                    WHEN 'Milhho Safrinha'   THEN 'Milho Safrinha'
                    WHEN 'Sojjja Premium'    THEN 'Soja Premium'
                    WHEN 'Racão Bovina 25kg' THEN 'Ração Bovina 25kg'
                    WHEN 'Fertilizanti NPK'  THEN 'Fertilizante NPK'
                    WHEN 'Insetcida Power'   THEN 'Inseticida Power'
                 END
 WHERE produto IN ('Milhho Safrinha', 'Sojjja Premium', 'Racão Bovina 25kg',
                   'Fertilizanti NPK', 'Insetcida Power');

-- (c) Verificação: nenhum nome incorreto deve permanecer.
SELECT COUNT(*) AS nomes_incorretos_restantes
  FROM tb_vendas_agro
 WHERE produto IN ('Milhho Safrinha', 'Sojjja Premium', 'Racão Bovina 25kg',
                   'Fertilizanti NPK', 'Insetcida Power');

SELECT id, produto FROM tb_vendas_agro WHERE id BETWEEN 54 AND 58;


-- ---------------------------------------------------------------------
-- P1-Q03. Padronização dos fornecedores
-- Esperado: 3 registros atualizados (IDs 59, 60 e 61).
-- ---------------------------------------------------------------------

-- (a) Conferência
SELECT id, produto, fornecedor
  FROM tb_vendas_agro
 WHERE fornecedor IN ('Campo Vrede', 'NutriCamp', 'Bio Planti');

-- (b) Atualização
UPDATE tb_vendas_agro
   SET fornecedor = CASE fornecedor
                       WHEN 'Campo Vrede' THEN 'Campo Verde'
                       WHEN 'NutriCamp'   THEN 'NutriCampo'
                       WHEN 'Bio Planti'  THEN 'BioPlant'
                    END
 WHERE fornecedor IN ('Campo Vrede', 'NutriCamp', 'Bio Planti');

-- (c) Verificação: lista de fornecedores distintos após a correção.
SELECT fornecedor, COUNT(*) AS qtd_registros
  FROM tb_vendas_agro
 GROUP BY fornecedor
 ORDER BY fornecedor;


-- ---------------------------------------------------------------------
-- P1-Q04. Correção dos valores unitários
-- Filtros identificam apenas os valores incorretos, preservando os
-- registros corretos dos mesmos produtos (IDs 23, 30, 21 e 28):
--   Soja Exportação   -> valor muito baixo  (< 10,00)     -> 160,00
--   Fungicida Premium -> valor extremamente alto (> 10.000,00) -> 950,00
--   Calcário Premium  -> valor negativo (< 0)            -> 55,50
--   Adubo Nitrogenado -> valor zerado (= 0)              -> 275,00
-- Esperado: 4 registros atualizados (IDs 62, 63, 64 e 65).
-- ---------------------------------------------------------------------

-- (a) Conferência
SELECT id, produto, valor_unitario
  FROM tb_vendas_agro
 WHERE (produto = 'Soja Exportação'   AND valor_unitario < 10)
    OR (produto = 'Fungicida Premium' AND valor_unitario > 10000)
    OR (produto = 'Calcário Premium'  AND valor_unitario < 0)
    OR (produto = 'Adubo Nitrogenado' AND valor_unitario = 0);

-- (b) Atualizações (um comando por regra, cada um com seu filtro)
UPDATE tb_vendas_agro SET valor_unitario = 160.00
 WHERE produto = 'Soja Exportação'   AND valor_unitario < 10;

UPDATE tb_vendas_agro SET valor_unitario = 950.00
 WHERE produto = 'Fungicida Premium' AND valor_unitario > 10000;

UPDATE tb_vendas_agro SET valor_unitario = 55.50
 WHERE produto = 'Calcário Premium'  AND valor_unitario < 0;

UPDATE tb_vendas_agro SET valor_unitario = 275.00
 WHERE produto = 'Adubo Nitrogenado' AND valor_unitario = 0;

-- (c) Verificação: todos os registros desses produtos permanecem cadastrados.
SELECT id, produto, valor_unitario
  FROM tb_vendas_agro
 WHERE produto IN ('Soja Exportação', 'Fungicida Premium', 'Calcário Premium', 'Adubo Nitrogenado')
 ORDER BY produto, id;

-- Nenhum dos quatro produtos deve manter valor fora do padrão (esperado: 0).
SELECT COUNT(*) AS valores_incorretos_restantes
  FROM tb_vendas_agro
 WHERE (produto = 'Soja Exportação'   AND valor_unitario < 10)
    OR (produto = 'Fungicida Premium' AND valor_unitario > 10000)
    OR (produto = 'Calcário Premium'  AND valor_unitario < 0)
    OR (produto = 'Adubo Nitrogenado' AND valor_unitario = 0);


-- ---------------------------------------------------------------------
-- P1-Q05. Correção das quantidades
--   Milho Tradicional: -10 -> 170
--   Ração Ovina:         0 -> 66
-- Esperado: 2 registros atualizados (IDs 66 e 67).
-- ---------------------------------------------------------------------

-- (a) Conferência
SELECT id, produto, quantidade
  FROM tb_vendas_agro
 WHERE (produto = 'Milho Tradicional' AND quantidade = -10)
    OR (produto = 'Ração Ovina'       AND quantidade = 0);

-- (b) Atualizações
UPDATE tb_vendas_agro SET quantidade = 170
 WHERE produto = 'Milho Tradicional' AND quantidade = -10;

UPDATE tb_vendas_agro SET quantidade = 66
 WHERE produto = 'Ração Ovina' AND quantidade = 0;

-- (c) Verificação
SELECT id, produto, quantidade
  FROM tb_vendas_agro
 WHERE produto IN ('Milho Tradicional', 'Ração Ovina')
 ORDER BY id;


-- ---------------------------------------------------------------------
-- P1-Q06. Padronização dos estados
--   PARANA -> PR ; SÃO PAULO -> SP
-- Esperado: 2 registros atualizados (IDs 68 e 69).
-- ---------------------------------------------------------------------

-- (a) Conferência
SELECT id, produto, estado
  FROM tb_vendas_agro
 WHERE estado IN ('PARANA', 'SÃO PAULO');

-- (b) Atualização
UPDATE tb_vendas_agro
   SET estado = CASE estado
                   WHEN 'PARANA'    THEN 'PR'
                   WHEN 'SÃO PAULO' THEN 'SP'
                END
 WHERE estado IN ('PARANA', 'SÃO PAULO');

-- (c) Verificação: estados existentes na base.
SELECT estado, COUNT(*) AS qtd_registros
  FROM tb_vendas_agro
 GROUP BY estado
 ORDER BY estado;


-- ---------------------------------------------------------------------
-- P1-Q07. Padronização das categorias
--   Graos -> Grãos ; Racao -> Rações
-- Esperado: 2 registros atualizados (IDs 70 e 71).
-- ---------------------------------------------------------------------

-- (a) Conferência
SELECT id, produto, categoria
  FROM tb_vendas_agro
 WHERE categoria IN ('Graos', 'Racao');

-- (b) Atualização
UPDATE tb_vendas_agro
   SET categoria = CASE categoria
                      WHEN 'Graos' THEN 'Grãos'
                      WHEN 'Racao' THEN 'Rações'
                   END
 WHERE categoria IN ('Graos', 'Racao');

-- (c) Verificação: categorias existentes na base.
SELECT categoria, COUNT(*) AS qtd_registros
  FROM tb_vendas_agro
 GROUP BY categoria
 ORDER BY categoria;


-- ---------------------------------------------------------------------
-- P1-Q08. Exclusão de datas incompatíveis
-- Data limite do período operacional: 2025-12-31.
-- Esperado: 4 registros excluídos (IDs 72, 73, 74 e 75).
-- ---------------------------------------------------------------------

-- (a) Conferência
SELECT id, produto, data_venda
  FROM tb_vendas_agro
 WHERE data_venda > '2025-12-31';

-- (b) Exclusão
DELETE FROM tb_vendas_agro
 WHERE data_venda > '2025-12-31';

-- (c) Verificação: nenhuma data após o limite (esperado: 0).
SELECT COUNT(*) AS datas_apos_limite
  FROM tb_vendas_agro
 WHERE data_venda > '2025-12-31';


-- ---------------------------------------------------------------------
-- P1-Q09. Exclusão de registros de teste
-- Os registros de teste (IDs 74 e 75) já foram excluídos na Q08 por terem
-- datas inválidas. O comando é apresentado conforme solicitado e deve
-- afetar 0 linhas.
-- ---------------------------------------------------------------------

-- (a) Conferência (esperado: nenhum registro)
SELECT id, produto, categoria, fornecedor
  FROM tb_vendas_agro
 WHERE produto    IN ('XXXXX', 'TESTE PRODUTO')
    OR categoria  IN ('ERRO', 'TESTE')
    OR fornecedor IN ('DESCONHECIDO', 'TESTE');

-- (b) Exclusão
DELETE FROM tb_vendas_agro
 WHERE produto    IN ('XXXXX', 'TESTE PRODUTO')
    OR categoria  IN ('ERRO', 'TESTE')
    OR fornecedor IN ('DESCONHECIDO', 'TESTE');

-- (c) Verificação
SELECT COUNT(*) AS registros_de_teste_restantes
  FROM tb_vendas_agro
 WHERE produto    IN ('XXXXX', 'TESTE PRODUTO')
    OR categoria  IN ('ERRO', 'TESTE')
    OR fornecedor IN ('DESCONHECIDO', 'TESTE');


-- ---------------------------------------------------------------------
-- P1-Q10. Bloqueio comercial de defensivos
-- Categoria Defensivos com valor_unitario > 800,00 -> estoque = false.
-- Esperado: 6 registros no filtro (IDs 25, 30, 44, 49, 63 e 69); o ID 25
-- já estava indisponível, então 5 registros mudam de fato.
-- ---------------------------------------------------------------------

-- (a) Conferência
SELECT id, produto, categoria, valor_unitario, estoque
  FROM tb_vendas_agro
 WHERE categoria = 'Defensivos'
   AND valor_unitario > 800;

-- (b) Atualização
UPDATE tb_vendas_agro
   SET estoque = false
 WHERE categoria = 'Defensivos'
   AND valor_unitario > 800;

-- (c) Verificação: situação de todos os defensivos.
SELECT id, produto, valor_unitario, estoque
  FROM tb_vendas_agro
 WHERE categoria = 'Defensivos'
 ORDER BY valor_unitario DESC;

-- Resumo final da limpeza: quantidade de registros DEPOIS (esperado: 68).
SELECT COUNT(*) AS total_registros_apos_limpeza FROM tb_vendas_agro;


-- =====================================================================
-- PARTE 2 — RELATÓRIO GERENCIAL DA AGROTECH SOLUTIONS
-- (base tratada: 68 registros)
-- =====================================================================

-- ---------------------------------------------------------------------
-- P2-Q01. Produtos disponíveis (registros com estoque = true)
-- ---------------------------------------------------------------------
SELECT COUNT(*) AS qtd_registros_disponiveis
  FROM tb_vendas_agro
 WHERE estoque = true;


-- ---------------------------------------------------------------------
-- P2-Q02. Participação dos fornecedores (quantidade de registros)
-- ---------------------------------------------------------------------
SELECT fornecedor,
       COUNT(*) AS qtd_registros
  FROM tb_vendas_agro
 GROUP BY fornecedor
 ORDER BY qtd_registros DESC, fornecedor;


-- ---------------------------------------------------------------------
-- P2-Q03. Os 10 registros de maior valor unitário
-- ---------------------------------------------------------------------
SELECT produto,
       categoria,
       valor_unitario,
       estado
  FROM tb_vendas_agro
 ORDER BY valor_unitario DESC, id
 LIMIT 10;


-- ---------------------------------------------------------------------
-- P2-Q04. Valor unitário médio por categoria (2 casas decimais)
-- ---------------------------------------------------------------------
SELECT categoria,
       ROUND(AVG(valor_unitario), 2) AS valor_unitario_medio
  FROM tb_vendas_agro
 GROUP BY categoria
 ORDER BY valor_unitario_medio DESC;


-- ---------------------------------------------------------------------
-- P2-Q05. Distribuição por estado (quantidade de registros)
-- ---------------------------------------------------------------------
SELECT estado,
       COUNT(*) AS qtd_registros
  FROM tb_vendas_agro
 GROUP BY estado
 ORDER BY qtd_registros DESC, estado;


-- ---------------------------------------------------------------------
-- P2-Q06. Sementes e Grãos disponíveis em estoque
-- ---------------------------------------------------------------------
SELECT produto,
       categoria,
       quantidade,
       valor_unitario,
       estado
  FROM tb_vendas_agro
 WHERE categoria IN ('Sementes', 'Grãos')
   AND estoque = true
 ORDER BY categoria, produto;


-- ---------------------------------------------------------------------
-- P2-Q07. Registros com quantidade superior a 200 unidades
-- ---------------------------------------------------------------------
SELECT produto,
       quantidade,
       estado
  FROM tb_vendas_agro
 WHERE quantidade > 200
 ORDER BY quantidade DESC, produto;


-- ---------------------------------------------------------------------
-- P2-Q08. Valor potencial do estoque disponível
-- Valor potencial = quantidade × valor_unitario, somente estoque = true.
-- ---------------------------------------------------------------------
SELECT ROUND(SUM(quantidade * valor_unitario), 2) AS valor_potencial_estoque_disponivel
  FROM tb_vendas_agro
 WHERE estoque = true;


-- ---------------------------------------------------------------------
-- P2-Q09. Produtos indisponíveis por categoria (estoque = false)
-- ---------------------------------------------------------------------
SELECT categoria,
       COUNT(*) AS qtd_registros_indisponiveis
  FROM tb_vendas_agro
 WHERE estoque = false
 GROUP BY categoria
HAVING COUNT(*) >= 1
 ORDER BY qtd_registros_indisponiveis DESC, categoria;


-- ---------------------------------------------------------------------
-- P2-Q10. Vendas entre 01/03/2025 e 31/05/2025 (datas inclusas)
-- ---------------------------------------------------------------------
SELECT produto,
       categoria,
       data_venda,
       valor_unitario,
       estado
  FROM tb_vendas_agro
 WHERE data_venda BETWEEN '2025-03-01' AND '2025-05-31'
 ORDER BY data_venda ASC, id;


-- =====================================================================
-- PARTE 3 — KPIs DA AGROTECH SOLUTIONS
-- Todos os KPIs usam a tabela tb_vendas_agro após a Parte 1.
-- Divisões usam NULLIF(denominador, 0): se o denominador for zero, o
-- resultado é NULL em vez de erro, e COALESCE exibe 0.00.
-- Valores monetários (R$) e percentuais com 2 casas decimais.
-- =====================================================================

-- ---------------------------------------------------------------------
-- KPI 01 — Taxa de Disponibilidade Comercial (%)
-- Tema: Disponibilidade
-- Objetivo: medir a parcela dos registros cadastrados que está liberada
--   para comercialização (estoque = true).
-- Regra de cálculo:
--   numerador   = COUNT(*) dos registros com estoque = true
--   denominador = COUNT(*) de todos os registros
--   KPI = numerador / denominador × 100
-- Base: todos os registros (68).
-- ---------------------------------------------------------------------
SELECT SUM(estoque = true)  AS registros_disponiveis,
       SUM(estoque = false) AS registros_indisponiveis,
       COUNT(*)             AS total_registros,
       COALESCE(ROUND(SUM(estoque = true) * 100.0 / NULLIF(COUNT(*), 0), 2), 0)
                            AS taxa_disponibilidade_pct
  FROM tb_vendas_agro;


-- ---------------------------------------------------------------------
-- KPI 02 — Valor Potencial Bloqueado (R$ e %)
-- Tema: Disponibilidade / Valor financeiro do estoque
-- Objetivo: medir quanto do valor potencial do estoque está "parado" em
--   registros indisponíveis (estoque = false) e não pode ser ofertado.
-- Regra de cálculo:
--   valor potencial do registro = quantidade × valor_unitario
--   numerador   = SUM(valor potencial) dos registros com estoque = false
--   denominador = SUM(valor potencial) de todos os registros
--   KPI = numerador / denominador × 100
-- Base: todos os registros. Unidade: R$ e %.
-- ---------------------------------------------------------------------
SELECT ROUND(SUM(CASE WHEN estoque = false THEN quantidade * valor_unitario ELSE 0 END), 2)
                                   AS valor_potencial_bloqueado_rs,
       ROUND(SUM(quantidade * valor_unitario), 2)
                                   AS valor_potencial_total_rs,
       COALESCE(ROUND(SUM(CASE WHEN estoque = false THEN quantidade * valor_unitario ELSE 0 END) * 100.0
                      / NULLIF(SUM(quantidade * valor_unitario), 0), 2), 0)
                                   AS pct_valor_potencial_bloqueado
  FROM tb_vendas_agro;

-- KPI 02 (detalhe): composição do valor potencial bloqueado por categoria.
--   pct_do_bloqueado = valor bloqueado da categoria / valor bloqueado total × 100
SELECT categoria,
       COUNT(*)                                   AS registros_indisponiveis,
       ROUND(SUM(quantidade * valor_unitario), 2) AS valor_potencial_bloqueado_rs,
       COALESCE(ROUND(SUM(quantidade * valor_unitario) * 100.0
                      / NULLIF((SELECT SUM(quantidade * valor_unitario)
                                  FROM tb_vendas_agro
                                 WHERE estoque = false), 0), 2), 0)
                                                  AS pct_do_bloqueado
  FROM tb_vendas_agro
 WHERE estoque = false
 GROUP BY categoria
 ORDER BY valor_potencial_bloqueado_rs DESC;


-- ---------------------------------------------------------------------
-- KPI 03 — Distribuição de Unidades por Estado (%)
-- Tema: Estoque e logística / Categorias e estados (comparação entre estados)
-- Objetivo: mostrar onde estão armazenadas as unidades, para orientar a
--   logística e a alocação de armazéns.
-- Regra de cálculo:
--   numerador   = SUM(quantidade) do estado
--   denominador = SUM(quantidade) de todos os registros (subquery)
--   KPI = numerador / denominador × 100
-- Base: todos os registros (unidades físicas, disponíveis ou não).
-- ---------------------------------------------------------------------
SELECT estado,
       COUNT(*)        AS qtd_registros,
       SUM(quantidade) AS unidades,
       COALESCE(ROUND(SUM(quantidade) * 100.0
                      / NULLIF((SELECT SUM(quantidade) FROM tb_vendas_agro), 0), 2), 0)
                       AS pct_unidades
  FROM tb_vendas_agro
 GROUP BY estado
 ORDER BY unidades DESC;


-- ---------------------------------------------------------------------
-- KPI 04 — Volume Médio por Registro, por Categoria (unidades/registro)
-- Tema: Estoque e logística / Categorias (comparação entre categorias)
-- Objetivo: identificar quais categorias concentram grandes volumes por
--   registro (itens de granel) e quais trabalham com lotes pequenos,
--   comparando cada uma com a média geral da empresa.
-- Regra de cálculo:
--   media_categoria = SUM(quantidade) / COUNT(*) da categoria
--   media_geral     = SUM(quantidade) / COUNT(*) de toda a base (subquery)
--   indice_vs_media = media_categoria / media_geral × 100
--   (100 = igual à média; acima de 100 = acima da média)
-- Base: todos os registros. Unidade: unidades por registro.
-- ---------------------------------------------------------------------
SELECT categoria,
       COUNT(*)                                        AS qtd_registros,
       SUM(quantidade)                                 AS unidades,
       ROUND(SUM(quantidade) / NULLIF(COUNT(*), 0), 2) AS media_unidades_por_registro,
       (SELECT ROUND(SUM(quantidade) / NULLIF(COUNT(*), 0), 2)
          FROM tb_vendas_agro)                         AS media_geral,
       COALESCE(ROUND((SUM(quantidade) / NULLIF(COUNT(*), 0)) * 100.0
                      / NULLIF((SELECT SUM(quantidade) / NULLIF(COUNT(*), 0)
                                  FROM tb_vendas_agro), 0), 2), 0)
                                                       AS indice_vs_media_geral_pct
  FROM tb_vendas_agro
 GROUP BY categoria
 ORDER BY media_unidades_por_registro DESC;


-- ---------------------------------------------------------------------
-- KPI 05 — Valor Potencial do Estoque Disponível (R$)
-- Tema: Valor financeiro do estoque
-- Objetivo: estimar o valor, a preço de cadastro, das unidades que podem
--   ser comercializadas agora. Não representa faturamento nem lucro.
-- Regra de cálculo:
--   KPI = SUM(quantidade × valor_unitario) WHERE estoque = true
-- Base: apenas registros disponíveis. Unidade: R$.
-- ---------------------------------------------------------------------
SELECT COUNT(*)                                  AS registros_disponiveis,
       SUM(quantidade)                           AS unidades_disponiveis,
       ROUND(SUM(quantidade * valor_unitario), 2) AS valor_potencial_disponivel_rs
  FROM tb_vendas_agro
 WHERE estoque = true;


-- ---------------------------------------------------------------------
-- KPI 06 — Participação das Categorias no Valor Potencial Disponível (R$ e %)
-- Tema: Valor financeiro do estoque / Categorias (comparação entre categorias)
-- Objetivo: mostrar quais categorias sustentam o valor potencial que
--   pode ser comercializado, apontando dependência de poucos segmentos.
-- Regra de cálculo:
--   numerador   = SUM(quantidade × valor_unitario) da categoria, estoque = true
--   denominador = SUM(quantidade × valor_unitario) total, estoque = true (subquery)
--   KPI = numerador / denominador × 100
-- Base: apenas registros disponíveis.
-- ---------------------------------------------------------------------
SELECT categoria,
       ROUND(SUM(quantidade * valor_unitario), 2) AS valor_potencial_disponivel_rs,
       COALESCE(ROUND(SUM(quantidade * valor_unitario) * 100.0
                      / NULLIF((SELECT SUM(quantidade * valor_unitario)
                                  FROM tb_vendas_agro
                                 WHERE estoque = true), 0), 2), 0)
                                                  AS pct_do_valor_disponivel
  FROM tb_vendas_agro
 WHERE estoque = true
 GROUP BY categoria
 ORDER BY valor_potencial_disponivel_rs DESC;


-- ---------------------------------------------------------------------
-- KPI 07 — Participação dos Fornecedores: Cadastro × Valor Disponível (%)
-- Tema: Fornecedores (comparação entre fornecedores)
-- Objetivo: comparar o peso de cada fornecedor na quantidade de registros
--   com o peso no valor potencial disponível, revelando dependência
--   financeira que a simples contagem de registros esconde.
-- Regra de cálculo:
--   pct_registros:
--     numerador   = COUNT(*) dos registros do fornecedor
--     denominador = COUNT(*) de todos os registros (subquery)
--   pct_valor_potencial_disponivel:
--     numerador   = SUM(quantidade × valor_unitario) do fornecedor, estoque = true
--     denominador = SUM(quantidade × valor_unitario) total, estoque = true (subquery)
--   KPI = numerador / denominador × 100 (nos dois casos)
-- Base: todos os registros (pct_registros) e apenas disponíveis (pct_valor).
-- ---------------------------------------------------------------------
SELECT fornecedor,
       COUNT(*) AS qtd_registros,
       COALESCE(ROUND(COUNT(*) * 100.0
                      / NULLIF((SELECT COUNT(*) FROM tb_vendas_agro), 0), 2), 0)
                AS pct_registros,
       ROUND(SUM(CASE WHEN estoque = true THEN quantidade * valor_unitario ELSE 0 END), 2)
                AS valor_potencial_disponivel_rs,
       COALESCE(ROUND(SUM(CASE WHEN estoque = true THEN quantidade * valor_unitario ELSE 0 END) * 100.0
                      / NULLIF((SELECT SUM(quantidade * valor_unitario)
                                  FROM tb_vendas_agro
                                 WHERE estoque = true), 0), 2), 0)
                AS pct_valor_potencial_disponivel
  FROM tb_vendas_agro
 GROUP BY fornecedor
 ORDER BY qtd_registros DESC, fornecedor;


-- ---------------------------------------------------------------------
-- KPI 08 — Preço Médio Ponderado por Unidade, por Categoria (R$/unidade)
-- Tema: Valor financeiro do estoque / Categorias (comparação entre categorias)
-- Objetivo: mostrar quanto vale, em média, cada unidade armazenada de
--   cada categoria. Diferente da média simples (P2-Q04), pondera pela
--   quantidade: registros com mais unidades pesam mais.
-- Regra de cálculo:
--   KPI = SUM(quantidade × valor_unitario) / SUM(quantidade), por categoria
-- Base: todos os registros. Unidade: R$ por unidade.
-- ---------------------------------------------------------------------
SELECT categoria,
       SUM(quantidade)                            AS unidades,
       ROUND(SUM(quantidade * valor_unitario), 2) AS valor_potencial_total_rs,
       COALESCE(ROUND(SUM(quantidade * valor_unitario) / NULLIF(SUM(quantidade), 0), 2), 0)
                                                  AS preco_medio_ponderado_rs
  FROM tb_vendas_agro
 GROUP BY categoria
 ORDER BY preco_medio_ponderado_rs DESC;


-- ---------------------------------------------------------------------
-- KPI 09 — Índice de Concentração de Fornecedores (HHI)
-- Tema: Fornecedores (concentração)
-- Objetivo: resumir em um único número o quanto a base depende de
--   poucos fornecedores.
-- Regra de cálculo:
--   participação_f = registros do fornecedor / total de registros × 100
--   HHI = SUM(participação_f ²)  -> varia de 0 a 10.000
--   Faixas de referência (critério do Índice Herfindahl-Hirschman usado
--   em análise de concentração de mercado): < 1.500 baixa;
--   1.500 a 2.500 moderada; > 2.500 alta.
--   Referência de equilíbrio: com N fornecedores iguais, HHI = 10.000 / N.
-- Base: todos os registros. Usa subquery na tabela derivada e no total.
-- ---------------------------------------------------------------------
SELECT COUNT(*)                                 AS qtd_fornecedores,
       ROUND(SUM(POWER(participacao_pct, 2)), 2) AS hhi_fornecedores,
       ROUND(10000 / NULLIF(COUNT(*), 0), 2)    AS hhi_se_distribuicao_igual,
       ROUND(MAX(participacao_pct), 2)          AS maior_participacao_pct
  FROM (SELECT fornecedor,
               COUNT(*) * 100.0
               / NULLIF((SELECT COUNT(*) FROM tb_vendas_agro), 0) AS participacao_pct
          FROM tb_vendas_agro
         GROUP BY fornecedor) AS part;


-- ---------------------------------------------------------------------
-- KPI 10 — Registros com Volume Baixo na Categoria (%)
-- Tema: Estoque e logística
-- Objetivo: sinalizar registros disponíveis com poucas unidades em
--   relação ao padrão da própria categoria (candidatos a reposição).
-- Critério de "volume baixo" (sugestão do grupo, não fornecida pela
--   empresa): quantidade inferior a 50% da média de unidades por
--   registro da mesma categoria, calculada sobre todos os registros da
--   categoria (subquery correlacionada).
-- Regra de cálculo:
--   numerador   = registros disponíveis com quantidade < 0,5 × média da categoria
--   denominador = registros disponíveis
--   KPI = numerador / denominador × 100
-- Base: apenas registros disponíveis (estoque = true).
-- ---------------------------------------------------------------------
SELECT SUM(volume_baixo) AS registros_volume_baixo,
       COUNT(*)          AS registros_disponiveis,
       COALESCE(ROUND(SUM(volume_baixo) * 100.0 / NULLIF(COUNT(*), 0), 2), 0)
                         AS pct_registros_volume_baixo
  FROM (SELECT t.id,
               CASE WHEN t.quantidade < 0.5 * (SELECT AVG(c.quantidade)
                                                 FROM tb_vendas_agro c
                                                WHERE c.categoria = t.categoria)
                    THEN 1 ELSE 0 END AS volume_baixo
          FROM tb_vendas_agro t
         WHERE t.estoque = true) AS disp;

-- KPI 10 (detalhe): quais registros estão abaixo do critério.
SELECT t.id, t.produto, t.categoria, t.estado, t.quantidade,
       ROUND((SELECT AVG(c.quantidade) FROM tb_vendas_agro c
               WHERE c.categoria = t.categoria), 2) AS media_categoria
  FROM tb_vendas_agro t
 WHERE t.estoque = true
   AND t.quantidade < 0.5 * (SELECT AVG(c.quantidade)
                               FROM tb_vendas_agro c
                              WHERE c.categoria = t.categoria)
 ORDER BY t.categoria, t.quantidade;

-- =====================================================================
-- FIM DO SCRIPT
-- =====================================================================
