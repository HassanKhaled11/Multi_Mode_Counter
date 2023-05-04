parameter WIDTH = 'd100;

class C_Class;

rand bit init;
rand bit [1:0] mode_control;
rand logic [WIDTH-1:0] load_value;
bit winner_testcase;
bit loser_testcase; 

//============== CONSTRAINS ====================

constraint init_c{
        (winner_testcase == 1 || loser_testcase == 1) ->  init == 0 ;
        init dist {1:/1 , 0:/9};
}

constraint ctrl_c{
        (winner_testcase == 1) ->  mode_control dist{2'b00:/50 , 2'b01:/50};
        (loser_testcase == 1) ->  mode_control dist{2'b10:/50 , 2'b11:/50};
         mode_control dist {2'b00:/25 , 2'b01:/25 , 2'b10:/25 , 2'b11:/25};
}


//============== COVER GROUP ====================


covergroup cg;

ctrl_bits: coverpoint mode_control {

bins zero_zero = {2'b00};
bins zero_one  = {2'b01};
bins one_zero  = {2'b10};
bins one_one   = {2'b11};

bins zz_zo     = (2'b00 => 2'b01);
bins zz_oz     = (2'b00 => 2'b10);
bins zz_oo     = (2'b00 => 2'b11);

bins zo_zz     = (2'b01 => 2'b00);
bins zo_oz     = (2'b01 => 2'b10);
bins zo_oo     = (2'b01 => 2'b11);

bins oz_zz     = (2'b10 => 2'b00);
bins oz_zo     = (2'b10 => 2'b01);
bins oz_oo     = (2'b10 => 2'b11);

bins oo_zz     = (2'b11 => 2'b00);
bins oo_zo     = (2'b11 => 2'b01);
bins oo_oz     = (2'b11 => 2'b10);
}

endgroup
  
  
  

function new();
cg = new();
endfunction

endclass

//----------------- TESTBENCH -------------------


module multi_mode_counter_tb();

reg         clk,rst_n,init ; 
logic [WIDTH-1:0] load_value_tb  ;
logic [1:0] mode_control_tb;

wire  GAMEOVER;
wire  [1:0] WHO; 
wire [WIDTH-1:0] max_value;


multi_mode_counter   #(.WIDTH(WIDTH)) counter_instance (.clk(clk),.rst_n(rst_n),.load_value(load_value_tb),.mode_control(mode_control_tb),
                                     .init(init),.GAMEOVER(GAMEOVER) ,.WHO(WHO));


C_Class cc_obj = new();

assign max_value =(1 << WIDTH) - 1;

initial begin
clk = 0;
  forever begin
    #1 clk = ~clk;
  end
end


initial begin
rst_n = 0;
#2;
rst_n = 1;
#2;


for(int i = 0 ; i <100 ; i++) begin
@(negedge clk);
assert(cc_obj.randomize());
mode_control_tb = cc_obj.mode_control;
init = cc_obj.init;
load_value_tb = cc_obj.load_value;
end
rst_n = 0;
#2;
rst_n =1;
#2;

winner_gameover();

rst_n = 0;
#2;
rst_n =1;
#2;

loser_gameover();
#2;
end

//========== TASK FOR TESTING GAMEOVER WITH WINNER ==============
  
task winner_gameover();
init = 1;
for(int i = 0 ; i < 20 ; i++)begin
@(negedge clk);
load_value_tb = max_value;
#4;
load_value_tb = 0;
end
init = 0;
endtask

//========== TASK FOR TESTING GAMEOVER WITH LOSER ===============

task loser_gameover();
init = 1;
for(int i = 0 ; i < 20 ; i++)begin
@(negedge clk);
load_value_tb = 0;
#4;
load_value_tb = max_value;
end
init = 0;
#2;
$stop;
endtask
  
//========== SAMPLING COVER GROUP ===============================
  
always @(posedge clk) begin
cc_obj.cg.sample();
end



endmodule

