module traffic_light (
    input  clk,
    input  rst,
    input  pass,
    output reg R,
    output reg G,
    output reg Y
);

//write your code here
reg [11:0] cycle;
reg [2:0] state;

initial begin
    state<=1;
    cycle<=1;
    R=0;
    Y=0;
    G=1;
end
always@(posedge clk or posedge rst) begin
    if(rst) begin
	state<=1;
	cycle<=1;
    end
    else if(pass&&state!=1) begin
	cycle<=1;
	state<=1;
    end
    else begin
	if(state==1) begin
	    if(cycle>=1024) begin
	    	state<=2;
	    	cycle<=1;
	    end
	    else begin
		cycle<=cycle+1;
	    end
    	end
	
    	if(state==2) begin
	    if(cycle>=128) begin
	    	state<=3;
	    	cycle<=1;
	    end
	    else begin
		cycle<=cycle+1;
	    end
    	end
        if(state==3) begin
	    if(cycle>=128) begin
	    	state<=4;
	    	cycle<=1;
	    end
	    else begin
		cycle<=cycle+1;
	    end
    	end
	
        if(state==4) begin
	    if(cycle>=128) begin
	    	state<=5;
	    	cycle<=1;
	    end
	    else begin
		cycle<=cycle+1;
	    end
    	end
	
        if(state==5) begin
	    if(cycle>=128) begin
	    	state<=6;
	    	cycle<=1;
	    end
	    else begin
		cycle<=cycle+1;
	    end
    	end
	
    	if(state==6) begin
	    if(cycle>=512) begin
	    	state<=7;
	    	cycle<=1;
	    end
	    else begin
		cycle<=cycle+1;
	    end
    	end
	
    	if(state==7) begin
	    if(cycle>=1024) begin
	    	state<=1;
	    	cycle<=1;
	    end
	    else begin
		cycle<=cycle+1;
	    end
    	end
    end
end
always@(state) begin
    case(state)
	1,3,5: begin
	    R=0;
	    G=1;
	    Y=0;
	end
	2,4: begin
	    R=0;
	    G=0;
	    Y=0;
	end
	6: begin
	    R=0;
	    G=0;
	    Y=1;
	end
	7: begin
	    R=1;
	    G=0;
	    Y=0;    
	end
	default:
	begin
	end
    endcase
end

endmodule
