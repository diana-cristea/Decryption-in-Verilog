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

module demux #(
		parameter MST_DWIDTH = 32,
		parameter SYS_DWIDTH = 8
	)(
		// Clock and reset interface
		input clk_sys,
		input clk_mst,
		input rst_n,
		
		//Select interface
		input[1:0] select,
		
		// Input interface
		input [MST_DWIDTH -1  : 0]	 data_i,
		input 						 	 valid_i,
		
		//output interfaces
		output reg [SYS_DWIDTH - 1 : 0] 	data0_o,
		output reg     						valid0_o,
		
		output reg [SYS_DWIDTH - 1 : 0] 	data1_o,
		output reg     						valid1_o,
		
		output reg [SYS_DWIDTH - 1 : 0] 	data2_o,
		output reg     						valid2_o
    );
	// am luat o variabila pentru a retine datele din data_i
   reg [MST_DWIDTH -1  : 0] data_copie;
	// ok1 este contorul pentru afisarea celor 4 caractere separate din data_i in ordine
	// ok este contorul pentru inceperea afisarii datelor pe iesire
	reg [2:0] ok1,ok;
	
	// TODO: Implement DEMUX logic
	
	//pe fronturile crescatoare ale ceasului mai lent(clk_mst) se dau valori semnalelor de valid out
	always @(posedge clk_mst) begin
	   if(!rst_n) begin //se reseteaza iesirile
			valid0_o<=0;
			valid1_o<=0;
			valid2_o<=0;
		end
		//initial semnalele de valid_o sunt 0
		valid0_o<=0; 
		valid1_o<=0;
		valid2_o<=0;
	   if(valid_i) begin //daca este ridicat semnalul valid_i, atunci in functie de valoarea lui select, valid_o-ul modulului corespunzator
		                  //devine 1, iar celelate raman pe 0
			case(select)
				2'b00: begin 
					valid0_o<=1;
					valid1_o<=0;
					valid2_o<=0;
				end
				2'b01: begin
					valid1_o<=1;
					valid0_o<=0;
					valid2_o<=0;
				end
				2'b10: begin
					valid2_o<=1;
					valid0_o<=0;
					valid1_o<=0;
				end
			endcase	
		end
	end
	
	//afisarea datelor este sincronizata pe ceasul sistemului, care este mai rapid(clk_sys)
	always @(posedge clk_sys) begin
		ok<=0;
		//datele afisate sunt 0 initial
		data0_o<=0;
		data1_o<=0;
		data2_o<=0;
		if(!rst_n) begin //daca este activat resetul, iesirile sunt reintializate
			data0_o<=0;
			data1_o<=0;
			data2_o<=0;
		end
		else begin 
			if(valid_i) begin //cand valid_i este activ
            if(ok==2) data_copie<=data_i;	//se copiaza datele intr-o variabila auxiliara inainte de urmatorul front al clk_mst		
				ok1<=0; //se initializeaza contorul pentru cele 4 caractere din fiecare data_i
				if(ok<3) ok<=ok+1; //se incrementeaza contorul pentru inceperea afisarii
			end
			if(ok==3 || valid0_o || valid1_o || valid2_o) begin //daca au trecut 4 cicluri de clk_sys si cat timp unul din semnalele de 
			                                                    // valid out este ridicat, se face afisarea
				case(select)
			   // daca select este 0, corespunzator modulului caesar, se trimit date pe portul iesirii corespunzatoare, iar restul raman 0
					2'b00: begin
						data1_o<=0;
						data2_o<=0;
						if(ok1==0) data0_o<=data_copie[31:24]; //primul caracter
						else if(ok1==1) data0_o<=data_copie[23:16]; //al doilea caracter
						else if(ok1==2) data0_o<=data_copie[15:8]; // al treilea caracter
						else if(ok1==3) data0_o<=data_copie[7:0];  //al patrulea caracter
					end
				// daca select este 1, corespunzator modulului scytale, se trimit date pe portul iesirii corespunzatoare, iar restul raman 0
					2'b01: begin
						data0_o<=0;
						data2_o<=0;
						if(ok1==0) data1_o<=data_copie[31:24]; //primul caracter
						else if(ok1==1) data1_o<=data_copie[23:16]; //al doilea caracter
						else if(ok1==2) data1_o<=data_copie[15:8]; // al treilea caracter
						else if(ok1==3) data1_o<=data_copie[7:0];
					end
				// daca select este 2, corespunzator modulului zig-zag, se trimit date pe portul iesirii corespunzatoare, iar restul raman 0
					2'b10: begin
						data0_o<=0;
						data1_o<=0;
						if(ok1==0) data2_o<=data_copie[31:24]; //primul caracter
						else if(ok1==1) data2_o<=data_copie[23:16]; //al doilea caracter
						else if(ok1==2) data2_o<=data_copie[15:8]; // al treilea caracter
						else if(ok1==3) data2_o<=data_copie[7:0]; //al patrulea caracter
					end
				endcase
			   if(ok1<3) ok1<=ok1+1; //daca nu am ajuns la numarul maxim de caractere dintr-un "set", se incrementeaza contorul	
			   else ok1<=0; //altfel, o ia de la capat
	     end
		  if(!valid_i && ok1==3) data_copie<=0; // dupa ce valid_i s-a facut 0 si s-au afisat ultimele 4 caractere, variabila pentru datele de intrare devine 0
	     end
	end
endmodule
