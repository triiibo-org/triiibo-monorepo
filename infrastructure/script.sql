-- DDL do projeto Triiibo (gerado a partir de docs/DATA_STRUCT_MAP.md)

SET NAMES utf8mb4;
SET time_zone = "+00:00";

--
-- Banco de dados: `triiibo`
--

DROP DATABASE IF EXISTS `triiibo`;
CREATE DATABASE IF NOT EXISTS `triiibo` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `triiibo`;

-- --------------------------------------------------------
-- F. Acesso e auditoria
-- --------------------------------------------------------

--
-- Estrutura para tabela `admin`
--

CREATE TABLE `admin` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `nome` VARCHAR(150) NOT NULL,
  `email` VARCHAR(255) NOT NULL,
  `senha_hash` VARCHAR(255) NOT NULL,
  `perfil` ENUM('admin','editor','leitor') NOT NULL DEFAULT 'editor',
  `ativo` TINYINT(1) NOT NULL DEFAULT 1,
  `ultimo_login_em` DATETIME DEFAULT NULL,
  `data_cadastro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `data_atualizacao` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_admin_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Estrutura para tabela `log_auditoria`
--

CREATE TABLE `log_auditoria` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `admin_id` CHAR(36) DEFAULT NULL,
  `acao` VARCHAR(50) NOT NULL,
  `entidade` VARCHAR(100) NOT NULL,
  `entidade_id` CHAR(36) NOT NULL COMMENT 'UUID (texto) do registro auditado',
  `dados_antes` JSON DEFAULT NULL,
  `dados_depois` JSON DEFAULT NULL,
  `ip` VARCHAR(45) DEFAULT NULL,
  `data_cadastro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_log_admin` (`admin_id`),
  KEY `idx_log_entidade` (`entidade`, `entidade_id`),
  CONSTRAINT `fk_log_admin` FOREIGN KEY (`admin_id`) REFERENCES `admin` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Log imutável: sem data_atualizacao';

-- --------------------------------------------------------
-- A. Pessoas e CRM (supertipo usuario)
-- --------------------------------------------------------

--
-- Estrutura para tabela `usuario`
--

CREATE TABLE `usuario` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `nome` VARCHAR(150) NOT NULL,
  `email` VARCHAR(255) NOT NULL,
  `telefone` VARCHAR(20) DEFAULT NULL,
  `data_cadastro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `data_atualizacao` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_usuario_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Estrutura para tabela `endereco`
--

