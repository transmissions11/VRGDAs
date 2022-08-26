from abc import ABC, abstractmethod
import math


class VRGDA(ABC):
    def __init__(self, target_price, price_decrease_percent):
        self.target_price = target_price
        self.price_decrease_percent = price_decrease_percent

    @abstractmethod
    def get_price(self, time_since_start, num_sold):
        pass


class LinearVRGDA(VRGDA): 
    def __init__(self, target_price, price_decrease_percent, per_time_unit): 
        super().__init__(target_price, price_decrease_percent)
        self.per_unit_time = per_time_unit

    def get_price(self, time_since_start, num_sold):
        num_periods = time_since_start - num_sold / self.per_unit_time
        decay_constant = 1 - self.price_decrease_percent
        scale_factor = math.pow(decay_constant, num_periods)

        return  self.target_price * scale_factor