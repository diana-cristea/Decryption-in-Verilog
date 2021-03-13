`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:13:49 11/23/2020 
// Design Name: 
// Module Name:    decryption_regfile 
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
module decryption_regfile #(
			parameter addr_witdth = 8,
			parameter reg_width 	 = 16
		)(
			// Clock and reset interface
			input clk, 
			input rst_n,
			
			// Register access interface
			input[addr_witdth - 1:0] addr,
			input read,
			input write,
			input [reg_width -1 : 0] wdata,
			output reg [reg_width -1 : 0] rdata,
			output reg done,
			output reg error,
			
			// Output wires
			output reg[reg_width - 1 : 0] select,
			output reg[reg_width - 1 : 0] caesar_key,
			output reg[reg_width - 1 : 0] scytale_key,
			output reg[reg_width - 1 : 0] zigzag_key
    );

// TODO implementati bancul de registre.

//bloc de initializare cu valorile de reset ale registrilor 
//si a semnalelor done si error
	initial begin
		select<=16'h0;
		caesar_key<=16'h0;
		scytale_key<=16'hffff;
		zigzag_key<=16'h2;
		done<=0;
		error<=0;
	end
   //pe fiecare front crescator de ceas	
	always @(posedge clk) begin
		done<=0; //done si error sunt 0 la inceput
		error<=0;
		if(!rst_n) begin //daca este activat reset(rst_n este 0), se reseteaza valorile registrilor
			select<=16'h0;
			caesar_key<=16'h0;
			scytale_key<=16'hffff;
			zigzag_key<=16'h2;
		end
		//daca este activat semnalul de citire, se verifica adresa primita
      //daca este o adresa valida, rdata preia valoarea din registrul aflat la adresa respectiva
      //iar citirea este validata de semnalul done(=1 in ciclul de ceas urmator)
      //nu avem eroare		
		else if(read) begin
			case(addr) 
				8'h0: begin rdata<=select;
			         done<=1;
					   end
				8'h10:begin rdata<=caesar_key;
					   done<=1;
					   end
				8'h12:begin rdata<=scytale_key;
			          done<=1;
					    end
			   8'h14:begin rdata<=zigzag_key;
			         done<=1;
					   end
				//altfel, daca adresa de intrare nu corespunde niciunui registru se indica o eroare la citire, validata tot de done
			   default: begin error<=1;
			          done<=1;
					    end
		   endcase
	  end
	  //daca este activat semnalul de scriere, se verifica adresa primita
	  //iar daca aceasta corespunde unuia din registrii, se va stoca in registrul respectiv valoarea din wdata,
	  //iar semnalul done este pus pe 1 (pe ciclul de ceas urmator)
	  //nu exista eroare la scriere
	  else if(write) begin
			case(addr)
				8'h0: begin select<=wdata[1:0]; //pentru registrul select se folosesc doar bitii [1:0], scrierea celorlalti fiind ignorata
						done<=1;
						end
				8'h10:begin caesar_key<=wdata;
						done<=1;
						end
				8'h12:begin scytale_key<=wdata;
						done<=1;
					end
				8'h14:begin zigzag_key<=wdata;
						done<=1;
						end
				//altfel, daca adresa nu este valida, se indica o eroare la scriere, iar done este pus pe 1 in ciclul urmator
				default: begin error<=1;
						done<=1;
						end
			endcase
	  end
  end
  
endmodule
