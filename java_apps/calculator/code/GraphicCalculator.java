
import java.awt.*;
import javax.swing.*;

public class GraphicCalculator implements Runnable {
    private JFrame frame;

    @Override
    public void run() {
        frame = new JFrame("Calculator");
        frame.setPreferredSize(new Dimension(300, 150));

        frame.setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);

        createComponents(frame.getContentPane());

        frame.pack();
        frame.setVisible(true);

    }

    private void createComponents(Container container) {
        GridLayout layout = new GridLayout(3, 1);
        container.setLayout(layout);
        
        JTextField output = new JTextField("0");
        output.setEnabled(false);
        
        JTextField input = new JTextField();
        
        // Panel
        JPanel panel = new JPanel(new GridLayout(1, 3));
        
        JButton plus = new JButton("+");
        JButton minus = new JButton("-");
        JButton z = new JButton("Z");
        
        plus.addActionListener(new Listener(input, output, plus));
        minus.addActionListener(new Listener(input, output, minus));
        z.addActionListener(new Listener(input, output, z));
        
        panel.add(plus);
        panel.add(minus);
        panel.add(z);

        container.add(output);
        container.add(input);
        container.add(panel);
        
    }
        

    public JFrame getFrame() {
        return frame;
    }
}
