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
  mxfp8_mac uut (
    .clk_i(clk_i),
    .resetn_i(resetn_i),
    .mode(mode_binary),
    .shared_exp1(shared_exp1),
    .element1_concat(element1_concat),
    .shared_exp2(shared_exp2),
    .element2_concat(element2_concat),
    .fp_in(fp_in),
    .sum_of_products(sum_of_products),
    .fp_out(fp_out)
  );

  integer file, r;
  reg [31:0] expected_fp_out;

  integer iter;

  // Clock generation
  always #5 clk_i = ~clk_i;

  initial begin
    // Initialize Inputs
    clk_i = 0;
    resetn_i = 1;
    file = $fopen("mxfp8_test_vectors.txt", "r");
    if (file == 0) begin
      $display("Error: Could not open file.");
      $finish;
    end

    // Reset the module
    resetn_i = 0;
    #10;
    resetn_i = 1;
    iter = 0;

    // Read the values from the file and apply the test inputs
    while (!$feof(file)) begin
      $display("Iteration %d", iter);
      iter = iter + 1;
      r = $fscanf(file, "%b %b %b %b %b %h %h\n", mode_binary, shared_exp1, element1_concat, shared_exp2, element2_concat, fp_in, expected_fp_out);
      if (r != 7) begin
        $display("Error: Incorrect number of values read.");
        $finish;
      end

      // Display the values read from the file
      $display("mode_binary = %b", mode_binary);
      $display("shared_exp1 = %b", shared_exp1);
      $display("shared_exp2 = %b", shared_exp2);
      $display("element1_concat = %b", element1_concat);
      $display("element2_concat = %b", element2_concat);
      $display("fp_in = %h", fp_in);
      $display("expected_fp_out = %h", expected_fp_out);

      // Apply test inputs
      #10; // Wait for the UUT to process the inputs

      // Compare the result with the expected value
      if (fp_out !== expected_fp_out) begin
        $display("Mismatch: expected_fp_out = %h, fp_out = %h", expected_fp_out, fp_out);
        $stop;
      end

      $display("\n");

      // Wait some time before next input set
      #10;
    end

    // Close the file
    $fclose(file);

    // Finish the simulation
    $finish;
  end

endmodule
