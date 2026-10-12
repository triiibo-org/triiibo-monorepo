-- DDL do projeto Triiibo (gerado a partir de docs/DATA_STRUCT_MAP.md)

SET time_zone = "+00:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Banco de dados: `triiibo`
--
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
-- Estrutura para tabela `endereco`
--

CREATE TABLE `endereco` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
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
  KEY `idx_endereco_cep` (`cep`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Estrutura para tabela `usuario`
--

CREATE TABLE `usuario` (
  `id` CHAR(36) NOT NULL DEFAULT (UUID()),
  `nome` VARCHAR(150) NOT NULL,
  `email` VARCHAR(255) NOT NULL,
  `telefone` VARCHAR(20) DEFAULT NULL,
  `endereco_id` CHAR(36) DEFAULT NULL,
  `data_cadastro` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `data_atualizacao` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_usuario_email` (`email`),
  KEY `idx_usuario_endereco` (`endereco_id`),
  CONSTRAINT `fk_usuario_endereco` FOREIGN KEY (`endereco_id`) REFERENCES `endereco` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
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
  PRIMARY KEY (`id`)
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
  CONSTRAINT `fk_ficha_validada_por` FOREIGN KEY (`validada_por`) REFERENCES `admin` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
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
  UNIQUE KEY `uq_transacao_gateway_id` (`gateway_transacao_id`)
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

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
