import os
import joblib
import boto3

from dotenv import load_dotenv

load_dotenv()

BUCKET_NAME = os.getenv("S3_BUCKET")
MODEL_KEY = os.getenv("S3_MODEL_KEY")
LOCAL_MODEL_PATH = os.getenv(
    "LOCAL_MODEL_PATH",
    "models/lightgbm_churn_model.pkl"
)


def load_model():
    if os.path.exists(LOCAL_MODEL_PATH):
        print("Loading LightGBM model from local file...")
        return joblib.load(LOCAL_MODEL_PATH)

    if BUCKET_NAME and MODEL_KEY:
        print("Local model not found. Downloading model from S3...")

        s3 = boto3.client("s3")

        os.makedirs(os.path.dirname(LOCAL_MODEL_PATH), exist_ok=True)

        s3.download_file(
            BUCKET_NAME,
            MODEL_KEY,
            LOCAL_MODEL_PATH
        )

        print("Loading LightGBM model...")
        return joblib.load(LOCAL_MODEL_PATH)

    raise FileNotFoundError(
        "Model file not found locally and S3 configuration is missing. "
        "Please place lightgbm_churn_model.pkl in the models/ folder "
        "or configure S3_BUCKET and S3_MODEL_KEY in .env."
    )