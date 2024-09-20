import random
import struct
import os

from decimal import Decimal, getcontext

# Define the desired directories and file paths
#directory1 = "C:\\Users\\user\\vivado_projects\\mxfp8_mac\\mxfp8_mac.sim\\sim_1\\behav\\xsim"
#C:\Users\user\Desktop\YHS_SNU\graduation_project\MXFP8_E4M3_mac\utils
directory2 = "C:\\Users\\user\\Desktop\\YHS_SNU\\graduation_project\\MXFP_MAC\\utils"

#file_path1 = os.path.join(directory1, "mxfp8_test_vectors.txt")
file_path2 = os.path.join(directory2, "mxfp_test_vectors.txt")

group_size = 32

###### CHANGE THIS PART ######
num_test = [20, 20, 20, 20, 20]  # e4m3, e2m3, e3m2, e2m1, int8
##############################



# Function to generate vector with the same exponent
def generate_vector_with_same_exponent(mode):
    shared_exponent = random.randint(80, 180)  # 공유하는 지수 값
    
    vector = []
    
    if mode == 0:  # e4m3
        elem_sign = [random.choice([0, 1]) for _ in range(group_size)]
        elem_exp = [random.randint(0, 15) for _ in range(group_size)]  # 4비트
        elem_man = [random.randint(0, 7) for _ in range(group_size)]  # 3비트
        vector = [(elem_sign[i], elem_exp[i], elem_man[i]) for i in range(group_size)]
        
    elif mode == 1:  # e2m3
        elem_sign = [random.choice([0, 1]) for _ in range(group_size)]
        elem_exp = [random.randint(0, 3) for _ in range(group_size)]  # 2비트
        elem_man = [random.randint(0, 7) for _ in range(group_size)]  # 3비트
        vector = [(elem_sign[i], elem_exp[i], elem_man[i]) for i in range(group_size)]
        
    elif mode == 2:  # e3m2
        elem_sign = [random.choice([0, 1]) for _ in range(group_size)]
        elem_exp = [random.randint(0, 7) for _ in range(group_size)]  # 3비트
        elem_man = [random.randint(0, 3) for _ in range(group_size)]  # 2비트
        vector = [(elem_sign[i], elem_exp[i], elem_man[i]) for i in range(group_size)]
        
    elif mode == 3:  # e2m1
        elem_sign = [random.choice([0, 1]) for _ in range(group_size)]
        elem_exp = [random.randint(0, 3) for _ in range(group_size)]  # 2비트
        elem_man = [random.randint(0, 1) for _ in range(group_size)]  # 1비트
        vector = [(elem_sign[i], elem_exp[i], elem_man[i]) for i in range(group_size)]
        
    elif mode == 4:  # int8 (8비트 2's complement)
        vector = [random.randint(-127, 127) for _ in range(group_size)]  # -127 ~ 127 사이의 값 생성
    
    return vector, shared_exponent


# Function to convert elements of the vector to decimal
def to_decimal_updated(sign, exponent, mantissa, mode):
    if mode == 0:  # e4m3
        bias = 7
        mantissa_divisor = 8  # 2^3
    elif mode == 1:  # e2m3
        bias = 1
        mantissa_divisor = 8  # 2^3
    elif mode == 2:  # e3m2
        bias = 3
        mantissa_divisor = 4  # 2^2
    elif mode == 3:  # e2m1
        bias = 1
        mantissa_divisor = 2  # 2^1
    else:
        raise ValueError("Invalid mode")

    if exponent == 0 and mantissa == 0:
        return 0
    elif exponent == 0 and mantissa != 0:
        exponent_value = 1 - bias
        mantissa_value = mantissa / mantissa_divisor
    else:
        exponent_value = exponent - bias
        mantissa_value = 1 + mantissa / mantissa_divisor  # Normalized numbers

    if sign == 1:
        return - (2 ** exponent_value) * mantissa_value
    else:
        return (2 ** exponent_value) * mantissa_value



fp_acc_reconverted = 1.0

