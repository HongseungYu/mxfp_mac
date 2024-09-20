module level1_adder_baseline (


  input wire [2:0] mode,
  
  input wire sign_1,
  input wire sign_2,

  input wire [4:0] sum_exp_1, //elem1_adjusted_exp + elem2_adjusted_exp
  input wire [4:0] sum_exp_2, //elem1_adjusted_exp + elem2_adjusted_exp

  input wire [13:0] raw_product_1,
  input wire [13:0] raw_product_2,

  output wire [36:0] aligned_product_1,
  output wire [36:0] aligned_product_2
  );

  reg signed [4:0] shift_bias;

  reg [4:0] shift_distance_1;
  reg [4:0] shift_distance_2;

  always @(*) begin
    case(mode)
      3'd0 : shift_bias = -2; // e4m3  
      3'd1 : shift_bias = 10; // e2m3 -2+10
      3'd2 : shift_bias = 8; // e3m2
      3'd3 : shift_bias = 14; // e2m1
      default : shift_bias = 0; // int8 (always shift 6 bits, bias is 0)
    endcase

    shift_distance_1 = $signed({1'b0, sum_exp_1}) + shift_bias;
    shift_distance_2 = $signed({1'b0, sum_exp_2}) + shift_bias;
  end


  // 2's complement conversion
  reg signed [14:0] adjusted_product_1;
  reg signed [14:0] adjusted_product_2;

  always @(*) begin
    if(sign_1) begin
      adjusted_product_1 = -raw_product_1;
    end else begin
      adjusted_product_1 = raw_product_1;
    end
  end

  always @(*) begin
    if(sign_2) begin
      adjusted_product_2 = -raw_product_2;
    end else begin
      adjusted_product_2 = raw_product_2;
    end
  end

  // 37bit aligner
    
  // MXFP8(e4m3): 1 + 1 = 2 -> 2^(-6) + 2^(-6) = 2^(-12)
  // 18.17 16 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0
  //                                _ _._ _ _ _ _ _  
  // if sum_exp = 2, left shift 0 bits
  // if sum_exp = 3, left shift 1 bits 
  // ...

  // MXFP6(e2m3): 

  assign aligned_product_1 = adjusted_product_1 << shift_distance_1;
  assign aligned_product_2 = adjusted_product_2 << shift_distance_2;

endmodule








