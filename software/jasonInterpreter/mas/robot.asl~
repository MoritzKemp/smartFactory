/*
* Definition of an BDI-Agent.
* Represents a multi-purpose robot of the smart Bearing Factory.
*/

/* Initial beliefs and rules */
envSize(20,20). //Assumption may be fetch from env in the future
free. //initially the robot is free and capable to do a job

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
		dropBearingBox;
		+free.

+!deliveredBearingBox: not free
	<- 	.print("Not free, assume that anybody else will handle this").
	
+!atStock 
	<- .print("at stock plan").
	
+!haveBearingBox 
	<- .print("have bearing box plan").
	
+!atDeliveryBox
	<- .print("at delivery box plan").
							
