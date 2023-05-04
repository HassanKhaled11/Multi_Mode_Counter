module multi_mode_counter #(parameter WIDTH)(

input            clk                ,
input            rst_n              ,
input            init         	    ,
input      [WIDTH-1:0] load_value   ,
input      [1:0] mode_control       ,

output reg       GAMEOVER           ,
output reg [1:0] WHO

);

wire [WIDTH-1:0] max_value;

assign max_value = (1 << WIDTH) - 1;
//------ DECLARATIONS ---------------------

typedef enum reg[2:0] {INITIAL = 3'b000,COUNT = 3'b001,WINNER_FLAG = 3'b010 , LOSER_FLAG = 3'b011 , COMPLETE = 3'b100} state;
state current_state,next_state;

wire WINNER;
wire LOSER;


reg unsigned[WIDTH-1:0] counter;
reg [3:0] winner_counter,loser_counter;



assign WINNER = ( (&counter) && (current_state == 3'b001))? 1'b1 : 0;
assign LOSER =  (counter == 0 && current_state == 3'b001)? 1'b1 : 0;


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

              counter <= 0;              
              GAMEOVER <= 0;
              WHO <= 0;
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
        	winner_counter = winner_counter + 1;
         	 end


    LOSER_FLAG: begin
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


property winner_as;
@(posedge clk) disable iff(!rst_n || GAMEOVER ) (&counter) |-> ##[0:1] $rose(WINNER);
endproperty


winner_assert: assert property(winner_as);
winner_assert_cov: cover property(winner_as);


property winner_deass;
@(posedge clk) disable iff(!rst_n || GAMEOVER ) $rose(WINNER) |=>  $fell(WINNER);
endproperty

winner_deassert: assert property(winner_deass);
winner_deassert_cov: cover property(winner_deass);


property loser_as;
@(posedge clk) disable iff(!rst_n || GAMEOVER ) !(counter) |-> ##[0:1] $rose(LOSER);
endproperty

loser_assert: assert property(loser_as);
loser_assert_cov: cover property(loser_as);


property loser_deass;
@(posedge clk) disable iff(!rst_n || GAMEOVER ) $rose(LOSER) |=>  $fell(LOSER);
endproperty

loser_deassert: assert property(loser_deass);
loser_deassert_cov: cover property(loser_deass);


property gameover_check;
@(posedge clk) (winner_counter == 4'b1111 || loser_counter == 4'b1111) |-> ##[1:2] $rose(GAMEOVER);
endproperty

assert property(gameover_check);
cover property (gameover_check);



property WHO_check;
@(posedge clk) $rose(GAMEOVER) |-> (WHO == 2'd2||WHO == 2'd1);
endproperty

assert property(WHO_check);
cover property (WHO_check);



endmodule
