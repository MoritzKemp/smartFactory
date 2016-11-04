// Agent john in project book_trading.mas2j

/* Initial beliefs and rules */

book("Harry", 32, 20).
book("Jason", 50, 10).

/* Initial goals */

!registerDF.

/* Plans */
+!registerDF <- jadedf.register("book-selling", "JADE-book-trading").

//handle CFP performatives

+!kqml_received(Sender, cfp, Content, MsgId)
	: book(Content, Price, Qtd) & Qtd > 0
	<- .send(Sender, propose, Price, MsgId).
	
+!kqml_received(Sender, cfp, Content, MsgId)
	<- .send(Sender, refuse, "not-available", MsgId).

+!kqlm_received(Sender, accept_proposal, Content, MsgId)
	: book(Content, Price, Qtd) & Qtd > 0
	<- -+book(Content, Price, Qtd-1);
		.print("New stock for ", Content, " is ", Qtd-1);
		.send(Sender, tell, Content, MsgId).
		
+!kqml_received(Sender, accept_proposal, Content, MsgId)
	<- .send(Sender, failure, "not-available", MsgId).
