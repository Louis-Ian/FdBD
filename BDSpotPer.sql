--SITE:
--https://codeshare.io/aymP99

-- Criar o diretório C:\BDSpotPer--
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
---------------
--Criar tabelas

USE BDSpotPer

CREATE TABLE playlists(
  cod_playlist int NOT NULL,
    nome varchar(20),
    duração float,
    criação date,
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
  duracao decimal(5,2),
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

---------------------- FUNCIONA ATÉ AQUI

CREATE CLUSTERED INDEX IndiceFaixaPrimario
ON faixas (cod_faixas)
WITH (PAD_INDEX=OFF, FILLFACTOR=100)
ON BDSpotPer_fg02

CREATE NONCLUSTERED INDEX IndiceFaixaSecundario
ON faixas
WITH (PAD_INDEX=OFF, FILLFACTOR=100)
ON BDSpotPer_fg02


CREATE VIEW V1(NOME, QTDD)
WITH SCHEMABINDING
AS
  SELECT p.nome, count_big(*)
    FROM  dbo.playlists p INNER JOIN  dbo.AUX01_FAIXAS_PLAYLISTS aux
  ON p.cod_playlist = aux.cod_playlist
    group by p.nome, p.cod_playlist

Create unique clustered index I_V1
on V1 (NOME)

CREATE CLUSTERED INDEX IndiceFaixaPrimario ON faixas WITH PAD_INDEX OFF FILLFACTOR 100 ON BDSpotPer_fg02

CREATE NONCLUSTERED INDEX IndiceFaixaSecundario ON faixas WITH PAD_INDEX OFF FILLFACTOR 100 ON BDSpotPer_fg02

--------------------------
--------------------- JAVA

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.PreparedStatement;


public class Conexão {
  private Connection conn;
  public void conecta(){  
    String connectionURL = "jdbc:sqlserver://localhost:1433;"
        +"databaseName=BDSpotPer";
    try{
      Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver").newInstance();
      this.conn = DriverManager.getConnection(connectionURL,"sa","Admin123");
      System.out.println("Conexão Obtida com sucesso");
    }catch(SQLException ex){
      System.out.println("SQLException: " + ex.getMessage());
      System.out.println("SQLSQLState: " + ex.getSQLState());
      System.out.println("SQLVendorError: " + ex.getErrorCode());
      
    }catch(Exception e){
      System.out.println("Não foi possivel conectar ao banco" + e);
    }
  };
  
  public void sentença(String entrada){ 
    try{
      conn.setAutoCommit(false);
      PreparedStatement ps = conn.prepareStatement(entrada);
      ps.executeUpdate();
      conn.commit();
      
    }catch(SQLException ex){
      if (conn != null) {
            try {
                System.err.print("Rollback efetuado na transação");
                conn.rollback();
            } catch(SQLException e2) {
                System.err.print("Erro na transação!"+e2);
            }
        }
    }
    
  }
  
  public void incluir(String entrada){
    
  }
  
  
  public static void main(String[] args) {
  
    Conexão c = new Conexão();
    c.conecta();

  }

}
