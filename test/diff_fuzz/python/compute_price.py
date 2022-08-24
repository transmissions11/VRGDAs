from VRGDA import LinearVRGDA
from eth_abi import encode_single
import argparse

def main(args): 
    if (args.type == 'linear'): 
        calculate_linear_vrgda_price(args)
    
def calculate_linear_vrgda_price(args): 
    vrgda = LinearVRGDA(
        args.target_price / (10 ** 18), ## scale decimals 
        args.price_decrease_percent / (10 ** 18), ## scale decimals 
        args.per_time_unit / (10 ** 18), ## scale decimals 
    )
    price = vrgda.get_price(
        args.time_since_start / (10 ** 18), ##scale decimals  
        args.num_sold + 1 ## price of next item
    )
    price *= (10 ** 18) ## scale up
    encode_and_print(price)

def encode_and_print(price):
    enc = encode_single('uint256', int(price))
    ## append 0x for FFI parsing 
    print("0x" + enc.hex())

def parse_args(): 
    parser = argparse.ArgumentParser()
    parser.add_argument("type", choices=["linear"])
    parser.add_argument("--time_since_start", type=int)
    parser.add_argument("--num_sold", type=int)
    parser.add_argument("--target_price", type=int)
    parser.add_argument("--price_decrease_percent", type=int)
    parser.add_argument("--per_time_unit", type=int)
    return parser.parse_args()

if __name__ == '__main__':
    args = parse_args() 
    main(args)