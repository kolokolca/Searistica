import javax.swing.*;
import java.awt.*;
import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.awt.event.*;
import javax.swing.table.*;
import java.util.ArrayList;
import javax.swing.event.*;
import java.io.File;

public class MissionFrame extends JFrame{
	public MissionFrame(){
        setSize(FRAME_WIDTH, FRAME_HEIGHT);
		createXNumTextField();
		createYNumTextField();
		createJButton();
		createMenu();
		createPanel();
		createJTable();
		createTextPanel();
	}

	public void createXNumTextField(){
		xLabel = new JLabel("x:");
		final int FIELD_WIDTH = 10;
		xInput = new JTextField(FIELD_WIDTH);
		xInput.setText("");
	}
	public void createYNumTextField(){
		yLabel = new JLabel("y:");
		final int FIELD_WIDTH = 10;
		yInput = new JTextField(FIELD_WIDTH);
		yInput.setText("");
	}
	public void createJButton(){
		addPoint = new JButton("Add Point");
		class ClickListener implements ActionListener{
			public void actionPerformed(ActionEvent event){
				double x = Double.parseDouble(xInput.getText());
				double y = Double.parseDouble(yInput.getText());
				model.addRow(new Object[]{x,y});
				tablePoints.add(new Double[]{x,y});
				xInput.setText("");
				yInput.setText("");
				dataVis.updateArray(tablePoints);
				if(tablePoints.size()>2 && solverDirectory!=null && uMapLoaded && vMapLoaded)
					solveItem.setEnabled(true);
			}
		}
		ActionListener listener = new ClickListener();
		addPoint.addActionListener(listener);
	}


	public void createPanel(){
		panel = new JPanel();
		panel.setLayout(new BorderLayout());
		panel2 = new JPanel();
		panel2.setLayout(new BorderLayout());
		JPanel panel3 = new JPanel();
		panel3.setLayout(new GridBagLayout());
		panel3.add(xLabel);
		panel3.add(xInput);
		panel3.add(yLabel);
		panel3.add(yInput);
		panel3.add(addPoint);
		panel2.add(panel3, BorderLayout.NORTH);
		dataVis = new GraphingData();
		panel.add(dataVis, BorderLayout.CENTER);
		panel.add(panel2, BorderLayout.EAST);
		add(panel);

	}
	public void createTextPanel(){
		tPanel = new JPanel();
		resultArea = new JTextArea(10,40);
		resultArea.setEditable(false);
		JScrollPane scrollPanea = new JScrollPane(resultArea);
		tPanel.add(scrollPanea);
		panel2.add(tPanel, BorderLayout.SOUTH);
	}
	public void createJTable(){
		model = new DefaultTableModel();
		results = new JTable(model);
		model.addColumn("Longtitude");
		model.addColumn("Latitude");

		tablePoints = new ArrayList<Double[]>();

		class tableListener implements TableModelListener{

			ArrayList<Double[]> points;
			boolean errfound=false;
			public tableListener(ArrayList<Double[]> p){
				points=p;
			}
			public void tableChanged(TableModelEvent e){

				if(e.getType()==TableModelEvent.UPDATE){
					DefaultTableModel table = (DefaultTableModel) e.getSource();
					try{//try to add new value to points, parsing them to doubles
						points.get(e.getFirstRow())[e.getColumn()]=
							Double.parseDouble((String)table.getValueAt(e.getFirstRow(),e.getColumn()));
							if(points.size()>2 && solverDirectory!=null && uMapLoaded && vMapLoaded)
								solveItem.setEnabled(true);
							dataVis.updateArray(points);
					}
					catch(Exception er){//if it doesn't parse, revert them using stored value in points.
						if (errfound){
							errfound=false;
							return;
						}
						er.printStackTrace();
						errfound=true;
						table.setValueAt(points.get(e.getFirstRow())[e.getColumn()],e.getFirstRow(), e.getColumn());
						errfound=false;
					}
				}
				return;
			}
		}

		model.addTableModelListener(new tableListener(tablePoints));

		textPanel = new JPanel();
		JScrollPane scrollPane = new JScrollPane(results);
		results.setPreferredScrollableViewportSize(new Dimension(500,200));
		textPanel.add(scrollPane);
		panel2.add(textPanel, BorderLayout.CENTER);
	}

