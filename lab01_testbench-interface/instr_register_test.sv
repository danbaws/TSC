/***********************************************************************
 * A SystemVerilog testbench for an instruction register.
 * The course labs will convert this to an object-oriented testbench
 * with constrained random test generation, functional coverage, and
 * a scoreboard for self-verification.
 **********************************************************************/

module instr_register_test
  import instr_register_pkg::*;  // user-defined types are defined in instr_register_pkg.sv
  (input  logic          clk,
   output logic          load_en,
   output logic          reset_n,
   output operand_t      operand_a,
   output operand_t      operand_b,
   output opcode_t       opcode,
   output address_t      write_pointer,
   output address_t      read_pointer,
   input  instruction_t  instruction_word
  );

  timeunit 1ns/1ns;
  parameter WRITE_NR=20;
  parameter READ_NR=20;
  instruction_t iw_reg_test [0:31];
  parameter READ_ORDER=1;
  parameter WRITE_ORDER=1;
  parameter TEST="nume_test";
  int trecut=0;
  int teste=0;
  parameter SEED_VAL=555;
  int seed = SEED_VAL;

  initial begin
    $display("\n\n***********************************************************");
    $display(    "***  THIS IS A SELF-CHECKING TESTBENCH (YET).  YOU      ***");
    $display(    "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(    "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(    "***********************************************************");
    $display("\nReseting the instruction register...");
    write_pointer  = 5'h00;         // initialize write pointer
    read_pointer   = 5'h1F;         // initialize read pointer
    load_en        = 1'b0;          // initialize load control line
    reset_n       <= 1'b0;          // assert reset_n (active low)
    repeat (2) @(posedge clk) ;     // hold in reset for 2 clock cycles
    reset_n        = 1'b1;          // deassert reset_n (active low)

    $display("\nWriting values to register stack...");
    @(posedge clk) load_en = 1'b1;  // enable writing to register
    //repeat (3) begin
      repeat (WRITE_NR) begin      // 03.06.2024 - Daniel
      @(posedge clk) randomize_transaction;
      @(negedge clk) 
      print_transaction;
    end
    @(posedge clk) load_en = 1'b0;  // turn-off writing to register

    // read back and display same three register locations
    $display("\nReading back the same register locations written...");
    //for (int i=0; i<=2; i++) begin
    for (int i=0; i<=READ_NR; i++) begin        // 03.06.2024 - Daniel
      // later labs will replace this loop with iterating through a
      // scoreboard to determine which addresses were written and
      // the expected values to be read back

      case(READ_ORDER)
        0: @(posedge clk) read_pointer = i; // increasing
        1: @(posedge clk) read_pointer = 31 - i%32; // decreasing
        2: @(posedge clk) read_pointer = $unsigned($random)%32; // Random de la 0 la 31
        default: @(posedge clk) read_pointer = i; // crescator default
      endcase
      // @(posedge clk) read_pointer = i;
      @(negedge clk) print_results;
       check_result;
    end

    @(posedge clk) ;
    $display("\n***********************************************************");
    $display(  "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
    $display(  "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(  "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(  "***********************************************************\n");
     $display("\nAu trecut: %0d. Din totalul de teste: %0d.", trecut, teste);
     write_to_file;
     $finish;
  end

  function void randomize_transaction;
    // A later lab will replace this function with SystemVerilog
    // constrained random values
    //
    // The static temp variable is required in order to write to fixed
    // addresses of 0, 1 and 2.  This will be replaced with randomized
    // write_pointer values in a later lab
    //
    // static int temp = 0;
    operand_a     = $random(seed)%16;                 // between -15 and 15
    operand_b     = $unsigned($random)%16;            // between 0 and 15
    opcode        = opcode_t'($unsigned($random)%8);  // between 0 and 7, cast to opcode_t type
    // write_pointer = temp++;  //0 1 ... etc ramane 0 dupa care iw_reg_test incepe de la 0. temp++ de la 0, ++temp era 1.
    case(WRITE_ORDER)
    0: begin  //increasing
      static int temp = 0;
      write_pointer = temp++;
    end
    1: begin //decreasing
      static int temp = 31;
      write_pointer = temp--;
    end
    2: begin //random
      write_pointer = $unsigned($random)%32;
    end
    default: begin // crescator default
      static int temp = 0;
      write_pointer = temp++;
    end
  endcase

    iw_reg_test[write_pointer] = '{opcode, operand_a, operand_b, {64{1'b0}}};
    $display("Test: A=%0d, B=%0d, Opcode=%0d", operand_a, operand_b, opcode);
  endfunction: randomize_transaction

  function void print_transaction;
    $display("Writing to register location %0d: ", write_pointer);
    $display("  opcode = %0d (%s)", opcode, opcode.name);
    $display("  operand_a = %0d",   operand_a);
    $display("  operand_b = %0d\n", operand_b);
  endfunction: print_transaction

  function void print_results;
    $display("Read from register location %0d: ", read_pointer);
    $display("  opcode = %0d (%s)", instruction_word.opc, instruction_word.opc.name);
    $display("  operand_a = %0d",   instruction_word.op_a);
    $display("  operand_b = %0d",   instruction_word.op_b);
    $display("  result = %0d", instruction_word.result);
  endfunction: print_results

  function void check_result;
    if(instruction_word.op_a === iw_reg_test[read_pointer].op_a && instruction_word.op_b === iw_reg_test[read_pointer].op_b && instruction_word.opc === iw_reg_test[read_pointer].opc) begin //primul if
    case (iw_reg_test[read_pointer].opc)
        ZERO: begin
          iw_reg_test[read_pointer].result = 64'b0;
        end
        PASSA:  begin
          iw_reg_test[read_pointer].result = iw_reg_test[read_pointer].op_a;
        end
        PASSB:  begin
          iw_reg_test[read_pointer].result = iw_reg_test[read_pointer].op_b;
        end
        ADD:  begin
          iw_reg_test[read_pointer].result = iw_reg_test[read_pointer].op_a + iw_reg_test[read_pointer].op_b;
        end
        SUB:  begin
          iw_reg_test[read_pointer].result = iw_reg_test[read_pointer].op_a - iw_reg_test[read_pointer].op_b;
        end
        MULT: begin
          iw_reg_test[read_pointer].result = iw_reg_test[read_pointer].op_a * iw_reg_test[read_pointer].op_b;
        end
        DIV:  begin
          if (iw_reg_test[read_pointer].op_b === 0) begin
              iw_reg_test[read_pointer].result = 64'b0;
          end else begin
              iw_reg_test[read_pointer].result = iw_reg_test[read_pointer].op_a / iw_reg_test[read_pointer].op_b;    
          end
        end
        MOD:  begin
          if (iw_reg_test[read_pointer].op_b === 0) begin
              iw_reg_test[read_pointer].result = 64'b0;
          end else begin
              iw_reg_test[read_pointer].result = iw_reg_test[read_pointer].op_a % iw_reg_test[read_pointer].op_b;
          end
        end
        POW:  begin
          iw_reg_test[read_pointer].result = iw_reg_test[read_pointer].op_a ** iw_reg_test[read_pointer].op_b;
        end
        default: iw_reg_test[read_pointer].result = 64'b0;
      endcase


      if(iw_reg_test[read_pointer].result === instruction_word.result) begin
        $display("Rezultatul este corect!\n");
        trecut++;
      end else begin
        $display("Rezultatul este gresit!\n");
      end
      teste=READ_NR;
    end //inchidem primul if
  endfunction: check_result

    function void write_to_file;
    int fd;

    fd = $fopen("../reports/regression_status.txt", "a");
    if(trecut == teste) begin
      $fdisplay(fd, "%s : passed", TEST);
    end
    else begin
      $fdisplay(fd, "%s : failed", TEST);
    end

    $fclose(fd);

  endfunction: write_to_file
  
endmodule: instr_register_test
