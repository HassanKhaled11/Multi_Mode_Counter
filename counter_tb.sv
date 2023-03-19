module multi_mode_counter_tb();

reg         clk,rst_n,init ; 
logic [3:0] load_value_tb  ;
logic [1:0] mode_control_tb;

wire  GAMEOVER;
wire  [1:0] WHO; 


multi_mode_counter  counter_instance(.clk(clk),.rst_n(rst_n),.load_value(load_value_tb),.mode_control(mode_control_tb),
                                     .init(init),.GAMEOVER(GAMEOVER) ,.WHO(WHO));


initial begin
clk = 0;
  forever begin
    #1 clk = ~clk;
  end
end


initial begin
init = 0;
load_value_tb = 0;
mode_control_tb = 0;
rst_n = 0;
#100;
rst_n = 1;
#5;

mode_control_tb = 2'b0;
#10;
mode_control_tb = 2'b01;
#6;
mode_control_tb = 2'b10;
#6;
mode_control_tb = 2'b11;
#6;
load_value_tb = 4'd14;
#2;
init=1;
#2;
init = 0;
#2;
mode_control_tb = 2'b11;
#4;
rst_n = 0;
#2;
rst_n = 1;
mode_control_tb = 2'b0;
end

initial begin
#690;
mode_control_tb = 2;
end


initial begin
#1215;
$stop;
end




endmodule
