`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:24:12 11/27/2020 
// Design Name: 
// Module Name:    scytale_decryption 
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
module scytale_decryption #(
			parameter D_WIDTH = 8, 
			parameter KEY_WIDTH = 8, 
			parameter MAX_NOF_CHARS = 50,
			parameter START_DECRYPTION_TOKEN = 8'hFA
		)(
			// Clock and reset interface
			input clk,
			input rst_n,
			
			// Input interface
			input[D_WIDTH - 1:0] data_i,
			input valid_i,
			
			// Decryption Key
			input[KEY_WIDTH - 1 : 0] key_N,
			input[KEY_WIDTH - 1 : 0] key_M,
			
			// Output interface
			output reg[D_WIDTH - 1:0] data_o,
			output reg valid_o,
			output reg busy
    );

// TODO: Implement Scytale Decryption here
reg [D_WIDTH-1:0] text [0 : MAX_NOF_CHARS-1]; //am folosit un vector cu 50 de elemente pentru stocarea datelor
//i2 e folosit pt introducerea datelor de intrare in vector
//i este folosit pentru afisarea in ordinea indicata de algoritm a datelor pe iesire
integer i,lin,col,i2; 

	always @(posedge clk) begin
		if(!rst_n) begin //daca se activeaza reset, semnalele de iesire sunt puse pe 0
			data_o<=0;
			valid_o<=0;
			busy<=0;
		end
		else begin
		   //partea de afisare
		   //daca a fost activat busy, se activeaza si valid_o
	      if(busy) begin  //am folosit acest if pt a introduce decalajul dintre busy si valid_o
				valid_o<=1;
					if(lin<=key_N) begin //daca nu s-a depasit numarul de linii indicat de key_N
						data_o<=text[i]; //Se afiseaza primul caracter
						i<=i+key_N; //este incrementat cu nr de linii, pt a trece pe "coloana" urmatoare
						col<=col+1; //se incrementeaza contorul pt pseudo-coloane
						if(col>=key_M-1) begin //daca nu s-a depasit nr de coloane indicat de key_M
							lin<=lin+1; //se trece la urmatoarea "linie"
							i<=lin; //contorul de afisare trece la urmatoarea linie
							col<=0; //se reinitializeaza nr coloanei
						end
					end
					if(lin>key_N) begin //daca contorul de linii a depasit nr de linii se reinitializeaza iesirile
						data_o<=0;
						valid_o<=0;
						busy<=0;
					end
			end
			//partea de citire
			if(valid_i && !busy) begin //daca s-a semnalat inceperea primirii de date si busy nu e ridicat
				if(data_i!=START_DECRYPTION_TOKEN) begin //daca nu s-a ajuns la caracterul de incepere decriptare
					text[i2]<=data_i; //vectorul de stocare primeste in ordine valorile primite la intrare
					i2<=i2+1; //se incrementeaza contorul
					//semnalele busy si valid_o raman pe 0
					busy<=0;
					valid_o<=0;
					//se initializeaza contoarele
					i<=0;
					col<=0;
					lin<=1;
				end
			   else begin //altfel daca s-a primit caracterul special, busy este ridicat si urmeaza a se incepe decriptarea in ciclul urmator 
					busy<=1;
				end
			end
		  else i2<=0; //initializarea contorului de citire inainte si dupa ce s-au primit datele
		end
	end
endmodule
