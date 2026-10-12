# Alinhamento das tabelas

## Decisões globais

- UUID: CHAR(36) com DEFAULT (UUID()) em todas as PKs e FKs. Funciona no MySQL 8 e no MariaDB 10.4 (versão do phpMyAdmin do grupo), onde UUID_TO_BIN não existe. Custa mais espaço que BINARY(16) e o UUID v1 não é ordenado como o swap do MySQL 8, mas é legível. Default de coluna com expressão exige parênteses: DEFAULT (UUID()). Em log_auditoria.entidade_id o UUID também é gravado em texto (CHAR(36)).
- Palavras reservadas: `lead` é função de janela no MySQL 8 (LEAD). Use sempre crases (`lead`) em queries da aplicação.
- Stakeholder PF/PJ não é disjunto: o banco não impede o mesmo stakeholder ter linha em stakeholder_pf e stakeholder_pj. Parceiro só aceita PJ (FK para stakeholder_pj). Regra de exclusividade fica na aplicação.
- Faixa etária: trigger BEFORE INSERT/UPDATE em inscricao exige participante entre 13 e 17 anos na data de início da edição.
- ficha_medica.inscricao_id não é UNIQUE: uma inscrição pode ter várias fichas (decisão intencional, ex: reenvio).
- log_auditoria é imutável: não possui data_atualizacao.
- Datas: data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP e data_atualizacao DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP.
- Auditoria de “todas as tabelas”: Se a auditoria será feita por trigger, seriam 3 triggers por tabela. Fica na aplicação e documente isso, porque alterações feitas direto no banco não passam por ela.
- Arquivo como link nesse MVP: some a tabela arquivo por hora. Os campos viram \*\_url VARCHAR(2048) direto nas tabelas (logotipo_url, ficha_medica.arquivo_url). Perde-se mime_type e tamanho, mas ganha-se simplicidade, e migrar para arquivo depois é fácil. Essa decisão foi feita pensando em não lidar com armazenamento de arquivos ou com armazenamento em nuvem (ex: AWS S3).
- Fluxo de interação de serviços:

```mermaid
graph TD
    Landing[Landing (pública)] -->|/public/* (sem auth)| API
    CRM[CRM (admin)] -->|/admin/* (auth + RBAC)| API
    API --> MySQL
```

## A. Pessoas e CRM (supertipo usuario)

| Entidade                           | Atributos                                                                 |
| ---------------------------------- | ------------------------------------------------------------------------- |
| usuario                            | id, nome, email UNIQUE, telefone, endereco_id?                            |
| responsavel (PK/FK usuario)        | usuario_id, cpf UNIQUE                                                    |
| stakeholder                        | usuario_id                                                                |
| stakeholder_pf (PK/FK stakeholder) | stakeholder_id, cpf UNIQUE //REDUNDANCIA CONTROLADA DO CPF                |
| stakeholder_pj (PK/FK stakeholder) | stakeholder_id, cnpj UNIQUE, razao_social                                 |
| parceiro (PK/FK stakeholder_pj)    | stakeholder_id, nome_marca, logotipo_url, site_url, ativo                 |
| lead                               | id, usuario_id, edicao_id?, origem ENUM, status_funil ENUM, convertido_em |
| participante                       | id, nome, data_nascimento                                                 |
| responsavel_participante (N:N)     | PK(responsavel_id, participante_id), parentesco, guardiao_legal           |
| participante_restricao (N:N)       | PK(participante_id, restricao_id), observacao                             |
| restricao_alimentar (domínio)      | id, nome UNIQUE                                                           |
| endereco                           | id, cep, logradouro, numero, complemento, bairro, cidade, estado          |

## B. Edição e inscrição

| Entidade                         | Atributos                                                                                                                      |
| -------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| edicao                           | id, nome, data_inicio, data_fim, vagas_totais, valor, status ENUM                                                              |
| inscricao                        | id, UNIQUE(participante_id, edicao_id), FK composta(responsavel_id, participante_id), status ENUM, tipo_vaga ENUM, etapa_atual |
| ficha_medica                     | id, inscricao_id, arquivo_url, validada_em?, validada_por?                                                                     |
| parceria (N:N parceiro × edição) | PK (parceiro_id, edicao_id), tipo_apoio, exibir_na_landing                                                                     |
| programacao                      | id, edicao_id, dia, hora_inicio, titulo, descricao                                                                             |

## C. Financeiro

| Entidade                              | Atributos                                                                            |
| ------------------------------------- | ------------------------------------------------------------------------------------ |
| transacao                             | id, metodo ENUM, parcelas, valor, status ENUM, gateway, gateway_transacao_id? UNIQUE |
| pagamento_inscricao (PK/FK transacao) | transacao_id, inscricao_id                                                           |
| doacao                                | id, stakeholder_id, transacao_id, edicao_id?, anonima, comprovante_arquivo_url?      |
| gateway_evento                        | id, transacao_id, evento_externo_id UNIQUE, tipo ENUM, payload JSON, processado_em   |

## D. Comunicação e LGPD

| Entidade         | Atributos                                                                                      |
| ---------------- | ---------------------------------------------------------------------------------------------- |
| template_contato | id, tipo ENUM, assunto, corpo, ativo //agrupar um disparo em lote de e-mails                   |
| campanha         | id, nome, template_id, criada_por                                                              |
| comunicacao      | id, usuario_id, template_id, campanha_id?, inscricao_id?, canal, assunto, corpo, status, erro? |
| mensagem_contato | id, usuario_id, assunto, mensagem, status ENUM                                                 |
| consentimento    | id, usuario_id, finalidade, versao_termo, aceito, registrado_em, ip //LGPD                     |

## E. Conteúdo editável da landing

| Entidade       | Atributos                                                               |
| -------------- | ----------------------------------------------------------------------- |
| secao          | id, slug, nome                                                          |
| conteudo_texto | id, chave UNIQUE (ex: hero.titulo), secao_id, valor, atualizado_por     |
| midia          | id, secao_id, edicao_id?, url_externa, tipo ENUM, legenda, ordem, ativo |
| faq            | id, pergunta, resposta, ordem, ativo                                    |
| rede_social    | id, nome, url, ordem, ativo                                             |

**ordem:** É um número inteiro que define em que posição cada item aparece na tela.

### ENTIDADES PLANEJADAS PARA ESCOPO FUTURO:

| Entidade | Atributos                                                  |
| -------- | ---------------------------------------------------------- |
| arquivo  | id, caminho, nome_original, mime_type, tamanho_bytes, hash |

## F. Acesso e auditoria

| Entidade      | Atributos                                                                           |
| ------------- | ----------------------------------------------------------------------------------- |
| admin         | id, nome, email UNIQUE, senha_hash, perfil ENUM, ativo, ultimo_login_em             |
| log_auditoria | id, admin_id?, acao, entidade, entidade_id, dados_antes JSON, dados_depois JSON, ip |
