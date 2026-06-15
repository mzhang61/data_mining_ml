from pydantic import BaseModel

class ChurnRequest(BaseModel):

    city: int
    bd: int
    registered_via: int

    transaction_count: int
    avg_payment_plan_days: float
    avg_plan_list_price: float
    avg_actual_amount_paid: float

    auto_renew_count: int
    cancel_count: int

    log_days: int

    avg_num_25: float
    avg_num_50: float
    avg_num_75: float
    avg_num_985: float
    avg_num_100: float
    avg_num_unq: float

    avg_total_secs: float
    sum_total_secs: float