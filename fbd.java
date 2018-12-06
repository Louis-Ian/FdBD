import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.PreparedStatement;
import java.sql.Statement;
import java.sql.ResultSetMetaData;
import java.sql.ResultSet;
import java.util.Scanner;

public class fbd {
    private Connection conn;
    public boolean error;
    public fbd(String url){   
        try{
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver").newInstance();
            this.conn = DriverManager.getConnection(url,"sa","Admin123");
            System.out.println("Conexão Obtida com sucesso");
            this.error = false;
        }catch(SQLException ex){
            System.out.println("SQLException: " + ex.getMessage());
            System.out.println("SQLSQLState: " + ex.getSQLState());
            System.out.println("SQLVendorError: " + ex.getErrorCode());
            this.error = true;
        }catch(Exception e){
            System.out.println("Não foi possivel conectar ao banco" + e);
            this.error = true;
        }
    };
   
    public void comando(){
            Scanner sc = new Scanner(System.in);
            System.out.println("Para finalizar o comando digite 'FIM' ");
            System.out.println("Entre com seu comando");
            String a = "";
            String entrada = "";
            while(sc.hasNext()){
              a = sc.nextLine();
              if(a.equals("FIM")) break;
              entrada = entrada.concat(a);
            }
        try{  
            conn.setAutoCommit(false);
            PreparedStatement ps = conn.prepareStatement(entrada);
            ps.executeUpdate();
            conn.commit();
            conn.setAutoCommit(true);
           
        }catch(SQLException ex){
            if (conn != null) {
                try {
                    System.err.println("Rollback efetuado na transação ");
                    System.out.println("SQLException: " + ex.getMessage());
                    conn.rollback();
                } catch(SQLException e2) {
                	error = true;
                    System.err.println("Erro na transação!"+e2);
                }
            }
        }
        sc.close();
    }

    public void consulta(){

        Scanner sc = new Scanner(System.in);
        System.out.println("Para finalizar a consulta digite 'FIM' ");
        System.out.println("Entre com sua consulta");
        String a = "";
        String entrada = "";
        while(sc.hasNext()){
          a = sc.nextLine();
          if(a.equals("FIM")) break;
          entrada = entrada.concat(a);
        }

        try{
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(entrada);
            ResultSetMetaData rsmet = rs.getMetaData();
            int n_column = rsmet.getColumnCount();
            String change;
            while(rs.next()){
                for (int i = 1; i<=n_column;i++) {
                    change = rs.getString(i);
                    System.out.print(change+" "); 
                }
                System.out.println("");
            }  
        }catch(SQLException ex){
        	error = true;
            System.out.println("SQLException: " + ex.getMessage());
            System.out.println("SQLSQLState: " + ex.getSQLState());
            System.out.println("SQLVendorError: " + ex.getErrorCode());
        }   
    }
    
public void ouvir_musica(int entrada) {
        try{
		Statement stmt2 = conn.createStatement();
    	ResultSet rs3 = stmt2.executeQuery("select cod_faixas from faixas where cod_faixas = "+entrada);
    	rs3.next();
    	int s = rs3.getInt(1);
        System.out.println("VocÃª estÃ¡ ouvindo " );
        Statement stmt = conn.createStatement();
       	ResultSet rs = stmt.executeQuery("select * from dbo.funcao2(1)");
       	rs.next();
       	int flag = rs.getInt(1);
        rs.close();
        if(flag!=0){
        	ResultSet rs2 = stmt.executeQuery("select * from AUX01_FAIXAS_PLAYLISTS where cod_faixas="+entrada);
        	rs2.next();
        	int n = rs2.getInt("num_de_vezes");
            rs2.close();
            stmt.close();
        	conn.setAutoCommit(false);
        	PreparedStatement ps = conn.prepareStatement("update AUX01_FAIXAS_PLAYLISTS set num_de_vezes = ?, ultima_vez=getdate() where cod_faixas=?");
        	ps.setInt(1, n+1);
        	ps.setInt(2, entrada);
            ps.executeUpdate();
            conn.commit();
            conn.setAutoCommit(true);
        	
        }
        }catch(SQLException ex){
            System.out.println("SQLException: " + ex.getMessage());
            System.out.println("SQLSQLState: " + ex.getSQLState());
            System.out.println("SQLVendorError: " + ex.getErrorCode());
        }
}
       
    
    public void listar_albuns() {
    	try {
        	Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("select * from albuns");
            ResultSetMetaData rsmet = rs.getMetaData();
            int n_column = rsmet.getColumnCount();
            String change;
            while(rs.next()){
                for (int i = 1; i<=n_column;i++) {
                    change = rs.getString(i);
                    System.out.print(change+" "); 
                }
                System.out.println("");
            }}catch(SQLException ex){
                System.out.println("SQLException: " + ex.getMessage());
                System.out.println("SQLSQLState: " + ex.getSQLState());
                System.out.println("SQLVendorError: " + ex.getErrorCode());
            } 
    }
    
