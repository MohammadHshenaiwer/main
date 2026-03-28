import java.util.Scanner;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.FileReader;
import java.io.BufferedReader;

public class readfile {
    public static void main(String[] args) {
        Scanner scan = new Scanner(Syste19m.in);
        System.out.println("enter NAME or GRADE");
        String search = scan.nextLine();
        try (BufferedReader input = new BufferedReader(new FileReader("writeinfile.txt"));) {
            String line;
            while ((line = input.readLine()) != null) {
                String parts[] = line.split(",");
                if (search.equalsIgnoreCase("Name"))
                    System.out.println("Name: " + parts[0]);
                else if (search.equalsIgnoreCase("Grade"))
                    System.out.println("Grade: " + parts[1]);

            }

        } catch (FileNotFoundException e) {
            System.out.println("An error occurred: " + e.getMessage());
        } catch (IOException e) {
            System.out.println("An error occurred: " + e.getMessage());
        }
    }
}
