import java.util.InputMismatchException;
import java.util.Scanner;

public class addfunction {
    public static void main(String[] args) {
        try (Scanner snan = new Scanner(System.in)) {
            System.out.println("enter the first number");
            int num1 = snan.nextInt();
            System.out.println("enter the second number");
            int num2 = snan.nextInt();
            int result = divide(num1, num2);
            System.out.println("The result is:" + result);

        } catch (InputMismatchException e) {
            System.out.println("Error: Invalid input");
        }
    }

    public static int divide(int num1, int num2) {
        try {
            if (num2 == 0) {
                System.out.println("Error: Cannot divide by zero");
                return 0;
            }
            return num1 / num2;
        } catch (ArithmeticException e) {
            System.out.println("Error: Cannot divide by zero");
            return 0;
        }
    }

}
