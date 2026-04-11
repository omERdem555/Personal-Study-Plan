import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_absolute_error
import joblib
import matplotlib.pyplot as plt

# veriyi yükle
df = pd.read_csv("data.csv")

# input ve output ayır
X = df.drop("improvement", axis=1)
y = df["improvement"]   

# train / test split
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# model oluştur
model = RandomForestRegressor(
    n_estimators=100,
    max_depth=10,
    random_state=42
)

# modeli eğit
model.fit(X_train, y_train)

# tahmin yap
y_pred = model.predict(X_test)

# hata hesapla
mae = mean_absolute_error(y_test, y_pred)
print(f"MAE (ortalama hata - improvement): {mae:.2f}")

# 🔴 MODELİ KAYDET
joblib.dump(model, "model.pkl")
print("Model kaydedildi: model.pkl")

# 🔴 FEATURE IMPORTANCE
importances = model.feature_importances_
features = X.columns

plt.barh(features, importances)
plt.xlabel("Önem")
plt.title("Feature Importance")
plt.show()