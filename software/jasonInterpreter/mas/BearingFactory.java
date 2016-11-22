// Environment code for project mas.mas2j

import jason.asSyntax.*;
import jason.environment.*;
import jason.environment.grid.GridWorldModel;
import jason.environment.grid.GridWorldView;
import jason.environment.grid.Location;
import java.util.logging.*;
import java.util.*;

import java.awt.Color;                                                                                        
import java.awt.Font;                                                                                         
import java.awt.Graphics;                                                                                     
import java.util.Random;                                                                                      
import java.util.logging.Logger;  
import javax.swing.*;

import java.awt.BorderLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

public class BearingFactory extends Environment {

	//Environment specs 
	public static final int grid_height = 20;
	public static final int grid_width = 20;
	public static final int nAg = 1;
	
	//Graphical key of static objects
	public static final int stock = 8;
	public static final int assembly_aid_tray = 16;
	public static final int force_fitting_machine = 32;
	public static final int delivery_box = 64;
	
	//Static object locations
	public static final Location stockLoc 			= new Location(3, 2);
	public static final Location aidTrayLoc 		= new Location(15, 2); 
	public static final Location forceFittingLoc 	= new Location(18, 7);
	public static final Location deliveryBoxLoc 	= new Location(6, 17); 
	
	//Perceptions
	public static final Literal moveEast = Literal.parseLiteral("moveEast");
	public static final Literal moveSouth = Literal.parseLiteral("moveSouth");
	public static final Literal moveNorth = Literal.parseLiteral("moveNorth");
	public static final Literal moveWest = Literal.parseLiteral("moveWest");
	public static final Literal dropBearingBox = Literal.parseLiteral("dropBearingBox");
	public static final Literal dropForceFittedBearingBox = Literal.parseLiteral("dropForceFittedBearingBox");
	public static final Literal dropAssemblyAidTray = Literal.parseLiteral("dropAssemblyAidTray");
	public static final Literal finishBearingBox = Literal.parseLiteral("finishBearingBox");
	public static final Literal finishForceFittedBearingBox = Literal.parseLiteral("finishForceFittedBearingBox");
	public static final Literal envSize = Literal.parseLiteral("envSize");
	
	//Order storage
	List<String> openOrders = new ArrayList<String>();
	
	private BearingFactoryModel model;
	private BearingFactoryView view;
	
    private Logger logger = Logger.getLogger("mas.mas2j."+BearingFactory.class.getName());

	JFrame f;
	JButton btn_1;
	JButton btn_2;
	
    /** Called before the MAS execution with the args informed in .mas2j */
    @Override
    public void init(String[] args) {
        model = new BearingFactoryModel();
		view = new BearingFactoryView(model);
		model.setView(view);
		
		//Add static obejct locations as global percept beleifs
		Literal envSize = Literal.parseLiteral("envSize("+grid_width+","+grid_height+")");
		addPercept(envSize);
		Literal stockPos = Literal.parseLiteral("pos(stock, "+stockLoc.x+","+stockLoc.y+")");
		addPercept(stockPos);
		Literal aidTrayPos = Literal.parseLiteral("pos(aidTray, "+aidTrayLoc.x+","+aidTrayLoc.y+")");
		addPercept(aidTrayPos);
		Literal forceFittingPos = Literal.parseLiteral("pos(forceFitting, "+forceFittingLoc.x+","+forceFittingLoc.y+")");
		addPercept(forceFittingPos);
		Literal deliveryBoxPos = Literal.parseLiteral("pos(deliveryBox, "+deliveryBoxLoc.x+","+deliveryBoxLoc.y+")");
		addPercept(deliveryBoxPos);
		updatePercepts();
		
		btn_1 = new JButton("Bearing Box");
		btn_1.addActionListener(new ActionListener(){
			public void actionPerformed(ActionEvent e) {
				btnBearingBoxHandler();
            }
		});
		
		btn_2 = new JButton("Force fitted bearing box");
		btn_2.addActionListener(new ActionListener(){
			public void actionPerformed(ActionEvent e) {
				btnForceFittedBearingBoxHandler();
            }
		});
		
		f = new JFrame("Place your orders");
        f.getContentPane().setLayout(new BorderLayout());
        f.getContentPane().add(BorderLayout.SOUTH, btn_1);
		f.getContentPane().add(BorderLayout.NORTH, btn_2);
        f.pack();
        f.setVisible(true);
    }

