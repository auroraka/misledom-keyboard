module keyboard_decoder(
	input wire[7:0] kcode,
	output reg[3:0] kdata
);

always @ (*) begin
	case (kcode)
		//standard keyboard
		8'h45:kdata<=4'h0;
		8'h16:kdata<=4'h1;
		8'h1E:kdata<=4'h2;
		8'h26:kdata<=4'h3;
		8'h25:kdata<=4'h4;
		8'h2E:kdata<=4'h5;
		8'h36:kdata<=4'h6;
		8'h3D:kdata<=4'h7;
		8'h3E:kdata<=4'h8;
		8'h46:kdata<=4'h9;
		8'h1C:kdata<=4'hA;
		8'h32:kdata<=4'hB;
		8'h21:kdata<=4'hC;
		8'h23:kdata<=4'hD;
		8'h24:kdata<=4'hE;
		8'h2B:kdata<=4'hF;
		//small keypad
		8'h70:kdata<=4'h0;
		8'h69:kdata<=4'h1;
		8'h72:kdata<=4'h2;
		8'h7A:kdata<=4'h3;
		8'h6B:kdata<=4'h4;
		8'h73:kdata<=4'h5;
		8'h74:kdata<=4'h6;
		8'h6C:kdata<=4'h7;
		8'h75:kdata<=4'h8;
		8'h7D:kdata<=4'h9;
		default:kdata<=4'h0;
	endcase
end

endmodule