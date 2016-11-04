package com.studium.mas.jadex.tutorial.a1;

import jadex.bdiv3.annotation.Belief;
import jadex.bdiv3.annotation.Body;
import jadex.bdiv3.annotation.Goal;
import jadex.bdiv3.annotation.GoalParameter;
import jadex.bdiv3.annotation.GoalResult;
import jadex.bdiv3.annotation.Plan;
import jadex.bdiv3.annotation.PlanAPI;
import jadex.bdiv3.annotation.PlanAborted;
import jadex.bdiv3.annotation.PlanBody;
import jadex.bdiv3.annotation.PlanContextCondition;
import jadex.bdiv3.annotation.PlanFailed;
import jadex.bdiv3.annotation.PlanPassed;
import jadex.bdiv3.annotation.Plans;
import jadex.bdiv3.annotation.Trigger;
import jadex.bdiv3.features.IBDIAgentFeature;
import jadex.bdiv3.runtime.ChangeEvent;
import jadex.bdiv3.runtime.IPlan;
import jadex.bdiv3.runtime.impl.PlanFailureException;
import jadex.bridge.component.IExecutionFeature;
import jadex.commons.future.IFuture;
import jadex.micro.annotation.Agent;
import jadex.micro.annotation.AgentBody;
import jadex.micro.annotation.AgentCreated;
import jadex.micro.annotation.AgentFeature;
import jadex.micro.annotation.Description;
import jadex.rules.eca.ChangeInfo;
import java.util.HashMap;
import java.util.Map;

@Agent
@Description("The translation agent.")
public class TranslationBDI {

    @AgentFeature
    protected IBDIAgentFeature bdiFeature;
    
    @Belief
    protected Map<String, String> wordtable;

    @AgentCreated
    public void init(){
        this.wordtable = new HashMap<String, String>();
        this.wordtable.put("coffee", "Kaffee");
        this.wordtable.put("milk", "Milch");
        this.wordtable.put("cow", "Kuh");
        this.wordtable.put("cat", "Katze");
        this.wordtable.put("dog", "Hund");
        this.wordtable.put("bugger", "Flegel");
    }
    
    @AgentBody
    public void body(){
        String eword = "cat";
        String gword = (String) bdiFeature.dispatchTopLevelGoal(new Translate(eword)).get();
        System.out.println(gword);
        
    }
    
    @Goal
    public class Translate{
        @GoalParameter
        protected String eword;
        
        @GoalResult
        protected String gword;
        
        public Translate(String eword){
            this.eword = eword;
        }
    }
    
    
    
    @Plan(trigger=@Trigger(goals=Translate.class))
    protected String translate(String eword){
        System.out.println("Plan A");
        throw new PlanFailureException();
    }
    
    @Plan(trigger=@Trigger(goals=Translate.class))
    protected String translateB(String eword)
    {
      System.out.println("Plan B");
      return wordtable.get(eword);
    }
    
//    @AgentBody
//    public IFuture<Void> executeBody()
//    {
//            try{
//                bdiFeature.adoptPlan(new TranslationPlan());
//                execFeature.waitForDelay(1000).get();
//                context = false;
//                System.out.println("context set to false");
//            } catch(Exception e){
//                e.printStackTrace();
//            }
//            System.out.println("Hello, this is an BDI agent!");
//            return IFuture.DONE;
//    }
    
//    @Plan(trigger=@Trigger(factaddeds="wordtable"))
//    public void checkWordPairPlan(ChangeEvent event) {
//        ChangeInfo<String> change = ((ChangeInfo<String>) event.getValue());
//        if(change.getInfo().equals("bugger"))
//            System.out.println("Warning, a colloquial wordpair has been added " + change.getInfo() + " " + change.getValue());
//        else
//            System.out.println("Everthing alright");
//    }
    
//    @Plan
//    public class TranslationPlan {
//
//        @PlanAPI
//        protected IPlan plan;
//
//        protected Map<String, String> wordtable;
//
//        public TranslationPlan()
//        {
//            
//        }
//
//        @PlanBody
//        public void translateEnglishGerman()
//        {
//            System.out.println("Plan started.");
//            plan.waitFor(10000).get();
//            System.out.println("Plan resumed.");
//            String eword = "dog";
//            String gword = wordtable.get(eword);
//            System.out.println("Translated: "+eword+" - "+gword);
//        }
//
//        @PlanPassed
//        public void passed(){
//            System.out.println("Plan finished successully!");
//        }
//
//        @PlanAborted
//        public void aborted(){
//            System.out.println("Plan aborted!");
//        }
//
//        @PlanFailed
//        public void failed(Exception e){
//            System.out.println("Plan failed: " + e);
//        }
//
//        @PlanContextCondition(beliefs="context")
//        public boolean checkCondition(){
//            return context;
//        }
//    }
}
