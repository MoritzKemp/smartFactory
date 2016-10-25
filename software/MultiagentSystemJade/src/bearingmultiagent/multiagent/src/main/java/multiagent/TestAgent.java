package multiagent;

import jade.core.Agent;

public class TestAgent extends Agent{

	protected void setup()
	{
		System.out.println("TestAgent: " + getAID().getName() + "ready");
	}
}
