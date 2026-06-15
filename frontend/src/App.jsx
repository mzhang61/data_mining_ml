import { useState } from "react";
import axios from "axios";

const featureGroups = [
  {
    title: "Customer Information",
    features: [
      {
        name: "city",
        label: "City",
        description: "Encoded city ID of the user."
      },
      {
        name: "bd",
        label: "Age",
        description: "User age. Use 0 if age is unknown."
      },
      {
        name: "registered_via",
        label: "Registered Via",
        description: "Registration method ID used by the customer."
      }
    ]
  },
  {
    title: "Transaction Behavior",
    features: [
      {
        name: "transaction_count",
        label: "Transaction Count",
        description: "Total number of subscription transactions made by the user."
      },
      {
        name: "avg_payment_plan_days",
        label: "Average Payment Plan Days",
        description: "Average number of days in the user's subscription plans."
      },
      {
        name: "avg_plan_list_price",
        label: "Average Plan List Price",
        description: "Average listed price of the user's subscription plans."
      },
      {
        name: "avg_actual_amount_paid",
        label: "Average Actual Amount Paid",
        description: "Average amount the user actually paid."
      },
      {
        name: "auto_renew_count",
        label: "Auto Renew Count",
        description: "Number of transactions with auto-renew enabled."
      },
      {
        name: "cancel_count",
        label: "Cancel Count",
        description: "Number of subscription cancellation records."
      }
    ]
  },
  {
    title: "Listening Behavior",
    features: [
      {
        name: "log_days",
        label: "Log Days",
        description: "Number of days with recorded listening activity."
      },
      {
        name: "avg_num_25",
        label: "Average 25% Plays",
        description: "Average number of songs played less than 25% per day."
      },
      {
        name: "avg_num_50",
        label: "Average 50% Plays",
        description: "Average number of songs played between 25% and 50% per day."
      },
      {
        name: "avg_num_75",
        label: "Average 75% Plays",
        description: "Average number of songs played between 50% and 75% per day."
      },
      {
        name: "avg_num_985",
        label: "Average 98.5% Plays",
        description: "Average number of songs played almost completely per day."
      },
      {
        name: "avg_num_100",
        label: "Average Completed Plays",
        description: "Average number of songs played completely per day."
      },
      {
        name: "avg_num_unq",
        label: "Average Unique Songs",
        description: "Average number of unique songs played per day."
      },
      {
        name: "avg_total_secs",
        label: "Average Listening Seconds",
        description: "Average listening time in seconds per active day."
      },
      {
        name: "sum_total_secs",
        label: "Total Listening Seconds",
        description: "Total listening time in seconds across all recorded days."
      }
    ]
  }
];

function App() {
  const [result, setResult] = useState(null);
  const [loading, setLoading] = useState(false);

  const [formData, setFormData] = useState({
    city: 1,
    bd: 30,
    registered_via: 7,
    transaction_count: 20,
    avg_payment_plan_days: 30,
    avg_plan_list_price: 99,
    avg_actual_amount_paid: 99,
    auto_renew_count: 20,
    cancel_count: 0,
    log_days: 200,
    avg_num_25: 2,
    avg_num_50: 0.5,
    avg_num_75: 0.3,
    avg_num_985: 0.2,
    avg_num_100: 20,
    avg_num_unq: 18,
    avg_total_secs: 4000,
    sum_total_secs: 800000
  });

  const handleChange = (name, value) => {
    setFormData({
      ...formData,
      [name]: Number(value)
    });
  };

  const handlePredict = async () => {
    try {
      setLoading(true);
      setResult(null);

      const response = await axios.post(
        "http://127.0.0.1:8000/predict",
        formData
      );

      setResult(response.data);
    } catch (error) {
      console.error(error);
      alert("Prediction failed. Check backend server.");
    } finally {
      setLoading(false);
    }
  };

  const riskLevel = result
    ? result.churn_probability >= 0.7
      ? "High Risk"
      : result.churn_probability >= 0.3
      ? "Medium Risk"
      : "Low Risk"
    : "";

  return (
    <div style={styles.page}>
      <div style={styles.container}>
        <h1 style={styles.title}>Customer Churn Predictor</h1>
        <p style={styles.subtitle}>
          Enter customer transaction and listening behavior to predict churn risk.
        </p>

        {featureGroups.map((group) => (
          <div key={group.title} style={styles.card}>
            <h2 style={styles.groupTitle}>{group.title}</h2>

            <div style={styles.grid}>
              {group.features.map((feature) => (
                <div key={feature.name} style={styles.field}>
                  <label style={styles.label}>{feature.label}</label>
                  <input
                    type="number"
                    value={formData[feature.name]}
                    onChange={(e) =>
                      handleChange(feature.name, e.target.value)
                    }
                    style={styles.input}
                  />
                  <p style={styles.description}>
                    {feature.description}
                  </p>
                </div>
              ))}
            </div>
          </div>
        ))}

        <button
          onClick={handlePredict}
          disabled={loading}
          style={styles.button}
        >
          {loading ? "Predicting..." : "Predict Churn"}
        </button>

        {result && (
          <div style={styles.resultCard}>
            <h2>Prediction Result</h2>

            <p>
              <strong>Churn Probability:</strong>{" "}
              {(result.churn_probability * 100).toFixed(2)}%
            </p>

            <p>
              <strong>Prediction:</strong> {result.label}
            </p>

            <p>
              <strong>Threshold:</strong> {result.threshold}
            </p>

            <p>
              <strong>Risk Level:</strong> {riskLevel}
            </p>
          </div>
        )}
      </div>
    </div>
  );
}

const styles = {
  page: {
    minHeight: "100vh",
    background: "#f4f6f8",
    padding: "40px"
  },
  container: {
    maxWidth: "1100px",
    margin: "0 auto",
    background: "white",
    padding: "30px",
    borderRadius: "12px",
    boxShadow: "0 4px 16px rgba(0,0,0,0.08)"
  },
  title: {
    marginBottom: "8px"
  },
  subtitle: {
    color: "#666",
    marginBottom: "30px"
  },
  card: {
    marginBottom: "28px",
    padding: "20px",
    border: "1px solid #e0e0e0",
    borderRadius: "10px"
  },
  groupTitle: {
    marginBottom: "18px",
    fontSize: "20px"
  },
  grid: {
    display: "grid",
    gridTemplateColumns: "repeat(auto-fit, minmax(260px, 1fr))",
    gap: "18px"
  },
  field: {
    display: "flex",
    flexDirection: "column"
  },
  label: {
    fontWeight: "600",
    marginBottom: "6px"
  },
  input: {
    padding: "10px",
    borderRadius: "6px",
    border: "1px solid #ccc",
    fontSize: "15px"
  },
  description: {
    fontSize: "13px",
    color: "#666",
    marginTop: "6px",
    lineHeight: "1.4"
  },
  button: {
    width: "100%",
    padding: "14px",
    background: "#2563eb",
    color: "white",
    border: "none",
    borderRadius: "8px",
    fontSize: "17px",
    fontWeight: "600",
    cursor: "pointer"
  },
  resultCard: {
    marginTop: "28px",
    padding: "22px",
    borderRadius: "10px",
    background: "#f1f5f9",
    border: "1px solid #dbeafe"
  }
};

export default App;