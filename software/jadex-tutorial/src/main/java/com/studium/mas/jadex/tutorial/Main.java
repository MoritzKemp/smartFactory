package com.studium.mas.jadex.tutorial;

import jadex.base.PlatformConfiguration;
import jadex.base.Starter;

public class Main {
    public static void main(String[] args)
	{
		PlatformConfiguration configuration = PlatformConfiguration.getDefaultNoGui();
		configuration.addComponent("com.studium.mas.jadex.tutorial.a1.TranslationBDI.class");
		Starter.createPlatform(configuration).get();
	}
}