	public void createMenu(){
		JMenuBar menuBar = new JMenuBar();
		setJMenuBar(menuBar);

		JMenu editMenu = new JMenu("Options");
		menuBar.add(editMenu);

		JMenuItem addItem = new JMenuItem("Add a file of points");
		editMenu.add(addItem);

		class AddListener implements ActionListener{
   			public void actionPerformed(ActionEvent event){
				JFileChooser chooser = new JFileChooser(new File("").getAbsolutePath());
				int returnVal = chooser.showOpenDialog(panel);
				if(returnVal == JFileChooser.APPROVE_OPTION){
					try{
						java.util.Scanner in = new java.util.Scanner(chooser.getSelectedFile());
						while(in.hasNext()){
							Double x = in.nextDouble();
							Double y = in.nextDouble();
							Object[] point = new Object[]{x,y};
							model.addRow(point);
							tablePoints.add(new Double[]{x,y});
						}
						dataVis.updateArray(tablePoints);
						if(tablePoints.size()>2 && solverDirectory!=null && uMapLoaded && vMapLoaded)
							solveItem.setEnabled(true);
					}
					catch(Exception e){
						JOptionPane.showMessageDialog(panel, "Cannot Open File", "Error", JOptionPane.ERROR_MESSAGE);
						e.printStackTrace();
						}

			}
 		}
		ActionListener addListener = new AddListener();
 		addItem.addActionListener(addListener);

		JMenuItem exportItem = new JMenuItem("Export Solution");
		editMenu.add(exportItem);
		exportItem.setEnabled(false);

		solveItem = new JMenuItem("Solve");
		editMenu.add(solveItem);
		solveItem.setEnabled(false);

		class SolveListener implements ActionListener{
   			public void actionPerformed(ActionEvent event){
   				//SolverRunner run = new SolverRunner(solverDirectory, uMapDirectory, vMapDirectory);
   				//respond to the solver
			}
		}
		ActionListener setListener = new SolveListener();
		solveItem.addActionListener(setListener);
		JMenuItem resetItem = new JMenuItem("Reset");
		editMenu.add(resetItem);
		class ResetListener implements ActionListener{
   			public void actionPerformed(ActionEvent event){
				model.setRowCount(0);
				tablePoints.clear();
				dataVis.updateArray(tablePoints);
				solveItem.setEnabled(false);
				//resultArea.setText("");
			}
		}
		ActionListener resetListener = new ResetListener();
		resetItem.addActionListener(resetListener);

		JMenuItem findSolverItem = new JMenuItem("Specify Solver Location");
		editMenu.add(findSolverItem);
		class FindSolverListener implements ActionListener{
   			public void actionPerformed(ActionEvent event){
   				JFileChooser chooser = new JFileChooser(new File("").getAbsolutePath());
				int returnVal = chooser.showOpenDialog(panel);
				if(returnVal == JFileChooser.APPROVE_OPTION){
					solverDirectory = chooser.getSelectedFile().getAbsolutePath();
					if(tablePoints.size()>2)
						solveItem.setEnabled(true);
				}
			}
		}
		ActionListener findSolverListener = new FindSolverListener();
		findSolverItem.addActionListener(findSolverListener);

		JMenuItem mapUItem = new JMenuItem("Specify U Vector Map");
		editMenu.add(mapUItem);
		class findUMap implements ActionListener{
   			public void actionPerformed(ActionEvent event){
   				JFileChooser chooser = new JFileChooser(new File("").getAbsolutePath());
				int returnVal = chooser.showOpenDialog(panel);
				if(returnVal == JFileChooser.APPROVE_OPTION){
					uMapDictectory = chooser.getSelectedFile().getAbsolutePath();
					uMapLoaded = true;
					if(tablePoints.size()>2 && uMapLoaded && vMapLoaded)
						solveItem.setEnabled(true);
				}
			}
		}
		ActionListener findUMap = new findUMap();
		mapUItem.addActionListener(findUMap);

		JMenuItem mapVItem = new JMenuItem("Specify V Vector Map");
		editMenu.add(mapVItem);
		class findVMap implements ActionListener{
   			public void actionPerformed(ActionEvent event){
   				JFileChooser chooser = new JFileChooser(new File("").getAbsolutePath());
				int returnVal = chooser.showOpenDialog(panel);
				if(returnVal == JFileChooser.APPROVE_OPTION){
					vMapDictectory = chooser.getSelectedFile().getAbsolutePath();
					vMapLoaded = true;
					if(tablePoints.size()>2 && uMapLoaded && vMapLoaded)
						solveItem.setEnabled(true);
				}
			}
		}
		ActionListener findVMap = new findVMap();
		mapVItem.addActionListener(findVMap);

	}


	ArrayList<Double[]> tablePoints;
	private JMenuItem solveItem;
	private String solverDirectory;
	private String uMapDictectory;
	private boolean uMapLoaded;
	private String vMapDictectory;
	private boolean vMapLoaded;
	private GraphingData dataVis;
	private String xmessage;
	private String ymessage;
    private JLabel xLabel;
    private JLabel yLabel;
	private JButton addPoint;
	private JTextField xInput;
	private JTextField yInput;
	private JPanel panel;
	private JPanel panel2;
	private JPanel textPanel;
	private JPanel tPanel;
	private JTextArea resultArea;
	private JTable results;
	private DefaultTableModel model;
    private static int FRAME_WIDTH = 960;
    private static int FRAME_HEIGHT = 480;
    private static int DEFAULT_SIZE = 16;
}
