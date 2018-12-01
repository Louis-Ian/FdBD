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
                    System.err.print("Rollback efetuado na transação");
                    conn.rollback();
                } catch(SQLException e2) {
                    System.err.print("Erro na transação!"+e2);
                }
            }
        }
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
   
    public static void main(String[] args) {
        String url = "jdbc:sqlserver://localhost:1433;"
                +"databaseName=teste";
        fbd c = new fbd(url);
        int opcao = 0;
        Scanner teclado  = new Scanner(System.in);
        do{
            System.out.println("1-Consulta");
            System.out.println("2-Comando");
            System.out.println("0-Sair");
            System.out.print("Escolha: ");
            opcao = teclado.nextInt();
            switch(opcao){
                case 1:
                    c.consulta();
                    break;
                case 2:
                    c.comando();
                    break;
                case 0:
                    System.out.println("Exit");
                    break;
                default:
                    System.out.println("Opção Invalida!");
                    break;
            }
        }while(opcao != 0);
    }
}