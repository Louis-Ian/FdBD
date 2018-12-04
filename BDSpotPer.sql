--SITE:
--https://codeshare.io/aymP99

-------------------------------------
---- Criar o diretório C:\BDSpotPer--
CREATE DATABASE BDSpotPer
ON
  PRIMARY (
  NAME = 'BDSpotPer',
  FILENAME = 'C:\FBD\BDSpotPer.mdf',
  SIZE = 5120KB,
  FILEGROWTH = 1024KB
  ),

  FILEGROUP BDSpotPer_fg01
  (
  NAME = 'BDSpotPer_001',
  FILENAME = 'C:\FBD\BDSpotPer_001.ndf',
  SIZE = 5120KB,
  FILEGROWTH = 30%
  ), 

  FILEGROUP BDSpotPer_fg02
  (
  NAME = 'BDSpotPer_002-1',
  FILENAME = 'C:\FBD\BDSpotPer_002_1.ndf',
  SIZE = 2048KB,
  MAXSIZE = 5120KB,
  FILEGROWTH = 1024KB
  ),
  (
  NAME ='BDSpotPer_002-2',
  FILENAME = 'C:\FBD\BDSpotPer_002_2.ndf',
  SIZE = 1024KB,
  MAXSIZE = 3072KB,
  FILEGROWTH = 15%
  )

  LOG ON 
  (
  NAME = 'BDSpotPer_log',
  FILENAME = 'C:\FBD\BDSpotPer_log.ldf',
  SIZE = 1024KB,
  FILEGROWTH = 10%
  )
--------------------
---- Criar tabelas--

USE BDSpotPer

CREATE TABLE playlists(
	cod_playlist int NOT NULL,
  	nome varchar(20),
  	duração float,
  	criação	date,
  	CONSTRAINT PK_PLAYLISTS PRIMARY KEY (cod_playlist)
) on BDSpotPer_fg01

CREATE TABLE composicoes(
	cod_composicoes int NOT NULL,
   	tipo_composicao varchar(20),
  	descricao varchar(140),
  	CONSTRAINT PK_COMPOSICOES PRIMARY KEY (cod_composicoes)
) on BDSpotPer_fg02

CREATE TABLE faixas(
	cod_faixas int NOT NULL,
  	cod_composicoes int NOT NULL,
	duracao decimal(5,2),
	tipo_gravacao varchar(20) NOT NULL,
	descricao varchar(140),
  	CONSTRAINT PK_FAIXAS PRIMARY KEY (cod_faixas),
  	CONSTRAINT FK_FAIXAS_COMPOSICOES FOREIGN KEY (cod_composicoes) REFERENCES composicoes
) on BDSpotPer_fg01

CREATE TABLE AUX01_FAIXAS_PLAYLISTS(
	cod_playlist int NOT NULL,
  	cod_faixas int NOT NULL,
  	num_de_vezes int,
  	ultima_vez date,
  	CONSTRAINT PK_AUX01_FAIXAS_PLAYLISTS PRIMARY KEY (cod_playlist, cod_faixas),
  	CONSTRAINT FK_AUX01_PLAYLISTS FOREIGN KEY (cod_playlist) REFERENCES playlists,
  	CONSTRAINT FK_AUX01_FAIXAS FOREIGN KEY (cod_faixas) REFERENCES faixas
) on BDSpotPer_fg01

CREATE TABLE gravadoras(
	cod_gravadoras int NOT NULL,
  	nome varchar(29),
  	endereço varchar(29),
  	homepage varchar(39),
  	CONSTRAINT PK_GRAVADORAS PRIMARY KEY (cod_gravadoras)
) on BDSpotPer_fg02

CREATE TABLE telefones(
	cod_gravadoras int NOT NULL,
  	telefones int,
  	CONSTRAINT PK_TELEFONES PRIMARY KEY (cod_gravadoras,telefones),
  	CONSTRAINT FK_TELEFONES_GRAVADORAS FOREIGN KEY (cod_gravadoras) REFERENCES gravadoras
) on BDSpotPer_fg02

CREATE TABLE albuns(
  	cod_album int NOT NULL,
  	preco_compra float NOT NULL,
  	data_compra date NOT NULL,
  	data_gravacao date,
  	tipo_compra varchar(8) NOT NULL,
  	cod_gravadora int NOT NULL,
  	descricao varchar(140),
  	CONSTRAINT PK_ALBUNS PRIMARY KEY (cod_album),
  	CONSTRAINT FK_ALBUNS_GRAVADORAS FOREIGN KEY (cod_gravadora) REFERENCES gravadoras
) on BDSpotPer_fg02

