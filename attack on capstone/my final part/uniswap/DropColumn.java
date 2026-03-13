import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;

public class DropColumn {
    public static void main(String[] args) {
        String url = "jdbc:postgresql://db.shwfqfuuhzvbhtpzqdbs.supabase.co:5432/postgres?sslmode=require";
        String user = "postgres";
        String password = "Minbl23!mkbn";

        try (Connection conn = DriverManager.getConnection(url, user, password);
             Statement stmt = conn.createStatement()) {
            
            // Drop want_description column from swap_offers
            stmt.execute("ALTER TABLE swap_offers DROP COLUMN IF EXISTS want_description");
            System.out.println("Column dropped successfully.");
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
