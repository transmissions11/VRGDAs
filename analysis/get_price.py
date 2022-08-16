from astro import LinearASTRO
from eth_abi import encode_single
import argparse

def main(args): 
    if (args.type == 'linear'): 
        calculate_linear(args)
    if (args.type == 'logistic'):
        # todo: implement
        #calculate_logistic(args)
        pass

def calculate_linear(args):
    linear_astro = LinearASTRO(args.initial_price / (10 ** 18), args.period_price_decrease / (10 ** 18), args.per_day)
    price = linear_astro.get_price(args.time_since_start, args.sold)
    ##convert price to wei 
    price *= (10 ** 18)
    enc = encode_single('uint256', int(price))
    ## append 0x for FFI parsing 
    print("0x" + enc.hex())
    

def parse_args(): 
    parser = argparse.ArgumentParser()
    parser.add_argument("type")
    parser.add_argument("--initial_price", type=int)
    parser.add_argument("--period_price_decrease", type=int)
    parser.add_argument("--per_day", type=int)
    parser.add_argument("--time_since_start", type=int)
    parser.add_argument("--sold", type=int)
    return parser.parse_args()

if __name__ == '__main__':
    args = parse_args() 
    main(args)