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
	<- 	.print("Delegate order ",Type);
		!delegatedTask(task(Type, Id));
		-order(Type, Id, false)[source(customer)];
		-order(Type, Id, false)[source(customer), _].

+taskAvailable(Type, From) : not task(_,_,_)
	<- 	.random(Value);
		!offerMade(Value, From);
		.abolish(taskAvailable(Type, From)).
		
+taskAvailable(Type, From) : task(_,_,_)
	<- 	!refuse(From);
		-taskAvailable(Type,From)[source(_)];
		.print("Refuse proposal").

+finishTask(Type, TaskId)[source(_)] : true
	<- 	-delegatedTask(Type, TaskId, From)[source(_)];
		-finishTask(Type, TaskId)[source(_)];
		.print("Task ", Type," from ",From, " finished!").
		
+!taskDone(Type, TaskId, ManagerId) : true
	<- 	+task(Type, TaskId, ManagerId);
		.print("Doing: ", Type,".");
		!Type;
		?robotName(Manager, ManagerId);
		.send(Manager, tell, finishTask(Type, TaskId));
		-task(Type, TaskId, ManagerId)[source(_)].
	
		
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
		.print("Broadcast task proposal: ",Type," Waiting 2 sec for answers.");
		.wait(2000);
		!awardedRobot(Type,TaskId);
		.abolish(offer(_,_)).

+!offerMade(Value, From) : true
	<- 	?robotName(Recipient, From);
		?id(MyId);
		.send(Recipient, tell, offer(MyId, Value));
		.print("Send offer with value ",Value).
		
+!refuse(From) : true
	<- 	?robotName(Recipient, From);
		?id(MyId);
		.send(Recipient, tell, reject(MyId)).
		
+!awardedRobot(Type, TaskId) : offer(_,_)
	<-	.findall(o(Value,Id), offer(Id,Value), L);
		.print("List of offers: ",L);
		.max(L, o(V,I));
		.print("Max is: ",o(V, I));
		!announce(Type, TaskId, L, I);
		+delegatedTask(Type, TaskId, I).
+!awardedRobot(Type, TaskId) : not offer(_,_)
	<- 	?id(MyId);
		!taskDone(Type, TaskId, MyId).
		
+!announce(_,_,[],_) .
+!announce(Type, TaskId, [o(_,Winner)|T], Winner) : robotName(WinName, Winner)
	<- 	?id(MyId);
		.send(WinName, achieve, taskDone(Type, TaskId, MyId));
		!announce(Type, TaskId, T, Winner).
+!announce(Type, TaskId, [o(_,Looser)|T], Winner) : robotName(LName, Looser)
	<-	.send(LName, tell, reject(TaskId));
		!announce(Type, TaskId, T, Winner).
		
+reject(Id)
	<- 	.abolish(reject(Id));
		.print("Recieved a rejection from ", Id).
/** END CNP **/
		
/**** Plans for orders ****/

/** Level 0 **/
+!deliveredBearingBox : true
	<-	!haveBearingBox;
		!droppedBearingBox.

+!deliveredForceFittedBearingBox : true
	<- 	!haveForceFittedBearingBox;
		!delegatedTask(task(returnedAssemblyAid, 1));
		!droppedForceFittedBearingBox.
		
/** Level 1 **/
+!haveForceFittedBearingBox : true
	<- 	!haveAssemblyParts;
		!loadedForceFittingMachine;
		+forceFittedBearingBox.
		
		
+!haveAssemblyParts : true
	<- 	!haveBearingBox;
		!haveAxle;
		!haveAssemblyAid.

+!loadedForceFittingMachine : axle & bearingBox & assemblyAid
	<- 	!atForceFittingMachine;
		-axle;
		-bearingBox;
		-assemblyAid.
	
/** Level 2**/
+!haveBearingBox : not bearingBox
	<- 	!atStock;
		+bearingBox;
		.print("have bearing box").

+!haveAxle : not axle
	<-	!atStock;
		+axle;
		.print("have axle").
		
+!haveAssemblyAid : not assemblyAid
	<-	!atAssemblyAidTray;
		+assemblyAid;
		.print("have assembly aid").

+!returnedAssemblyAid: not assemblyAid
	<-	!atForceFittingMachine;
		+assemblyAid;
		!returnedAssemblyAid.
+!returnedAssemblyAid: assemblyAid
	<-	!atAssemblyAidTray;
		-assemblyAid.

+!droppedBearingBox : bearingBox
	<- 	!atDeliveryBox;
		-bearingBox.

+!droppedForceFittedBearingBox : forceFittedBearingBox
	<-	!atDeliveryBox;
		-forceFittedBearingBox.
		
/** Level 3 **/
+!atStock : pos(stock, X, Y) & pos(my, A, B) & (not X = A | not Y = B)
	<-	!at(X, Y);
		.print("arrive at stock").
+!atStock : true.
	
+!atAssemblyAidTray : pos(aidTray, X, Y) & pos(my , A, B) & (not X = A | Y = B)
	<- 	!at(X,Y);
		.print("arrive at assembly aid tray").
+!atAssemblyAidTray : true.

+!atForceFittingMachine : pos(forceFitting, X, Y) & pos(my, A, B) & (not X = A | Y = B)
	<-	!at(X,Y);
		.print("arrive at force fitting machine").
+!atForceFittingMachine : true.
				
+!atDeliveryBox : pos(deliveryBox, X, Y) & pos(my, A, B) & (not X = A | not Y = B)
	<- 	!at(X,Y);
		.print("arrive at delivery box").
+!atDeliveryBox : true.		
/** END Plans for orders **/



/***** BEGIN Basic movement plans *****/
+!at(X, Y) : pos(my, A, B) & not (X=A & Y=B)
	<- 	!atEast(X);
		!atWest(X);
		!atSouth(Y);
		!atNorth(Y).
+!at(X, Y) : true.

+!atNorth(Y) : pos(my, A, B) & B > Y
	<- 	moveNorth;
		!atNorth(Y).
+!atNorth(Y) : true.

+!atWest(X) : pos(my, A, B) & A > X
	<- 	moveWest;
		!atWest(X).
+!atWest(X) : true.

+!atEast(X) : pos(my, A, B) & A < X
	<- 	moveEast;
		!atEast(X).	
+!atEast(X) : true.

+!atSouth(Y) : pos(my, A, B) & B < Y
	<- 	moveSouth;
		!atSouth(Y).
+!atSouth(Y) : true.

/** END Basic movement plans **/


