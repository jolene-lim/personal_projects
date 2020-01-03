/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package dungeon;
import java.util.HashMap;
import java.util.Scanner;
        
/**
 *
 * @author jolene
 */
public class Dungeon {
    
    private int length;
    private int height;
    private int vampires;
    private int moves;
    private boolean vampiresMove;
    private Player player;
    private HashMap<Integer, Piece> positions = new HashMap<Integer, Piece>();
    private Scanner reader = new Scanner(System.in);
    
    public Dungeon() {
        System.out.print("Length of Board: ");
        int length = Integer.parseInt(reader.nextLine());
        
        System.out.print("Width of Board: ");
        int height = Integer.parseInt(reader.nextLine());

        System.out.print("Number of Vampires: ");
        int vampires = Integer.parseInt(reader.nextLine());

        System.out.print("Lamp Lifespan (No. of Rounds): ");
        int moves = Integer.parseInt(reader.nextLine());
        
        System.out.print("Do vampires move (true/false): ");
        boolean vampiresMove = Boolean.parseBoolean(reader.nextLine());
        
        this.length = length;
        this.height = height;
        this.vampires = vampires;
        this.moves = moves;
        this.vampiresMove = vampiresMove;
        this.player = new Player(length, height);
    }
    
    public void run() {
        this.positions.put(this.player.getPosition(), this.player);
        this.createVampires();
                
        for (int k = this.moves; k > 0; k --) {
            
            // Print no of moves
            System.out.println(k);
            System.out.println();
            
            // Print positions
            System.out.println("@ " + this.player.getX() + " " + this.player.getY() + " " + this.player.getPosition());
            
            for (Piece i : this.positions.values()) {
                if (i.isVamp()) {
                    System.out.println("v " + i.getX() + " " + i.getY() + " " + i.getPosition());
                }
            }
            
            System.out.println();
            
            // Print game
            for (int i = 0; i < this.length * this.height ; i ++ ) {
                
                if (this.positions.containsKey(i)) {
                    if (this.positions.get(i).isVamp()) {
                        System.out.print("v");
                    } else {
                        System.out.print("@");
                    }
                } else {
                    System.out.print(".");
                }
                
                if ((i + 1) % this.length == 0) {
                    System.out.println();
                }
            }
            System.out.println();
            
            // Move
            String fullCommand = this.reader.nextLine();
            for (int i = 0; i < fullCommand.length(); i ++) {
                char command = fullCommand.charAt(i);
                this.player.move(command);
                
                if (this.positions.containsKey(this.player.getPosition())) {
                    if (this.positions.get(this.player.getPosition()).isVamp()) {
                        this.positions.remove(this.player.getPosition());
                        this.vampires --;
                    }
                }
            }
                        
            // Update positions if vampires move
            if (this.vampiresMove) {
                this.positions.clear();
                this.positions.put(this.player.getPosition(), this.player);
                this.createVampires();
            }
            
            if (this.vampires == 0) {
                System.out.println("YOU WIN");
                break;
            }
        }
        
        if (this.vampires != 0) {
            System.out.println("YOU LOSE");
        }
        
    }
    

    private void createVampires() {
        for (int i = 0; i < this.vampires; i ++) {
            Vampire vamp = new Vampire(this.length, this.height);
            while (this.positions.containsKey(vamp.getPosition())) {
                vamp = new Vampire(this.length, this.height);
            }
            
            this.positions.put(vamp.getPosition(), vamp);
        }
    }
}
