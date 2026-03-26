import java.util.Scanner;
import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;

public class writeinfile {

    public static void main(String[] args) {
        Scanner input = new Scanner(System.in);
        try (BufferedWriter output = new BufferedWriter(new FileWriter("writeinfile.txt", true));) {
            System.out.println("enter a name");
            String name = input.nextLine();
            System.out.println("enter you grade");
            int grade = input.nextInt();
            output.write(name + "\n");
            output.write(grade + "\n");
            output.close();
        } catch (IOException e) {
            System.out.println("An error occurred: " + e.getMessage());
            e.printStackTrace();
        }
    }
}