    public void inserir_playlist_db(int cod, String nome) {
    	 try{  
             conn.setAutoCommit(false);
             PreparedStatement ps = conn.prepareStatement("insert playlists values ("+cod+",null, 0, getdate())");
             ps.executeUpdate();
             ps = conn.prepareStatement("update playlists set nome=? where cod_playlist = ?");
             ps.setString(1, nome);
             ps.setInt(2, cod);
             ps.executeUpdate();
             conn.commit();
             conn.setAutoCommit(true);
            
         }catch(SQLException ex){
             if (conn != null) {
                 try {
                     System.err.println("Rollback efetuado na transação ");
                     System.out.println("SQLException: " + ex.getMessage());
                     conn.rollback();
                 } catch(SQLException e2) {
                	 error = true;
                     System.err.println("Erro na transação!"+e2);
                 }
             }
         }
    }
    
    public void inserir_faixa_playlist(int cod_faixa, int cod_playlist) {
   	 try{  
            conn.setAutoCommit(false);
            PreparedStatement ps = conn.prepareStatement("insert into AUX01_FAIXAS_PLAYLISTS values(" + cod_playlist +","+ cod_faixa+", 0, getdate())");
            ps.executeUpdate();
            conn.commit();
            conn.setAutoCommit(true);
           
        }catch(SQLException ex){
            if (conn != null) {
                try {
                    System.err.println("Rollback efetuado na transação ");
                    System.out.println("SQLException: " + ex.getMessage());
                    conn.rollback();
                } catch(SQLException e2) {
               	 	error = true;
                    System.err.println("Erro na transação!"+e2);
                }
            }
        }
   }
    
    public void inserir_album_playlist(int cod_album, int cod_playlist) {
    	try{  
    		Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("select cod_faixas from AUX02_FAIXAS_ALBUNS where cod_albuns = " + cod_album);
            while(rs.next()){
            	inserir_faixa_playlist(rs.getInt(1), cod_playlist);
            }      
        }catch(SQLException ex){
            System.out.println("SQLException: " + ex.getMessage());
            System.out.println("SQLSQLState: " + ex.getSQLState());
            System.out.println("SQLVendorError: " + ex.getErrorCode());
        } 
    }
    
    public void alterar_album(String ref, int cod, float prcomp, String tipo_compra, int cod_gravadora, String n_ref ) {
    	try{  
            conn.setAutoCommit(false);
    		String sql = "update albuns set cod_album=?, preco_compra=?, tipo_compra=?, cod_gravadora=?,  descricao=? where descricao like ?";
    		PreparedStatement stmt = conn.prepareStatement(sql);
    		stmt.setInt(1,cod);
    		stmt.setFloat(2,prcomp);
    		stmt.setString(3,tipo_compra);
    		stmt.setInt(4,cod_gravadora);
    		stmt.setString(5, n_ref);
    		stmt.setString(6,'%' + ref + '%');
            stmt.executeUpdate();
            conn.commit();
            conn.setAutoCommit(true);
    	}catch(SQLException ex){
            if (conn != null) {
                try {
                    System.err.println("Rollback efetuado na transação ");
                    System.out.println("SQLException: " + ex.getMessage());
                    conn.rollback();
                } catch(SQLException e2) {
            		error = true;
                    System.err.println("Erro na transação!"+e2);
                }
            }
        }     
    }
   
    public static void main(String[] args) {
        String url = "jdbc:sqlserver://localhost:1433;"
                +"databaseName=BDSpotPer";
        fbd c = new fbd(url);
        int opcao = 0;
        Scanner teclado  = new Scanner(System.in);
        
        
        do{ 
        	if(c.error) break;
        	System.out.println("0-Sair");
            System.out.println("1-Ouvir Musica");
            System.out.println("2-Listar Albuns");
            System.out.println("3-Incluir playlist");
            System.out.println("4-Incluir Faixa na Playlist");
            System.out.println("5-Incluir Album na Playlist");
            System.out.println("6-Alterar album");
            System.out.print("Escolha: ");
            opcao = teclado.nextInt();
            switch(opcao){
                case 1:
                    System.out.println("Digite o código da musica que você deseja ouvir");
                    c.ouvir_musica(teclado.nextInt());
                    break;
                case 2:
                	System.out.println("Lista de albuns");
                    c.listar_albuns();
                    break;
                case 3:
                	System.out.println("Entre com o codigo da playlist, seguido do nome dela");
                    c.inserir_playlist_db(teclado.nextInt(),teclado.next());
                    break;
                case 4:
                	System.out.println("Entre com o cod da faixa, seguido do cod da playlist");
                    c.inserir_faixa_playlist(teclado.nextInt(),teclado.nextInt());
                    break;
                case 5:
                	System.out.println("Entre com o cod do album, seguido do cod da playlist");
                    c.inserir_album_playlist(teclado.nextInt(),teclado.nextInt());
                    break;
                case 6:
                	System.out.println("Entre com a descricao do album que deseja alterar, seguido dos novos atributos"
                			+ " cod,preco_compra,tipo_compra,cod_gravadora,descricao");
                    c.alterar_album(teclado.next(),teclado.nextInt() ,teclado.nextFloat(),teclado.next(),teclado.nextInt(),teclado.next());
                    break;
                case 0:
                    System.out.println("Exit");
                    break;
                default:
                    System.out.println("Opção Invalida!");
                    break;
            }
        }while(opcao != 0);
        teclado.close();
    }
}
