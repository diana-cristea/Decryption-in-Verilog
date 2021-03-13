`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:12:00 11/23/2020 
// Design Name: 
// Module Name:    demux 
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

module decryption_top#(
			parameter addr_witdth = 8,
			parameter reg_width 	 = 16,
			parameter MST_DWIDTH = 32,
			parameter SYS_DWIDTH = 8
		)(
		// Clock and reset interface
		input clk_sys,
		input clk_mst,
		input rst_n,
		
		// Input interface
		input [MST_DWIDTH -1 : 0] data_i,
		input 						  valid_i,
		output busy,
		
		//output interface
		output [SYS_DWIDTH - 1 : 0] data_o,
		output      					 valid_o,
		
		// Register access interface
		input[addr_witdth - 1:0] addr,
		input read,
		input write,
		input [reg_width - 1 : 0] wdata,
		output[reg_width - 1 : 0] rdata,
		output done,
		output error
		
    );
	wire [15:0] select, caesar_key, scytale_key, zigzag_key;
	wire [7:0] data0_o, data1_o, data2_o, data_o0, data_o1, data_o2, data0_i, data1_i, data2_i;
	wire valid_o0, valid_o1, valid_o2, valid0_o, valid1_o, valid2_o, valid0_i, valid1_i, valid2_i, busy0, busy1, busy2;
	
	// TODO: Add and connect all Decryption blocks
		decryption_regfile rgfile(
		.clk(clk_sys), 
		.rst_n(rst_n), 
		.addr(addr), 
		.read(read), 
		.write(write), 
		.wdata(wdata), 
		.rdata(rdata), 
		.done(done), 
		.error(error), 
		.select(select), 
		.caesar_key(caesar_key), 
		.scytale_key(scytale_key), 
		.zigzag_key(zigzag_key)
	);
	
   demux dmx(
				.clk_sys(clk_sys),
				.clk_mst(clk_mst),
				.rst_n(rst_n),
				.select(select[1:0]),
				.data_i(data_i),
				.valid_i(valid_i),
				.data0_o(data0_o),
				.valid0_o(valid0_o),
				.data1_o(data1_o),
				.valid1_o(valid1_o),
				.data2_o(data2_o),
				.valid2_o(valid2_o) );
				
	caesar_decryption caesar(
		.clk(clk_sys), 
		.rst_n(rst_n), 
		.data_i(data0_o), 
		.valid_i(valid0_o), 
		.key(caesar_key), 
		.data_o(data_o0), 
		.valid_o(valid_o0), 
		.busy(busy0)
	);
   
	scytale_decryption scytale(
		.clk(clk_sys), 
		.rst_n(rst_n), 
		.data_i(data1_o), 
		.valid_i(valid1_o), 
		.key_N(scytale_key[15:8]), 
		.key_M(scytale_key[7:0]), 
		.data_o(data_o1), 
		.valid_o(valid_o1), 
		.busy(busy1)
	);
	
	zigzag_decryption zigzag(
		.clk(clk_sys), 
		.rst_n(rst_n), 
		.data_i(data2_o), 
		.valid_i(valid2_o), 
		.key(zigzag_key[7:0]), 
		.busy(busy2), 
		.data_o(data_o2), 
		.valid_o(valid_o2)
	);
	
   mux mx(
		.clk(clk_sys), 
		.rst_n(rst_n), 
		.select(select[1:0]), 
		.data_o(data_o), 
		.valid_o(valid_o), 
		.data0_i(data_o0), 
		.valid0_i(valid_o0), 
		.data1_i(data_o1), 
		.valid1_i(valid_o1), 
		.data2_i(data_o2), 
		.valid2_i(valid_o2)
	);	
	assign busy=(busy0 || busy1 || busy2); 
endmodule
