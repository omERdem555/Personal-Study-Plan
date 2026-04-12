import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_absolute_error
import joblib

df = pd.read_csv("data.csv")

df = pd.get_dummies(df, columns=["subject"])

X = df.drop("predicted_net", axis=1)
y = df["predicted_net"]

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

model = RandomForestRegressor(
    n_estimators=200,
    max_depth=12,
    random_state=42
)

model.fit(X_train, y_train)

pred = model.predict(X_test)

print("MAE:", mean_absolute_error(y_test, pred))

# 🔥 kritik: feature set'i kaydet
joblib.dump(model, "model.pkl")
joblib.dump(X.columns.tolist(), "features.pkl")

print("Model + feature set kaydedildi")