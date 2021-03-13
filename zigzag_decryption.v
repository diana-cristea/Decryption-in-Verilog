`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:33:04 11/23/2020 
// Design Name: 
// Module Name:    zigzag_decryption 
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
module zigzag_decryption #(
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
			input[KEY_WIDTH - 1 : 0] key,
			
			// Output interface
			output reg busy,
			output reg[D_WIDTH - 1:0] data_o,
			output reg valid_o
    );

// TODO: Implement ZigZag Decryption here
reg [D_WIDTH-1:0] text [0 : MAX_NOF_CHARS-1]; //vector in care se stocheaza datele citite
reg [D_WIDTH-1:0] text1 [0 : MAX_NOF_CHARS-1]; //vector in care se pun datele stocate in ordinea corespunzatoare pt key=3
// i este contorul de afisare
// i2 este contoru de citire si stocare
//j este folosit pt numarul liniei
//l1, l2, l3 sunt folosite pt decriptarea in cazul key=3 pt fiecare linie
//c este folosit pe stocarea in vectorul suplimentar in ordinea potrivita
integer i,i1,j,i2,i3,nrcaract,l1,l2,l3,c; 

always @(posedge clk) begin
	if(!rst_n) begin // la reset se initializeaza output-urile
	   data_o<=0;
	   valid_o<=0;
	   busy<=0;
	end
	else begin
	      if(busy) begin //dupa ce busy a fost ridicat, se pune si valid_o pe 1 pt a introduce decalajul dintre acestea
			      valid_o<=1;
					if(key==2) begin //daca se decripteaza cu cheia 2
						if(nrcaract[0]==0) begin //pentru numar par de caractere
							if(i1<=(nrcaract>>1)) begin //pe prima linie indicii merg pana la jumatate din nr de caractere
								data_o<=text[i]; //se trimite pe iesire primul caracter
								i<=i+(nrcaract>>1); //se incrementeaza cu jumatate din nr de caractere total
							// se incrementeaza contorul folosit pt afisarea a 2 caractere in diagonala
								j<=j+1; //acesta semnalizeaza daca ne aflam pe prima sau a 2-a linie practic
							if(j>=1) begin 
								i1<=i1+1; //dupa se trece la caracterul de pe prima linie, dar pe pozitia urmatoare
								i<=i1;
								j<=0; // se intoarce la prima linie
							end
							end
							if(i1>(nrcaract>>1)) begin //daca a fost depasita jumatatea nr de caractere, practic au fost afisate toate caracterele
							// si se reinitializeaza iesirile
								data_o<=0;
								valid_o<=0;
								busy<=0;
							end
						end
						else begin
						    // daca avem numar impar de caractere, caracterul din mijloc va fi afisat ultimul
							if(i1<=(nrcaract>>1)) begin // se merge pana la jumatatea nr de caractere, adica pana la ultimul caracter inainte de cel de mijloc
								data_o<=text[i]; // se afiseaza primul caracter
								i<=i+(nrcaract>>1)+1; // se incrementeaza cu jumatate de nr de caract +1
								j<=j+1; //se trece la linia 2
								if(j>=1) begin 
									i1<=i1+1; //se incrementeaza nr coloanei
									i<=i1;
									j<=0; //se intoarce la prima linie
								end
							 end
							if(i1==(nrcaract>>1)+1) begin //daca s-a trecut de caracterul de mijloc,  
								data_o<=text[i1-1]; //acesta va fi afisat ultimul
								i1<=i1+1;
							end
							if(i1>(nrcaract>>1)+1) begin //daca s-au afisat toate caracterele, adica am trecut si de cel din mijloc, 
							//se reinitializeaza iesirile
								data_o<=0;
								valid_o<=0;
								busy<=0;
							end
						end
					end
					// pentru cheia 3, se afiseaza in ordine toate caracterele puse deja in ordinea corespunzatoare din vectorul suplimentar
					if(key==3) begin
						if(i3<nrcaract) begin
							data_o<=text1[i3]; // in acest caz afisarea se face din noul vector
							i3<=i3+1;
						end
						else begin // daca s-a terminat afisarea, se reinitializeaza iesirile
							data_o<=0;
							valid_o<=0;
							busy<=0;
						end
					
				    end
			end
			// aici se face citirea pentru ambele cazuri ale cheii
			if(valid_i && !busy) begin //daca este activat valid_i si nu e ridicat semnalul busy
				if(data_i!=START_DECRYPTION_TOKEN) begin // si nu s-a ajung la caracterul special
					text[i2]<=data_i; //se primesc si stocheaza datele in ordine
					i2<=i2+1; // se trece la urmatoarea pozitie
					//cand se primesc date busy si valid_o raman pe 0
					busy<=0; 
					valid_o<=0;
					// se initializeaza contoarele
					i<=0;
					j<=0;
					i1<=1;
					i3<=0;
				end
			     else begin // daca s-a primit caracterul special, se ridica semnalul busy urmand a se incepe afisarea in ciclul urmator
					 busy<=1;
					 nrcaract<=i2; // se salveaza numarul de caractere citite
				  end
			end
		  else i2<=0; // dupa ce s-a terminat citirea si stocarea se reinitializeaza contorul pt citire
		end
	end
	 // aici se executa algoritmul de decriptare propriu-zis pentru key=3
	 // stocandu-se intr-un alt vector caracterele in ordinea corespunzatoare
	 always @(*) begin
	   if(key==3) begin
			if(data_i==START_DECRYPTION_TOKEN && (busy==0)) begin // dupa ce s-a terminat citirea
	 // se disting 4 cazuri in functie de numarul de caractere citite
	 // numarul pana la care merg contoarele fiecarei linii difera de la un caz la altul
	 // l1, l2, l3 arata pe ce pozitie trebuie stocat caracterul din vectorul cu date in noul vector

			if(nrcaract==((nrcaract>>2)<<2)) begin // cazul 4k caractere
				c=0; // contorul de afisare din primul vector porneste de la 0
				for(l1=0;l1<=MAX_NOF_CHARS-1;l1=l1+4) begin // pe prima linie indecsii cresc din 4 in 4, incepand cu 0
					if(l1<=nrcaract-4) begin
						text1[l1]=text[c];
						c=c+1; //se incrementeaza dupa fiecare stocare
					end
				end
				for(l2=1;l2<=MAX_NOF_CHARS-1;l2=l2+2) begin // pe a 2-a linie indecsii cresc din 2 in 2, incepand cu 1
					if(l2<=nrcaract-1) begin
						text1[l2]=text[c];
						c=c+1;
					end
				end
				for(l3=2;l3<=MAX_NOF_CHARS-1;l3=l3+4) begin // pe a 3-a linie indecsii cresc din 4 in 4, incepand cu 2
					if(l3<=nrcaract-2) begin
						text1[l3]=text[c];
						c=c+1;
					end
				end		
			end
			else if(nrcaract==(((nrcaract>>2)<<2)+1)) begin //cazul 4k+1 caractere
				c=0; // contorul de afisare din primul vector porneste de la 0
				for(l1=0;l1<=MAX_NOF_CHARS-1;l1=l1+4) begin // pe prima linie indecsii cresc din 4 in 4, incepand cu 0
					if(l1<=nrcaract-1) begin
						text1[l1]=text[c];
						c=c+1; //se incrementeaza dupa fiecare stocare
					end
				end
				for(l2=1;l2<=MAX_NOF_CHARS-1;l2=l2+2) begin // pe a 2-a linie indecsii cresc din 2 in 2, incepand cu 1
					if(l2<=nrcaract-2) begin
						text1[l2]=text[c];
						c=c+1;
					end
				end
				for(l3=2;l3<=MAX_NOF_CHARS-1;l3=l3+4) begin // pe a 3-a linie indecsii cresc din 4 in 4, incepand cu 2
					if(l3<=nrcaract-3) begin
						text1[l3]=text[c];
						c=c+1;
					end
				end		
			end
			else if(nrcaract==(((nrcaract>>2)<<2)+2)) begin //cazul 4k+2 caractere
				c=0;  // contorul de afisare din primul vector porneste de la 0
				for(l1=0;l1<=MAX_NOF_CHARS-1;l1=l1+4) begin // pe prima linie indecsii cresc din 4 in 4, incepand cu 0
					if(l1<=nrcaract-2) begin
						text1[l1]=text[c];
						c=c+1; //se incrementeaza dupa fiecare stocare
					end
				end
				for(l2=1;l2<=MAX_NOF_CHARS-1;l2=l2+2) begin // pe a 2-a linie indecsii cresc din 2 in 2, incepand cu 1
					if(l2<=nrcaract-1) begin
						text1[l2]=text[c];
						c=c+1;
					end
				end
				for(l3=2;l3<=MAX_NOF_CHARS-1;l3=l3+4) begin // pe a 3-a linie indecsii cresc din 4 in 4, incepand cu 2
					if(l3<=nrcaract-3) begin
						text1[l3]=text[c];
						c=c+1;
					end
				end		
			end
			else if(nrcaract==(((nrcaract>>2)<<2)+3)) begin //cazul 4k+3 caractere
				c=0;  // contorul de afisare din primul vector porneste de la 0
				for(l1=0;l1<=MAX_NOF_CHARS-1;l1=l1+4) begin // pe prima linie indecsii cresc din 4 in 4, incepand cu 0
					if(l1<=nrcaract-3) begin
						text1[l1]=text[c];
						c=c+1; //se incrementeaza dupa fiecare stocare
					end
				end
				for(l2=1;l2<=MAX_NOF_CHARS-1;l2=l2+2) begin // pe a 2-a linie indecsii cresc din 2 in 2, incepand cu 1
					if(l2<=nrcaract-2) begin
						text1[l2]=text[c];
						c=c+1;
					end
				end
				for(l3=2;l3<=MAX_NOF_CHARS-1;l3=l3+4) begin // pe a 3-a linie indecsii cresc din 4 in 4, incepand cu 2
					if(l3<=nrcaract-1) begin
						text1[l3]=text[c];
						c=c+1;
					end
				end	
			end 
		end
	end
 end
	
endmodule
