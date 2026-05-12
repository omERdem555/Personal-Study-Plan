from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import joblib
import pandas as pd
import os
import random

app = FastAPI()

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))

MODEL_PATH = os.path.join(BASE_DIR, "ML", "model.pkl")
FEATURE_PATH = os.path.join(BASE_DIR, "ML", "features.pkl")

model = joblib.load(MODEL_PATH)
feature_names = joblib.load(FEATURE_PATH)


# -------------------------
# PREDICT ENDPOINT
# -------------------------
@app.post("/predict")
def predict(data: dict):

    df = pd.DataFrame([[
        data["subject"],
        data["total_questions"],
        data["correct"],
        data["wrong"],
        data["time_spent"],
        data["difficulty"],
        data["current_net"],
        data["target_net"]
    ]], columns=[
        "subject",
        "total_questions",
        "correct",
        "wrong",
        "time_spent",
        "difficulty",
        "current_net",
        "target_net"
    ])

    df = pd.get_dummies(df)

    df = df.reindex(columns=feature_names, fill_value=0)

    prediction = model.predict(df)[0]

    return {
        "predicted_net": float(prediction)
    }


# -------------------------
# PLAN ENDPOINT
# -------------------------
@app.post("/plan")
def plan(data: dict):

    best = None
    best_score = -float("inf")

    for _ in range(100):

        study_time = random.randint(10, 240)
        difficulty = random.uniform(0.5, 1.5)

        df = pd.DataFrame([[
            data["subject"],
            data["total_questions"],
            data["correct"],
            data["wrong"],
            study_time,
            difficulty,
            data["current_net"],
            data["target_net"]
        ]], columns=[
            "subject",
            "total_questions",
            "correct",
            "wrong",
            "time_spent",
            "difficulty",
            "current_net",
            "target_net"
        ])

        df = pd.get_dummies(df)
        df = df.reindex(columns=feature_names, fill_value=0)

        pred = model.predict(df)[0]

        if pred > best_score:
            best_score = pred
            best = {
                "study_time": study_time,
                "predicted_net": float(pred)
            }

    return best