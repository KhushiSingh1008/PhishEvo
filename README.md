# PhishEvo 🛡️
**Bio-Inspired Phishing URL Evolution Tracker**

PhishEvo is a specialized intelligence tool built for tracking, analyzing, and predicting the evolution of phishing URLs, drawing inspiration from biological genome sequencing. By mimicking DNA mutation tracking algorithms (like Smith-Waterman alignment and Markov chains) and augmenting them with Google's Vertex AI, PhishEvo identifies campaign lineages and predicts future threat variants before they launch.

## 🚀 Tech Stack (Google Cloud Migration)
This project has been fully migrated to a robust Google technology stack:
* **Frontend Mobile App:** Flutter (Material 3)
* **API Backend:** Python (FastAPI) hosted on **Google Cloud Run**
* **Database:** **Firebase Firestore**
* **Authentication:** **Firebase Auth** (Google Sign-In)
* **Threat Intelligence & Reporting:** **Google Vertex AI** (Gemini 1.5 Pro)
* **Geospatial Mapping:** **Google Maps Flutter SDK**

## 📂 Project Structure
`	ext
phishevo/
├── backend/               # Python API & Genomic Algorithms
│   ├── main.py            # FastAPI endpoints
│   ├── firestore_db.py    # Firestore integration
│   ├── vertex_reporter.py # Gemini 1.5 Pro reporting
│   ├── encoder.py         # URL genome encoding logic
│   ├── aligner.py         # Smith-Waterman alignment
│   ├── predictor.py       # Markov chain predictions
│   └── Dockerfile         # Cloud Run container configuration
│
└── flutter_app/           # Flutter Mobile App
    ├── lib/               
    │   ├── main.dart      # Entry point & App Shell
    │   ├── screens/       # Analyze, Lineage, Maps, Reports
    │   ├── services/      # REST API & Firebase bindings
    │   ├── models/        # Data serialization
    │   └── widgets/       # UI Components (e.g., Genome chips)
    └── pubspec.yaml       # Dart dependencies
`

## 🛠️ Setup Instructions

### 1. Backend (Cloud Run / Local)
1. Navigate to the backend directory:
   `ash
   cd backend
   `
2. Create a virtual environment and install dependencies:
   `ash
   python -m venv venv
   .\venv\Scripts\activate  # On Windows
   pip install -r requirements.txt
   `
3. Set your Google Application Credentials for Vertex AI & Firestore:
   `ash
   set GOOGLE_APPLICATION_CREDENTIALS="path/to/your/serviceAccountKey.json"
   `
4. Run the local development server:
   `ash
   uvicorn main:app --host 0.0.0.0 --port 8080 --reload
   `

### 2. Frontend (Flutter)
1. Navigate to the app directory:
   `ash
   cd flutter_app
   `
2. Install dependencies:
   `ash
   flutter pub get
   `
3. Configure Firebase:
   `ash
   dart pub global run flutterfire_cli:flutterfire configure --project=phishevo
   `
4. Run the app:
   `ash
   flutter run
   `

## 🧬 How it Works
1. **Analyze:** A suspicious URL is converted into an abstract "Genome String" representing structural heuristics (brand spoofing, typosquatting).
2. **Align:** The sequence is aligned against known campaign families using bioinformatics algorithms. 
3. **Report:** Vertex AI parses the sequence mutations to generate a human-readable threat intelligence report.
4. **Map:** Real-world origins of phishing operations are visualized on an interactive Google Map framework.
5. **Predict:** PhishEvo predicts the next logical mutations a malicious actor will register natively to update blocklists pre-emptively.
