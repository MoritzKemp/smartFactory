/*
* Definition of an BDI-Agent.
* Represents a multi-purpose robot of the smart Bearing Factory.
*/

/* Initial beliefs and rules */
free. 				//initially the robot is free and capable to do a job
robotName(Name, Id) :- .concat("robot", Id, Name).

/* Initial goals */
!coordinationStructure.


/* Plans */

+order(Type, Id, false)[source(customer)] : true 
	<- .print("Delegate order ",Type);
		!delegatedTask(task(Type, Id));
		-order(Type, Id, false)[source(customer), _];
		+task(Type, Id).

+taskAvailable(Type, From) : free
	<- 	.random(Value);
		-free
		!offerMade(Value, From);
		.abolish(taskAvailable(Type, From)).
		
+taskAvailable(Type, From) : not free
	<- 	!reject(From);
		.abolish(taskAvailable(Type, From));
		.print("Reject proposal").

+!taskDone(Type, TaskId, ManagerId) : true
	<- 	+task(Type, Id);
		!Type;
		?robotName(Manager, ManagerId);
		.send(Manager, tell, finishTask(Type, TaskId));
		-task(Type, TaskId)[source(_)];
		+free.
	
+finishTask(Type, TaskId) : task(Type, TaskId)
	<- 	.abolish(task(Type, TaskId));
		.abolish(finishTask(Type, TaskId));
		.print("Task ", Type, " finished!").
		
/***** BEGIN Coordination plans *****/
+!coordinationStructure : not chairman(_) & not leader(_)
	<- 	!determinedChairman;
		?chairman(X);
		?id(Y)
		if(X==Y)
		{
		!electedLeader;
		?leader(Leader);
		informEnv(Leader);
		.print(Leader);
		}.

+!determinedChairman : not chairman(_)
	<- 	?robots(ROBOT_IDS);
		.min(ROBOT_IDS, MIN);
		+chairman(MIN).
		
+!electedLeader : not leader(_) & chairman(X) & id(Y) & X = Y
	<- .broadcast(achieve, bid);
	   !bid;
	   .wait(2000); //wait for other agents to cast their vote
	   .findall(b(Vote,Ag),bid(Ag,Vote)[source(self)],L);
	   .max(L,b(Vote,W));
	   .findall(c(Vote2,Ag2),bid(Ag2,Vote2),M);
	   .max(M,c(Vote2,W2));	   
	   if(Vote2 > Vote)
	   {
	   .broadcast(tell,leader(W2));
	   -+leader(W2); 
	   };
	   if(Vote >= Vote2)
	   {
	   .broadcast(tell,leader(W));
	   -+leader(W);
	   };
	   .abolish(bid(_,_)).
+!electedLeader : true <- .print("Not the chair").

+!bid : true
	<- 	.random(Value);
		?chairman(ChairId);
		?id(MyId);
		.concat("robot", ChairId, Recipient); 
		.send(Recipient, tell, bid(MyId,Value));
		.print("Vote was ", Value).

/** END Coordinate plans**/

/** BEGIN CNP **/
+!delegatedTask(task(Type, TaskId)) : true
	<-	?id(MyId)
		.broadcast(tell, taskAvailable(Type, MyId));
		.print("Broadcast task proposal. Waiting 4 sec for answers.");
		.wait(4000);
		!awardedRobot(Type,TaskId);
		.abolish(offer(_,_)).

+!offerMade(Value, From) : true
	<- 	?robotName(Recipient, From);
		?id(MyId);
		.send(Recipient, tell, offer(MyId, Value));
		.print("Send offer with value ",Value).
		
+!reject(From) : true
	<- 	?robotName(Recipient, From);
		?id(MyId);
		.send(Recipient, tell, reject(MyId)).
		
+!awardedRobot(Type, TaskId) : offer(_,_)
	<-	.findall(o(Id,Value), offer(Id,Value), L);
		.max(L, o(Id,Value));
		!announce(Type, TaskId, L, Id).
+!awardedRobot(Type, TaskId) : not offer(_,_)
	<- 	!taskDone(Type, TaskId);
		.print("No proposals. Do it myself.").
		