    @Override
    public boolean executeAction(String agName, Structure action) {
		try {
			
			if(action.equals(moveEast)) {
				model.moveEast();
			} else if(action.equals(moveSouth)) {
				model.moveSouth();
			} else if(action.equals(moveNorth)) {
				model.moveNorth();
			} else if(action.equals(moveWest)) {
				model.moveWest();
			} else if(action.equals(dropBearingBox)) {
				logger.info("drop bearing box");
			} else if(action.equals(dropForceFittedBearingBox)) {
				logger.info("drop force fitted bearing box");
			} else if(action.equals(dropAssemblyAidTray)) {
				logger.info("drop assembly aid tray");
			} else if(action.equals(finishBearingBox)) {
				removePercept(Literal.parseLiteral("order(bearingBox)"));
			} else if(action.equals(finishForceFittedBearingBox)) {
				removePercept(Literal.parseLiteral("order(forceFittedBearingBox)"));
			} else {
				logger.info("action not defined");
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		informAgsEnvironmentChanged();
		
		try {                                                                                                 
            Thread.sleep(500);                                                                                
        } catch (Exception e) {}  
		
		updatePercepts();
        return true; // the action was executed with success 
    }
	
	
	// Update agent locations
	public void updatePercepts(){
		clearPercepts("robot");
		//Update agent locations
		Location loc1 = model.getAgPos(0);
		Literal pos1 = Literal.parseLiteral("pos(r1,"+loc1.x+","+loc1.y+")");
		addPercept("robot", pos1);
		//Update order queue
	}
	
	private void btnBearingBoxHandler(){
		logger.info("add order");
		openOrders.add("bearingBox");
		Literal order = Literal.parseLiteral("order(bearingBox)");
		addPercept(order);
	}

	private void btnForceFittedBearingBoxHandler(){
		logger.info("add order");
		openOrders.add("forceFittedBearingBox");
		Literal order = Literal.parseLiteral("order(forceFittedBearingBox)");
		addPercept(order);
	}
	
    /** Called before the end of MAS execution */
    @Override
    public void stop() {
        super.stop();
    }
	
	
	class BearingFactoryModel extends GridWorldModel {
		
		private BearingFactoryModel(){
			super(grid_height, grid_width, nAg);
			add(stock, stockLoc);
			add(assembly_aid_tray, aidTrayLoc);
			add(force_fitting_machine, forceFittingLoc);
			add(delivery_box, deliveryBoxLoc);
			setAgPos(0,10,10);
		}
		
		public void moveEast()  throws Exception{
			Location loc_1 = getAgPos(0);
			loc_1.x++;
			setAgPos(0, loc_1);
		}
		
		public void moveSouth()  throws Exception{
			Location loc_1 = getAgPos(0);
			loc_1.y++;
			setAgPos(0, loc_1);
		}
		
		public void moveNorth()  throws Exception{
			Location loc_1 = getAgPos(0);
			loc_1.y--;
			setAgPos(0, loc_1);
		}
		
		public void moveWest()  throws Exception{
			Location loc_1 = getAgPos(0);
			loc_1.x--;
			setAgPos(0, loc_1);
		}
	}
	
	class BearingFactoryView extends GridWorldView {
		
		public BearingFactoryView(BearingFactoryModel model){
			super(model, "Bearing Factory", 400);
			setVisible(true);
			repaint();
		}
		
		@Override
		public void draw(Graphics g, int x, int y, int object) {
			
			switch (object) {
				case stock: 
					drawStock(g, x, y); 
					break;
				case assembly_aid_tray: 
					drawAidTray(g, x, y); 
					break;
				case force_fitting_machine: 
					drawMachine(g, x, y); 
					break;
				case delivery_box: 
					drawDeliveryBox(g, x, y);
			}
		}
		
		public void drawStock(Graphics g, int x, int y){
			super.drawObstacle(g, x, y);
			g.setColor(Color.white);
			drawString(g, x, y, new Font("Arial", Font.BOLD, 16),"St");
		}
		
		public void drawAidTray(Graphics g, int x, int y){
			super.drawObstacle(g, x, y);
			g.setColor(Color.white);
			drawString(g, x, y, new Font("Arial", Font.BOLD, 16),"Ai");
		}
		
		public void drawMachine(Graphics g, int x, int y){
			super.drawObstacle(g, x, y);
			g.setColor(Color.white);
			drawString(g, x, y, new Font("Arial", Font.BOLD, 16),"Fo");
		}
		
		public void drawDeliveryBox(Graphics g, int x, int y){
			super.drawObstacle(g, x, y);
			g.setColor(Color.white);
			drawString(g, x, y, new Font("Arial", Font.BOLD, 16),"De");
		}
		
	}
}