CREATE TABLE `endereco` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `id_usuario` CHAR(36) NOT NULL,
  `cep` CHAR(8) NOT NULL,
  `logradouro` VARCHAR(255) NOT NULL,
  `numero` VARCHAR(20) DEFAULT NULL,
  `complemento` VARCHAR(100) DEFAULT NULL,
  `bairro` VARCHAR(100) NOT NULL,
  `cidade` VARCHAR(100) NOT NULL,
  `estado` CHAR(2) NOT NULL,
  `data_cadastro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `data_atualizacao` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_endereco_cep` (`cep`),
  KEY `idx_endereco_usuario` (`id_usuario`),
  CONSTRAINT `fk_endereco_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Estrutura para tabela `responsavel`
--

CREATE TABLE `responsavel` (
  `usuario_id` CHAR(36) NOT NULL,
  `cpf` CHAR(11) NOT NULL,
  `data_cadastro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `data_atualizacao` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`usuario_id`),
  UNIQUE KEY `uq_responsavel_cpf` (`cpf`),
  CONSTRAINT `fk_responsavel_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Estrutura para tabela `stakeholder`
--

CREATE TABLE `stakeholder` (
  `usuario_id` CHAR(36) NOT NULL,
  `data_cadastro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `data_atualizacao` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`usuario_id`),
  CONSTRAINT `fk_stakeholder_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Estrutura para tabela `stakeholder_pf`
--

CREATE TABLE `stakeholder_pf` (
  `stakeholder_id` CHAR(36) NOT NULL,
  `cpf` CHAR(11) NOT NULL COMMENT 'Redundância controlada do CPF',
  `data_cadastro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `data_atualizacao` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`stakeholder_id`),
  UNIQUE KEY `uq_stakeholder_pf_cpf` (`cpf`),
  CONSTRAINT `fk_stakeholder_pf_stakeholder` FOREIGN KEY (`stakeholder_id`) REFERENCES `stakeholder` (`usuario_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Estrutura para tabela `stakeholder_pj`
--

CREATE TABLE `stakeholder_pj` (
  `stakeholder_id` CHAR(36) NOT NULL,
  `cnpj` CHAR(14) NOT NULL,
  `razao_social` VARCHAR(255) NOT NULL,
  `data_cadastro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `data_atualizacao` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`stakeholder_id`),
  UNIQUE KEY `uq_stakeholder_pj_cnpj` (`cnpj`),
  CONSTRAINT `fk_stakeholder_pj_stakeholder` FOREIGN KEY (`stakeholder_id`) REFERENCES `stakeholder` (`usuario_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Estrutura para tabela `parceiro`
--

CREATE TABLE `parceiro` (
  `stakeholder_id` CHAR(36) NOT NULL,
  `nome_marca` VARCHAR(150) NOT NULL,
  `logotipo_url` VARCHAR(2048) DEFAULT NULL,
  `site_url` VARCHAR(2048) DEFAULT NULL,
  `ativo` TINYINT(1) NOT NULL DEFAULT 1,
  `data_cadastro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `data_atualizacao` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`stakeholder_id`),
  CONSTRAINT `fk_parceiro_stakeholder_pj` FOREIGN KEY (`stakeholder_id`) REFERENCES `stakeholder_pj` (`stakeholder_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Estrutura para tabela `participante`
--

CREATE TABLE `participante` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `nome` VARCHAR(150) NOT NULL,
  `data_nascimento` DATE NOT NULL,
  `data_cadastro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `data_atualizacao` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Estrutura para tabela `responsavel_participante`
--

CREATE TABLE `responsavel_participante` (
  `responsavel_id` CHAR(36) NOT NULL,
  `participante_id` CHAR(36) NOT NULL,
  `parentesco` VARCHAR(50) NOT NULL,
  `guardiao_legal` TINYINT(1) NOT NULL DEFAULT 0,
  `data_cadastro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `data_atualizacao` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`responsavel_id`, `participante_id`),
  KEY `idx_rp_participante` (`participante_id`),
  CONSTRAINT `fk_rp_responsavel` FOREIGN KEY (`responsavel_id`) REFERENCES `responsavel` (`usuario_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_rp_participante` FOREIGN KEY (`participante_id`) REFERENCES `participante` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Estrutura para tabela `restricao_alimentar`
--

CREATE TABLE `restricao_alimentar` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `nome` VARCHAR(100) NOT NULL,
  `data_cadastro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `data_atualizacao` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_restricao_nome` (`nome`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Estrutura para tabela `participante_restricao`
--

CREATE TABLE `participante_restricao` (
  `participante_id` CHAR(36) NOT NULL,
  `restricao_id` CHAR(36) NOT NULL,
  `observacao` VARCHAR(500) DEFAULT NULL,
  `data_cadastro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `data_atualizacao` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`participante_id`, `restricao_id`),
  KEY `idx_pr_restricao` (`restricao_id`),
  CONSTRAINT `fk_pr_participante` FOREIGN KEY (`participante_id`) REFERENCES `participante` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_pr_restricao` FOREIGN KEY (`restricao_id`) REFERENCES `restricao_alimentar` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- B. Edição e inscrição
-- --------------------------------------------------------

--
-- Estrutura para tabela `edicao`
--

CREATE TABLE `edicao` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `nome` VARCHAR(150) NOT NULL,
  `data_inicio` DATE NOT NULL,
  `data_fim` DATE NOT NULL,
  `vagas_totais` INT UNSIGNED NOT NULL,
  `valor` DECIMAL(10,2) NOT NULL,
  `status` ENUM('rascunho','inscricoes_abertas','inscricoes_encerradas','em_andamento','finalizada','cancelada') NOT NULL DEFAULT 'rascunho',
  `data_cadastro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `data_atualizacao` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `chk_edicao_datas` CHECK (`data_fim` >= `data_inicio`),
  CONSTRAINT `chk_edicao_valor` CHECK (`valor` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Estrutura para tabela `lead`
--

CREATE TABLE `lead` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `usuario_id` CHAR(36) NOT NULL,
  `edicao_id` CHAR(36) DEFAULT NULL,
  `origem` ENUM('instagram','google','indicacao','evento','outro') NOT NULL DEFAULT 'outro',
  `status_funil` ENUM('novo','contatado','qualificado','convertido','perdido') NOT NULL DEFAULT 'novo',
  `convertido_em` DATETIME DEFAULT NULL,
  `data_cadastro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `data_atualizacao` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_lead_usuario` (`usuario_id`),
  KEY `idx_lead_edicao` (`edicao_id`),
  CONSTRAINT `fk_lead_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_lead_edicao` FOREIGN KEY (`edicao_id`) REFERENCES `edicao` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Estrutura para tabela `inscricao`
--

CREATE TABLE `inscricao` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `participante_id` CHAR(36) NOT NULL,
  `edicao_id` CHAR(36) NOT NULL,
  `responsavel_id` CHAR(36) NOT NULL,
  `status` ENUM('pendente','confirmada','lista_espera','cancelada') NOT NULL DEFAULT 'pendente',
  `tipo_vaga` ENUM('pagante','bolsista','patrocinada') NOT NULL DEFAULT 'pagante',
  `etapa_atual` VARCHAR(50) DEFAULT NULL,
  `data_cadastro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `data_atualizacao` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_inscricao_participante_edicao` (`participante_id`, `edicao_id`),
  KEY `idx_inscricao_edicao` (`edicao_id`),
  KEY `idx_inscricao_status` (`status`),
  KEY `idx_inscricao_responsavel_participante` (`responsavel_id`, `participante_id`),
  CONSTRAINT `fk_inscricao_edicao` FOREIGN KEY (`edicao_id`) REFERENCES `edicao` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_inscricao_responsavel_participante` FOREIGN KEY (`responsavel_id`, `participante_id`) REFERENCES `responsavel_participante` (`responsavel_id`, `participante_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Estrutura para tabela `ficha_medica`
--

CREATE TABLE `ficha_medica` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `inscricao_id` CHAR(36) NOT NULL,
  `arquivo_url` VARCHAR(2048) NOT NULL,
  `validada_em` DATETIME DEFAULT NULL,
  `validada_por` CHAR(36) DEFAULT NULL,
  `data_cadastro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `data_atualizacao` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ficha_inscricao` (`inscricao_id`),
  KEY `idx_ficha_validada_por` (`validada_por`),
  CONSTRAINT `fk_ficha_inscricao` FOREIGN KEY (`inscricao_id`) REFERENCES `inscricao` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_ficha_validada_por` FOREIGN KEY (`validada_por`) REFERENCES `admin` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `chk_ficha_validacao` CHECK ((`validada_em` IS NULL AND `validada_por` IS NULL) OR (`validada_em` IS NOT NULL AND `validada_por` IS NOT NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Estrutura para tabela `parceria`
--

CREATE TABLE `parceria` (
  `parceiro_id` CHAR(36) NOT NULL,
  `edicao_id` CHAR(36) NOT NULL,
  `tipo_apoio` VARCHAR(100) NOT NULL,
  `exibir_na_landing` TINYINT(1) NOT NULL DEFAULT 1,
  `data_cadastro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `data_atualizacao` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`parceiro_id`, `edicao_id`),
  KEY `idx_parceria_edicao` (`edicao_id`),
  CONSTRAINT `fk_parceria_parceiro` FOREIGN KEY (`parceiro_id`) REFERENCES `parceiro` (`stakeholder_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_parceria_edicao` FOREIGN KEY (`edicao_id`) REFERENCES `edicao` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Estrutura para tabela `programacao`
--

CREATE TABLE `programacao` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `edicao_id` CHAR(36) NOT NULL,
  `dia` DATE NOT NULL,
  `hora_inicio` TIME NOT NULL,
  `titulo` VARCHAR(200) NOT NULL,
  `descricao` TEXT DEFAULT NULL,
  `data_cadastro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `data_atualizacao` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_programacao_edicao` (`edicao_id`, `dia`, `hora_inicio`),
  CONSTRAINT `fk_programacao_edicao` FOREIGN KEY (`edicao_id`) REFERENCES `edicao` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- C. Financeiro
-- --------------------------------------------------------

--
-- Estrutura para tabela `transacao`
--

CREATE TABLE `transacao` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `metodo` ENUM('pix','cartao_credito','cartao_debito','boleto') NOT NULL,
  `parcelas` TINYINT UNSIGNED NOT NULL DEFAULT 1,
  `valor` DECIMAL(10,2) NOT NULL,
  `status` ENUM('pendente','aprovada','recusada','estornada','cancelada') NOT NULL DEFAULT 'pendente',
  `gateway` VARCHAR(50) NOT NULL,
  `gateway_transacao_id` VARCHAR(100) DEFAULT NULL,
  `data_cadastro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `data_atualizacao` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_transacao_gateway_id` (`gateway_transacao_id`),
  CONSTRAINT `chk_transacao_parcelas` CHECK (`parcelas` >= 1),
  CONSTRAINT `chk_transacao_valor` CHECK (`valor` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Estrutura para tabela `pagamento_inscricao`
--

CREATE TABLE `pagamento_inscricao` (
  `transacao_id` CHAR(36) NOT NULL,
  `inscricao_id` CHAR(36) NOT NULL,
  `data_cadastro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `data_atualizacao` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`transacao_id`),
  KEY `idx_pagamento_inscricao` (`inscricao_id`),
  CONSTRAINT `fk_pagamento_transacao` FOREIGN KEY (`transacao_id`) REFERENCES `transacao` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_pagamento_inscricao` FOREIGN KEY (`inscricao_id`) REFERENCES `inscricao` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Estrutura para tabela `doacao`
--

CREATE TABLE `doacao` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `stakeholder_id` CHAR(36) NOT NULL,
  `transacao_id` CHAR(36) NOT NULL,
  `edicao_id` CHAR(36) DEFAULT NULL,
  `anonima` TINYINT(1) NOT NULL DEFAULT 0,
  `comprovante_arquivo_url` VARCHAR(2048) DEFAULT NULL,
  `data_cadastro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `data_atualizacao` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_doacao_transacao` (`transacao_id`),
  KEY `idx_doacao_stakeholder` (`stakeholder_id`),
  KEY `idx_doacao_edicao` (`edicao_id`),
  CONSTRAINT `fk_doacao_stakeholder` FOREIGN KEY (`stakeholder_id`) REFERENCES `stakeholder` (`usuario_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_doacao_transacao` FOREIGN KEY (`transacao_id`) REFERENCES `transacao` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_doacao_edicao` FOREIGN KEY (`edicao_id`) REFERENCES `edicao` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Estrutura para tabela `gateway_evento`
--

CREATE TABLE `gateway_evento` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `transacao_id` CHAR(36) NOT NULL,
  `evento_externo_id` VARCHAR(100) NOT NULL,
  `tipo` ENUM('criada','aprovada','recusada','estornada','cancelada','atualizada') NOT NULL,
  `payload` JSON NOT NULL,
  `processado_em` DATETIME DEFAULT NULL,
  `data_cadastro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `data_atualizacao` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_gateway_evento_externo` (`evento_externo_id`),
  KEY `idx_gateway_evento_transacao` (`transacao_id`),
  CONSTRAINT `fk_gateway_evento_transacao` FOREIGN KEY (`transacao_id`) REFERENCES `transacao` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- D. Comunicação e LGPD
-- --------------------------------------------------------

--
-- Estrutura para tabela `template_contato`
--

CREATE TABLE `template_contato` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `tipo` ENUM('email','whatsapp','sms') NOT NULL DEFAULT 'email',
  `assunto` VARCHAR(255) NOT NULL,
  `corpo` TEXT NOT NULL,
  `ativo` TINYINT(1) NOT NULL DEFAULT 1,
  `data_cadastro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `data_atualizacao` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Estrutura para tabela `campanha`
-- (agrupa um disparo em lote de e-mails)
--

CREATE TABLE `campanha` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `nome` VARCHAR(150) NOT NULL,
  `template_id` CHAR(36) NOT NULL,
  `criada_por` CHAR(36) DEFAULT NULL,
  `data_cadastro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `data_atualizacao` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_campanha_template` (`template_id`),
  KEY `idx_campanha_criada_por` (`criada_por`),
  CONSTRAINT `fk_campanha_template` FOREIGN KEY (`template_id`) REFERENCES `template_contato` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_campanha_admin` FOREIGN KEY (`criada_por`) REFERENCES `admin` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Estrutura para tabela `comunicacao`
--

CREATE TABLE `comunicacao` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `usuario_id` CHAR(36) NOT NULL,
  `template_id` CHAR(36) DEFAULT NULL,
  `campanha_id` CHAR(36) DEFAULT NULL,
  `inscricao_id` CHAR(36) DEFAULT NULL,
  `canal` ENUM('email','whatsapp','sms') NOT NULL DEFAULT 'email',
  `assunto` VARCHAR(255) NOT NULL,
  `corpo` TEXT NOT NULL,
  `status` ENUM('pendente','enviada','falhou') NOT NULL DEFAULT 'pendente',
  `erro` VARCHAR(500) DEFAULT NULL,
  `data_cadastro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `data_atualizacao` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_comunicacao_contato` (`usuario_id`),
  KEY `idx_comunicacao_template` (`template_id`),
  KEY `idx_comunicacao_campanha` (`campanha_id`),
  KEY `idx_comunicacao_inscricao` (`inscricao_id`),
  CONSTRAINT `fk_comunicacao_contato` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_comunicacao_template` FOREIGN KEY (`template_id`) REFERENCES `template_contato` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_comunicacao_campanha` FOREIGN KEY (`campanha_id`) REFERENCES `campanha` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_comunicacao_inscricao` FOREIGN KEY (`inscricao_id`) REFERENCES `inscricao` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Estrutura para tabela `mensagem_contato`
--

CREATE TABLE `mensagem_contato` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `usuario_id` CHAR(36) NOT NULL,
  `assunto` VARCHAR(255) NOT NULL,
  `mensagem` TEXT NOT NULL,
  `status` ENUM('nova','lida','respondida','arquivada') NOT NULL DEFAULT 'nova',
  `data_cadastro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `data_atualizacao` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_mensagem_contato` (`usuario_id`),
  CONSTRAINT `fk_mensagem_contato` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Estrutura para tabela `consentimento` (LGPD)
--

CREATE TABLE `consentimento` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `usuario_id` CHAR(36) NOT NULL,
  `finalidade` VARCHAR(150) NOT NULL,
  `versao_termo` VARCHAR(20) NOT NULL,
  `aceito` TINYINT(1) NOT NULL,
  `registrado_em` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ip` VARCHAR(45) DEFAULT NULL,
  `data_cadastro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `data_atualizacao` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_consentimento_contato` (`usuario_id`),
  CONSTRAINT `fk_consentimento_contato` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- E. Conteúdo editável da landing
-- --------------------------------------------------------

--
-- Estrutura para tabela `secao`
--

CREATE TABLE `secao` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `slug` VARCHAR(100) NOT NULL,
  `nome` VARCHAR(150) NOT NULL,
  `data_cadastro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `data_atualizacao` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_secao_slug` (`slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Estrutura para tabela `conteudo_texto`
--

CREATE TABLE `conteudo_texto` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `chave` VARCHAR(150) NOT NULL COMMENT 'ex: hero.titulo',
  `secao_id` CHAR(36) NOT NULL,
  `valor` TEXT NOT NULL,
  `atualizado_por` CHAR(36) DEFAULT NULL,
  `data_cadastro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `data_atualizacao` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_conteudo_chave` (`chave`),
  KEY `idx_conteudo_secao` (`secao_id`),
  KEY `idx_conteudo_atualizado_por` (`atualizado_por`),
  CONSTRAINT `fk_conteudo_secao` FOREIGN KEY (`secao_id`) REFERENCES `secao` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_conteudo_admin` FOREIGN KEY (`atualizado_por`) REFERENCES `admin` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Estrutura para tabela `midia`
--

CREATE TABLE `midia` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `secao_id` CHAR(36) NOT NULL,
  `edicao_id` CHAR(36) DEFAULT NULL,
  `url_externa` VARCHAR(2048) NOT NULL,
  `tipo` ENUM('imagem','video') NOT NULL DEFAULT 'imagem',
  `legenda` VARCHAR(255) DEFAULT NULL,
  `ordem` INT NOT NULL DEFAULT 0 COMMENT 'Posição em que o item aparece na tela',
  `ativo` TINYINT(1) NOT NULL DEFAULT 1,
  `data_cadastro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `data_atualizacao` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_midia_secao` (`secao_id`),
  KEY `idx_midia_edicao` (`edicao_id`),
  CONSTRAINT `fk_midia_secao` FOREIGN KEY (`secao_id`) REFERENCES `secao` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_midia_edicao` FOREIGN KEY (`edicao_id`) REFERENCES `edicao` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Estrutura para tabela `faq`
--

CREATE TABLE `faq` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `pergunta` VARCHAR(500) NOT NULL,
  `resposta` TEXT NOT NULL,
  `ordem` INT NOT NULL DEFAULT 0 COMMENT 'Posição em que o item aparece na tela',
  `ativo` TINYINT(1) NOT NULL DEFAULT 1,
  `data_cadastro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `data_atualizacao` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Estrutura para tabela `rede_social`
--

CREATE TABLE `rede_social` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `nome` VARCHAR(100) NOT NULL,
  `url` VARCHAR(2048) NOT NULL,
  `ordem` INT NOT NULL DEFAULT 0 COMMENT 'Posição em que o item aparece na tela',
  `ativo` TINYINT(1) NOT NULL DEFAULT 1,
  `data_cadastro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `data_atualizacao` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- Triggers: faixa etária do participante (13 a 17 anos)
-- Idade calculada na data de início da edição.
-- --------------------------------------------------------

DELIMITER $$

CREATE TRIGGER `trg_inscricao_idade_bi` BEFORE INSERT ON `inscricao` FOR EACH ROW
BEGIN
  DECLARE v_idade INT;
  SELECT TIMESTAMPDIFF(YEAR, p.`data_nascimento`, e.`data_inicio`) INTO v_idade
    FROM `participante` p, `edicao` e
   WHERE p.`id` = NEW.`participante_id` AND e.`id` = NEW.`edicao_id`;
  IF v_idade IS NULL OR v_idade < 13 OR v_idade > 17 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Participante deve ter entre 13 e 17 anos na data de início da edição';
  END IF;
END$$

CREATE TRIGGER `trg_inscricao_idade_bu` BEFORE UPDATE ON `inscricao` FOR EACH ROW
BEGIN
  DECLARE v_idade INT;
  IF NEW.`participante_id` <> OLD.`participante_id` OR NEW.`edicao_id` <> OLD.`edicao_id` THEN
    SELECT TIMESTAMPDIFF(YEAR, p.`data_nascimento`, e.`data_inicio`) INTO v_idade
      FROM `participante` p, `edicao` e
     WHERE p.`id` = NEW.`participante_id` AND e.`id` = NEW.`edicao_id`;
    IF v_idade IS NULL OR v_idade < 13 OR v_idade > 17 THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Participante deve ter entre 13 e 17 anos na data de início da edição';
    END IF;
  END IF;
END$$

DELIMITER ;

START TRANSACTION;

-- --------------------------------------------------------
-- F. Acesso e auditoria
-- --------------------------------------------------------

--
-- Dados para a tabela `admin`
--
INSERT INTO `admin` (`id`, `nome`, `email`, `senha_hash`, `perfil`, `ativo`, `ultimo_login_em`) VALUES
('a1000000-0000-4000-8000-000000000001', 'Marina Campos', 'marina.campos@example.com', '$2b$12$ExemploHashFicticioExemploHashFicticioExemploHashFict', 'admin', 1, '2026-11-25 09:14:00'),
('a1000000-0000-4000-8000-000000000002', 'Thiago Ribeiro', 'thiago.ribeiro@example.com', '$2b$12$ExemploHashFicticioExemploHashFicticioExemploHashFict', 'editor', 1, '2026-11-26 17:42:10'),
('a1000000-0000-4000-8000-000000000003', 'Letícia Prado', 'leticia.prado@example.com', '$2b$12$ExemploHashFicticioExemploHashFicticioExemploHashFict', 'editor', 1, '2026-11-24 08:55:31'),
('a1000000-0000-4000-8000-000000000004', 'Daniel Moreira', 'daniel.moreira@example.com', '$2b$12$ExemploHashFicticioExemploHashFicticioExemploHashFict', 'leitor', 1, '2026-11-20 14:03:00'),
('a1000000-0000-4000-8000-000000000005', 'Carolina Azevedo', 'carolina.azevedo@example.com', '$2b$12$ExemploHashFicticioExemploHashFicticioExemploHashFict', 'leitor', 0, '2026-03-10 10:00:00');

--
-- Dados para a tabela `log_auditoria`
--
INSERT INTO `log_auditoria` (`id`, `admin_id`, `acao`, `entidade`, `entidade_id`, `dados_antes`, `dados_depois`, `ip`) VALUES
('a2000000-0000-4000-8000-000000000001', 'a1000000-0000-4000-8000-000000000001', 'CRIAR', 'edicao', 'd1000000-0000-4000-8000-000000000006', NULL, '{"nome": "Acampamento Jovem 2027", "status": "rascunho"}', '189.40.12.10'),
('a2000000-0000-4000-8000-000000000002', 'a1000000-0000-4000-8000-000000000001', 'ATUALIZAR', 'edicao', 'd1000000-0000-4000-8000-000000000006', '{"status": "rascunho"}', '{"status": "inscricoes_abertas"}', '189.40.12.10'),
('a2000000-0000-4000-8000-000000000003', 'a1000000-0000-4000-8000-000000000002', 'ATUALIZAR', 'conteudo_texto', '92000000-0000-4000-8000-000000000001', '{"valor": "Bem-vindo"}', '{"valor": "Viva uma semana que transforma"}', '177.12.88.45'),
('a2000000-0000-4000-8000-000000000004', 'a1000000-0000-4000-8000-000000000003', 'VALIDAR', 'ficha_medica', 'd4000000-0000-4000-8000-000000000001', '{"validada_em": null}', '{"validada_em": "2026-06-20 14:30:00"}', '201.17.5.99'),
('a2000000-0000-4000-8000-000000000005', 'a1000000-0000-4000-8000-000000000002', 'EXCLUIR', 'faq', '94000000-0000-4000-8000-000000000099', '{"pergunta": "Pergunta obsoleta", "ativo": 1}', NULL, '177.12.88.45'),
('a2000000-0000-4000-8000-000000000006', 'a1000000-0000-4000-8000-000000000002', 'LOGIN', 'admin', 'a1000000-0000-4000-8000-000000000002', NULL, NULL, '177.12.88.45');

-- --------------------------------------------------------
-- A. Pessoas e CRM
-- --------------------------------------------------------

--
-- Dados para a tabela `usuario`
--
INSERT INTO `usuario` (`id`, `nome`, `email`, `telefone`) VALUES
('b2000000-0000-4000-8000-000000000001', 'Ana Paula Almeida', 'ana.almeida@example.com', '(19) 99101-0001'),
('b2000000-0000-4000-8000-000000000002', 'Carlos Eduardo Costa', 'carlos.costa@example.com', '(19) 99101-0002'),
('b2000000-0000-4000-8000-000000000003', 'Helena Souza', 'helena.souza@example.com', '(19) 99101-0003'),
('b2000000-0000-4000-8000-000000000004', 'Juliana Ferreira', 'juliana.ferreira@example.com', '(11) 99101-0004'),
('b2000000-0000-4000-8000-000000000005', 'Roberto Oliveira', 'roberto.oliveira@example.com', '(19) 99101-0005'),
('b2000000-0000-4000-8000-000000000006', 'Fernando Barbosa', 'fernando.barbosa@example.com', '(21) 99202-0006'),
('b2000000-0000-4000-8000-000000000007', 'Camila Duarte', 'camila.duarte@example.com', '(31) 99202-0007'),
('b2000000-0000-4000-8000-000000000008', 'Marcos Teixeira', 'marcos.teixeira@example.com', '(19) 99202-0008'),
('b2000000-0000-4000-8000-000000000009', 'Patrícia Nogueira', 'patricia.nogueira@example.com', NULL),
('b2000000-0000-4000-8000-000000000010', 'Ricardo Menezes', 'ricardo.menezes@example.com', '(41) 99202-0010'),
('b2000000-0000-4000-8000-000000000011', 'Instituto Futuro Jovem', 'contato@futurojovem.example.com', '(11) 3000-0011'),
('b2000000-0000-4000-8000-000000000012', 'Livraria Saber', 'contato@livrariasaber.example.com', '(19) 3000-0012'),
('b2000000-0000-4000-8000-000000000013', 'Mercado Bom Preço', 'contato@bompreco.example.com', '(19) 3000-0013'),
('b2000000-0000-4000-8000-000000000014', 'Studio Fit Academia', 'contato@studiofit.example.com', '(19) 3000-0014'),
('b2000000-0000-4000-8000-000000000015', 'Cooperativa Vale Verde', 'contato@valeverde.example.com', NULL);

--
-- Dados para a tabela `endereco`
--
INSERT INTO `endereco` (`id`, `id_usuario`, `cep`, `logradouro`, `numero`, `complemento`, `bairro`, `cidade`, `estado`) VALUES
('b1000000-0000-4000-8000-000000000001', 'b2000000-0000-4000-8000-000000000001', '13170000', 'Rua das Acácias', '120', NULL, 'Jardim Primavera', 'Sumaré', 'SP'),
('b1000000-0000-4000-8000-000000000002', 'b2000000-0000-4000-8000-000000000002', '13171110', 'Avenida Brasil', '455', 'Apto 32', 'Centro', 'Sumaré', 'SP'),
('b1000000-0000-4000-8000-000000000003', 'b2000000-0000-4000-8000-000000000003', '13015904', 'Rua Barão de Jaguara', '1010', 'Sala 5', 'Centro', 'Campinas', 'SP'),
('b1000000-0000-4000-8000-000000000004', 'b2000000-0000-4000-8000-000000000004', '01310100', 'Avenida Paulista', '900', 'Conj. 71', 'Bela Vista', 'São Paulo', 'SP'),
('b1000000-0000-4000-8000-000000000005', 'b2000000-0000-4000-8000-000000000005', '13060000', 'Rua Doutor Quirino', '88', NULL, 'Cambuí', 'Campinas', 'SP'),
('b1000000-0000-4000-8000-000000000006', 'b2000000-0000-4000-8000-000000000006', '20040020', 'Rua da Assembleia', '50', 'Andar 3', 'Centro', 'Rio de Janeiro', 'RJ'),
('b1000000-0000-4000-8000-000000000007', 'b2000000-0000-4000-8000-000000000007', '30130010', 'Avenida Afonso Pena', '2000', NULL, 'Funcionários', 'Belo Horizonte', 'MG'),
('b1000000-0000-4000-8000-000000000008', 'b2000000-0000-4000-8000-000000000010', '80010000', 'Rua XV de Novembro', '300', 'Loja 2', 'Centro', 'Curitiba', 'PR'),
('b1000000-0000-4000-8000-000000000009', 'b2000000-0000-4000-8000-000000000011', '13015904', 'Rua Barão de Jaguara', '1010', 'Sala 5', 'Centro', 'Campinas', 'SP'),
('b1000000-0000-4000-8000-000000000010', 'b2000000-0000-4000-8000-000000000012', '13060000', 'Rua Doutor Quirino', '88', NULL, 'Cambuí', 'Campinas', 'SP'),
('b1000000-0000-4000-8000-000000000011', 'b2000000-0000-4000-8000-000000000013', '13171110', 'Avenida Brasil', '455', 'Apto 32', 'Centro', 'Sumaré', 'SP'),
('b1000000-0000-4000-8000-000000000012', 'b2000000-0000-4000-8000-000000000014', '13170000', 'Rua das Acácias', '120', NULL, 'Jardim Primavera', 'Sumaré', 'SP');

--
-- Dados para a tabela `responsavel`
--
INSERT INTO `responsavel` (`usuario_id`, `cpf`) VALUES
('b2000000-0000-4000-8000-000000000001', '39053344705'),
('b2000000-0000-4000-8000-000000000002', '11144477735'),
('b2000000-0000-4000-8000-000000000003', '52998224725'),
('b2000000-0000-4000-8000-000000000004', '86288366757'),
('b2000000-0000-4000-8000-000000000005', '12345678909');

--
-- Dados para a tabela `stakeholder`
--
INSERT INTO `stakeholder` (`usuario_id`) VALUES
('b2000000-0000-4000-8000-000000000006'),
('b2000000-0000-4000-8000-000000000007'),
('b2000000-0000-4000-8000-000000000008'),
('b2000000-0000-4000-8000-000000000009'),
('b2000000-0000-4000-8000-000000000010'),
('b2000000-0000-4000-8000-000000000011'),
('b2000000-0000-4000-8000-000000000012'),
('b2000000-0000-4000-8000-000000000013'),
('b2000000-0000-4000-8000-000000000014'),
('b2000000-0000-4000-8000-000000000015');

--
-- Dados para a tabela `stakeholder_pf`
--
INSERT INTO `stakeholder_pf` (`stakeholder_id`, `cpf`) VALUES
('b2000000-0000-4000-8000-000000000006', '98765432100'),
('b2000000-0000-4000-8000-000000000007', '45612378909'),
('b2000000-0000-4000-8000-000000000008', '32165498700'),
('b2000000-0000-4000-8000-000000000009', '74185296300'),
('b2000000-0000-4000-8000-000000000010', '95175385200');

--
-- Dados para a tabela `stakeholder_pj`
--
INSERT INTO `stakeholder_pj` (`stakeholder_id`, `cnpj`, `razao_social`) VALUES
('b2000000-0000-4000-8000-000000000011', '11222333000181', 'Instituto Futuro Jovem'),
('b2000000-0000-4000-8000-000000000012', '12345678000195', 'Livraria Saber Ltda'),
('b2000000-0000-4000-8000-000000000013', '23456789000112', 'Mercado Bom Preço Comércio de Alimentos Ltda'),
('b2000000-0000-4000-8000-000000000014', '34567890000123', 'Studio Fit Academia de Ginástica Ltda'),
('b2000000-0000-4000-8000-000000000015', '45678901000134', 'Cooperativa Vale Verde de Produtores Rurais');

--
-- Dados para a tabela `parceiro`
--
INSERT INTO `parceiro` (`stakeholder_id`, `nome_marca`, `logotipo_url`, `site_url`, `ativo`) VALUES
('b2000000-0000-4000-8000-000000000011', 'Futuro Jovem', 'https://placehold.co/500x500', 'https://futurojovem.example', 1),
('b2000000-0000-4000-8000-000000000012', 'Livraria Saber', 'https://placehold.co/500x500', 'https://livrariasaber.example', 1),
('b2000000-0000-4000-8000-000000000013', 'Bom Preço', 'https://placehold.co/500x500', 'https://bompreco.example', 1),
('b2000000-0000-4000-8000-000000000014', 'Studio Fit', 'https://placehold.co/500x500', 'https://studiofit.example', 1),
('b2000000-0000-4000-8000-000000000015', 'Vale Verde', 'https://placehold.co/500x500', NULL, 0);

--
-- Dados para a tabela `participante`
--
INSERT INTO `participante` (`id`, `nome`, `data_nascimento`) VALUES
('c1000000-0000-4000-8000-000000000001', 'Lucas Almeida', '2011-03-15'),
('c1000000-0000-4000-8000-000000000002', 'Beatriz Costa', '2010-09-20'),
('c1000000-0000-4000-8000-000000000003', 'Gabriel Souza', '2009-01-10'),
('c1000000-0000-4000-8000-000000000004', 'Mariana Ferreira', '2012-06-25'),
('c1000000-0000-4000-8000-000000000005', 'Pedro Oliveira', '2011-11-02'),
('c1000000-0000-4000-8000-000000000006', 'Sofia Oliveira', '2013-02-14'),
('c1000000-0000-4000-8000-000000000007', 'Rafael Costa', '2010-05-30'),
('c1000000-0000-4000-8000-000000000008', 'Isabela Ferreira', '2012-12-05');

--
-- Dados para a tabela `responsavel_participante`
--
INSERT INTO `responsavel_participante` (`responsavel_id`, `participante_id`, `parentesco`, `guardiao_legal`) VALUES
('b2000000-0000-4000-8000-000000000001', 'c1000000-0000-4000-8000-000000000001', 'Mãe', 1),
('b2000000-0000-4000-8000-000000000002', 'c1000000-0000-4000-8000-000000000002', 'Pai', 1),
('b2000000-0000-4000-8000-000000000002', 'c1000000-0000-4000-8000-000000000007', 'Pai', 1),
('b2000000-0000-4000-8000-000000000003', 'c1000000-0000-4000-8000-000000000003', 'Avó', 1),
('b2000000-0000-4000-8000-000000000004', 'c1000000-0000-4000-8000-000000000004', 'Mãe', 1),
('b2000000-0000-4000-8000-000000000004', 'c1000000-0000-4000-8000-000000000008', 'Mãe', 1),
('b2000000-0000-4000-8000-000000000005', 'c1000000-0000-4000-8000-000000000005', 'Pai', 1),
('b2000000-0000-4000-8000-000000000005', 'c1000000-0000-4000-8000-000000000006', 'Pai', 1);

--
-- Dados para a tabela `restricao_alimentar`
--
INSERT INTO `restricao_alimentar` (`id`, `nome`) VALUES
('c2000000-0000-4000-8000-000000000001', 'Intolerância à lactose'),
('c2000000-0000-4000-8000-000000000002', 'Doença celíaca / sem glúten'),
('c2000000-0000-4000-8000-000000000003', 'Vegetariano'),
('c2000000-0000-4000-8000-000000000004', 'Alergia a amendoim'),
('c2000000-0000-4000-8000-000000000005', 'Alergia a frutos do mar'),
('c2000000-0000-4000-8000-000000000006', 'Vegano');

--
-- Dados para a tabela `participante_restricao`
--
INSERT INTO `participante_restricao` (`participante_id`, `restricao_id`, `observacao`) VALUES
('c1000000-0000-4000-8000-000000000001', 'c2000000-0000-4000-8000-000000000001', 'Pode consumir leite sem lactose'),
('c1000000-0000-4000-8000-000000000002', 'c2000000-0000-4000-8000-000000000002', 'Evitar contaminação cruzada'),
('c1000000-0000-4000-8000-000000000003', 'c2000000-0000-4000-8000-000000000003', NULL),
('c1000000-0000-4000-8000-000000000004', 'c2000000-0000-4000-8000-000000000004', 'Alergia grave; carrega adrenalina autoinjetável'),
('c1000000-0000-4000-8000-000000000005', 'c2000000-0000-4000-8000-000000000005', 'Reação cutânea'),
('c1000000-0000-4000-8000-000000000006', 'c2000000-0000-4000-8000-000000000001', NULL),
('c1000000-0000-4000-8000-000000000008', 'c2000000-0000-4000-8000-000000000002', 'Sensibilidade leve ao glúten');

-- --------------------------------------------------------
-- B. Edição e inscrição
-- --------------------------------------------------------

--
-- Dados para a tabela `edicao`
--
INSERT INTO `edicao` (`id`, `nome`, `data_inicio`, `data_fim`, `vagas_totais`, `valor`, `status`) VALUES
('d1000000-0000-4000-8000-000000000001', 'Acampamento Jovem 2022', '2022-07-11', '2022-07-15', 40, 850.0, 'finalizada'),
('d1000000-0000-4000-8000-000000000002', 'Acampamento Jovem 2023', '2023-07-10', '2023-07-14', 45, 900.0, 'finalizada'),
('d1000000-0000-4000-8000-000000000003', 'Acampamento Jovem 2024', '2024-07-08', '2024-07-12', 50, 950.0, 'finalizada'),
('d1000000-0000-4000-8000-000000000004', 'Acampamento Jovem 2025', '2025-07-07', '2025-07-11', 50, 1000.0, 'finalizada'),
('d1000000-0000-4000-8000-000000000005', 'Acampamento Jovem 2026', '2026-07-06', '2026-07-10', 60, 1100.0, 'finalizada'),
('d1000000-0000-4000-8000-000000000006', 'Acampamento Jovem 2027', '2027-07-05', '2027-07-09', 60, 1200.0, 'inscricoes_abertas');

--
-- Dados para a tabela `lead`
--
INSERT INTO `lead` (`id`, `usuario_id`, `edicao_id`, `origem`, `status_funil`, `convertido_em`) VALUES
('d2000000-0000-4000-8000-000000000001', 'b2000000-0000-4000-8000-000000000001', 'd1000000-0000-4000-8000-000000000005', 'instagram', 'convertido', '2026-03-12 10:20:00'),
('d2000000-0000-4000-8000-000000000002', 'b2000000-0000-4000-8000-000000000002', 'd1000000-0000-4000-8000-000000000005', 'indicacao', 'convertido', '2026-03-20 16:45:00'),
('d2000000-0000-4000-8000-000000000003', 'b2000000-0000-4000-8000-000000000003', 'd1000000-0000-4000-8000-000000000006', 'google', 'qualificado', NULL),
('d2000000-0000-4000-8000-000000000004', 'b2000000-0000-4000-8000-000000000004', 'd1000000-0000-4000-8000-000000000006', 'evento', 'convertido', '2026-10-02 11:05:00'),
('d2000000-0000-4000-8000-000000000005', 'b2000000-0000-4000-8000-000000000005', 'd1000000-0000-4000-8000-000000000006', 'instagram', 'contatado', NULL),
('d2000000-0000-4000-8000-000000000006', 'b2000000-0000-4000-8000-000000000006', NULL, 'outro', 'novo', NULL);

--
-- Dados para a tabela `inscricao`
--
INSERT INTO `inscricao` (`id`, `participante_id`, `edicao_id`, `responsavel_id`, `status`, `tipo_vaga`, `etapa_atual`) VALUES
('d3000000-0000-4000-8000-000000000001', 'c1000000-0000-4000-8000-000000000001', 'd1000000-0000-4000-8000-000000000005', 'b2000000-0000-4000-8000-000000000001', 'confirmada', 'pagante', 'concluida'),
('d3000000-0000-4000-8000-000000000002', 'c1000000-0000-4000-8000-000000000002', 'd1000000-0000-4000-8000-000000000005', 'b2000000-0000-4000-8000-000000000002', 'confirmada', 'pagante', 'concluida'),
('d3000000-0000-4000-8000-000000000003', 'c1000000-0000-4000-8000-000000000003', 'd1000000-0000-4000-8000-000000000004', 'b2000000-0000-4000-8000-000000000003', 'confirmada', 'bolsista', 'concluida'),
('d3000000-0000-4000-8000-000000000004', 'c1000000-0000-4000-8000-000000000004', 'd1000000-0000-4000-8000-000000000005', 'b2000000-0000-4000-8000-000000000004', 'cancelada', 'pagante', 'cancelada'),
('d3000000-0000-4000-8000-000000000005', 'c1000000-0000-4000-8000-000000000005', 'd1000000-0000-4000-8000-000000000005', 'b2000000-0000-4000-8000-000000000005', 'confirmada', 'pagante', 'concluida'),
('d3000000-0000-4000-8000-000000000006', 'c1000000-0000-4000-8000-000000000001', 'd1000000-0000-4000-8000-000000000006', 'b2000000-0000-4000-8000-000000000001', 'pendente', 'pagante', 'pagamento'),
('d3000000-0000-4000-8000-000000000007', 'c1000000-0000-4000-8000-000000000006', 'd1000000-0000-4000-8000-000000000006', 'b2000000-0000-4000-8000-000000000005', 'lista_espera', 'bolsista', 'aguardando_vaga'),
('d3000000-0000-4000-8000-000000000008', 'c1000000-0000-4000-8000-000000000007', 'd1000000-0000-4000-8000-000000000006', 'b2000000-0000-4000-8000-000000000002', 'confirmada', 'pagante', 'ficha_medica'),
('d3000000-0000-4000-8000-000000000009', 'c1000000-0000-4000-8000-000000000008', 'd1000000-0000-4000-8000-000000000006', 'b2000000-0000-4000-8000-000000000004', 'pendente', 'patrocinada', 'documentos'),
('d3000000-0000-4000-8000-000000000010', 'c1000000-0000-4000-8000-000000000004', 'd1000000-0000-4000-8000-000000000006', 'b2000000-0000-4000-8000-000000000004', 'confirmada', 'pagante', 'ficha_medica');

--
-- Dados para a tabela `ficha_medica`
--
INSERT INTO `ficha_medica` (`id`, `inscricao_id`, `arquivo_url`, `validada_em`, `validada_por`) VALUES
('d4000000-0000-4000-8000-000000000001', 'd3000000-0000-4000-8000-000000000001', 'https://storage.example.com/fichas/2026/lucas-almeida.pdf', '2026-06-20 14:30:00', 'a1000000-0000-4000-8000-000000000003'),
('d4000000-0000-4000-8000-000000000002', 'd3000000-0000-4000-8000-000000000002', 'https://storage.example.com/fichas/2026/beatriz-costa.pdf', '2026-06-21 09:10:00', 'a1000000-0000-4000-8000-000000000003'),
('d4000000-0000-4000-8000-000000000003', 'd3000000-0000-4000-8000-000000000003', 'https://storage.example.com/fichas/2025/gabriel-souza.pdf', '2025-06-18 11:00:00', 'a1000000-0000-4000-8000-000000000001'),
('d4000000-0000-4000-8000-000000000004', 'd3000000-0000-4000-8000-000000000005', 'https://storage.example.com/fichas/2026/pedro-oliveira.pdf', '2026-06-22 16:25:00', 'a1000000-0000-4000-8000-000000000003'),
('d4000000-0000-4000-8000-000000000005', 'd3000000-0000-4000-8000-000000000008', 'https://storage.example.com/fichas/2027/rafael-costa.pdf', '2026-11-18 10:40:00', 'a1000000-0000-4000-8000-000000000001'),
('d4000000-0000-4000-8000-000000000006', 'd3000000-0000-4000-8000-000000000010', 'https://storage.example.com/fichas/2027/mariana-ferreira.pdf', NULL, NULL),
('d4000000-0000-4000-8000-000000000007', 'd3000000-0000-4000-8000-000000000006', 'https://storage.example.com/fichas/2027/lucas-almeida.pdf', NULL, NULL);

--
-- Dados para a tabela `parceria`
--
INSERT INTO `parceria` (`parceiro_id`, `edicao_id`, `tipo_apoio`, `exibir_na_landing`) VALUES
('b2000000-0000-4000-8000-000000000011', 'd1000000-0000-4000-8000-000000000005', 'Apoio institucional', 1),
('b2000000-0000-4000-8000-000000000012', 'd1000000-0000-4000-8000-000000000005', 'Doação de livros e materiais', 1),
('b2000000-0000-4000-8000-000000000012', 'd1000000-0000-4000-8000-000000000004', 'Doação de livros e materiais', 1),
('b2000000-0000-4000-8000-000000000013', 'd1000000-0000-4000-8000-000000000006', 'Fornecimento de alimentos', 1),
('b2000000-0000-4000-8000-000000000014', 'd1000000-0000-4000-8000-000000000006', 'Atividades esportivas', 1),
('b2000000-0000-4000-8000-000000000015', 'd1000000-0000-4000-8000-000000000006', 'Hortifrúti orgânico', 0),
('b2000000-0000-4000-8000-000000000011', 'd1000000-0000-4000-8000-000000000006', 'Apoio institucional', 1);

--
-- Dados para a tabela `programacao`
--
INSERT INTO `programacao` (`id`, `edicao_id`, `dia`, `hora_inicio`, `titulo`, `descricao`) VALUES
('d5000000-0000-4000-8000-000000000001', 'd1000000-0000-4000-8000-000000000006', '2027-07-05', '08:00:00', 'Credenciamento e boas-vindas', 'Recepção dos participantes e entrega de kits.'),
('d5000000-0000-4000-8000-000000000002', 'd1000000-0000-4000-8000-000000000006', '2027-07-05', '09:30:00', 'Abertura e dinâmica de integração', 'Apresentação da equipe e atividades de quebra-gelo.'),
('d5000000-0000-4000-8000-000000000003', 'd1000000-0000-4000-8000-000000000006', '2027-07-05', '14:00:00', 'Oficina de Liderança', 'Atividades práticas em pequenos grupos.'),
('d5000000-0000-4000-8000-000000000004', 'd1000000-0000-4000-8000-000000000006', '2027-07-06', '09:00:00', 'Palestra: Projeto de Vida', 'Convidado especial fala sobre escolhas e carreira.'),
('d5000000-0000-4000-8000-000000000005', 'd1000000-0000-4000-8000-000000000006', '2027-07-06', '14:00:00', 'Oficina de Comunicação', 'Oratória e trabalho em equipe.'),
('d5000000-0000-4000-8000-000000000006', 'd1000000-0000-4000-8000-000000000006', '2027-07-07', '09:00:00', 'Trilha ecológica', 'Caminhada guiada com monitores.'),
('d5000000-0000-4000-8000-000000000007', 'd1000000-0000-4000-8000-000000000006', '2027-07-07', '15:00:00', 'Workshop de Empreendedorismo', 'Construção de um mini-projeto em grupo.'),
('d5000000-0000-4000-8000-000000000008', 'd1000000-0000-4000-8000-000000000006', '2027-07-08', '10:00:00', 'Painel com parceiros', 'Conversa com representantes das organizações parceiras.'),
('d5000000-0000-4000-8000-000000000009', 'd1000000-0000-4000-8000-000000000006', '2027-07-08', '19:30:00', 'Noite cultural', NULL),
('d5000000-0000-4000-8000-000000000010', 'd1000000-0000-4000-8000-000000000006', '2027-07-09', '09:00:00', 'Mentoria em grupo', 'Planejamento de metas pós-edição.'),
('d5000000-0000-4000-8000-000000000011', 'd1000000-0000-4000-8000-000000000006', '2027-07-09', '15:00:00', 'Cerimônia de encerramento', 'Entrega de certificados e despedida.');

-- --------------------------------------------------------
-- C. Financeiro
-- --------------------------------------------------------

--
-- Dados para a tabela `transacao`
--
INSERT INTO `transacao` (`id`, `metodo`, `parcelas`, `valor`, `status`, `gateway`, `gateway_transacao_id`) VALUES
('e1000000-0000-4000-8000-000000000001', 'cartao_credito', 5, 1100.0, 'aprovada', 'stripe', 'pi_000001'),
('e1000000-0000-4000-8000-000000000002', 'pix', 1, 1100.0, 'aprovada', 'stripe', 'pi_000002'),
('e1000000-0000-4000-8000-000000000003', 'boleto', 1, 1000.0, 'aprovada', 'stripe', 'pi_000003'),
('e1000000-0000-4000-8000-000000000004', 'cartao_credito', 3, 1100.0, 'estornada', 'stripe', 'pi_000004'),
('e1000000-0000-4000-8000-000000000005', 'pix', 1, 1100.0, 'aprovada', 'stripe', 'pi_000005'),
('e1000000-0000-4000-8000-000000000006', 'cartao_credito', 6, 1200.0, 'aprovada', 'stripe', 'pi_000006'),
('e1000000-0000-4000-8000-000000000007', 'cartao_debito', 1, 1200.0, 'recusada', 'stripe', 'pi_000007'),
('e1000000-0000-4000-8000-000000000008', 'pix', 1, 1200.0, 'aprovada', 'stripe', 'pi_000008'),
('e1000000-0000-4000-8000-000000000009', 'boleto', 1, 1200.0, 'pendente', 'stripe', 'pi_000009'),
('e1000000-0000-4000-8000-000000000010', 'pix', 1, 100.0, 'aprovada', 'stripe', 'pi_000010'),
('e1000000-0000-4000-8000-000000000011', 'pix', 1, 2500.0, 'aprovada', 'stripe', 'pi_000011'),
('e1000000-0000-4000-8000-000000000012', 'cartao_credito', 1, 50.0, 'aprovada', 'stripe', 'pi_000012'),
('e1000000-0000-4000-8000-000000000013', 'cartao_credito', 3, 1000.0, 'aprovada', 'stripe', 'pi_000013'),
('e1000000-0000-4000-8000-000000000014', 'pix', 1, 200.0, 'pendente', 'stripe', 'pi_000014');

--
-- Dados para a tabela `pagamento_inscricao`
--
INSERT INTO `pagamento_inscricao` (`transacao_id`, `inscricao_id`) VALUES
('e1000000-0000-4000-8000-000000000001', 'd3000000-0000-4000-8000-000000000001'),
('e1000000-0000-4000-8000-000000000002', 'd3000000-0000-4000-8000-000000000002'),
('e1000000-0000-4000-8000-000000000003', 'd3000000-0000-4000-8000-000000000003'),
('e1000000-0000-4000-8000-000000000004', 'd3000000-0000-4000-8000-000000000004'),
('e1000000-0000-4000-8000-000000000005', 'd3000000-0000-4000-8000-000000000005'),
('e1000000-0000-4000-8000-000000000006', 'd3000000-0000-4000-8000-000000000008'),
('e1000000-0000-4000-8000-000000000007', 'd3000000-0000-4000-8000-000000000010'),
('e1000000-0000-4000-8000-000000000008', 'd3000000-0000-4000-8000-000000000010'),
('e1000000-0000-4000-8000-000000000009', 'd3000000-0000-4000-8000-000000000006');

--
-- Dados para a tabela `doacao`
--
INSERT INTO `doacao` (`id`, `stakeholder_id`, `transacao_id`, `edicao_id`, `anonima`, `comprovante_arquivo_url`) VALUES
('e2000000-0000-4000-8000-000000000001', 'b2000000-0000-4000-8000-000000000006', 'e1000000-0000-4000-8000-000000000010', 'd1000000-0000-4000-8000-000000000005', 0, 'https://storage.example.com/comprovantes/doacao-0001.pdf'),
('e2000000-0000-4000-8000-000000000002', 'b2000000-0000-4000-8000-000000000011', 'e1000000-0000-4000-8000-000000000011', 'd1000000-0000-4000-8000-000000000006', 0, 'https://storage.example.com/comprovantes/doacao-0002.pdf'),
('e2000000-0000-4000-8000-000000000003', 'b2000000-0000-4000-8000-000000000007', 'e1000000-0000-4000-8000-000000000012', NULL, 1, NULL),
('e2000000-0000-4000-8000-000000000004', 'b2000000-0000-4000-8000-000000000012', 'e1000000-0000-4000-8000-000000000013', 'd1000000-0000-4000-8000-000000000006', 0, 'https://storage.example.com/comprovantes/doacao-0004.pdf'),
('e2000000-0000-4000-8000-000000000005', 'b2000000-0000-4000-8000-000000000008', 'e1000000-0000-4000-8000-000000000014', 'd1000000-0000-4000-8000-000000000005', 0, NULL);

--
-- Dados para a tabela `gateway_evento`
--
INSERT INTO `gateway_evento` (`id`, `transacao_id`, `evento_externo_id`, `tipo`, `payload`, `processado_em`) VALUES
('e3000000-0000-4000-8000-000000000001', 'e1000000-0000-4000-8000-000000000001', 'evt_0001', 'criada', '{"id": "evt_0001", "type": "payment_intent.created", "data": {"object": {"id": "pi_000001", "object": "payment_intent", "amount": 110000, "currency": "brl", "status": "requires_payment_method"}}}', '2026-03-12 10:21:00'),
('e3000000-0000-4000-8000-000000000002', 'e1000000-0000-4000-8000-000000000001', 'evt_0002', 'aprovada', '{"id": "evt_0002", "type": "payment_intent.succeeded", "data": {"object": {"id": "pi_000001", "object": "payment_intent", "amount": 110000, "currency": "brl", "status": "succeeded"}}}', '2026-03-12 10:21:05'),
('e3000000-0000-4000-8000-000000000003', 'e1000000-0000-4000-8000-000000000002', 'evt_0003', 'aprovada', '{"id": "evt_0003", "type": "payment_intent.succeeded", "data": {"object": {"id": "pi_000002", "object": "payment_intent", "amount": 110000, "currency": "brl", "status": "succeeded"}}}', '2026-03-20 16:50:00'),
('e3000000-0000-4000-8000-000000000004', 'e1000000-0000-4000-8000-000000000004', 'evt_0004', 'aprovada', '{"id": "evt_0004", "type": "payment_intent.succeeded", "data": {"object": {"id": "pi_000004", "object": "payment_intent", "amount": 110000, "currency": "brl", "status": "succeeded"}}}', '2026-04-02 09:00:00'),
('e3000000-0000-4000-8000-000000000005', 'e1000000-0000-4000-8000-000000000004', 'evt_0005', 'estornada', '{"id": "evt_0005", "type": "charge.refunded", "data": {"object": {"id": "ch_000004", "object": "charge", "payment_intent": "pi_000004", "amount": 110000, "amount_refunded": 110000, "currency": "brl", "refunded": true}}}', '2026-04-10 15:30:00'),
('e3000000-0000-4000-8000-000000000006', 'e1000000-0000-4000-8000-000000000007', 'evt_0006', 'recusada', '{"id": "evt_0006", "type": "payment_intent.payment_failed", "data": {"object": {"id": "pi_000007", "object": "payment_intent", "amount": 120000, "currency": "brl", "status": "requires_payment_method"}}}', '2026-10-02 11:06:00'),
('e3000000-0000-4000-8000-000000000007', 'e1000000-0000-4000-8000-000000000009', 'evt_0007', 'criada', '{"id": "evt_0007", "type": "payment_intent.created", "data": {"object": {"id": "pi_000009", "object": "payment_intent", "amount": 120000, "currency": "brl", "status": "requires_action"}}}', NULL),
('e3000000-0000-4000-8000-000000000008', 'e1000000-0000-4000-8000-000000000008', 'evt_0008', 'aprovada', '{"id": "evt_0008", "type": "payment_intent.succeeded", "data": {"object": {"id": "pi_000008", "object": "payment_intent", "amount": 120000, "currency": "brl", "status": "succeeded"}}}', '2026-10-02 11:10:00');

-- --------------------------------------------------------
-- D. Comunicação e LGPD
-- --------------------------------------------------------

--
-- Dados para a tabela `template_contato`
--
INSERT INTO `template_contato` (`id`, `tipo`, `assunto`, `corpo`, `ativo`) VALUES
('f1000000-0000-4000-8000-000000000001', 'email', 'Confirmação de inscrição', 'Olá {{nome_responsavel}}, a inscrição de {{nome_participante}} na {{nome_edicao}} foi recebida com sucesso.', 1),
('f1000000-0000-4000-8000-000000000002', 'email', 'Lembrete de pagamento', 'Olá {{nome_responsavel}}, identificamos um pagamento pendente para a inscrição de {{nome_participante}}.', 1),
('f1000000-0000-4000-8000-000000000003', 'whatsapp', 'Boas-vindas', 'Oi {{nome_responsavel}}! Seja bem-vindo(a) à {{nome_edicao}}. Qualquer dúvida, responda esta mensagem.', 1),
('f1000000-0000-4000-8000-000000000004', 'sms', 'Ficha médica pendente', 'Falta enviar a ficha médica de {{nome_participante}}. Acesse o portal para concluir.', 1),
('f1000000-0000-4000-8000-000000000005', 'email', 'Pesquisa de satisfação', 'Conte como foi a experiência de {{nome_participante}} na {{nome_edicao}}. Leva menos de 2 minutos.', 0);

--
-- Dados para a tabela `campanha`
--
INSERT INTO `campanha` (`id`, `nome`, `template_id`, `criada_por`) VALUES
('f2000000-0000-4000-8000-000000000001', 'Confirmação de inscrições 2027', 'f1000000-0000-4000-8000-000000000001', 'a1000000-0000-4000-8000-000000000001'),
('f2000000-0000-4000-8000-000000000002', 'Cobrança de pendências - Out/2026', 'f1000000-0000-4000-8000-000000000002', 'a1000000-0000-4000-8000-000000000002'),
('f2000000-0000-4000-8000-000000000003', 'Boas-vindas turma 2027', 'f1000000-0000-4000-8000-000000000003', 'a1000000-0000-4000-8000-000000000002'),
('f2000000-0000-4000-8000-000000000004', 'Ficha médica pendente 2027', 'f1000000-0000-4000-8000-000000000004', 'a1000000-0000-4000-8000-000000000003'),
('f2000000-0000-4000-8000-000000000005', 'Pesquisa pós-edição 2026', 'f1000000-0000-4000-8000-000000000005', 'a1000000-0000-4000-8000-000000000001');

--
-- Dados para a tabela `comunicacao`
--
INSERT INTO `comunicacao` (`id`, `usuario_id`, `template_id`, `campanha_id`, `inscricao_id`, `canal`, `assunto`, `corpo`, `status`, `erro`) VALUES
('f3000000-0000-4000-8000-000000000001', 'b2000000-0000-4000-8000-000000000001', 'f1000000-0000-4000-8000-000000000001', 'f2000000-0000-4000-8000-000000000001', 'd3000000-0000-4000-8000-000000000006', 'email', 'Confirmação de inscrição', 'Olá Ana Paula, a inscrição de Lucas Almeida na Acampamento Jovem 2027 foi recebida com sucesso.', 'enviada', NULL),
('f3000000-0000-4000-8000-000000000002', 'b2000000-0000-4000-8000-000000000002', 'f1000000-0000-4000-8000-000000000001', 'f2000000-0000-4000-8000-000000000001', 'd3000000-0000-4000-8000-000000000008', 'email', 'Confirmação de inscrição', 'Olá Carlos Eduardo, a inscrição de Rafael Costa na Acampamento Jovem 2027 foi recebida com sucesso.', 'enviada', NULL),
('f3000000-0000-4000-8000-000000000003', 'b2000000-0000-4000-8000-000000000004', 'f1000000-0000-4000-8000-000000000002', 'f2000000-0000-4000-8000-000000000002', 'd3000000-0000-4000-8000-000000000009', 'email', 'Lembrete de pagamento', 'Olá Juliana, identificamos um pagamento pendente para a inscrição de Isabela Ferreira.', 'enviada', NULL),
('f3000000-0000-4000-8000-000000000004', 'b2000000-0000-4000-8000-000000000005', 'f1000000-0000-4000-8000-000000000003', 'f2000000-0000-4000-8000-000000000003', 'd3000000-0000-4000-8000-000000000007', 'whatsapp', 'Boas-vindas', 'Oi Roberto! Seja bem-vindo(a) à Acampamento Jovem 2027. Qualquer dúvida, responda esta mensagem.', 'enviada', NULL),
('f3000000-0000-4000-8000-000000000005', 'b2000000-0000-4000-8000-000000000001', 'f1000000-0000-4000-8000-000000000004', 'f2000000-0000-4000-8000-000000000004', 'd3000000-0000-4000-8000-000000000006', 'sms', 'Ficha médica pendente', 'Falta enviar a ficha médica de Lucas Almeida. Acesse o portal para concluir.', 'falhou', 'Número inválido ou fora de área'),
('f3000000-0000-4000-8000-000000000006', 'b2000000-0000-4000-8000-000000000003', 'f1000000-0000-4000-8000-000000000005', 'f2000000-0000-4000-8000-000000000005', 'd3000000-0000-4000-8000-000000000003', 'email', 'Pesquisa de satisfação', 'Conte como foi a experiência de Gabriel Souza na Acampamento Jovem 2025. Leva menos de 2 minutos.', 'enviada', NULL),
('f3000000-0000-4000-8000-000000000007', 'b2000000-0000-4000-8000-000000000004', 'f1000000-0000-4000-8000-000000000004', 'f2000000-0000-4000-8000-000000000004', 'd3000000-0000-4000-8000-000000000010', 'sms', 'Ficha médica pendente', 'Falta enviar a ficha médica de Mariana Ferreira. Acesse o portal para concluir.', 'pendente', NULL),
('f3000000-0000-4000-8000-000000000008', 'b2000000-0000-4000-8000-000000000006', NULL, NULL, NULL, 'email', 'Obrigado pela sua doação', 'Recebemos sua doação. Muito obrigado por apoiar o projeto!', 'enviada', NULL);

--
-- Dados para a tabela `mensagem_contato`
--
INSERT INTO `mensagem_contato` (`id`, `usuario_id`, `assunto`, `mensagem`, `status`) VALUES
('f4000000-0000-4000-8000-000000000001', 'b2000000-0000-4000-8000-000000000001', 'Dúvida sobre pagamento', 'Posso parcelar a inscrição em mais de 5 vezes no cartão?', 'respondida'),
('f4000000-0000-4000-8000-000000000002', 'b2000000-0000-4000-8000-000000000003', 'Bolsa de estudos', 'Quais são os critérios para a vaga de bolsista?', 'lida'),
('f4000000-0000-4000-8000-000000000003', 'b2000000-0000-4000-8000-000000000006', 'Como doar', 'Gostaria de saber como emitir recibo da minha doação.', 'nova'),
('f4000000-0000-4000-8000-000000000004', 'b2000000-0000-4000-8000-000000000008', 'Voluntariado', 'Tenho interesse em atuar como voluntário na próxima edição.', 'nova'),
('f4000000-0000-4000-8000-000000000005', 'b2000000-0000-4000-8000-000000000012', 'Proposta de parceria', 'Gostaríamos de apoiar a edição de 2027 com livros.', 'respondida'),
('f4000000-0000-4000-8000-000000000006', 'b2000000-0000-4000-8000-000000000004', 'Alteração de dados', 'Preciso atualizar o telefone cadastrado.', 'arquivada');

--
-- Dados para a tabela `consentimento`
--
INSERT INTO `consentimento` (`id`, `usuario_id`, `finalidade`, `versao_termo`, `aceito`, `registrado_em`, `ip`) VALUES
('f5000000-0000-4000-8000-000000000001', 'b2000000-0000-4000-8000-000000000001', 'Tratamento de dados de participante menor de idade', '2.1', 1, '2026-03-12 10:15:00', '189.40.12.10'),
('f5000000-0000-4000-8000-000000000002', 'b2000000-0000-4000-8000-000000000002', 'Tratamento de dados de participante menor de idade', '2.1', 1, '2026-03-20 16:40:00', '177.12.88.45'),
('f5000000-0000-4000-8000-000000000003', 'b2000000-0000-4000-8000-000000000003', 'Tratamento de dados de participante menor de idade', '2.0', 1, '2025-05-10 09:30:00', '201.17.5.99'),
('f5000000-0000-4000-8000-000000000004', 'b2000000-0000-4000-8000-000000000004', 'Tratamento de dados de participante menor de idade', '2.2', 1, '2026-10-02 11:00:00', '187.55.20.31'),
('f5000000-0000-4000-8000-000000000005', 'b2000000-0000-4000-8000-000000000005', 'Tratamento de dados de participante menor de idade', '2.2', 1, '2026-10-05 20:12:00', '191.33.7.120'),
('f5000000-0000-4000-8000-000000000006', 'b2000000-0000-4000-8000-000000000001', 'Recebimento de comunicações por e-mail', '2.1', 1, '2026-03-12 10:16:00', '189.40.12.10'),
('f5000000-0000-4000-8000-000000000007', 'b2000000-0000-4000-8000-000000000003', 'Recebimento de comunicações por e-mail', '2.1', 0, '2026-09-01 18:00:00', '201.17.5.99'),
('f5000000-0000-4000-8000-000000000008', 'b2000000-0000-4000-8000-000000000006', 'Uso de dados para emissão de recibo de doação', '2.2', 1, '2026-05-02 13:45:00', '200.150.1.77');

-- --------------------------------------------------------
-- E. Conteúdo editável da landing
-- --------------------------------------------------------

--
-- Dados para a tabela `secao`
--
INSERT INTO `secao` (`id`, `slug`, `nome`) VALUES
('91000000-0000-4000-8000-000000000001', 'hero', 'Topo (Hero)'),
('91000000-0000-4000-8000-000000000002', 'sobre', 'Sobre o projeto'),
('91000000-0000-4000-8000-000000000003', 'galeria', 'Galeria de fotos e vídeos'),
('91000000-0000-4000-8000-000000000004', 'parceiros', 'Parceiros e apoiadores'),
('91000000-0000-4000-8000-000000000005', 'contato', 'Contato');

--
-- Dados para a tabela `conteudo_texto`
--
INSERT INTO `conteudo_texto` (`id`, `chave`, `secao_id`, `valor`, `atualizado_por`) VALUES
('92000000-0000-4000-8000-000000000001', 'hero.titulo', '91000000-0000-4000-8000-000000000001', 'Viva uma semana que transforma', 'a1000000-0000-4000-8000-000000000002'),
('92000000-0000-4000-8000-000000000002', 'hero.subtitulo', '91000000-0000-4000-8000-000000000001', 'Acampamento para jovens de 13 a 17 anos', 'a1000000-0000-4000-8000-000000000002'),
('92000000-0000-4000-8000-000000000003', 'hero.cta', '91000000-0000-4000-8000-000000000001', 'Quero me inscrever', 'a1000000-0000-4000-8000-000000000001'),
('92000000-0000-4000-8000-000000000004', 'sobre.titulo', '91000000-0000-4000-8000-000000000002', 'Quem somos', 'a1000000-0000-4000-8000-000000000001'),
('92000000-0000-4000-8000-000000000005', 'sobre.descricao', '91000000-0000-4000-8000-000000000002', 'Uma experiência de convivência, aprendizado e protagonismo juvenil.', 'a1000000-0000-4000-8000-000000000002'),
('92000000-0000-4000-8000-000000000006', 'galeria.titulo', '91000000-0000-4000-8000-000000000003', 'Momentos das edições anteriores', NULL),
('92000000-0000-4000-8000-000000000007', 'parceiros.titulo', '91000000-0000-4000-8000-000000000004', 'Quem apoia essa ideia', NULL),
('92000000-0000-4000-8000-000000000008', 'parceiros.descricao', '91000000-0000-4000-8000-000000000004', 'Empresas e instituições que tornam o projeto possível.', 'a1000000-0000-4000-8000-000000000003'),
('92000000-0000-4000-8000-000000000009', 'contato.titulo', '91000000-0000-4000-8000-000000000005', 'Fale com a gente', 'a1000000-0000-4000-8000-000000000003'),
('92000000-0000-4000-8000-000000000010', 'contato.email', '91000000-0000-4000-8000-000000000005', 'contato@example.com', 'a1000000-0000-4000-8000-000000000001');

--
-- Dados para a tabela `midia`
--
INSERT INTO `midia` (`id`, `secao_id`, `edicao_id`, `url_externa`, `tipo`, `legenda`, `ordem`, `ativo`) VALUES
('93000000-0000-4000-8000-000000000001', '91000000-0000-4000-8000-000000000001', NULL, 'https://cdn.example.com/hero/video-institucional.mp4', 'video', 'Vídeo institucional', 1, 1),
('93000000-0000-4000-8000-000000000002', '91000000-0000-4000-8000-000000000003', 'd1000000-0000-4000-8000-000000000005', 'https://cdn.example.com/galeria/2026/foto-01.jpg', 'imagem', 'Abertura 2026', 1, 1),
('93000000-0000-4000-8000-000000000003', '91000000-0000-4000-8000-000000000003', 'd1000000-0000-4000-8000-000000000005', 'https://cdn.example.com/galeria/2026/foto-02.jpg', 'imagem', 'Trilha ecológica', 2, 1),
('93000000-0000-4000-8000-000000000004', '91000000-0000-4000-8000-000000000003', 'd1000000-0000-4000-8000-000000000005', 'https://cdn.example.com/galeria/2026/video-aftermovie.mp4', 'video', 'Aftermovie 2026', 3, 1),
('93000000-0000-4000-8000-000000000005', '91000000-0000-4000-8000-000000000003', 'd1000000-0000-4000-8000-000000000004', 'https://cdn.example.com/galeria/2025/foto-01.jpg', 'imagem', 'Oficina de liderança 2025', 4, 1),
('93000000-0000-4000-8000-000000000006', '91000000-0000-4000-8000-000000000003', 'd1000000-0000-4000-8000-000000000004', 'https://cdn.example.com/galeria/2025/foto-02.jpg', 'imagem', 'Noite cultural 2025', 5, 1),
('93000000-0000-4000-8000-000000000007', '91000000-0000-4000-8000-000000000003', 'd1000000-0000-4000-8000-000000000003', 'https://cdn.example.com/galeria/2024/foto-01.jpg', 'imagem', 'Turma 2024', 6, 0),
('93000000-0000-4000-8000-000000000008', '91000000-0000-4000-8000-000000000004', NULL, 'https://cdn.example.com/parceiros/faixa-parceiros.png', 'imagem', 'Parceiros 2027', 1, 1);

--
-- Dados para a tabela `faq`
--
INSERT INTO `faq` (`id`, `pergunta`, `resposta`, `ordem`, `ativo`) VALUES
('94000000-0000-4000-8000-000000000001', 'Quem pode participar?', 'Jovens de 13 a 17 anos completos na data de início da edição.', 1, 1),
('94000000-0000-4000-8000-000000000002', 'Como faço a inscrição?', 'Pelo formulário nesta página; o responsável legal preenche os dados e acompanha as etapas.', 2, 1),
('94000000-0000-4000-8000-000000000003', 'Quais formas de pagamento são aceitas?', 'Pix, cartão de crédito (com parcelamento), cartão de débito e boleto.', 3, 1),
('94000000-0000-4000-8000-000000000004', 'Existem bolsas?', 'Sim. Há vagas bolsistas e patrocinadas, sujeitas a análise e disponibilidade.', 4, 1),
('94000000-0000-4000-8000-000000000005', 'Como informar restrições alimentares?', 'Elas são registradas no cadastro do participante e consideradas no cardápio.', 5, 1),
('94000000-0000-4000-8000-000000000006', 'A ficha médica é obrigatória?', 'Sim. Ela deve ser enviada e validada pela equipe antes da edição.', 6, 1);

--
-- Dados para a tabela `rede_social`
--
INSERT INTO `rede_social` (`id`, `nome`, `url`, `ordem`, `ativo`) VALUES
('95000000-0000-4000-8000-000000000001', 'Facebook', 'https://facebook.com/exemplo', 1, 1),
('95000000-0000-4000-8000-000000000002', 'YouTube', 'https://youtube.com/@exemplo', 2, 1),
('95000000-0000-4000-8000-000000000003', 'LinkedIn', 'https://linkedin.com/company/exemplo', 3, 1),
('95000000-0000-4000-8000-000000000004', 'WhatsApp', 'https://wa.me/5519991010001', 4, 1),
('95000000-0000-4000-8000-000000000005', 'Instagram', 'https://instagram.com/@exemplo', 5, 0);

COMMIT;

-- --------------------------------------------------------
-- Conferência: contagem de registros por tabela
-- --------------------------------------------------------

SELECT 'admin' AS tabela, COUNT(*) AS total FROM `admin`
UNION ALL
SELECT 'log_auditoria' AS tabela, COUNT(*) AS total FROM `log_auditoria`
UNION ALL
SELECT 'endereco' AS tabela, COUNT(*) AS total FROM `endereco`
UNION ALL
SELECT 'usuario' AS tabela, COUNT(*) AS total FROM `usuario`
UNION ALL
SELECT 'responsavel' AS tabela, COUNT(*) AS total FROM `responsavel`
UNION ALL
SELECT 'stakeholder' AS tabela, COUNT(*) AS total FROM `stakeholder`
UNION ALL
SELECT 'stakeholder_pf' AS tabela, COUNT(*) AS total FROM `stakeholder_pf`
UNION ALL
SELECT 'stakeholder_pj' AS tabela, COUNT(*) AS total FROM `stakeholder_pj`
UNION ALL
SELECT 'parceiro' AS tabela, COUNT(*) AS total FROM `parceiro`
UNION ALL
SELECT 'participante' AS tabela, COUNT(*) AS total FROM `participante`
UNION ALL
SELECT 'responsavel_participante' AS tabela, COUNT(*) AS total FROM `responsavel_participante`
UNION ALL
SELECT 'restricao_alimentar' AS tabela, COUNT(*) AS total FROM `restricao_alimentar`
UNION ALL
SELECT 'participante_restricao' AS tabela, COUNT(*) AS total FROM `participante_restricao`
UNION ALL
SELECT 'edicao' AS tabela, COUNT(*) AS total FROM `edicao`
UNION ALL
SELECT 'lead' AS tabela, COUNT(*) AS total FROM `lead`
UNION ALL
SELECT 'inscricao' AS tabela, COUNT(*) AS total FROM `inscricao`
UNION ALL
SELECT 'ficha_medica' AS tabela, COUNT(*) AS total FROM `ficha_medica`
UNION ALL
SELECT 'parceria' AS tabela, COUNT(*) AS total FROM `parceria`
UNION ALL
SELECT 'programacao' AS tabela, COUNT(*) AS total FROM `programacao`
UNION ALL
SELECT 'transacao' AS tabela, COUNT(*) AS total FROM `transacao`
UNION ALL
SELECT 'pagamento_inscricao' AS tabela, COUNT(*) AS total FROM `pagamento_inscricao`
UNION ALL
SELECT 'doacao' AS tabela, COUNT(*) AS total FROM `doacao`
UNION ALL
SELECT 'gateway_evento' AS tabela, COUNT(*) AS total FROM `gateway_evento`
UNION ALL
SELECT 'template_contato' AS tabela, COUNT(*) AS total FROM `template_contato`
UNION ALL
SELECT 'campanha' AS tabela, COUNT(*) AS total FROM `campanha`
UNION ALL
SELECT 'comunicacao' AS tabela, COUNT(*) AS total FROM `comunicacao`
UNION ALL
SELECT 'mensagem_contato' AS tabela, COUNT(*) AS total FROM `mensagem_contato`
UNION ALL
SELECT 'consentimento' AS tabela, COUNT(*) AS total FROM `consentimento`
UNION ALL
SELECT 'secao' AS tabela, COUNT(*) AS total FROM `secao`
UNION ALL
SELECT 'conteudo_texto' AS tabela, COUNT(*) AS total FROM `conteudo_texto`
UNION ALL
SELECT 'midia' AS tabela, COUNT(*) AS total FROM `midia`
UNION ALL
SELECT 'faq' AS tabela, COUNT(*) AS total FROM `faq`
UNION ALL
SELECT 'rede_social' AS tabela, COUNT(*) AS total FROM `rede_social`;

-- Queries

SELECT
  u.id,
  u.nome,
  u.email,
  e.cidade,
  e.estado
FROM usuario u
LEFT JOIN endereco e ON e.id_usuario = u.id
ORDER BY u.nome ASC;

SELECT
  id,
  nome,
  data_inicio,
  data_fim,
  vagas_totais,
  status
FROM edicao
ORDER BY data_inicio DESC, data_cadastro DESC;

SELECT
  id,
  metodo,
  parcelas,
  valor,
  status
FROM transacao
WHERE metodo = 'pix'
ORDER BY data_cadastro DESC;

SELECT
  p.id AS participante_id,
  p.nome AS participante,
  rp.parentesco,
  CASE WHEN rp.guardiao_legal = 1 THEN 'Sim' ELSE 'Não' END AS guardiao_legal,
  u.id AS responsavel_id,
  u.nome AS responsavel,
  r.cpf AS cpf_responsavel,
  u.email AS email_responsavel
FROM participante p
JOIN responsavel_participante rp ON rp.participante_id = p.id
JOIN responsavel r ON r.usuario_id = rp.responsavel_id
JOIN usuario u ON u.id = r.usuario_id
ORDER BY p.nome ASC, u.nome ASC;

SELECT
  e.id AS edicao_id,
  e.nome AS edicao,
  e.status,
  COALESCE(SUM(t_insc.valor), 0.00) AS total_inscricoes,
  COALESCE(SUM(t_doa.valor), 0.00) AS total_doacoes,
  COALESCE(SUM(t_insc.valor), 0.00) + COALESCE(SUM(t_doa.valor), 0.00) AS total_arrecadado
FROM edicao e
LEFT JOIN inscricao i ON i.edicao_id = e.id
LEFT JOIN pagamento_inscricao pi ON pi.inscricao_id = i.id
LEFT JOIN transacao t_insc ON t_insc.id = pi.transacao_id AND t_insc.status = 'aprovada'
LEFT JOIN doacao d ON d.edicao_id = e.id
LEFT JOIN transacao t_doa ON t_doa.id = d.transacao_id AND t_doa.status = 'aprovada'
GROUP BY e.id, e.nome, e.status
ORDER BY total_arrecadado DESC, e.data_inicio DESC;

SELECT
  la.id AS log_id,
  la.acao,
  la.entidade,
  la.dados_antes,
  la.dados_depois,
  la.ip,
  la.data_cadastro AS data_hora_evento,
  COALESCE(a.nome, 'Sistema / Admin removido') AS admin_nome,
  a.email AS admin_email,
  a.perfil AS admin_perfil
FROM log_auditoria la
LEFT JOIN admin a ON a.id = la.admin_id
ORDER BY la.data_cadastro DESC;

SELECT
  COALESCE(e.nome, 'TOTAL GERAL') AS edicao,
  COUNT(i.id) AS total_inscricoes_confirmadas
FROM edicao e
LEFT JOIN inscricao i
  ON i.edicao_id = e.id
  AND i.status = 'confirmada'
GROUP BY e.nome WITH ROLLUP;

SELECT
  p.id AS participante_id,
  p.nome AS participante,
  e.nome AS edicao,
  i.status AS status_inscricao,
  i.tipo_vaga,
  COALESCE(t.status, 'sem_pagamento') AS status_pagamento,
  t.metodo AS metodo_pagamento,
  t.valor AS valor_transacao,
  CASE
    WHEN fm.id IS NULL THEN 'não_enviada'
    WHEN fm.validada_em IS NOT NULL THEN 'validada'
    ELSE 'aguardando_validacao'
  END AS status_ficha_medica,
  a.nome AS ficha_validada_por
FROM inscricao i
JOIN participante p ON p.id = i.participante_id
JOIN edicao e ON e.id = i.edicao_id
LEFT JOIN pagamento_inscricao pi ON pi.inscricao_id = i.id
LEFT JOIN transacao t ON t.id = pi.transacao_id
LEFT JOIN ficha_medica fm ON fm.inscricao_id = i.id
LEFT JOIN admin a ON a.id = fm.validada_por
ORDER BY e.data_inicio DESC, p.nome ASC;

SELECT
  pa.stakeholder_id,
  pa.nome_marca,
  spj.razao_social,
  spj.cnpj,
  u.email,
  COUNT(d.id) AS quantidade_doacoes,
  COALESCE(SUM(CASE WHEN t.status = 'aprovada' THEN t.valor ELSE 0 END), 0.00) AS total_doado_aprovado
FROM parceiro pa
JOIN stakeholder_pj spj ON spj.stakeholder_id = pa.stakeholder_id
JOIN usuario u ON u.id = pa.stakeholder_id
JOIN doacao d ON d.stakeholder_id = pa.stakeholder_id
JOIN transacao t ON t.id = d.transacao_id
GROUP BY
  pa.stakeholder_id,
  pa.nome_marca,
  spj.razao_social,
  spj.cnpj,
  u.email
ORDER BY total_doado_aprovado DESC;

SELECT
  DATE_FORMAT(data_cadastro, '%Y-%m') AS ano_mes,
  COUNT(*) AS total_inscricoes,
  SUM(CASE WHEN status = 'confirmada' THEN 1 ELSE 0 END) AS confirmadas,
  SUM(CASE WHEN status = 'pendente' THEN 1 ELSE 0 END) AS pendentes,
  SUM(CASE WHEN status = 'lista_espera' THEN 1 ELSE 0 END) AS lista_espera,
  SUM(CASE WHEN status = 'cancelada' THEN 1 ELSE 0 END) AS canceladas
FROM inscricao
GROUP BY DATE_FORMAT(data_cadastro, '%Y-%m')
ORDER BY ano_mes DESC;