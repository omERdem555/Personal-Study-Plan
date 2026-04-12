import random
import joblib
import pandas as pd
import os


BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
MODEL_PATH = os.path.join(BASE_DIR, "ML", "model.pkl")

model = joblib.load(MODEL_PATH)


def predict(subject, total_q, correct, wrong,
            study_time, difficulty, current_net, target_net):

    df = pd.DataFrame([[
        subject,
        total_q,
        correct,
        wrong,
        study_time,
        difficulty,
        current_net,
        target_net
    ]], columns=[
        "subject",
        "total_questions",
        "correct",
        "wrong",
        "study_time",
        "difficulty",
        "current_net",
        "target_net"
    ])

    df = pd.get_dummies(df)

    model_features = model.feature_names_in_
    df = df.reindex(columns=model_features, fill_value=0)

    return model.predict(df)[0]


def generate_plan(subject, total_q, correct, wrong,
                  current_net, target_net):

    best = None
    best_score = -float("inf")

    for _ in range(2000):

        study_time = random.randint(10, 240)
        difficulty = random.uniform(0.5, 1.5)

        predicted = predict(
            subject,
            total_q,
            correct,
            wrong,
            study_time,
            difficulty,
            current_net,
            target_net
        )

        if predicted > best_score:
            best_score = predicted
            best = {
                "study_time": study_time,
                "predicted_net": float(predicted),
                "gap": float(abs(target_net - predicted))
            }

    return best


if __name__ == "__main__":

    result = generate_plan(
        subject="math",
        total_q=100,
        correct=50,
        wrong=10,
        current_net=45,
        target_net=40
    )

    print(result)