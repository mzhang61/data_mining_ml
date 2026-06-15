from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import pandas as pd

from app.schemas import ChurnRequest
from app.model_loader import load_model

app = FastAPI(title="Customer Churn Prediction API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

model = load_model()

THRESHOLD = 0.30

FEATURE_COLS = [
    "city",
    "bd",
    "registered_via",
    "transaction_count",
    "avg_payment_plan_days",
    "avg_plan_list_price",
    "avg_actual_amount_paid",
    "auto_renew_count",
    "cancel_count",
    "log_days",
    "avg_num_25",
    "avg_num_50",
    "avg_num_75",
    "avg_num_985",
    "avg_num_100",
    "avg_num_unq",
    "avg_total_secs",
    "sum_total_secs",
]

@app.get("/")
def root():
    return {"message": "Customer Churn Prediction API is running"}

@app.post("/predict")
def predict_churn(request: ChurnRequest):
    input_dict = request.model_dump()

    input_df = pd.DataFrame([input_dict])
    input_df = input_df[FEATURE_COLS]

    churn_probability = model.predict_proba(input_df)[0][1]
    prediction = int(churn_probability >= THRESHOLD)

    return {
        "churn_probability": round(float(churn_probability), 4),
        "prediction": prediction,
        "label": "Churn" if prediction == 1 else "Not Churn",
        "threshold": THRESHOLD
    }