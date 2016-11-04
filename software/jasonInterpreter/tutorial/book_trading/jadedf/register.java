// Internal action code for project book_trading.mas2j

package jadedf;

import jade.domain.*;
import jade.domain.FIPAAgentManagement.*;
import jason.*;
import jason.asSemantics.*;
import jason.asSyntax.*;
import jason.infra.jade.JadeAgArch;
import jason.infra.jade.JasonBridgeArch;

import java.util.logging.Logger;

public class register extends DefaultInternalAction {

   private Logger logger = Logger.getLogger("JadeDF.mas2j."+register.class.getName());
   
   @Override
   public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
	   try {
		   if (ts.getUserAgArch().getArchInfraTier() instanceof JasonBridgeArch) {
			   // get a reference to the jade agent that represents this Jason agent
			   JadeAgArch infra = ((JasonBridgeArch)ts.getUserAgArch().getArchInfraTier()).getJadeAg();
				// 0. get arguments from the AgentSpeak code (type and name of the new service)
				StringTerm type = (StringTerm)args[0];
				StringTerm name = (StringTerm)args[1];
				// 1. get current services
				DFAgentDescription dfd = new DFAgentDescription();
				dfd.setName(infra.getAID());
				DFAgentDescription list[] = DFService.search( infra, dfd );
				// 2. deregister
				if ( list.length > 0 ) {
					DFService.deregister(infra);
					dfd = list[0]; // the first result
				}
				// 3. add a new services
				ServiceDescription sd = new ServiceDescription();
				sd.setType(type.getString());
				sd.setName(name.getString());
				dfd.addServices(sd);
				// 4. register again
				DFService.register(infra, dfd);
				return true;
		   	} else {
				logger.warning("jadefd.register can be used only with JADE infrastructure.");
			}
	   } catch (Exception e) {
		   logger.warning("Error in internal action 'jadedf.register'! "+e);
	   }
	   return false;
   }
}

