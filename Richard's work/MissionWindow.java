import javax.swing.JFrame;
public class MissionWindow 
{ 
    public static void main(String args[]) 
    { 
        JFrame frame = new MissionFrame(); 
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE); 
        frame.setTitle("Mission Window"); 
        frame.setVisible(true);
    } 
} 