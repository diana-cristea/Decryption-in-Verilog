`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:53:30 11/26/2020 
// Design Name: 
// Module Name:    mux 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module mux #(
		parameter D_WIDTH = 8
	)(
		// Clock and reset interface
		input clk,
		input rst_n,
		
		//Select interface
		input[1:0] select,
		
		// Output interface
		output reg[D_WIDTH - 1 : 0] data_o,
		output reg						 valid_o,
				
		//output interfaces
		input [D_WIDTH - 1 : 0] 	data0_i,
		input   							valid0_i,
		
		input [D_WIDTH - 1 : 0] 	data1_i,
		input   							valid1_i,
		
		input [D_WIDTH - 1 : 0] 	data2_i,
		input     						valid2_i
    );
	
	//TODO: Implement MUX logic here
   always @(posedge clk) begin
	   //daca select e 0 iesirile sunt datele primite de la modulului caesar
		if(!select) begin 
			data_o<=data0_i;
			valid_o<=valid0_i;
		end
		//altfel daca select e 1 iesirile sunt datele primite de la modulului scytale
		else if(select==1) begin 
			data_o<=data1_i;
			valid_o<=valid1_i;
		end
		//daca select e 2 iesirile sunt cele datele de iesirea ale modulului zigzag
		else if(select==2) begin 
			data_o<=data2_i;
			valid_o<=valid2_i;
		end					
	end
endmodule
