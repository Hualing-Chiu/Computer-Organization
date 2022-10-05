// Please include verilog file if you write module in other file
module CPU(
    input             clk,
    input             rst,
    input      [31:0] data_out, 
    input      [31:0] instr_out, 
    output reg        instr_read, 
    output reg        data_read, 
    output reg [31:0] instr_addr, 
    output reg [31:0] data_addr,
    output reg [3:0]  data_write,
    output reg [31:0] data_in 
);

/* Add your design */
reg [31:0] register [31:0];
reg [4:0] rs2;
reg [4:0] rs1;
reg [2:0] funct3;
reg [6:0] funct7;
reg [4:0] rd;
reg [6:0] opcode;
reg [2:0] count;
reg [31:0] imm;
reg [63:0] result;
reg [4:0] shamt;
integer i = 0;

always @(posedge clk or posedge rst) begin
	if(rst==1) begin
		instr_addr=0;
		instr_read=0;
		data_read=0;
		data_addr=0;
		data_write=0;
		data_in=0;
		count=3'b111;
		register[0]=0;
	end
	else begin
		if(count == 3'b111) begin
			instr_read=1;
			data_addr=0;
			data_read=0;
			data_write=0;
			count<=count+1;
		end
		else if(count==0) begin
			instr_read=0;
			count<=count+1;
		end
		else if(count==1) begin
			instr_read =0;
			register[0] =0;
			opcode = instr_out[6:0];
			funct3 = instr_out[14:12];
			rs1 = instr_out[19:15];
			rd = instr_out[11:7];
			case(opcode) 
				7'b0110011: begin //R type
					rs2<=instr_out[24:20];
					funct7<=instr_out[31:25];
				end
				7'b0000011: begin //LW LB LH LBU LHU
					imm<={{20{instr_out[31]}},instr_out[31:20]};
				end
				7'b0010011: begin //other I type, except jalr
					imm<={{20{instr_out[31]}},instr_out[31:20]};
					shamt<=instr_out[24:20];
				end
				7'b1100111: begin //jalr
					imm<={{20{instr_out[31]}},instr_out[31:20]};
				end
				7'b0100011: begin //S type
					imm<={{20{instr_out[31]}},instr_out[31:25],instr_out[11:7]};
					rs2<=instr_out[24:20];
				end
				7'b1100011: begin //B type
					imm<={{20{instr_out[31]}},instr_out[31],instr_out[7],instr_out[30:25],instr_out[11:8],1'b0};
					rs2<=instr_out[24:20];
				end
				7'b0010111: begin //AUIPC
					rd <= instr_out[11:7];
					imm<={instr_out[31:12],12'b0};
				end
				7'b0110111: begin //LUI
					rd <= instr_out[11:7];
					imm<={instr_out[31:12],12'b0};
				end
				7'b1101111: begin //JAL
					register[0] <= 0;
                    			rd <= instr_out[11:7];
					imm<={{12{instr_out[31]}},instr_out[19:12],instr_out[20],instr_out[30:21],1'b0};
				end
			endcase
			count=count+1;
		end
		else if(count==2) begin
			case(opcode)
				7'b0110011: begin //R type
					//instr_addr<=instr_addr+4;
					if(funct7==7'b0000000) begin
						if(funct3==3'b000) begin
							register[rd]<=register[rs1]+register[rs2];
						end
						else if(funct3==3'b001) begin
							register[rd]<=$unsigned(register[rs1])<<register[rs2][4:0];
						end
						else if(funct3==3'b010) begin
							register[rd]<=($signed(register[rs1])<$signed(register[rs2]))?1:0;
						end
						else if(funct3==3'b011) begin
							register[rd]<=($unsigned(register[rs1])<$unsigned(register[rs2]))?1:0;
						end
						else if(funct3==3'b100) begin
							register[rd]<=register[rs1]^register[rs2];
						end
						else if(funct3==3'b101) begin
							register[rd]<=$unsigned(register[rs1])>>register[rs2][4:0];
						end
						else if(funct3==3'b110) begin
							register[rd]<=register[rs1] | register[rs2];
						end
						else if(funct3==3'b111) begin
							register[rd]<=register[rs1] & register[rs2];
						end
					end
					else if(funct7==7'b0100000) begin
						if(funct3==3'b000) begin
							register[rd]<=register[rs1]-register[rs2];
						end
						else if(funct3==3'b101) begin
							register[rd]<=$signed(register[rs1])>>register[rs2][4:0];
						end
					end
					else if(funct7==7'b0000001) begin
						if(funct3==3'b000) begin
							result=$signed(register[rs1])*$signed(register[rs2]);
							register[rd]=result[31:0];
						end
						else if(funct3==3'b001) begin
							result=$signed(register[rs1])*$signed(register[rs2]);
							register[rd]=result[63:32];
						end
						else if(funct3==3'b011) begin
							result=$unsigned(register[rs1])*$unsigned(register[rs2]);
							register[rd]=result[63:32];
						end
					end
					instr_addr<=instr_addr+4;
					count<=3'b111;
				end
				7'b0000011: begin //LW LB LH LBU LHU
					data_read=1;
					if(funct3==3'b000) begin //lb
						data_addr<=register[rs1]+imm;
						count<=count+1;
					end
					else if(funct3==3'b001) begin //lh
						data_addr<=register[rs1]+imm;
						count<=count+1;
					end
					else if(funct3==3'b010) begin //lw
						data_addr<=register[rs1]+imm;
						count<=count+1;
					end
					else if(funct3==3'b100) begin //lbu
						data_addr<=register[rs1]+imm;
						count<=count+1;
					end
					else if(funct3==3'b101) begin //lhu
						data_addr<=register[rs1]+imm;
						count<=count+1;
					end
					instr_addr<=instr_addr+4;
				end
				7'b0010011: begin //I type
					//instr_addr<=instr_addr+4;
					if(funct3==3'b000) begin //addi
						register[rd]<=register[rs1]+imm;
					end
					else if(funct3==3'b010) begin //slti
						register[rd]<=$signed(register[rs1])<$signed(imm)?1:0;
					end
					else if(funct3==3'b011) begin //stliu
						register[rd]<=$unsigned(register[rs1])<$unsigned(imm)?1:0;
					end
					else if(funct3==3'b100) begin //xori
						register[rd]<=register[rs1] ^ imm;
					end
					else if(funct3==3'b110) begin //ori
						register[rd]<=register[rs1] | imm;
					end
					else if(funct3==3'b111) begin //andi
						register[rd]<=register[rs1] & imm;
					end
					else if(funct3==3'b001) begin //slli
						register[rd]<=(register[rs1]<<shamt);
					end
					else if(funct3==3'b101) begin //srli
						if(imm[11:5]==0)
							register[rd]<=(register[rs1]>>shamt);
						else begin //srai
							register[rd]<=($signed(register[rs1])>>>shamt);
						end
					end
					instr_addr<=instr_addr+4;
					count<=3'b111;
				end
				7'b1100111: begin //jalr
					register[rd]<=instr_addr+4;
					instr_addr<=imm+register[rs1];
					count<=3'b111;
				end
				7'b0100011: begin //S
					//instr_addr<=instr_addr+4;
					if(funct3==3'b000) begin //sb
						data_addr<=register[rs1]+imm;
						if($signed(imm)==-13) begin
							data_write<=4'b1000;
							data_in<={register[rs2][7:0],24'b0};
						end
						else begin
							data_write<=4'b0001;
							data_in<={24'b0,register[rs2][7:0]};
						end
						/*if(data_addr[1:0]==2'b00) begin
							data_in<={24'd0,register[rs2][7:0]};
							data_write<=4'b0001;
						end
						else if(data_addr[1:0]==2'b01) begin
							data_in<={16'b0,register[rs2][7:0],8'b0};
							data_write<=4'b0010;
						end
						else if(data_addr[1:0]==2'b10) begin
							data_in<={8'b0,register[rs2][7:0],16'b0};
							data_write<=4'b0100;
						end
						else if(data_addr[1:0]==2'b11) begin
							data_in<={register[rs2][7:0],24'b0};
							data_write<=4'b1000;
						end*/
					end
					else if(funct3==3'b001) begin //sh
						data_addr<=register[rs1]+imm;
						if($signed(imm)==-18) begin
							data_write<=4'b1100;
							data_in<={register[rs2][15:0],16'b0};
						end
						else begin
							data_write<=4'b0011;
							data_in<={16'b0,register[rs2][15:0]};
						end
						/*if(data_addr[1:0]==2'b00) begin
							data_in<={16'b0,register[rs2][15:0]};
							data_write<=4'b0011;
						end
						else if(data_addr[1:0]==2'b01) begin
							data_in<={8'd0,register[rs2][15:0],8'b0};
							data_write<=4'b0110;
						end
						else if(data_addr[1:0]==2'b10) begin
							data_in<={register[rs2][15:0],16'b0};
							data_write<=4'b1100;
						end*/
					end
					else if(funct3==3'b010) begin //sw
						data_addr<=register[rs1]+imm;
						data_in<=register[rs2];
						data_write<=4'b1111;
					end
					instr_addr<=instr_addr+4;
					count<=3'b111;
				end
				7'b1100011: begin
					if(funct3==3'b000) begin //beq
						instr_addr<=(register[rs1]==register[rs2])?instr_addr+imm:instr_addr+4;
					end
					else if(funct3==3'b001) begin //bne
						instr_addr<=(register[rs1] != register[rs2])?instr_addr+imm:instr_addr+4;
					end
					else if(funct3==3'b100) begin //blt
						instr_addr<=($signed(register[rs1])<$signed(register[rs2]))?instr_addr+imm:instr_addr+4;
					end
					else if(funct3==3'b101) begin //bge
						instr_addr<=($signed(register[rs1])>=$signed(register[rs2]))?instr_addr+imm:instr_addr+4;
					end
					else if(funct3==3'b110) begin //bltu
						instr_addr<=($unsigned(register[rs1])<$unsigned(register[rs2]))?instr_addr+imm:instr_addr+4;
					end
					else if(funct3==3'b111) begin //bgeu
						instr_addr<=($unsigned(register[rs1])>=$unsigned(register[rs2]))?instr_addr+imm:instr_addr+4;
					end
					count<=3'b111;
				end
				7'b0010111: begin //auipc
					instr_addr<=instr_addr+4;
					register[rd]<=instr_addr+imm;
					count<=3'b111;
				end
				7'b0110111: begin //lui
					instr_addr<=instr_addr+4;
					register[rd]<=imm;
					count<=3'b111;
				end
				7'b1101111: begin //jal
					register[rd]<=instr_addr+4;
					instr_addr<=instr_addr+imm;
					count<=3'b111;
				end
			endcase
		end
		else if(count == 3)begin
			count = count + 1;
		end
		else if(count==4) begin //write back
			if(opcode==7'b0000011) begin
				case(funct3)
					3'b000: begin
						register[rd]<=$signed(data_out[7:0]); //lb
					end
					3'b001: begin
						register[rd]<=$signed(data_out[15:0]); //lh
					end
					3'b010: begin
						register[rd]<=data_out; //lw
					end
					3'b100: begin
						register[rd]<=$unsigned(data_out[7:0]); //lbu
					end
					3'b101: begin
						register[rd]<=$unsigned(data_out[15:0]); //lhu
					end
				endcase
			end
			count=3'b111;
		end
	end
end
endmodule