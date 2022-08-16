from abc import ABC, abstractmethod
import math 

class Astro(ABC): 
    
    def __init__(self, initial_price, period_price_decrease): 
        self.initial_price = initial_price
        self.period_price_decrease = period_price_decrease

    def get_price(self, time_since_start, sold):
        t1 = self.initial_price
        t2 = 1 - self.period_price_decrease
        t3 = time_since_start - self.get_target_day_for_next_sale(sold)

        return t1 * math.pow(t2, t3)

    @abstractmethod
    def get_target_day_for_next_sale(self, sold):
        pass

class LinearASTRO(Astro):
    
    def __init__(self, initial_price, period_price_decrease, per_day): 
        super().__init__(initial_price, period_price_decrease)
        self.per_day = per_day
        
    def get_target_day_for_next_sale(self, sold):
        return sold / self.per_day