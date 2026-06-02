# Gadgeon Finance Tracker

A full-stack personal finance tracking application built with ASP.NET Core Web API (.NET 10) and Flutter. This project was developed as part of an internship at Gadgeon Smart Systems.

---

## Project Structure

---

## Backend — ASP.NET Core Web API

### Prerequisites
- .NET 10 SDK
- SQL Server or SQL Server LocalDB
- Visual Studio 2026 or VS Code with C# Dev Kit

### Tech Stack
- ASP.NET Core Web API (.NET 10)
- Entity Framework Core 10
- ASP.NET Core Identity
- JWT Authentication
- Serilog
- AutoMapper
- API Versioning (v1 and v2)
- Swagger / OpenAPI

### Setup

**1. Clone the repository**
```bash
git clone https://github.com/nitin-sai-geon/FinanceTrackerFlutter.net.git
cd FinanceTrackerFlutter.net/GadgeonFinanceTracker
```

**2. Create `appsettings.Development.json`**

Create this file in the `GadgeonFinanceTracker` folder — it is excluded from Git for security:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=(localdb)\\mssqllocaldb;Database=GadgeonFinanceTrackerDb;Trusted_Connection=True;TrustServerCertificate=True",
    "AuthConnection": "Server=(localdb)\\mssqllocaldb;Database=GadgeonFinanceTrackerAuthDb;Trusted_Connection=True;TrustServerCertificate=True"
  },
  "Jwt": {
    "Key": "your-secret-key-minimum-32-characters-long",
    "Issuer": "https://localhost:7232",
    "Audience": "https://localhost:7232"
  }
}
```

**3. Apply database migrations**

Open Package Manager Console in Visual Studio and run:


**4. Run the project**

Select the `http` profile and run. Swagger will be available at:


### API Endpoints

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | /api/Auth/Register | Register new user | None |
| POST | /api/Auth/Login | Login and get JWT token | None |
| GET | /api/Auth/Profile | Get logged in user profile | Bearer |
| PUT | /api/Auth/UpdateProfile | Update user profile | Bearer |
| GET | /api/v1/Transactions | Get user transactions | Reader |
| POST | /api/v1/Transactions | Create transaction | Reader |
| PUT | /api/v1/Transactions/{id} | Update transaction | Reader |
| DELETE | /api/v1/Transactions/{id} | Delete transaction | Reader |
| GET | /api/v2/Transactions | Get transactions with category type | Reader |
| GET | /api/Categories | Get all categories | Reader/Writer |

### Roles
- **Reader** — assigned to all app users on registration. Can manage their own transactions.
- **Writer** — admin role. Can manage users.

---

## Frontend — Flutter

### Prerequisites
- Flutter SDK 3.x
- Android Studio or Android emulator
- VS Code with Flutter and Dart extensions

### Tech Stack
- Flutter 3.41
- Riverpod (state management)
- fl_chart (pie charts)
- flutter_dotenv (environment variables)
- http (API calls)
- uuid

### Setup

**1. Navigate to the Flutter project**
```bash
cd FinanceTrackerFlutter.net/finance_tracker
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Create `.env` file**

Create a `.env` file in the project root:


> Note: `10.0.2.2` is the Android emulator address for localhost. For a physical device use your machine's local IP address.

**4. Set up ADB reverse (Android emulator only)**

Since the backend runs locally, run this command to tunnel the connection:
```bash
adb reverse tcp:5274 tcp:5274
```

**5. Run the app**
```bash
flutter run
```

### App Features
- Login and registration with JWT authentication
- Home screen with transaction list and month/year filter
- Category filter chips
- Add, edit and delete transactions
- Income vs expense comparison chart with category breakdown
- Profile screen
- Secure token storage via Riverpod state

---

## Local Development Notes

- The backend uses HTTP (not HTTPS) for local development to avoid certificate issues with the Android emulator
- `adb reverse` is required when testing on an Android emulator against a locally hosted backend
- When hosting the backend publicly, update `BASE_URL` in the Flutter `.env` file to the hosted URL

---

## Author

Nitin Sai
