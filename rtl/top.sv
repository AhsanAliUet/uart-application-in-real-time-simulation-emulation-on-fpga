

module top (
   input  logic clk_fpga,
   input  logic rst_i,

   input  logic rx_en,
   input  logic rx_in,
   output logic rx_done,
   output logic rx_busy,
   output logic rx_error,

   output logic [7:0] anode,
   output logic [6:0] display
);

   parameter CLOCK     = 100000000;
   parameter BAUD_RATE =  9600;
   
   logic       rx_clk;
   logic [7:0] rx_out;

   baud_rate_generator  #(
      .CLOCK     (CLOCK    ),
      .BAUD_RATE (BAUD_RATE)
   )i_brg(
      .clk  (clk_fpga),
      .rxClk(rx_clk  )
   );

   rx i_rx(
      .clk (rx_clk  ),
      .en  (rx_en   ),
      .in  (rx_in   ),
      .out (rx_out  ),
      .done(rx_done ),
      .busy(rx_busy ),
      .err (rx_error)
   );

   logic [31:0] count;

   counter i_counter(
      .clk_i(clk_fpga),
      .rst_i(rst_i   ),
      .max  (rx_out  ),

      .count(count   )
   );

   //printing on SSDs

    logic [17:0] timer2;    //timer2 is for segment selection
    logic        clk_seg;
    logic [2:0]  seg_count;
    logic [3:0]  data;
   
    always_ff @ (posedge clk_fpga)
    begin
      if (rst_i) begin
         timer2 <= '0;
      end
        timer2  <= timer2 + 1;
        clk_seg <= timer2[17];  //17

        if (timer2 > 131072)
        begin
            timer2 <= 0;
        end
     end

     always_ff @ (posedge clk_seg)
     begin
        seg_count <= seg_count + 1;
        if (seg_count > 3)   //because # of segments to be used are 4
        begin
            seg_count <= 0;
        end

        //data of count will be displayed on SSDs
        case(seg_count)
            0: begin anode <= 8'b11111110; data  <= count[3:0];   end
            1: begin anode <= 8'b11111101; data  <= count[7:4];   end
            2: begin anode <= 8'b10111111; data  <= rx_out[3:0];  end
            3: begin anode <= 8'b01111111; data  <= rx_out[7:4];  end
        endcase
     end


   // Cathode patterns of the 7-segment 1 LED display 
    always_comb
    begin
        case(data)
        4'b0000: display = 7'b0000001; // "0"     
        4'b0001: display = 7'b1001111; // "1" 
        4'b0010: display = 7'b0010010; // "2" 
        4'b0011: display = 7'b0000110; // "3" 
        4'b0100: display = 7'b1001100; // "4" 
        4'b0101: display = 7'b0100100; // "5" 
        4'b0110: display = 7'b0100000; // "6" 
        4'b0111: display = 7'b0001111; // "7" 
        4'b1000: display = 7'b0000000; // "8"     
        4'b1001: display = 7'b0000100; // "9"
        4'b1010: display = 7'b0001000; // "A"     
        4'b1011: display = 7'b1100000; // "b"     
        4'b1100: display = 7'b0110001; // "C"     
        4'b1101: display = 7'b1000010; // "d"
        4'b1110: display = 7'b0110000; // "E"
        4'b1111: display = 7'b0111000; // "F"
        
        default: display = 7'b1111110; // "-"
        endcase
    
end

endmodule: top