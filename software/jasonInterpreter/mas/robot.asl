/*
* Definition of an BDI-Agent.
* Represents a multi-purpose robot of the smart Bearing Factory.
*/

/* Initial beliefs and rules */
free. 				//initially the robot is free and capable to do a job

/* Initial goals */

!idle.

/* Plans */

/**** Waiting loop plans ***/
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
	
+!atStock : pos(stock, X, Y) & pos(r1, A, B) & (not X = A | not Y = B)
	<-	!at(X, Y);
		.print("arrive at stock").
	
+!haveBearingBox : not bearingBox
	<- 	+bearingBox;
		.print("have bearing box").

+!haveAxle : not axle
	<-	+axle;
		.print("have axle").
		
+!atAssemblyAidTray : pos(aidTray, X, Y) & pos(r1, A, B) & (not X = A | Y = B)
	<- 	!at(X,Y);
		.print("arrive at assembly aid tray").

+!haveAssemblyAidTray : not assemblyAidTray
	<-	+assemblyAidTray;
		.print("have assembly aid tray").

+!atForceFittingMachine : pos(forceFitting, X, Y) & pos(r1, A, B) & (not X = A | Y = B)
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
		
+!atDeliveryBox : pos(deliveryBox, X, Y) & pos(r1, A, B) & (not X = A | not Y = B)
	<- 	!at(X,Y);
		.print("arrive at delivery box").

+!droppedBearingBox : bearingBox & (pos(deliveryBox, X, Y) & pos(r1, A, B) & ( X = A & Y = B))
	<- 	dropBearingBox;
		-bearingBox.

+!droppedForceFittedBearingBox : forceFittedBearingBox & (pos(deliveryBox, X, Y) & pos(r1, A, B) & ( X = A & Y = B))
	<-	dropForceFittedBearingBox;
		-forceFittedBearingBox.
		
/***** Basic movement plans *****/
+!at(X, Y) : pos(r1, A, B) & not (X=A & Y=B)
	<- 	!atEast(X);
		!atWest(X);
		!atSouth(Y);
		!atNorth(Y).
+!at(X, Y) <- .print("arrived at destination").

+!atNorth(Y) : pos(r1, A, B) & B > Y
	<- 	moveNorth;
		!atNorth(Y).
+!atNorth(Y) <- .print("finish moving north").

+!atWest(X) : pos(r1, A, B) & A > X
	<- 	moveWest;
		!atWest(X).
+!atWest(X) : .print("finish moving west").

+!atEast(X) : pos(r1, A, B) & A < X
	<- 	moveEast;
		!atEast(X).	
+!atEast(X) <- .print("finish moving east").

+!atSouth(Y) : pos(r1, A, B) & B < Y
	<- 	moveSouth;
		!atSouth(Y).
+!atSouth(Y) <- .print("finish moving south").