CREATE TABLE AUX02_FAIXAS_ALBUNS(
   	cod_faixas int NOT NULL,
	cod_albuns int NOT NULL,
  	CONSTRAINT PK_AUX02_FAIXAS_ALBUNS PRIMARY KEY (cod_albuns, cod_faixas),
  	CONSTRAINT FK_AUX02_FAIXAS FOREIGN KEY (cod_faixas) REFERENCES faixas,
  	CONSTRAINT FK_AUX02_ALBUNS FOREIGN KEY (cod_albuns) REFERENCES albuns
) on BDSpotPer_fg02

CREATE TABLE compositores(
	cod_compositores int NOT NULL,
  	nome varchar(20),
  	data_nasc date,
  	data_morte date,
  	pais varchar(20),
  	cidade varchar(29),
  	estado varchar(20),
  	CONSTRAINT PK_COMPOSITORES PRIMARY KEY(cod_compositores)
) on BDSpotPer_fg02

CREATE TABLE AUX03_FAIXAS_COMPOSITORES(
	cod_faixas int NOT NULL,
  	cod_compositores int NOT NULL,
  	CONSTRAINT PK_AUX03_FAIXAS_COMPOSITORES PRIMARY KEY (cod_faixas, cod_compositores),
  	CONSTRAINT FK_AUX03_FAIXAS FOREIGN KEY (cod_faixas) REFERENCES faixas,
  	CONSTRAINT FK_AUX03_COMPOSITORES FOREIGN KEY (cod_compositores) REFERENCES compositores
) on BDSpotPer_fg02

CREATE TABLE periodos(
	cod_periodos int NOT NULL,
  	intervalo int,
  	descrição varchar(140),
  	CONSTRAINT FK_PERIODOS PRIMARY KEY (cod_periodos)
) on BDSpotPer_fg02

CREATE TABLE AUX04_PERIODOS_COMPOSITORES(
	cod_compositores int NOT NULL,
  	cod_periodos int NOT NULL,
  	CONSTRAINT PK_AUX04_PERIODOS_COMPOSITORES PRIMARY KEY (cod_compositores, cod_periodos),
  	CONSTRAINT FK_AUX04_COMPOSITORES FOREIGN KEY (cod_compositores) REFERENCES compositores,
  	CONSTRAINT FK_AUX04_PERIODOS FOREIGN KEY (cod_periodos) REFERENCES periodos
) on BDSpotPer_fg02

CREATE TABLE interpretes(
	cod_interpretes int NOT NULL,
  	nome varchar(40),
  	tipo_interprete varchar(20),
  	CONSTRAINT PK_INTERPRETES PRIMARY KEY (cod_interpretes)
) on BDSpotPer_fg02

CREATE TABLE AUX05_FAIXAS_INTERPRETES(
	cod_faixas int NOT NULL,
  	cod_interpretes int NOT NULL,
	CONSTRAINT PK_AUX05_FAIXAS_INTERPRETES PRIMARY KEY (cod_faixas,cod_interpretes),
  	CONSTRAINT FK_AUX05_FAIXAS FOREIGN KEY (cod_faixas) REFERENCES faixas,
  	CONSTRAINT FK_AUX05_INTERPRETES FOREIGN KEY (cod_interpretes) REFERENCES interpretes
) on BDSpotPer_fg02

-------------------
---- Criar visões--
CREATE VIEW V1
WITH SCHEMABINDING
AS
	SELECT p.nome as nome, count_big(*) as qtde
    FROM  dbo.playlists p INNER JOIN  dbo.AUX01_FAIXAS_PLAYLISTS aux
	ON p.cod_playlist = aux.cod_playlist
    group by p.nome

Create unique clustered index I_V1
on V1 (nome)

--------------------
---- Criar indexes--

ALTER TABLE AUX05_FAIXAS_INTERPRETES
DROP CONSTRAINT PK_AUX05_FAIXAS_INTERPRETES

ALTER TABLE AUX05_FAIXAS_INTERPRETES
DROP CONSTRAINT FK_AUX05_FAIXAS

ALTER TABLE AUX03_FAIXAS_COMPOSITORES
DROP CONSTRAINT FK_AUX03_FAIXAS

ALTER TABLE AUX02_FAIXAS_ALBUNS
DROP CONSTRAINT FK_AUX02_FAIXAS

ALTER TABLE AUX01_FAIXAS_PLAYLISTS
DROP CONSTRAINT FK_AUX01_FAIXAS

