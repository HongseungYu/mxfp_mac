`timescale 1ns / 1ps

module tb_level1_adder;

    // 입력 신호
    reg sign_1;
    reg sign_2;
    reg [4:0] sum_exp_1;
    reg [4:0] sum_exp_2;
    reg [7:0] raw_product_1;
    reg [7:0] raw_product_2;

    // 출력 신호
    wire signed [37:0] sum_level1;

    // 테스트할 DUT
    level1_adder uut (
        .sign_1(sign_1),
        .sign_2(sign_2),
        .sum_exp_1(sum_exp_1),
        .sum_exp_2(sum_exp_2),
        .raw_product_1(raw_product_1),
        .raw_product_2(raw_product_2),
        .sum_level1(sum_level1)
    );

    // 테스트 벡터를 적용
    initial begin
        // 초기화
        sign_1 = 0;
        sign_2 = 0;
        sum_exp_1 = 5'd0;
        sum_exp_2 = 5'd0;
        raw_product_1 = 8'd0;
        raw_product_2 = 8'd0;

        // 시뮬레이션 동안 필요한 지연
        #10;

        // 테스트 케이스 1
        sign_1 = 1;
        sign_2 = 1;
        sum_exp_1 = 5'd14;
        sum_exp_2 = 5'd14;
        raw_product_1 = 8'd90;
        raw_product_2 = 8'd104;
        #10;

        // 추가 테스트 케이스를 여기에 추가할 수 있습니다.

        // 시뮬레이션 종료
        $finish;
    end

    // 모니터링
    initial begin
        $monitor("At time %t: sign_1 = %b, sign_2 = %b, sum_exp_1 = %d, sum_exp_2 = %d, raw_product_1 = %d, raw_product_2 = %d -> sum_level1 = %d",
                 $time, sign_1, sign_2, sum_exp_1, sum_exp_2, raw_product_1, raw_product_2, sum_level1);
    end

    // Icarus Verilog part
    initial begin
        $dumpfile("level1_adder.vcd");  // any file name possible
        $dumpvars;
    end

endmodule
