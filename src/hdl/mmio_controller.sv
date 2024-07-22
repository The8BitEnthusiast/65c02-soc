/* adapted from mmio controller design by Prof. Pong Chu in his book
*  FPGA Prototyping by SystemVerilog Examples
*/
module mmio_controller 
(  
   input logic clk,
   input logic rst,
   input logic mmio_cs,
   input logic mmio_we,
   input logic [11:0] mmio_addr, // 4 bits used for slot ID, 8 bits for registers 
   input logic [7:0] mmio_wr_data,
   output logic [7:0] mmio_rd_data,
   // slot interface
   output logic [15:0] slot_cs_array,
   output logic [15:0] slot_mem_we_array,
   output logic [7:0]  slot_reg_addr_array [15:0],
   input logic  [7:0]  slot_rd_data_array [15:0], 
   output logic [7:0] slot_wr_data_array [15:0]
);

   // declaration
   logic [3:0] slot_addr;
   logic [7:0] reg_addr;

   // body
   assign slot_addr = mmio_addr[11:8];
   assign reg_addr  = mmio_addr[7:0];

   // address decoding
   always_comb 
   begin
      slot_cs_array = 0;
      if (mmio_cs)
         slot_cs_array[slot_addr] = 1;
   end
   
   // broadcast to all slots 
   generate
      genvar i;
      for (i=0; i<16; i=i+1) 
      begin:  slot_signal_gen
         assign slot_mem_we_array[i] = mmio_we;
         assign slot_wr_data_array[i] = mmio_wr_data;
         assign slot_reg_addr_array[i] = reg_addr;
      end
   endgenerate
   // mux for read data 
   assign mmio_rd_data = slot_rd_data_array[slot_addr];   
endmodule

