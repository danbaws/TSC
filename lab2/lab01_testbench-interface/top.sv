/***********************************************************************
 * A SystemVerilog top-level netlist to connect testbench to DUT
 **********************************************************************/

module top;
  timeunit 1ns/1ns;

  // user-defined types are defined in instr_register_pkg.sv
  import instr_register_pkg::*;

//lsb si msb. lsb modifica putin nr, msb modifica mult nr
//la negare -128 ... 0 ... 127

  // clock variables
  logic clk;
  logic test_clk; // logic - pune el daca e wire sau reg

  // interconnecting signals
  logic          load_en;
  logic          reset_n;
  opcode_t       opcode;
  operand_t      operand_a, operand_b;
  address_t      write_pointer, read_pointer;
  instruction_t  instruction_word;

  // instantiate testbench and connect ports
  instr_register_test test (
    .clk(test_clk),
    .load_en(load_en),
    .reset_n(reset_n),
    .operand_a(operand_a),
    .operand_b(operand_b),
    .opcode(opcode),
    .write_pointer(write_pointer),
    .read_pointer(read_pointer),
    .instruction_word(instruction_word)
   );

  // instantiate design and connect ports
  instr_register dut (
    .clk(clk),
    .load_en(load_en),
    .reset_n(reset_n),
    .operand_a(operand_a),
    .operand_b(operand_b),
    .opcode(opcode),
    .write_pointer(write_pointer),
    .read_pointer(read_pointer),
    .instruction_word(instruction_word)
   );

  // clock oscillators  #5 - time units (ns) mili, micro, nano, pico  ///  kilo, mega, giga, tera
  // factor de umplere 50% - perioada = 10 ns => factor = 5/10*100%=50% (frontul pozitiv)
  initial begin
    clk <= 0;
    forever #5  clk = ~clk;
  end

  initial begin  // timp de simulare 0 (initial begin)
    test_clk <=0;
    // offset test_clk edges from clk to prevent races between
    // the testbench and the design
    #4 forever begin  // factor de umplere = 80% 8/10*100%=80%
      #2ns test_clk = 1'b1;
      #8ns test_clk = 1'b0;
    end
  end

endmodule: top
