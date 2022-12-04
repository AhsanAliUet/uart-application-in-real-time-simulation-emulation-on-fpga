

module counter(
   input  logic        clk_i,
   input  logic        rst_i,
   input  logic [7:0]  max,

   output logic [31:0] count
);

   logic        clk_1_sec;
   logic [31:0] reducer;

   always_ff @ (posedge clk_i, posedge rst_i)   //clock reducing to 1 second
   begin
      if (rst_i)
      begin
         reducer   <= '0;
         clk_1_sec <= '0;
      end

      else if (reducer >= 50000000)      //100_000_000/2 for 1 second tick
      begin
         clk_1_sec <= ~clk_1_sec;
         reducer   <= '0;
      end

      else
      begin
         reducer <= reducer + 1;
      end
   end


   always_ff @ (posedge clk_1_sec, posedge rst_i)
   begin
      if (rst_i || max == 0)
      begin
         count <= '0;
      end
      else
      begin
         // if (vari != 0 || vari > count)
         if (max >= count)
         begin
            count <= count + 1;
            if (count == max && max != 0)
            begin
               count <= '0;
            end
         end
         else if (max <= count)
         begin
            count <= '0;
         end

      end
   end

endmodule: counter