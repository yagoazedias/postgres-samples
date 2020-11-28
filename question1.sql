-- 1. Implemente uma solução através da programação em banco de dados para validar os
-- valores de uma coluna que represente uma situação (estado) garantindo que os seus
-- valores e suas transições atendam a especificação de um diagrama de transição de
-- estados (DTE). Quanto mais genérica e reutilizável for a solução melhor a pontuação
-- nessa questão. Junto da solução deverá ser entregue um cenário de teste
-- demonstrando o funcionamento da solução.

-- Montadora (Tabela: manufacturer):
-- Colunas (id: serial, stage: text):
-- Estágios: (iniciado, em produção, em review, montado)
-- Trocas permitidas: "iniciado" -> "em produção", "em produção" -> "em review", "em review" -> "montado"

-- Criação da tabela
CREATE TABLE manufacturer (id serial PRIMARY KEY, stage VARCHAR);

-- Inserções para exemplo
insert into manufacturer (stage) values ('iniciado');
insert into manufacturer (stage) values ('iniciado');
insert into manufacturer (stage) values ('em produção');
insert into manufacturer (stage) values ('em produção');
insert into manufacturer (stage) values ('em review');
insert into manufacturer (stage) values ('em review');
insert into manufacturer (stage) values ('montado');
insert into manufacturer (stage) values ('montado');

-- Função que retorna uma trigger de validação
CREATE OR REPLACE FUNCTION verify_stage_transition() RETURNS trigger as $verify_stage_transition$
BEGIN
  IF NOT (OLD.stage = 'iniciado' AND NEW.stage = 'em produção')
  AND NOT (OLD.stage = 'em produção' AND NEW.stage = 'em review')
  AND NOT (OLD.stage = 'em review' AND NEW.stage = 'montado')
  THEN
    RAISE EXCEPTION 'TRANSIÇÃO DE ESTADO NÃO PERMITIDA';
  END IF;
  RETURN NEW;
END;
$verify_stage_transition$ LANGUAGE plpgsql;

-- Liga os updates da tabela a trigger e faz a verificação da troca de estado
CREATE TRIGGER verify_stage_transition BEFORE UPDATE ON manufacturer
  FOR EACH ROW EXECUTE PROCEDURE verify_stage_transition();

-- Updates que fazem trocas de estados *NÃO PERMITIDOS*
UPDATE manufacturer SET stage = 'em review' WHERE stage = 'montado';

-- Updates que fazem trocas de estados *PERMITIDOS*
UPDATE manufacturer SET stage = 'em produção' WHERE stage = 'iniciado';

-- ==================================================================================
