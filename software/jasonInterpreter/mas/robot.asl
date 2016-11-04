/*
* Definition of an BDI-Agent.
* Represents a multi-purpose robot of the smart Bearing Factory.
*/

/* Initial beliefs and rules */
free. 				//initially the robot is free and capable to do a job

/* Initial goals */

!start.

/* Plans */

+!start : true
	<- 	.print("hello world.");
		!deliveredBearingBox.
		
+!move : pos(r1, X, Y) & X<10 
	<- 	moveRight;
		!move.

+!move <- .print("Finish moving").

+!deliveredBearingBox : free
	<-	-free;
		!atStock;
		!haveBearingBox;
		!atDeliveryBox;
		!droppedBearingBox
		dropBearingBox;
		+free.

+!deliveredBearingBox: not free
	<- 	.print("Not free, assume that anybody else will handle this").
	
+!atStock : pos(stock, X, Y) & pos(r1, A, B) & (not X = A | not Y = A)
	<-	!at(X, Y);
		.print("arrive at stock").
	
+!haveBearingBox : not bearingBox
	<- 	+bearingBox;
		.print("have bearing box").
	
+!atDeliveryBox : pos(deliveryBox, X, Y) & pos(r1, A, B) & (not X = A | not Y = A)
	<- 	!at(X,Y);
		.print("arrive at delivery box").

+!droppedBearingBox : bearingBox
	<- -bearingBox.

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
