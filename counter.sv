module multi_mode_counter(

input            clk          ,
input            rst_n        ,
input            init         ,
input      [3:0] load_value   ,
input      [1:0] mode_control ,

output reg       GAMEOVER     ,
output reg [1:0] WHO

);


//------ DECLARATIONS ---------------------

typedef enum reg[2:0] {INITIAL = 3'b000,COUNT = 3'b001,WINNER_FLAG = 3'b010 , LOSER_FLAG = 3'b011 , COMPLETE = 3'b100} state;
state current_state,next_state;


reg WINNER;
reg LOSER;


reg unsigned[3:0] counter;
reg [3:0] winner_counter,loser_counter;



assign WINNER = (counter == 4'd15 && current_state == 3'b001)? 1'b1 : 0;
assign LOSER =  (counter == 4'd00 && current_state == 3'b001)? 1'b1 : 0;

//-------------------------------------------------------------------

always @(posedge clk or negedge rst_n) begin
	
	if(~rst_n) begin
		current_state <= INITIAL;
	end 

	else begin
		current_state <= next_state;
	end
end


//-------------------------------------------------------------------

always @(*)begin

	case (current_state) 
	    
	    INITIAL: begin
                    next_state = COUNT;
	    	     end


	    COUNT : begin

                 if(winner_counter == 4'b1111 || loser_counter == 4'b1111)
                 	next_state = COMPLETE;
                 else if(WINNER)
                 	next_state = WINNER_FLAG;
                 else if(LOSER)
                 	next_state = LOSER_FLAG;
                 else
                 	next_state = COUNT;

	    	    end


	    WINNER_FLAG: next_state = COUNT;

	    LOSER_FLAG:  next_state = COUNT; 

	    COMPLETE  :  next_state = INITIAL; 

      
	endcase 

end


//-------------------------------------------------------------------


always @(posedge clk)begin

   case(current_state)
   	
    INITIAL : begin

              counter <= 4'b1;              
              GAMEOVER <= 0;
              WHO <= 0;
              //WINNER <= 0;
	     // LOSER <= 0;
	      winner_counter <=0;
              loser_counter <= 0;

    	      end



   COUNT : begin

           if(init)begin
    	     counter <= load_value;
           end


       	    else if (mode_control == 2'b00)begin
	      counter <= counter +  1 ;
	    end


	 else if(mode_control == 2'b01)begin
	    counter <= counter + 2;
	   end


   	else if(mode_control == 2'b10)begin
    	counter <= counter - 1;
    	end


       else if(mode_control == 2'b11)begin
    	counter <= counter - 2;
    	end

   end



    WINNER_FLAG: begin
        	//WINNER = 0;
        	winner_counter = winner_counter + 1;
         	 end


    LOSER_FLAG: begin
                  // LOSER = 0;
                   loser_counter = loser_counter + 1;
                end     


    COMPLETE : begin
                 GAMEOVER = 1'b1;
                 if(winner_counter == 4'b1111)
                 	WHO = 2'b10;
                 else
                 	WHO = 2'b01;
    	       end

    endcase

end



endmodule