-----------------------------
---- Perguntar ao professor--
/*
ALTER TABLE faixas
DROP CONSTRAINT PK_faixas

CREATE CLUSTERED INDEX IndiceFaixaPrimario
ON faixas (cod_faixas)
WITH (PAD_INDEX=OFF, FILLFACTOR=100)
ON BDSpotPer_fg02

ALTER TABLE faixas
ADD CONSTRAINT PK_faixas PRIMARY KEY (cod_faixas)
*/

CREATE NONCLUSTERED INDEX IndiceFaixaSecundario
ON faixas (cod_composicoes)
WITH (PAD_INDEX=OFF, FILLFACTOR=100)
ON BDSpotPer_fg02

ALTER TABLE AUX05_FAIXAS_INTERPRETES
ADD CONSTRAINT PK_AUX05_FAIXAS_INTERPRETES PRIMARY KEY (cod_faixas, cod_interpretes)

ALTER TABLE AUX05_FAIXAS_INTERPRETES
ADD CONSTRAINT FK_AUX05_FAIXAS FOREIGN KEY (cod_faixas) REFERENCES faixas ON DELETE CASCADE ON UPDATE CASCADE

ALTER TABLE AUX03_FAIXAS_COMPOSITORES
ADD CONSTRAINT FK_AUX03_FAIXAS FOREIGN KEY (cod_faixas) REFERENCES faixas ON DELETE CASCADE ON UPDATE CASCADE

ALTER TABLE AUX02_FAIXAS_ALBUNS
ADD CONSTRAINT FK_AUX02_FAIXAS FOREIGN KEY (cod_faixas) REFERENCES faixas ON DELETE CASCADE ON UPDATE CASCADE

ALTER TABLE AUX01_FAIXAS_PLAYLISTS
ADD CONSTRAINT FK_AUX01_FAIXAS FOREIGN KEY (cod_faixas) REFERENCES faixas ON DELETE CASCADE ON UPDATE CASCADE

--------------------
---- Criar Função-- 
--Entra nome do compositor e sai o codigo e a descricao dos albuns que ele participou
CREATE FUNCTION funcao1 (@nome_entr VARCHAR(20))
RETURNS @tab_result TABLE(Cod INT ,descricao VARCHAR(140))
AS
BEGIN
	INSERT INTO @tab_result
	SELECT a.cod_album, a.descricao
	FROM albuns a inner join AUX02_FAIXAS_ALBUNS fb inner join faixas f inner join AUX03_FAIXAS_COMPOSITORES fc inner join compositores c
	ON fc.cod_compositores=c.cod_compositores ON f.cod_faixas = fc.cod_faixas ON fb.cod_faixas = f.cod_faixas ON a.cod_album=fb.cod_albuns
	WHERE c.nome = @nome_entr
	RETURN
END

CREATE FUNCTION funcao2(@entrada int)
returns @ret table (cod_playlist int)
as
begin
	if((select count(*) from AUX01_FAIXAS_PLAYLISTS fp where fp.cod_faixas=@entrada)>=1) 
	begin
		insert into @ret
		select fp.cod_playlist
		from AUX01_FAIXAS_PLAYLISTS fp
		where fp.cod_faixas = @entrada
	end
	else
		insert into @ret values (0)
	
	return 
end

-----------------------
---- Criar Restricoes--

ALTER TABLE albuns  WITH CHECK ADD  CONSTRAINT CONS_MIN_DATE CHECK  ((data_compra>datefromparts((2000),(1),(1))))
ALTER TABLE albuns  WITH CHECK ADD  CONSTRAINT CONS_TYPE_BUY CHECK  ((tipo_compra='CD' OR tipo_compra='vinil' OR tipo_compra='download'))
ALTER TABLE faixas  WITH CHECK ADD  CONSTRAINT CONS_TYPE_MUSIC CHECK  ((tipo_gravacao='ADD' OR tipo_gravacao='DDD'));

CREATE TRIGGER gatilho1
ON AUX02_FAIXAS_ALBUNS
FOR INSERT, UPDATE
AS
	
	IF(
		(SELECT cod_faixas FROM inserted)
		NOT IN
		(SELECT f.cod_faixas 
		FROM faixas f, AUX03_FAIXAS_COMPOSITORES fc ,compositores c, AUX04_PERIODOS_COMPOSITORES pc, periodos p 
		WHERE f.cod_faixas = fc.cod_faixas AND fc.cod_compositores = c.cod_compositores AND c.cod_compositores = pc.cod_compositores AND pc.cod_periodos = p.cod_periodos AND p.descrição = 'Barroco' AND f.tipo_gravacao <> 'DDD')
	)
	BEGIN
	RAISERROR('Tentando entrar no album faixa do periodo barroco, que não é do tipo DDD', 15, 1)
	ROLLBACK TRANSACTION
	END;

