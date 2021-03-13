`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:17:08 11/23/2020 
// Design Name: 
// Module Name:    ceasar_decryption 
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
module caesar_decryption #(
				parameter D_WIDTH = 8,
				parameter KEY_WIDTH = 16
			)(
			// Clock and reset interface
			input clk,
			input rst_n,
			
			// Input interface
			input[D_WIDTH - 1:0] data_i,
			input valid_i,
			
			// Decryption Key
			input[KEY_WIDTH - 1 : 0] key,
			
			// Output interface
			output reg[D_WIDTH - 1:0] data_o,
			output reg valid_o,
			output reg busy
    );

// TODO: Implement Caesar Decryption here

	always @(posedge clk) begin
		busy<=0; //semnalul busy este mereu 0 pentru acest modul
		valid_o<=0;
		if(!rst_n) begin //daca este activ semnalul de reset(in 0), se reinitializeaza iesirile
			data_o<=0;
			valid_o<=0;
			end
		else begin
			if(valid_i) begin // Cat timp valid_i este ridicat
				valid_o<=1; //dupa ce valid_i a fost activat, valid_o este ridicat 
				data_o<=data_i-key; //se ia fiecare caracter si i se scade cheia de decriptare fiind afisat pe iesire
			end
     	//altfel se reinitializeaza valorile de iesire
			else begin
				valid_o<=0;
				data_o<=0;
			end
		end
	end
endmodule
