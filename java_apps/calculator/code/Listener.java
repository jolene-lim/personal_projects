/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 *
 * @author jolene
 */

import java.awt.event.*;
import javax.swing.*;

public class Listener implements ActionListener {
    
    private JTextField input;
    private JTextField output;
    private JButton method;
    
    public Listener(JTextField input, JTextField output, JButton method) {
        this.input = input;
        this.output = output;
        this.method = method;
    }
    
    
    @Override
    public void actionPerformed(ActionEvent ae) {
        
        int output = Integer.parseInt(this.output.getText());
        
        if (this.method.getText().equals("Z")) {
            output = 0;
            
        } else {
            int input = Integer.parseInt(this.input.getText());
            
            if (this.method.getText().equals("-")) {
                output -= input;
            
            } else if (this.method.getText().equals("+")) {
                output += input;
            }
        }
        
        this.input.setText("");
        this.output.setText(Integer.toString(output));
        
        
    }
}
