package multiagent;

import jade.core.Agent;

public class RobotAgent extends Agent{

	protected void setup()
	{
		System.out.println("RobotAgent: " + getAID().getName() + "ready");
	}
}
