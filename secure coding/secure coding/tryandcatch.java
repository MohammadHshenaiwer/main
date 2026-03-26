import java.util.InputMismatchException;
import java.util.Scanner;

public class tryandcatch {
    public static void main(String[] args) {
        Scanner input = new Scanner(System.in);
        try {

            System.out.println("please enter two intergers");
            int x = input.nextInt();
            int y = input.nextInt();
            System.out.println(x / y);

            int a[] = { 1, 4, 5 };

            System.out.println("please enter a value");

            int b = input.nextInt();
            System.out.println("the value of the index u wotre is   :" + a[b]);

            String name = "mohaMmad";
            System.out.println("enter the number to tell the coresponding letter");
            int ind = input.nextInt();
            System.out.println(name.charAt(ind));

            String str = input.next();
            int value = Integer.parseInt(str);
            System.out.println(value + 10);

        } catch (NumberFormatException e) {
            System.out.println("please enter  number");

        }

        catch (StringIndexOutOfBoundsException e) {
            System.out.println("please enter a smaller number");
        }

        catch (ArrayIndexOutOfBoundsException e) {
            System.out.println("please enter a number between 1 and 3");
        } catch (InputMismatchException e) {
            System.out.println("please enter a number");
        }
        // catch (ArithmeticException e) {
        // System.out.println("DO NOT ENTER A ZERO");
        // }
        catch (RuntimeException e) {
            System.out.println("this is run time exception: " + e.getMessage());
        } finally {
            System.out.println("see you ");
        }
    }
}