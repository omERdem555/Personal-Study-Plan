import pandas as pd
import random

data = []

for _ in range(1000):
    current_score = random.randint(30, 80)
    target_score = random.randint(current_score + 5, 100)

    study_time = random.randint(30, 180)  # dakika
    efficiency = random.randint(1, 5)
    topic_error_rate = round(random.uniform(0.1, 0.6), 2)

    # improvement hesapla
    improvement = (study_time * 0.1) * (efficiency / 5) * (1 - topic_error_rate)

    predicted_score = current_score + improvement

    if predicted_score > target_score:
        predicted_score = target_score

    data.append([
        current_score,
        target_score,
        study_time,
        efficiency,
        topic_error_rate,
        predicted_score
    ])

df = pd.DataFrame(data, columns=[
    "current_score",
    "target_score",
    "study_time",
    "efficiency",
    "topic_error_rate",
    "predicted_score"
])

df.to_csv("data.csv", index=False)

print("Veri seti oluşturuldu!")