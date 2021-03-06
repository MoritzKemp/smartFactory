/*
* Definition of an BDI-Agent.
* Represents a multi-purpose robot of the smart Bearing Factory.
*/

/* Initial beliefs and rules */
free. 				//initially the robot is free and capable to do a job
robotName(Name, Id) :- .concat("robot", Id+1, Name).

/* Initial goals */

!idle.

/* Plans */

/**** Waiting loop plans ***/

+!idle : not chairman(X)
	<-	determineChairmanById;
		!idle.
+!idle : finishOrder(A)
	<- 	.findall(b(Id, A), order(A, Id, true), L);
		.min(L, b(NewId, A));	
		.abolish(order(A, NewId, true));
		.abolish(finishOrder(A));
		!idle.
+!idle : chairman(X) & id(Y) & (X=Y) & not leader(_)
	<-	!leader;
		?leader(LEADER);
		informAboutLeader(LEADER+1);
		!idle.
+!idle : order(Order,ID,false)[source(customer)] | order(Order,ID,false)[source(customer),source(percept)]
	<- .print("Delegate order ",Order);
		!delegateOrder(Order);
		-order(Order,ID,false)[source(customer),source(percept)];
		-order(Order,ID,false)[source(customer)];
		+order(Order,ID,true)[source(customer)];
		!idle.
+!idle <- .wait(1000); !idle.

/**** Plans for orders ****/

+!deliveredBearingBox : free & leader(Leader) & robotName(N, Leader)
	<-	-free;
		!atStock;
		!haveBearingBox;
		!atDeliveryBox;
		!droppedBearingBox;
		finishBearingBox;
		.send(N, tell, finishOrder(deliveredBearingBox));
		+free.
+!deliveredBearingBox : not free
	<- 	.print("Not free, assume that anybody else will handle this").

+!deliveredForceFittedBearingBox : free & leader(Leader) & robotName(N, Leader)
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
		.send(N, tell, finishOrder(deliveredForceFittedBearingBox));
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
+!leader : not leader(X) & id(Y) & chairman(Z) & (Y = Z) & robots(O)
	<- .broadcast(achieve, bid);
	   !bid;
	   .wait(2000); //wait for other agents to cast their vote
	   //.print(f);
	   .findall(b(V,A),bid(A,V)[source(self)],L);
	   .max(L,b(V,W));
	   .findall(c(V2,A2),bid(A2,V2),M);
	   .max(M,c(V2,W2));
	   
	   if(V2 > V)
	   {
	   .broadcast(tell,leader(W2));
	   -+leader(W2); 
	   };
	   if(V >= V2)
	   {
	   .broadcast(tell,leader(W));
	   -+leader(W);
	   };
	   .abolish(bid(_,_)).
	   
+!bid : chairman(Z) & id(E)
	<- 	.print("attempting to vote");
		.random(C);
		.print(C);
		.concat("robot", Z+1, R); 
		.send(R, tell, bid(E,C)).
		
+!delegateOrder(Order) : true
	<-	.broadcast(tell, orderAvailable(Order));
		.print("Broadcast order proposal");
		.wait(4000);
		!awardedRobot(Order);
		.abolish(proposal(_,_)).

+!awardedRobot(Order) : proposal(_,_)
	<-	.findall(offer(Y,X), proposal(X,Y), L);
		.max(L, offer(V,P));
		!announce(Order, L, P).
+!awardedRobot(Order) : not proposal(_,_)
	<- .print("No proposals. Do it myself.");
		!Order.

/** [Head|Tail] **/
+!announce(_,[],_) .
+!announce(Order, [offer(_, WinAg)|T], WinAg) : robotName(WinName, WinAg)
	<- .send(WinName, achieve, Order);
		!announce(Order, T, WinAg).
+!announce(Order, [offer(_,LAg)|T], WinAg) : robotName(LName, LAg)
	<-	.send(LName, tell, reject(Order));
		!announce(Order, T, WinAg).
		
+orderAvailable(Order) : free & leader(Leader) & id(A) & robotName(LeaderName, Leader)
	<- 	.random(C);
		.send(LeaderName, tell, proposal(A, C));
		.abolish(orderAvailable(Order));
		.print("Send proposal with value ", C).
+orderAvailable(Order) : not free & leader(Leader) & id(A)& robotName(LeaderName, Leader)
	<- 	.send(LeaderName, tell, reject(A));
		.abolish(orderAvailable(Order));
		.print("Reject proposal").

		
+reject(Order)
	<- 	.print("Recieved a rejection.");
		.abolish(reject(_)).		


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
