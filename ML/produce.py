import pandas as pd
import random

data = []

subjects = [
    "math", "physics", "chemistry", "biology", "history", "geography", "literature", "philosophy",
    "economics", "psychology", "sociology", "political science", "computer science", "statistics",
    "algebra", "geometry", "calculus", "trigonometry", "linear algebra", "discrete math",
    "quantum physics", "classical mechanics", "thermodynamics", "optics", "electromagnetism",
    "organic chemistry", "inorganic chemistry", "physical chemistry", "analytical chemistry",
    "biochemistry", "molecular biology", "genetics", "ecology", "evolution", "anatomy",
    "astronomy", "astrophysics", "cosmology", "environmental science", "earth science",
    "meteorology", "oceanography", "materials science", "nanotechnology", "robotics",
    "artificial intelligence", "machine learning", "data science", "cyber security",
    "software engineering", "web development", "mobile development", "game development",
    "database systems", "networking", "operating systems", "compiler design",
    "linguistics", "foreign languages", "translation studies", "creative writing",
    "journalism", "media studies", "communication", "law", "international relations",
    "business administration", "management", "marketing", "finance", "accounting",
    "entrepreneurship", "supply chain", "human resources", "education", "pedagogy",
    "curriculum studies", "instructional design", "special education", "early childhood education",
    "music theory", "music history", "visual arts", "graphic design", "architecture",
    "urban planning", "industrial design", "fashion design", "theater", "film studies",
    "photography", "health science", "nutrition", "public health", "nursing",
    "medicine", "pharmacology", "dentistry", "veterinary science"
]

for _ in range(100000):

    subject = random.choice(subjects)

    total_questions = random.randint(10, 50)
    correct = random.randint(0, total_questions)
    wrong = total_questions - correct

    current_net = correct - (wrong * 0.25)

    study_time = random.randint(10, 240)
    difficulty = random.uniform(0.5, 1.5)

    target_net = current_net + random.uniform(5, 20)

    # gerçek dünya etkisi
    efficiency = random.uniform(0.6, 1.4)

    predicted_net = (
        current_net +
        (study_time * 0.05 * efficiency) -
        (difficulty * 2)
    )

    noise = random.uniform(-2, 2)

    predicted_net = max(0, predicted_net + noise)

    data.append([
        subject,
        total_questions,
        correct,
        wrong,
        study_time,
        difficulty,
        current_net,
        target_net,
        predicted_net
    ])

df = pd.DataFrame(data, columns=[
    "subject",
    "total_questions",
    "correct",
    "wrong",
    "study_time",
    "difficulty",
    "current_net",
    "target_net",
    "predicted_net"
])

df.to_csv("data.csv", index=False)

print("Dataset hazır")