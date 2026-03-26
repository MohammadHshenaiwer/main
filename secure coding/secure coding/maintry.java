public class maintry {
    public static void func1() {
        // try {
        throw new ArithmeticException("demo");
        // } catch (ArithmeticException e) {
        // System.out.println("inside func1");
        // }
    }

    public static void main(String[] args) {
        // try {
        func1();
        // } catch (ArithmeticException e) {
        // System.out.println("inside main");
        // }
    }

}