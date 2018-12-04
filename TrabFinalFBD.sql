CREATE DATABASE BDSpotPer2
ON
  PRIMARY (
  NAME = 'BDSpotPer',
  FILENAME = 'C:\FBD2\BDSpotPer.mdf',
  SIZE = 5120KB,
  FILEGROWTH = 1024KB
  ),

  FILEGROUP BDSpotPer_fg01
  (
  NAME = 'BDSpotPer_001',
  FILENAME = 'C:\FBD2\BDSpotPer_001.ndf',
  SIZE = 5120KB,
  FILEGROWTH = 30%
  ), 

  FILEGROUP BDSpotPer_fg02
  (
  NAME = 'BDSpotPer_002-1',
  FILENAME = 'C:\FBD2\BDSpotPer_002_1.ndf',
  SIZE = 2048KB,
  MAXSIZE = 5120KB,
  FILEGROWTH = 1024KB
  ),
  (
  NAME ='BDSpotPer_002-2',
  FILENAME = 'C:\FBD2\BDSpotPer_002_2.ndf',
  SIZE = 1024KB,
  MAXSIZE = 3072KB,
  FILEGROWTH = 15%
  )

  LOG ON 
  (
  NAME = 'BDSpotPer_log',
  FILENAME = 'C:\FBD2\BDSpotPer_log.ldf',
  SIZE = 1024KB,
  FILEGROWTH = 10%
  )
---------------
--Criar tabelas

USE BDSpotPer2

CREATE TABLE playlists(
	cod_playlist int NOT NULL,
  	nome varchar(20),
  	duração float,
  	criação	date,
  	CONSTRAINT PK_PLAYLISTS PRIMARY KEY (cod_playlist)
) on BDSpotPer_fg01

CREATE TABLE composicoes(
	cod_composicoes int NOT NULL,
  	descricao varchar(140),
   	tipo_composicao varchar(20),
  	CONSTRAINT PK_COMPOSICOES PRIMARY KEY (cod_composicoes)
) on BDSpotPer_fg02

CREATE TABLE faixas(
	cod_faixas int NOT NULL,
  	cod_composicoes int NOT NULL,
	descricao varchar(140),
	duracao decimal(5,2) not null,
	tipo_gravacao varchar(20),
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
  	cod_album int not null,
  	descricao varchar(140),
  	preco_compra float,
  	data_compra date,
  	data_gravacao date,
  	tipo_compra varchar(8),
  	cod_gravadora int not null,
  	CONSTRAINT PK_ALBUNS PRIMARY KEY (cod_album),
  	CONSTRAINT FK_ALBUNS_GRAVADORAS FOREIGN KEY (cod_gravadora) REFERENCES gravadoras
) on BDSpotPer_fg02

