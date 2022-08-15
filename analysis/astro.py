from abc import ABC, abstractmethod
import math 

class Astro(ABC): 
    
    def __init__(self, initial_price, period_price_decrease): 
        self.initial_price = initial_price
        self.period_price_decrease = period_price_decrease

    def get_price(self, time_since_start, sold):
        t1 = self.initial_price
        t2 = 1 - period_price_decrease
        t3 = get_target_day_for_next_sale(sold) - time_since_start

        return t1 * math.pow(t2, t3)

    @abstractmethod
    def get_target_day_for_next_sale(self, sold):
        pass

class Linear(DiscreteGDA):
    
    def __init__(self, initial_price, decay_constant, scale_factor): 
        self.initial_price = initial_price
        self.decay_constant = decay_constant
        self.scale_factor = scale_factor
        
    def get_cumulative_purchase_price(self, num_total_purchases, time_since_start, quantity):
        t1 = self.initial_price * math.pow(self.scale_factor, num_total_purchases)
        t2 = math.pow(self.scale_factor, quantity) - 1
        t3 = math.exp(self.decay_constant * time_since_start)
        t4 = self.scale_factor - 1
        return t1 * t2 / (t3 * t4)
    
class ExponentialContinuousGDA(ContinuousGDA): 
    
    def __init__(self, initial_price, decay_constant, emission_rate): 
        self.initial_price = initial_price
        self.decay_constant = decay_constant
        self.emission_rate = emission_rate
        
    def get_cumulative_purchase_price(self, age_last_available_auction, quantity):
        t1 = self.initial_price / self.decay_constant
        t2 = math.exp(self.decay_constant * quantity / self.emission_rate) - 1 
        t3 = math.exp(self.decay_constant * age_last_available_auction)
        return t1 * t2 / t3