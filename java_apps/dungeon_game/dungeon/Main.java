package dungeon;
import java.util.Scanner;

public class Main {
    public static void main(String[] args) {
        Scanner reader = new Scanner(System.in);
        System.out.print("Length of Board: ");
        int length = Integer.parseInt(reader.nextLine());
        
        System.out.print("Width of Board: ");
        int width = Integer.parseInt(reader.nextLine());

        System.out.print("Number of Vampires: ");
        int vampires = Integer.parseInt(reader.nextLine());

        System.out.print("Lamp Lifespan (No. of Rounds): ");
        int rounds = Integer.parseInt(reader.nextLine());
        
        System.out.print("Do vampires move (true/false): ");
        boolean move = Boolean.parseBoolean(reader.nextLine());
        
        new Dungeon(length, width, vampires, rounds, move).run();
    }
    
}
