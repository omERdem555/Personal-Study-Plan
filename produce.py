import pandas as pd
import random

data = []

for _ in range(5000):
    current_score = random.randint(30, 80)
    target_score = random.randint(current_score + 5, 100)

    study_time = random.randint(30, 180)
    efficiency = random.randint(1, 5)
    topic_error_rate = round(random.uniform(0.1, 0.6), 2)

    # Daha gerçekçi improvement
    base_gain = study_time * random.uniform(0.05, 0.15)
    efficiency_effect = efficiency * random.uniform(0.5, 1.5)
    error_penalty = (1 - topic_error_rate) * random.uniform(0.5, 1.2)

    improvement = base_gain * efficiency_effect * error_penalty

    # noise ekle (çok önemli)
    noise = random.uniform(-5, 5)

    predicted_score = current_score + improvement + noise

    # sınırları kontrol et
    predicted_score = max(0, min(100, predicted_score))

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