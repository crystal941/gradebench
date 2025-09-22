# GradeBench

[![Live Demo](https://img.shields.io/badge/demo-online-green)](https://gradebench-app.azurewebsites.net)

**GradeBench** is a cloud-based analytics tool designed to help educators and students interact with assignment datasets.  
It enables users to upload student and marks data, validate inputs, and explore insights through an interactive web interface.

---

## 🚀 Live Application
You can try the deployed app here:  
👉 [https://gradebench-app.azurewebsites.net](https://gradebench-app.azurewebsites.net)

---

## 📂 Sample Data
To test the application, use the provided CSV files in the `data/` folder:

- [`sample-students.csv`](data/sample-students.csv)  
- [`sample-marks.csv`](data/sample-marks.csv)  

Simply upload these files through the web interface to get started.

---

## ✨ Features
- Upload student and marks data (CSV format).  
- Automated validation of dataset consistency and formatting.  
- Interactive dashboards to explore student performance and anomalies.  
- Deployed on **Azure Web Apps** in a containerized environment.  

---

## 🛠️ Tech Stack
- [R Shiny](https://shiny.rstudio.com/) – Interactive web framework for R.  
- [Docker](https://www.docker.com/) – Containerized deployment.  
- [Azure Web Apps](https://azure.microsoft.com/en-us/products/app-service/web/) – Cloud hosting.  
- [Databricks (Prototype)](https://www.databricks.com/) – SQL workflows for extensible data pipelines (future scalability).  
- [Azure Bicep](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview) – Infrastructure as Code for deployment consistency.  

---

## ▶️ Getting Started (Local Development)

1. Clone this repository:
   ```bash
   git clone https://github.com/crystal941/gradebench.git
   cd gradebench
   ```

2. Install required R packages (see `DESCRIPTION` or your package list).

3. Run the app locally:
   ```r
   shiny::runApp("app")
   ```

4. Access the app at `http://127.0.0.1:3838/`.

---

## 📌 Roadmap
- Extend Databricks workflows from prototype into production-ready ETL pipelines.  
- Add support for larger datasets and more complex analytics.  
- Integrate CI/CD pipelines for automated testing and deployment.  

---

## 📄 License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

👩‍💻 Maintained by **crystal941**  
