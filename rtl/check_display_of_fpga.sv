
module check_display_of_fpga (
   input  logic clk_i,
   input  logic rst_i,

   input  logic [7:0] in,
   output logic [7:0] anode,
   output logic [6:0] display
);

   logic [3:0] seg_count = 0;
   logic [3:0] data;
   
   logic [17:0] timer2 = 0;    //timer2 is for segment selection
   logic        clk_seg;
   
    always_ff @ (posedge clk_i)
    begin
        timer2  <= timer2 + 1;
        clk_seg <= timer2[17];  //17

        if (timer2 > 131072)
        begin
            timer2 <= 0;
        end
     end

     always @ (posedge clk_i)   //clk_seg, just to check (I beileve this will work)
     begin
        seg_count <= seg_count + 1;
        if (seg_count > 2)   //because # of segments to run are 8
        begin
            seg_count <= 0;
        end

        //data of count will be displayed on SSDs
        case(seg_count)
            0: begin anode <= 8'b11111110; data <= in[3:0];   end
            1: begin anode <= 8'b11111101; data <= in[7:4];   end
        endcase
      end

// Cathode patterns of the 7-segment 1 LED display 
   always @(*)
   begin
        case(data)
        4'b0000: display <= 7'b0000001; // "0"     
        4'b0001: display <= 7'b1001111; // "1" 
        4'b0010: display <= 7'b0010010; // "2" 
        4'b0011: display <= 7'b0000110; // "3" 
        4'b0100: display <= 7'b1001100; // "4" 
        4'b0101: display <= 7'b0100100; // "5" 
        4'b0110: display <= 7'b0100000; // "6" 
        4'b0111: display <= 7'b0001111; // "7" 
        4'b1000: display <= 7'b0000000; // "8"     
        4'b1001: display <= 7'b0000100; // "9"
        4'b1010: display <= 7'b0001000; // "A"     
        4'b1011: display <= 7'b1100000; // "b"     
        4'b1100: display <= 7'b0110001; // "C"     
        4'b1101: display <= 7'b1000010; // "d"
        4'b1110: display <= 7'b0110000; // "E"
        4'b1111: display <= 7'b0111000; // "F"
        
        default: display <= 7'b1111110; // "-"
        endcase
    
   end


endmodule