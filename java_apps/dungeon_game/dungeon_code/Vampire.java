/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package dungeon;
import java.util.Random;

public class Vampire implements Piece {
    
    private int length;
    private int x;
    private int y;
    
    public Vampire(int length, int height) {
        Random rando = new Random();
        this.length = length;
        this.x = rando.nextInt(length);
        this.y = rando.nextInt(height);
    }
    
    public int getX() {
        return this.x;
    }
    
    public int getY() {
        return this.y;
    }
    
    public int getPosition() {
        return this.y * this.length + this.x;
    }
    
    public boolean isVamp() {
        return true;
    }
    
}
