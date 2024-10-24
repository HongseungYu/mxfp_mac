module tb_mxmac;

  // Inputs
  reg clk_i;
  reg resetn_i;
  reg [7:0] shared_exp1;
  reg [255:0] element1_concat;  // 8 elements, each 32 bits
  reg [7:0] shared_exp2;
  reg [255:0] element2_concat;  // 8 elements, each 32 bits
  reg [31:0] fp_in; // exp: 8, mantissa: 23
  reg [2:0] mode_binary;

  // Output
  wire signed [41:0] sum_of_products;
  wire [31:0] fp_out;

  // Instantiate the Unit Under Test (UUT)
  mxmac_pipelined uut (
    .clk_i(clk_i),
    .resetn_i(resetn_i),
    .mode(mode_binary),
    .shared_exp1(shared_exp1),
    .element1_concat(element1_concat),
    .shared_exp2(shared_exp2),
    .element2_concat(element2_concat),
    .fp_in(fp_in),
    .sum_of_products_reg7(sum_of_products),
    .fp_out(fp_out)
  );

  integer file, r;
  reg [31:0] expected_fp_out;

  integer iter;
  integer i;

  // Clock generation
  always #5 clk_i = ~clk_i;

  // Queue for expected outputs
  reg [31:0] expected_output_queue [0:15];  // Queue to hold expected outputs for comparison (depth of 16)
  reg [5:0] queue_head;   // Head of the queue
  reg [5:0] queue_tail;   // Tail of the queue
  reg queue_full;         // Flag to indicate if the queue is full
  reg queue_empty;        // Flag to indicate if the queue is empty

  initial begin
    // Initialize Inputs
    $dumpfile("test.vcd");
    $dumpvars;

    clk_i = 0;
    resetn_i = 1;
    file = $fopen("mxfp_test_vectors.txt", "r");
    if (file == 0) begin
      $display("Error: Could not open file.");
      $finish;
    end

    // Reset the module
    resetn_i = 0;
    #10;
    resetn_i = 1;
    iter = 0;

    // Initialize queue
    queue_head = 0;
    queue_tail = 0;
    queue_full = 0;
    queue_empty = 1;

    // Read the values from the file and apply the test inputs
    while (!$feof(file)) begin
      // Display the iteration
      $display("Iteration %d", iter);
      iter = iter + 1;

      // Read inputs and expected output from the file
      r = $fscanf(file, "%b %b %b %b %b %h %h\n", mode_binary, shared_exp1, element1_concat, shared_exp2, element2_concat, fp_in, expected_fp_out);
      if (r != 7) begin
        $display("Error: Incorrect number of values read.");
        $finish;
      end

      // Apply test inputs
      $display("Applying inputs at cycle %0d", iter);
      $display("mode_binary = %b", mode_binary);
      $display("shared_exp1 = %b", shared_exp1);
      $display("shared_exp2 = %b", shared_exp2);
      $display("element1_concat = %b", element1_concat);
      $display("element2_concat = %b", element2_concat);
      $display("fp_in = %h", fp_in);

      // Queue the expected output
      if (!queue_full) begin
        expected_output_queue[queue_tail] = expected_fp_out;
        queue_tail = (queue_tail + 1) % 16;  // Update the tail pointer
        if (queue_tail == queue_head) queue_full = 1;  // Check if queue is full
        queue_empty = 0;
      end else begin
        $display("Error: Queue is full.");
        $finish;
      end

      // Wait for 1 cycle (10 time units)
      #10;

      // Compare output 6 cycles after the input was applied
      if (!queue_empty && iter >= 8) begin
        $display("Checking output at cycle %0d", iter - 8);
        if (fp_out !== expected_output_queue[queue_head]) begin
          $display("Mismatch at cycle %0d: expected_fp_out = %h, fp_out = %h", iter - 8, expected_output_queue[queue_head], fp_out);
          $stop;
        end
        queue_head = (queue_head + 1) % 16;  // Update the head pointer
        if (queue_head == queue_tail) queue_empty = 1;  // Check if queue is empty
        queue_full = 0;
      end

      // Wait some time before next input set
    end

    // Close the file
    $fclose(file);

    // Finish the simulation
    $finish;
  end

endmodule
