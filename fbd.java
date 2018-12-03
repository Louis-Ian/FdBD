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
    private int contador_playlist;
    public fbd(String url){   
        try{
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver").newInstance();
            this.conn = DriverManager.getConnection(url,"sa","123456");
            System.out.println("Conexão Obtida com sucesso");
        }catch(SQLException ex){
            System.out.println("SQLException: " + ex.getMessage());
            System.out.println("SQLSQLState: " + ex.getSQLState());
            System.out.println("SQLVendorError: " + ex.getErrorCode());
           
        }catch(Exception e){
            System.out.println("Não foi possivel conectar ao banco" + e);
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
            System.out.println("SQLException: " + ex.getMessage());
            System.out.println("SQLSQLState: " + ex.getSQLState());
            System.out.println("SQLVendorError: " + ex.getErrorCode());
        }   
    }
    
    public void ouvir_musica() {
        
        System.out.println("Digite o código da musica que você deseja ouvir");
        Scanner sc = new Scanner(System.in);
        int entrada = sc.nextInt();
        System.out.println("Para parar de ouvir a musica digite 0");
        System.out.println("Você está ouvindo " ); 
        try {
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery("select * from faixas where cod_faixas = " + entrada);
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
        	
        CREATE FUNCTION funcao2(@entrada int)
        returns int
        as
        	if( exists(select * from AUX01_FAIXAS_PLAYLIST where cod_faixas=@entrada) )
        		return select cod_playlist from AUX01_FAIXAS_PLAYLIST where cod_faixas = @entrada;
        	else
        		return NULL;
        
        int flag = stmt.execute_Query("exec funcao2(entrada)");
        if(flag!=null){
        	
        	ResultSet rs = stmt.executeQuery("select * from AUX01_FAIXAS_PLAYLISTS where cod_faixas="+entrada);
        	conn.setAutoCommit(false);
        	PreparedStatement ps = conn.prepareStatement("update AUX01_FAIXAS_PLAYLISTS("+entrada+",exec funcao2("+entrada+","+rs.getInt(2)+",getdate())");
            ps.executeUpdate();
            conn.commit();
            conn.setAutoCommit(true);
        	
        }
        }catch(SQLException ex){
            System.out.println("SQLException: " + ex.getMessage());
            System.out.println("SQLSQLState: " + ex.getSQLState());
            System.out.println("SQLVendorError: " + ex.getErrorCode());
        }
        
        while(sc.hasNext()){
            entrada = sc.nextInt();
            if(entrada == 0) break;
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
    
    public void inserir_playlist_db(String nome) {
         try{  
             conn.setAutoCommit(false);
             PreparedStatement ps = conn.prepareStatement("insert into playlists values(" + contador_playlist +","+ nome+", 0, getdate())");
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
                     System.err.println("Erro na transação!"+e2);
                 }
             }
         }
    }
    
    public void inserir_faixa_playlist(int cod_faixa, int cod_playlist) {
     try{  
            conn.setAutoCommit(false);
            PreparedStatement ps = conn.prepareStatement("insert into AUX02_FAIXAS_PLAYLIST values(" + cod_faixa +","+ cod_playlist+", 0, getdate())");
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
    
    public void alterar_album(String ref, int cod, String n_ref, int preco, String tipo_compra, int cod_gravadora ) {
        try{  
            conn.setAutoCommit(false);
            String sql = "update album set cod=?, descricao=?, preco_compra=?, data_compra=?, data_gravacao=?, tipo_compra=?, cod_gravadora=? where descricao=?";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1,cod);
            stmt.setString(2,n_ref);
            stmt.setInt(3,preco);
            stmt.setString(6,tipo_compra);
            stmt.setInt(7, cod_gravadora);
            stmt.setString(8,ref);
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
                    System.err.println("Erro na transação!"+e2);
                }
            }
        }     
    }
   
    public static void main(String[] args) {
        String url = "jdbc:sqlserver://localhost:1433;"
                +"databaseName=BDSpotPer2";
        fbd c = new fbd(url);
        int opcao = 0;
        Scanner teclado  = new Scanner(System.in);
        
        do{ 
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
                    c.ouvir_musica();
                    break;
                case 2:
                    c.listar_albuns();
                    break;
                case 3:
                    c.inserir_playlist_db(teclado.next());
                    break;
                case 4:
                    c.inserir_faixa_playlist(teclado.nextInt(),teclado.nextInt());
                    break;
                case 5:
                    c.inserir_album_playlist(teclado.nextInt(),teclado.nextInt());
                    break;
                case 6:
                    c.alterar_album(teclado.nextLine(),teclado.nextInt(),teclado.next(),teclado.nextInt(),teclado.next(),teclado.nextInt());
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
