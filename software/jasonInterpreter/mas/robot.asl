/*
* Definition of an BDI-Agent.
* Represents a multi-purpose robot of the smart Bearing Factory.
*/

/* Initial beliefs and rules */
free. 				//initially the robot is free and capable to do a job
votingNecessary 
	:- 	not leader(X) & 
		id(Y) & 
		chairman(Z) & 
		(Y = Z).
		
/* Initial goals */

!idle.

/* Plans */

/**** Waiting loop plans ***/

+!idle : not chairman(X) & robots(X)  
	<-	//determineChairmanById;
		.min(X, CHAIR);
		+chairman(CHAIR);
		!leader;
		!idle.
+!idle : order(bearingBox)
	<- .print("as you wish. Processing order to deliver bearing box");
		!deliveredBearingBox;
		!idle.
+!idle : order(forceFittedBearingBox)
	<-	print("as you wish. Processing order to deliver force fitted bearing box");
		!deliveredForceFittedBearingBox;
		!idle.
+!idle <- .wait(1000); !idle.

/**** Plans for orders ****/
+!deliveredBearingBox : free
	<-	-free;
		!atStock;
		!haveBearingBox;
		!atDeliveryBox;
		!droppedBearingBox;
		finishBearingBox;
		+free.
+!deliveredBearingBox : not free
	<- 	.print("Not free, assume that anybody else will handle this").

+!deliveredForceFittedBearingBox : free
	<-	-free;
		!atStock;
		!haveBearingBox;
		!haveAxle;
		!atAssemblyAidTray;
		!haveAssemblyAidTray;
		!atForceFittingMachine;
		!haveForceFittedBearingBox;
		!atDeliveryBox;
		!droppedForceFittedBearingBox;
		!returnedAsseblyAidTray;
		finishForceFittedBearingBox;
		+free.
+!deliveredForceFittedBearingBox : not free
	<-	.print("Not free, assume that anybody else will handle this").
	
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
		+forceFittedBearingBox;
		.print("have force fitted bearing box").
		
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

		
/***** Coordination plans *****/
+!leader : votingNecessary
	<- 	.broadcast(achieve, vote);
		!vote;
		.wait(2000); //wait for other agents to cast their vote
		!countedVote.
+!leader : not leader(_) & chairman(X) & id(Y) & not (X = Y)
	<- .print("I'am not the chairman.").
+!leader : leader(_)
	<- .print("Elected leader exists.").
		
+!vote : chairman(Z) & id(E)
	<- 	.print("Attempting to vote");
		.random(C);
		.print(C);
		if(C <= 0.3){
		.concat("robot", Z+1, R);
		.send(R, tell, vote(E, 0));
		.print("Voted for robot1");
		}
		if(C>0.3 & C<=0.6){ 
		.concat("robot", Z+1, R);
		.send(R, tell, vote(E, 1));
		.print("Voted for robot2");
		};
		if(C>0.6){ 
		.concat("robot", Z+1, R);
		.send(R, tell, vote(E, 2));
		.print("Voted for robot3");
		}.

+!countedVote : not leader(_) & 
				.count((vote(_,0)),C0) &
				.count((vote(_,1)),C1) &
				.count((vote(_,2)),C2)
	<-	if(C0 >=2){ !namedLeader(0)};
		if(C1 >=2){ !namedLeader(1)};
		if(C2 >=2){ !namedLeader(2)};
		.abolish(vote(_,_)); //remove vote data 
		!leader. //if no majority, re-do

+!namedLeader(ID) 
	<-	+leader(ID);
		.broadcast(tell, leader(ID));
		.concat("Elected leader is robot ", ID+1, X);
		.print(X).

/***** Basic movement plans *****/
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
