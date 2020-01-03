/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package dungeon;

/**
 *
 * @author jolene
 */
public class Player implements Piece {
    private int length;
    private int height;
    private int x;
    private int y;
    
    public Player(int length, int height) {
        this.length = length;
        this.height = height;
        this.x = 0;
        this.y = 0;
    }
    
    public void move(char command) {
        
        if (command == 'w' && this.y != 0) {
            this.y --;
        } else if (command == 'a' && this.x != 0) {
            this.x --;
        } else if (command == 's' && this.y != this.height - 1) {
            this.y ++;
        } else if (command == 'd' && this.x != this.length - 1) {
            this.x ++;
        }
        
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
        return false;
    }
    
}