# Generate and save test vectors
with open(file_path2, "w") as f2:
    for mode in range(5):
        mode_binary = f"{mode:03b}" 
        print("Current mode:", mode_binary)
        for i in range(num_test[mode]):  # Generate 10 test vectors and inner product and accumulate them
            print("Accumulation step:", i + 1)

            getcontext().prec = 200  # Set the precision to 100 decimal places
            # 예시로 fp_in을 Decimal로 변환
            fp_in = random.uniform(-1, 1)

            fp_in_int = struct.unpack('>I', struct.pack('>f', fp_in))[0]
            fp_in_hex = f"{fp_in_int:08X}"

            fp_in = struct.unpack('>f', struct.pack('>I', fp_in_int))[0]


            print("fp_in_hex:", fp_in_hex)


            vector1, shared_exp1 = generate_vector_with_same_exponent(mode)
            vector2, shared_exp2 = generate_vector_with_same_exponent(mode)

            #print vector and shared exponent
            print("vector1:", vector1)
            print("vector2:", vector2)


            if mode != 4:
                decimal_vector1 = [to_decimal_updated(*num, mode=mode) for num in vector1]
                decimal_vector2 = [to_decimal_updated(*num, mode=mode) for num in vector2]
            else:
                decimal_vector1 = [num / 64 for num in vector1]
                decimal_vector2 = [num / 64 for num in vector2]

            print("decimal_vector1:", decimal_vector1)
            print("decimal_vector2:", decimal_vector2)

            print("shared_exp1_value:", shared_exp1 - 127)
            print("shared_exp2_value:", shared_exp2 - 127)

            vector1_shared_exp = f"{shared_exp1:08b}"
            vector2_shared_exp = f"{shared_exp2:08b}"

            if mode != 4:
                if mode == 0:  # e4m3
                    vector1_elements = "_".join([f"{num[0]}{num[1]:04b}{num[2]:03b}" for num in vector1])
                    vector2_elements = "_".join([f"{num[0]}{num[1]:04b}{num[2]:03b}" for num in vector2])
                elif mode == 1:  # e2m3
                    vector1_elements = "_".join([f"00{num[0]}{num[1]:02b}{num[2]:03b}" for num in vector1])
                    vector2_elements = "_".join([f"00{num[0]}{num[1]:02b}{num[2]:03b}" for num in vector2])
                elif mode == 2:  # e3m2
                    vector1_elements = "_".join([f"00{num[0]}{num[1]:03b}{num[2]:02b}" for num in vector1])
                    vector2_elements = "_".join([f"00{num[0]}{num[1]:03b}{num[2]:02b}" for num in vector2])
                elif mode == 3:  # e2m1
                    vector1_elements = "_".join([f"0000{num[0]}{num[1]:02b}{num[2]:01b}" for num in vector1])
                    vector2_elements = "_".join([f"0000{num[0]}{num[1]:02b}{num[2]:01b}" for num in vector2])
            else:
                # int8의 경우 8비트 2's complement로 변환
                vector1_elements = "_".join([f"{num:08b}" if num >= 0 else f"{num & 0xFF:08b}" for num in vector1])
                vector2_elements = "_".join([f"{num:08b}" if num >= 0 else f"{num & 0xFF:08b}" for num in vector2])


            dot_product_temp = Decimal(sum(x * y for x, y in zip(decimal_vector1, decimal_vector2)))
            print("dot_product_temp:", dot_product_temp)
            dot_product = (2 ** (Decimal(shared_exp1) - 127)) * (2 ** (Decimal(shared_exp2) - 127)) * dot_product_temp


            # 나머지 연산에서도 Decimal을 사용
            fp_acc = Decimal(dot_product) + Decimal(fp_in)

            # 원하는 정밀도로 변환 후 부동소수점으로 다시 변환
            fp_acc = float(fp_acc)
            
            fp_acc_int = struct.unpack('>I', struct.pack('>f', fp_acc))[0]
            fp_acc_reconverted = struct.unpack('>f', struct.pack('>I', fp_acc_int))[0]

            fp_acc_hex = f"{fp_acc_int:08X}"


            print("dot_product:", dot_product)
            print("fp_acc_hex:", fp_acc_hex, "\n")

            #f1.write(f"{mode_binary} {vector1_shared_exp} {vector1_elements} {vector2_shared_exp} {vector2_elements} {fp_in_hex} {fp_acc_hex}\n")
            f2.write(f"{mode_binary} {vector1_shared_exp} {vector1_elements} {vector2_shared_exp} {vector2_elements} {fp_in_hex} {fp_acc_hex}\n")