CREATE TRIGGER gatilho2
ON AUX02_FAIXAS_ALBUNS
FOR INSERT
AS
	IF(
	(SELECT COUNT(*)
	FROM AUX02_FAIXAS_ALBUNS fa
	WHERE fa.cod_albuns = (SELECT cod_albuns FROM inserted)) = 65)
	BEGIN
	RAISERROR('Album Cheio',15,1)
	ROLLBACK TRANSACTION
	END

CREATE TRIGGER gatilho3
ON albuns
FOR INSERT,UPDATE
AS
	IF((SELECT preco_compra FROM inserted) > (SELECT 3*AVG(preco_compra) FROM albuns a,AUX02_FAIXAS_ALBUNS fa,faixas f WHERE a.cod_album=fa.cod_albuns AND fa.cod_faixas=f.cod_faixas AND f.tipo_gravacao='DDD'))
	BEGIN
	RAISERROR('Preco invalido',15,1)
	ROLLBACK TRANSACTION
	END
    

CREATE TRIGGER gatilho1_cursor
ON AUX02_FAIXAS_ALBUNS
FOR INSERT, UPDATE
AS
	DECLARE @cod_faixass int
	DECLARE cursor_1 CURSOR SCROLL FOR SELECT cod_faixas FROM inserted
	OPEN cursor_1
	FETCH first FROM cursor_1 INTO @cod_faixass
	WHILE(@@FETCH_STATUS = 0)
	BEGIN
	IF(
		(@cod_faixass)
		NOT IN
		(SELECT f.cod_faixas 
		FROM faixas f, AUX03_FAIXAS_COMPOSITORES fc ,compositores c, AUX04_PERIODOS_COMPOSITORES pc, periodos p 
		WHERE f.cod_faixas = fc.cod_faixas and fc.cod_compositores = c.cod_compositores and c.cod_compositores = pc.cod_compositores and pc.cod_periodos = p.cod_periodos and p.descrição = 'Barroco' and f.tipo_gravacao <> 'DDD')
	)
	BEGIN
	RAISERROR('Tentando entrar no album  faixa do periodo barroco, que não é do tipo DDD', 10, 6)
	ROLLBACK TRANSACTION
	END
	FETCH next FROM cursor_1 INTO @cod_faixass
	END
	DEALLOCATE cursor_1
    
CREATE TRIGGER gatilho2_cursor
ON AUX02_FAIXAS_ALBUNS
FOR INSERT
AS
	DECLARE @cod_albuns int
	DECLARE cursor_2 CURSOR SCROLL FOR (SELECT cod_albuns FROM inserted)
	OPEN cursor_2
	FETCH first FROM cursor_2 INTO @cod_albuns
    WHILE(@@FETCH_STATUS = 0)
    BEGIN
	IF(
	(SELECT COUNT(*)
	FROM AUX02_FAIXAS_ALBUNS fa
	WHERE fa.cod_albuns = @cod_albuns) = 65)
	BEGIN
	RAISERROR('Album Cheio',10,6)
	ROLLBACK TRANSACTION
	END
    FETCH next FROM cursor_2 INTO @cod_albuns
	END
	DEALLOCATE cursor_2


CREATE TRIGGER gatilho3_cursor
ON albuns
FOR INSERT
AS
	DECLARE @preco_comprass int
	DECLARE cursor_3 CURSOR SCROLL FOR (SELECT preco_compra FROM inserted)
	OPEN cursor_3
	FETCH first FROM cursor_3 INTO @preco_comprass
    WHILE(@@FETCH_STATUS = 0)
    BEGIN
	IF(@preco_comprass > (SELECT 3*AVG(preco_compra) FROM albuns a,AUX02_FAIXAS_ALBUNS fa,faixas f WHERE a.cod_album=fa.cod_albuns AND fa.cod_faixas=f.cod_faixas AND f.tipo_gravacao='DDD'))
	BEGIN
	RAISERROR('Preco invalido',10,6)
	ROLLBACK TRANSACTION
	END
	FETCH next FROM cursor_3 INTO @preco_comprass
	END
	DEALLOCATE cursor_3
	 

CREATE TRIGGER gatilho4
ON AUX01_FAIXAS_PLAYLISTS
FOR INSERT,DELETE
AS
	BEGIN

		UPDATE playlists
		SET duração += f.duracao 
		FROM faixas f, inserted i
		WHERE f.cod_faixas = i.cod_faixas
	
		UPDATE playlists
		SET duração -= f.duracao 
		FROM faixas f, deleted i
		WHERE f.cod_faixas = i.cod_faixas
		
	END
    
------------------
-- Vamos povoar?--


----------------
---- Consultas--


