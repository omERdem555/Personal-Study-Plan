import random
import joblib

model = joblib.load("model.pkl")

def predict_improvement(current_score, study_time, efficiency, error_rate):
    return model.predict([[current_score, 0, study_time, efficiency, error_rate]])[0]


def generate_plan(current_score, target_score):
    best_plan = None
    best_gap = float("inf")

    # 1000 farklı plan deniyoruz
    for _ in range(1000):

        math_time = random.randint(20, 120)
        physics_time = random.randint(20, 120)
        chem_time = random.randint(20, 120)

        total_time = math_time + physics_time + chem_time

        efficiency = random.randint(1, 5)
        error_rate = random.uniform(0.1, 0.6)

        improvement = predict_improvement(
            current_score,
            total_time,
            efficiency,
            error_rate
        )

        predicted_score = current_score + improvement

        gap = abs(target_score - predicted_score)

        if gap < best_gap:
            best_gap = gap
            best_plan = {
                "math": math_time,
                "physics": physics_time,
                "chem": chem_time,
                "predicted_score": predicted_score
            }

    return best_plan


# test
current = 60
target = 80

plan = generate_plan(current, target)

print(plan)