CREATE TABLE AUX02_FAIXAS_ALBUNS(
   	cod_faixas int not null,
	cod_albuns int not null
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

CREATE VIEW V1
WITH SCHEMABINDING
AS
	SELECT p.nome as nome, count_big(*) as qtde
    FROM  dbo.playlists p INNER JOIN  dbo.AUX01_FAIXAS_PLAYLISTS aux
	ON p.cod_playlist = aux.cod_playlist
    group by p.nome

Create unique clustered index I_V1
on V1 (nome)

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

ALTER TABLE faixas
DROP CONSTRAINT PK_faixas

CREATE CLUSTERED INDEX IndiceFaixaPrimario
ON faixas (cod_faixas)
WITH (PAD_INDEX=OFF, FILLFACTOR=100)
ON BDSpotPer_fg02

CREATE NONCLUSTERED INDEX IndiceFaixaSecundario
ON faixas (tipo_gravacao)
WITH (PAD_INDEX=OFF, FILLFACTOR=100)
ON BDSpotPer_fg02

ALTER TABLE AUX05_FAIXAS_INTERPRETES
ADD CONSTRAINT PK_AUX05_FAIXAS_INTERPRETES PRIMARY KEY (cod_faixas, cod_interpretes)

ALTER TABLE faixas
ADD CONSTRAINT PK_faixas PRIMARY KEY (cod_faixas)

ALTER TABLE AUX05_FAIXAS_INTERPRETES
ADD CONSTRAINT FK_AUX05_FAIXAS FOREIGN KEY (cod_faixas) REFERENCES faixas ON DELETE CASCADE ON UPDATE CASCADE

ALTER TABLE AUX03_FAIXAS_COMPOSITORES
ADD CONSTRAINT FK_AUX03_FAIXAS FOREIGN KEY (cod_faixas) REFERENCES faixas ON DELETE CASCADE ON UPDATE CASCADE

ALTER TABLE AUX02_FAIXAS_ALBUNS
ADD CONSTRAINT FK_AUX02_FAIXAS FOREIGN KEY (cod_faixas) REFERENCES faixas ON DELETE CASCADE ON UPDATE CASCADE

ALTER TABLE AUX01_FAIXAS_PLAYLISTS
ADD CONSTRAINT FK_AUX01_FAIXAS FOREIGN KEY (cod_faixas) REFERENCES faixas ON DELETE CASCADE ON UPDATE CASCADE



ALTER TABLE albuns  WITH CHECK ADD  CONSTRAINT CONS_MIN_DATE CHECK  ((data_compra>datefromparts((2000),(1),(1))))
ALTER TABLE albuns  WITH CHECK ADD  CONSTRAINT CONS_TYPE_BUY CHECK  ((tipo_compra='CD' OR tipo_compra='vinil' OR tipo_compra='download'))
ALTER TABLE faixas  WITH CHECK ADD  CONSTRAINT CONS_TYPE_MUSIC CHECK  ((tipo_gravacao='ADD' OR tipo_gravacao='DDD'))

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

CREATE TRIGGER gatilho1
ON AUX02_FAIXAS_ALBUNS
FOR INSERT, UPDATE
AS
	IF(
		(SELECT cod_faixas FROM inserted)
		NOT IN
		(SELECT f.cod_faixas 
		FROM faixas f, AUX03_FAIXAS_COMPOSITORES fc ,compositores c, AUX04_PERIODOS_COMPOSITORES pc, periodos p 
		WHERE f.cod_faixas = fc.cod_faixas and fc.cod_compositores = c.cod_compositores and c.cod_compositores = pc.cod_compositores and pc.cod_periodos = p.cod_periodos and p.descrição = 'Barroco' and f.tipo_gravacao <> 'DDD')
	)
	BEGIN
	RAISERROR('Tentando entrar no album faixa do periodo barroco, que não é do tipo DDD', 15, 1)
	ROLLBACK TRANSACTION
	END

CREATE TRIGGER gatilho2
ON AUX02_FAIXAS_ALBUNS
FOR INSERT
AS
	IF(
	(SELECT COUNT(*)
	FROM AUX02_FAIXAS_ALBUNS fa
	WHERE fa.cod_albuns = (SELECT cod_albuns FROM inserted)) = 65)
	BEGIN
	RAISERROR ('Album Cheio',15,1)
	ROLLBACK TRANSACTION
	END

CREATE TRIGGER gatilho3
ON albuns
FOR INSERT
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
	RAISERROR('Tentando entrar no album faixa do periodo barroco, que não é do tipo DDD', 15, 1)
	ROLLBACK TRANSACTION
	END
	FETCH next FROM cursor_1 INTO @cod_faixass
	END
	DEALLOCATE cursor_1

CREATE TRIGGER gatilho2_cursor
ON AUX02_FAIXAS_ALBUNS
FOR INSERT
AS
	BEGIN
	DECLARE @cod_albunss int
	DECLARE cursor_2 CURSOR SCROLL FOR (SELECT cod_albuns FROM inserted)
	OPEN cursor_2
	FETCH first FROM cursor_2 INTO @cod_albunss
    WHILE(@@FETCH_STATUS = 0)
	BEGIN
	IF(
	(SELECT COUNT(*)
	FROM AUX02_FAIXAS_ALBUNS fa
	WHERE fa.cod_albuns = @cod_albunss) = 65)
	BEGIN
	RAISERROR('Album Cheio',15,1)
	ROLLBACK TRANSACTION
	END
    FETCH next FROM cursor_2 INTO @cod_albunss
	END
	DEALLOCATE cursor_2
	END


SELECT *
FROM funcao1('ZE')

insert into periodos values(2,null,'aaa')
insert into AUX04_PERIODOS_COMPOSITORES values (1,2)
insert into faixas values (3,1,null,null,'ADD')
insert into faixas values (4,1,null,null,'ADD')
insert into faixas values (5,1,null,null,'ADD')
insert into faixas values (6,1,null,null,'ADD')
insert into faixas values (7,1,null,null,'ADD')
insert into faixas values (8,1,null,null,'ADD')
insert into faixas values (9,1,null,null,'ADD')
insert into faixas values (10,1,null,null,'ADD')
insert into faixas values (11,1,null,null,'ADD')
insert into faixas values (12,1,null,null,'ADD')
insert into faixas values (13,1,null,null,'ADD')
insert into faixas values (14,1,null,null,'ADD')
insert into faixas values (15,1,null,null,'ADD')
insert into faixas values (16,1,null,null,'ADD')
insert into faixas values (17,1,null,null,'ADD')
insert into faixas values (18,1,null,null,'ADD')
insert into faixas values (19,1,null,null,'ADD')
insert into faixas values (20,1,null,null,'ADD')
insert into faixas values (21,1,null,null,'ADD')
insert into faixas values (22,1,null,null,'ADD')
insert into faixas values (23,1,null,null,'ADD')
insert into faixas values (24,1,null,null,'ADD')
insert into faixas values (25,1,null,null,'ADD')
insert into faixas values (26,1,null,null,'ADD')
insert into faixas values (27,1,null,null,'ADD')
insert into faixas values (28,1,null,null,'ADD')
insert into faixas values (29,1,null,null,'ADD')
insert into faixas values (30,1,null,null,'ADD')
insert into faixas values (31,1,null,null,'ADD')
insert into faixas values (32,1,null,null,'ADD')
insert into faixas values (33,1,null,null,'ADD')
insert into faixas values (34,1,null,null,'ADD')
insert into faixas values (35,1,null,null,'ADD')
insert into faixas values (36,1,null,null,'ADD')
insert into faixas values (37,1,null,null,'ADD')
insert into faixas values (38,1,null,null,'ADD')
insert into faixas values (39,1,null,null,'ADD')
insert into faixas values (40,1,null,null,'ADD')
insert into faixas values (41,1,null,null,'ADD')
insert into faixas values (42,1,null,null,'ADD')
insert into faixas values (43,1,null,null,'ADD')
insert into faixas values (44,1,null,null,'ADD')
insert into faixas values (45,1,null,null,'ADD')
insert into faixas values (46,1,null,null,'ADD')
insert into faixas values (47,1,null,null,'ADD')
insert into faixas values (48,1,null,null,'ADD')
insert into faixas values (49,1,null,null,'ADD')
insert into faixas values (50,1,null,null,'ADD')
insert into faixas values (51,1,null,null,'ADD')
insert into faixas values (52,1,null,null,'ADD')
insert into faixas values (53,1,null,null,'ADD')
insert into faixas values (54,1,null,null,'ADD')
insert into faixas values (55,1,null,null,'ADD')
insert into faixas values (56,1,null,null,'ADD')
insert into faixas values (57,1,null,null,'ADD')
insert into faixas values (58,1,null,null,'ADD')
insert into faixas values (59,1,null,null,'ADD')
insert into faixas values (60,1,null,null,'ADD')
insert into faixas values (61,1,null,null,'ADD')
insert into faixas values (62,1,null,null,'ADD')
insert into faixas values (63,1,null,null,'ADD')
insert into faixas values (64,1,null,null,'ADD')
insert into faixas values (65,1,null,null,'ADD')
insert into faixas values (66,1,null,null,'ADD')

insert into AUX03_FAIXAS_COMPOSITORES values(3,1)
insert into AUX03_FAIXAS_COMPOSITORES values(4,1)
insert into AUX03_FAIXAS_COMPOSITORES values(5,1)
insert into AUX03_FAIXAS_COMPOSITORES values(6,1)
insert into AUX03_FAIXAS_COMPOSITORES values(7,1)
insert into AUX03_FAIXAS_COMPOSITORES values(8,1)
insert into AUX03_FAIXAS_COMPOSITORES values(9,1)
insert into AUX03_FAIXAS_COMPOSITORES values(10,1)
insert into AUX03_FAIXAS_COMPOSITORES values(11,1)
insert into AUX03_FAIXAS_COMPOSITORES values(12,1)
insert into AUX03_FAIXAS_COMPOSITORES values(13,1)
insert into AUX03_FAIXAS_COMPOSITORES values(14,1)
insert into AUX03_FAIXAS_COMPOSITORES values(15,1)
insert into AUX03_FAIXAS_COMPOSITORES values(16,1)
insert into AUX03_FAIXAS_COMPOSITORES values(17,1)
insert into AUX03_FAIXAS_COMPOSITORES values(19,1)
insert into AUX03_FAIXAS_COMPOSITORES values(20,1)
insert into AUX03_FAIXAS_COMPOSITORES values(21,1)
insert into AUX03_FAIXAS_COMPOSITORES values(22,1)
insert into AUX03_FAIXAS_COMPOSITORES values(23,1)
insert into AUX03_FAIXAS_COMPOSITORES values(24,1)
insert into AUX03_FAIXAS_COMPOSITORES values(25,1)
insert into AUX03_FAIXAS_COMPOSITORES values(26,1)
insert into AUX03_FAIXAS_COMPOSITORES values(27,1)
insert into AUX03_FAIXAS_COMPOSITORES values(28,1)
insert into AUX03_FAIXAS_COMPOSITORES values(29,1)
insert into AUX03_FAIXAS_COMPOSITORES values(30,1)
insert into AUX03_FAIXAS_COMPOSITORES values(31,1)
insert into AUX03_FAIXAS_COMPOSITORES values(32,1)
insert into AUX03_FAIXAS_COMPOSITORES values(33,1)
insert into AUX03_FAIXAS_COMPOSITORES values(34,1)
insert into AUX03_FAIXAS_COMPOSITORES values(35,1)
insert into AUX03_FAIXAS_COMPOSITORES values(36,1)
insert into AUX03_FAIXAS_COMPOSITORES values(37,1)
insert into AUX03_FAIXAS_COMPOSITORES values(38,1)
insert into AUX03_FAIXAS_COMPOSITORES values(39,1)
insert into AUX03_FAIXAS_COMPOSITORES values(40,1)
insert into AUX03_FAIXAS_COMPOSITORES values(41,1)
insert into AUX03_FAIXAS_COMPOSITORES values(42,1)
insert into AUX03_FAIXAS_COMPOSITORES values(43,1)
insert into AUX03_FAIXAS_COMPOSITORES values(44,1)
insert into AUX03_FAIXAS_COMPOSITORES values(45,1)
insert into AUX03_FAIXAS_COMPOSITORES values(46,1)
insert into AUX03_FAIXAS_COMPOSITORES values(47,1)
insert into AUX03_FAIXAS_COMPOSITORES values(48,1)
insert into AUX03_FAIXAS_COMPOSITORES values(49,1)
insert into AUX03_FAIXAS_COMPOSITORES values(50,1)
insert into AUX03_FAIXAS_COMPOSITORES values(51,1)
insert into AUX03_FAIXAS_COMPOSITORES values(52,1)
insert into AUX03_FAIXAS_COMPOSITORES values(53,1)
insert into AUX03_FAIXAS_COMPOSITORES values(54,1)
insert into AUX03_FAIXAS_COMPOSITORES values(55,1)
insert into AUX03_FAIXAS_COMPOSITORES values(56,1)
insert into AUX03_FAIXAS_COMPOSITORES values(57,1)
insert into AUX03_FAIXAS_COMPOSITORES values(58,1)
insert into AUX03_FAIXAS_COMPOSITORES values(59,1)
insert into AUX03_FAIXAS_COMPOSITORES values(60,1)
insert into AUX03_FAIXAS_COMPOSITORES values(61,1)
insert into AUX03_FAIXAS_COMPOSITORES values(62,1)
insert into AUX03_FAIXAS_COMPOSITORES values(63,1)
insert into AUX03_FAIXAS_COMPOSITORES values(64,1)
insert into AUX03_FAIXAS_COMPOSITORES values(65,1)
insert into AUX03_FAIXAS_COMPOSITORES values(66,1)


insert into AUX02_FAIXAS_ALBUNS values(3,1)
insert into AUX02_FAIXAS_ALBUNS values(4,1)
insert into AUX02_FAIXAS_ALBUNS values(5,1)
insert into AUX02_FAIXAS_ALBUNS values(6,1)
insert into AUX02_FAIXAS_ALBUNS values(7,1)
insert into AUX02_FAIXAS_ALBUNS values(8,1)
insert into AUX02_FAIXAS_ALBUNS values(9,1)
insert into AUX02_FAIXAS_ALBUNS values(10,1)
insert into AUX02_FAIXAS_ALBUNS values(11,1)
insert into AUX02_FAIXAS_ALBUNS values(12,1)
insert into AUX02_FAIXAS_ALBUNS values(13,1)
insert into AUX02_FAIXAS_ALBUNS values(14,1)
insert into AUX02_FAIXAS_ALBUNS values(15,1)
insert into AUX02_FAIXAS_ALBUNS values(16,1)
insert into AUX02_FAIXAS_ALBUNS values(17,1)
insert into AUX02_FAIXAS_ALBUNS values(18,1)
insert into AUX02_FAIXAS_ALBUNS values(19,1)
insert into AUX02_FAIXAS_ALBUNS values(20,1)
insert into AUX02_FAIXAS_ALBUNS values(21,1)
insert into AUX02_FAIXAS_ALBUNS values(22,1)
insert into AUX02_FAIXAS_ALBUNS values(23,1)
insert into AUX02_FAIXAS_ALBUNS values(24,1)
insert into AUX02_FAIXAS_ALBUNS values(25,1)
insert into AUX02_FAIXAS_ALBUNS values(26,1)
insert into AUX02_FAIXAS_ALBUNS values(27,1)
insert into AUX02_FAIXAS_ALBUNS values(28,1)
insert into AUX02_FAIXAS_ALBUNS values(29,1)
insert into AUX02_FAIXAS_ALBUNS values(30,1)
insert into AUX02_FAIXAS_ALBUNS values(31,1)
insert into AUX02_FAIXAS_ALBUNS values(32,1)
insert into AUX02_FAIXAS_ALBUNS values(33,1)
insert into AUX02_FAIXAS_ALBUNS values(34,1)
insert into AUX02_FAIXAS_ALBUNS values(35,1)
insert into AUX02_FAIXAS_ALBUNS values(36,1)
insert into AUX02_FAIXAS_ALBUNS values(37,1)
insert into AUX02_FAIXAS_ALBUNS values(38,1)
insert into AUX02_FAIXAS_ALBUNS values(39,1)
insert into AUX02_FAIXAS_ALBUNS values(40,1)
insert into AUX02_FAIXAS_ALBUNS values(41,1)
insert into AUX02_FAIXAS_ALBUNS values(42,1)
insert into AUX02_FAIXAS_ALBUNS values(43,1)
insert into AUX02_FAIXAS_ALBUNS values(44,1)
insert into AUX02_FAIXAS_ALBUNS values(45,1)
insert into AUX02_FAIXAS_ALBUNS values(46,1)
insert into AUX02_FAIXAS_ALBUNS values(47,1)
insert into AUX02_FAIXAS_ALBUNS values(48,1)
insert into AUX02_FAIXAS_ALBUNS values(49,1)
insert into AUX02_FAIXAS_ALBUNS values(50,1)
insert into AUX02_FAIXAS_ALBUNS values(51,1)
insert into AUX02_FAIXAS_ALBUNS values(52,1)
insert into AUX02_FAIXAS_ALBUNS values(53,1)
insert into AUX02_FAIXAS_ALBUNS values(54,1)
insert into AUX02_FAIXAS_ALBUNS values(55,1)
insert into AUX02_FAIXAS_ALBUNS values(56,1)
insert into AUX02_FAIXAS_ALBUNS values(57,1)
insert into AUX02_FAIXAS_ALBUNS values(58,1)
insert into AUX02_FAIXAS_ALBUNS values(59,1)
insert into AUX02_FAIXAS_ALBUNS values(60,1)
insert into AUX02_FAIXAS_ALBUNS values(61,1)
insert into AUX02_FAIXAS_ALBUNS values(62,1)
insert into AUX02_FAIXAS_ALBUNS values(63,1)
insert into AUX02_FAIXAS_ALBUNS values(64,1)
insert into AUX02_FAIXAS_ALBUNS values(65,1)
insert into AUX02_FAIXAS_ALBUNS values(66,1)

delete from AUX02_FAIXAS_ALBUNS where cod_faixas=64
insert into AUX02_FAIXAS_ALBUNS values (66,1)


insert into AUX02_FAIXAS_ALBUNS values (1,1)

select *
from AUX02_FAIXAS_ALBUNS

select *
from gravadoras g, albuns a, AUX02_FAIXAS_ALBUNS fa, faixas f 
where g.cod_gravadoras=a.cod_gravadora and a.cod_album=fa.cod_albuns and fa.cod_faixas=f.cod_faixas



CREATE TRIGGER gatilho4
ON AUX01_FAIXAS_PLAYLISTS
FOR INSERT
AS
	BEGIN
		UPDATE playlists
		SET duração += f.duracao 
		FROM faixas f,inserted i, playlists p
		WHERE f.cod_faixas=i.cod_faixas and p.cod_playlist=i.cod_playlist


	END

CREATE TRIGGER 

insert into playlists values (1,null,0,GETDATE())
insert into AUX01_FAIXAS_PLAYLISTS values (1,70,0,DATEfromPARTs(2015,2,1))
delete from playlists
delete from AUX01_FAIXAS_PLAYLISTS

insert into faixas values (70,1,null,21,'ADD')

select *
from faixas


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

select count(*) from AUX01_FAIXAS_PLAYLISTS fp where fp.cod_faixas=1
select *
from funcao2(1)

select *
from AUX01_FAIXAS_PLAYLISTS fp


select fp.cod_playlist
from AUX01_FAIXAS_PLAYLISTS fp
where fp.cod_faixas = 0


select *
from playlists

select *
from albuns

select *
from AUX01_FAIXAS_PLAYLISTS

delete from AUX01_FAIXAS_PLAYLISTS
where cod_playlist = dbo.funcao2(1)
insert into AUX01_FAIXAS_PLAYLISTS values (4,1,0,GETDATE())

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


select cod_playlist from funcao2(1)

select * from AUX01_FAIXAS_PLAYLISTS