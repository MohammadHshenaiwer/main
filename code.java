import java.util.Scanner;

public class code {
    public static void main(String[] args) {
        Scanner scan = new Scanner(System.in);
        System.out.println("enter the array size");
        int size = scan.nextInt();
        int[] arr = new int[size];
        for (int i = 0; i < size; i++) {
            System.out.println("enter the element " + i);
            arr[i] = scan.nextInt();
        }
        if (size % 2 == 0) {
            int[] arr2 = new int[size];
            for (int i = 0; i < size; i++) {
                System.out.println("enter element " + i + " for second array:");
                arr2[i] = scan.nextInt();
            }

            boolean isSymmetric = true;
            for (int i = 0; i < size / 2; i++) {
                if (arr2[i] != arr2[size - 1 - i]) {
                    isSymmetric = false;
                    break;
                }
            }

            if (isSymmetric) {
                System.out.println("The first half of the second array is the same as the second half in reverse.");
            } else {
                System.out.println("The first half of the second array is NOT the same as the second half in reverse.");
            }
        } else {
            System.out.println("Array size is odd.");
        }
    }
}
