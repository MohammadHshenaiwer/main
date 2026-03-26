import java.util.Scanner;
import java.io.*;

public class lab1 {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        String filename = "customerInformation.txt";

        try {
            // Collecting user input
            System.out.println("Please Enter your name");
            String name = scanner.nextLine();

            System.out.println("Please Enter your nationality");
            String nationality = scanner.nextLine();

            System.out.println("Please Enter your phone number");
            String phoneNumber = scanner.nextLine();

            System.out.println("Please Enter your age");
            String age = scanner.nextLine();

            FileWriter fw = new FileWriter(filename, true);
            BufferedWriter bw = new BufferedWriter(fw);
            PrintWriter pw = new PrintWriter(bw);
            pw.println(name + "," + nationality + "," + phoneNumber + "," + age);
            pw.close();

            System.out.println("what do you want me to display for you?");
            System.out.println("1.      The name of the customers (please enter name)");
            System.out.println("2.      The nationality of the customers (please enter nationality).");
            System.out.println("3.      The phone number of the customers (please enter phoneNumber).");
            System.out.println("4.      The age of the customers (please enter age).");

            String choice = scanner.nextLine().trim();
            int index = -1;

            if (choice.equalsIgnoreCase("name")) {
                index = 0;
            } else if (choice.equalsIgnoreCase("nationality")) {
                index = 1;
            } else if (choice.equalsIgnoreCase("phoneNumber")) {
                index = 2;
            } else if (choice.equalsIgnoreCase("age")) {
                index = 3;
            }

            if (index != -1) {
                System.out.println("The " + choice + " of all customers are:");
                BufferedReader br = new BufferedReader(new FileReader(filename));
                String line;
                while ((line = br.readLine()) != null) {
                    String[] data = line.split(",");
                    if (data.length > index) {
                        System.out.println(data[index]);
                    }
                }
                br.close();
            } else {
                System.out.println("Invalid input. enter a valid field");
            }

        } catch (IOException e) {
            System.out.println("An error occurred while handling the file: " + e.getMessage());
        } finally {
            scanner.close();
        }
    }
}