+!announce(_,_,[],_) .
+!announce(Type, TaskId, [o(Winner,_)|T], Winner) : robotName(WinName, Winner)
	<- 	?id(MyId);
		.send(WinName, achieve, taskDone(Type, TaskId, MyId));
		!announce(Type, TaskId, T, Winner).
+!announce(Type, TaskId, [o(Looser,_)|T], Winner) : robotName(LName, Looser)
	<-	.send(LName, tell, reject(TaskId));
		!announce(Type, TaskId, T, Winner).
		
+reject(Id)
	<- 	.abolish(reject(Id));
		+free;
		.print("Recieved a rejection from ", Id).
/** END CNP **/
		
/**** Plans for orders ****/

+!deliveredBearingBox : true
	<-	!atStock;
		!haveBearingBox;
		!atDeliveryBox;
		!droppedBearingBox.

+!deliveredForceFittedBearingBox : true
	<-	!atStock;
		!haveBearingBox;
		!haveAxle;
		!atAssemblyAidTray;
		!haveAssemblyAidTray;
		!atForceFittingMachine;
		!haveForceFittedBearingBox;
		!delegatedTask(task(returnedAsseblyAidTray, 1));
		!atDeliveryBox;
		!droppedForceFittedBearingBox.
		
+!atStock : pos(stock, X, Y) & pos(my, A, B) & (not X = A | not Y = B)
	<-	!at(X, Y);
		.print("arrive at stock").
	
+!haveBearingBox : not bearingBox
	<- 	+bearingBox;
		.print("have bearing box").

+!haveAxle : not axle
	<-	+axle;
		.print("have axle").
		
+!atAssemblyAidTray : pos(aidTray, X, Y) & pos(my , A, B) & (not X = A | Y = B)
	<- 	!at(X,Y);
		.print("arrive at assembly aid tray").

+!haveAssemblyAidTray : not assemblyAidTray
	<-	+assemblyAidTray;
		.print("have assembly aid tray").

+!atForceFittingMachine : pos(forceFitting, X, Y) & pos(my, A, B) & (not X = A | Y = B)
	<-	!at(X,Y);
		.print("arrive at force fitting machine").
		
+!haveForceFittedBearingBox : not forceFittedBearingBox
	<- 	-bearingBox;
		-axle;
		-assemblyAidTray;
		+forceFittedBearingBox;
		.print("have force fitted bearing box").

+!returnedAsseblyAidTray: not assemblyAidTray
	<-	!atForceFittingMachine;
		+assemblyAidTray;
		!returnedAsseblyAidTray.
+!returnedAsseblyAidTray: assemblyAidTray
	<-	!atAssemblyAidTray;
		dropAssemblyAidTray;
		-assemblyAidTray.
		
+!atDeliveryBox : pos(deliveryBox, X, Y) & pos(my, A, B) & (not X = A | not Y = B)
	<- 	!at(X,Y);
		.print("arrive at delivery box").

+!droppedBearingBox : bearingBox & (pos(deliveryBox, X, Y) & pos(my, A, B) & ( X = A & Y = B))
	<- 	dropBearingBox;
		-bearingBox.

+!droppedForceFittedBearingBox : forceFittedBearingBox & (pos(deliveryBox, X, Y) & pos(my, A, B) & ( X = A & Y = B))
	<-	dropForceFittedBearingBox;
		-forceFittedBearingBox.
		
/** END Plans for orders **/



/***** BEGIN Basic movement plans *****/
+!at(X, Y) : pos(my, A, B) & not (X=A & Y=B)
	<- 	!atEast(X);
		!atWest(X);
		!atSouth(Y);
		!atNorth(Y).
+!at(X, Y) <- .print("arrived at destination").

+!atNorth(Y) : pos(my, A, B) & B > Y
	<- 	moveNorth;
		!atNorth(Y).
+!atNorth(Y) <- .print("finish moving north").

+!atWest(X) : pos(my, A, B) & A > X
	<- 	moveWest;
		!atWest(X).
+!atWest(X) : .print("finish moving west").

+!atEast(X) : pos(my, A, B) & A < X
	<- 	moveEast;
		!atEast(X).	
+!atEast(X) <- .print("finish moving east").

+!atSouth(Y) : pos(my, A, B) & B < Y
	<- 	moveSouth;
		!atSouth(Y).
+!atSouth(Y) <- .print("finish moving south").

/** END Basic movement plans **/


