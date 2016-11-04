package multiagent;

import jade.core.Profile;
import jade.core.ProfileImpl;
import jade.core.Runtime;
import jade.wrapper.AgentController;
import jade.wrapper.StaleProxyException;
import jade.wrapper.AgentContainer;

public class AgentDemo {

	public static void main(String[] args) {
                // Some config for the Main-container
		String host;
	        int port;
	        String platform = null;     //default name
	        boolean main = true;
	        host = "localhost";
	        port = -1;          //default-port 1099
	 
	        Runtime runtime = Runtime.instance();
	 
	        Profile profile = null;
	        AgentContainer container = null;
	 
	        profile = new ProfileImpl(host, port, platform, main);
                profile.setParameter(Profile.GUI, "true");
                
	        //Main-Container erzeugen
	        container = runtime.createMainContainer(profile);
	 
	        // Agenten erzeugen und startet - oder aussteigen.
	        try {
	            AgentController testAgent = container.createNewAgent(
	                        "testAgent",
	                        TestAgent.class.getName(),
	                        args);
                    AgentController robotAgent = container.createNewAgent(
	                        "robot",
	                        RobotAgent.class.getName(),
	                        args);
	            testAgent.start();
                    robotAgent.start();
	        } catch(StaleProxyException e) {
	            throw new RuntimeException(e);
	        }
	    }

	}


