# Gadgeon Finance Tracker

A full-stack personal finance tracking application built with ASP.NET Core Web API (.NET 10) and Flutter. Developed as part of an internship at Gadgeon Smart Systems.

---

## Project Structure

```
FinanceTrackerFlutter.net/
├── GadgeonFinanceTracker/     # ASP.NET Core Web API (Backend)
└── frontend(flutter)/         # Flutter Application (Frontend)
```

---

## Backend — ASP.NET Core Web API

### Prerequisites
- .NET 10 SDK
- SQL Server or SQL Server LocalDB
- Visual Studio 2022/2026 or VS Code with C# Dev Kit

### Tech Stack
- ASP.NET Core Web API (.NET 10)
- Entity Framework Core 10
- ASP.NET Core Identity with custom ApplicationUser
- JWT Authentication with refresh token rotation
- Google OAuth (native token exchange via Google.Apis.Auth)
- Serilog logging
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
    "Issuer": "http://localhost:5274",
    "Audience": "http://localhost:5274"
  },
  "GoogleKeys": {
    "ClientId": "your-google-web-client-id",
    "ClientSecret": "your-google-client-secret"
  }
}
```

**3. Apply database migrations**

Open Package Manager Console in Visual Studio and run:

```
Update-Database -Context FinanceTrackerDBContext
Update-Database -Context FinanceTrackerAuthDbContext
```

**4. Run the project**

Select the `http` profile and run. Swagger will be available at:
```
http://localhost:5274/swagger
```

### API Endpoints

#### Auth
| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | /api/Auth/Register | Register new user | None |
| POST | /api/Auth/Login | Login and get JWT + refresh token | None |
| POST | /api/Auth/Refresh | Refresh JWT using refresh token | None |
| POST | /api/Auth/GoogleToken | Sign in with Google ID token | None |
| GET | /api/Auth/Profile | Get logged in user profile | Bearer |
| PUT | /api/Auth/UpdateProfile | Update name, email, password | Bearer |

#### Transactions
| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | /api/v1/Transactions | Get transactions (paginated, filterable) | Reader |
| POST | /api/v1/Transactions | Create transaction | Reader |
| PUT | /api/v1/Transactions/{id} | Update transaction | Reader |
| DELETE | /api/v1/Transactions/{id} | Delete transaction | Reader |
| GET | /api/v2/Transactions | Get transactions with category type | Reader |
| POST | /api/v1/Transactions/{id}/attachment | Upload PNG/JPEG/SVG attachment | Reader |
| GET | /api/v1/Transactions/{id}/attachment | Get attachment details | Reader |

#### Categories
| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | /api/Categories | Get all categories | Reader/Writer |

### Query Parameters (GET /api/Transactions)

| Parameter | Type | Description |
|-----------|------|-------------|
| fromDate | date | Filter from date (yyyy-MM-dd) |
| toDate | date | Filter to date (yyyy-MM-dd) |
| categoryId | guid | Filter by category |
| sortBy | string | Sort field |
| isAscending | bool | Sort direction |
| pageNumber | int | Page number (default: 1) |
| pageSize | int | Page size (default: 10) |

### Roles
- **Reader** — assigned to all app users on registration. Can manage their own transactions.
- **Writer** — admin role.

### Seeded Categories

| Name | Type |
|------|------|
| Salary | Income |
| Freelance | Income |
| Investment | Income |
| Food | Expense |
| Transport | Expense |
| Entertainment | Expense |
| Shopping | Expense |
| Health & Medical | Expense |
| Rent & Housing | Expense |
| Utilities | Expense |
| Education | Expense |
| Travel | Expense |
| Fuel | Expense |

---

## Frontend — Flutter

### Prerequisites
- Flutter SDK 3.x
- Android Studio or Android emulator
- VS Code with Flutter and Dart extensions

### Tech Stack
- Flutter 3.x
- Riverpod (state management)
- Dio with JWT interceptor (HTTP client)
- fl_chart (pie charts)
- flutter_dotenv (environment variables)
- flutter_secure_storage (token persistence)
- google_sign_in (native Google authentication)
- image_picker (file attachments)
- pdf + printing (report export)

### Setup

**1. Navigate to the Flutter project**
```bash
cd FinanceTrackerFlutter.net/frontend(flutter)
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Create `.env` file**

Create a `.env` file in the project root:
```
BASE_URL=http://10.0.2.2:5274/api
GOOGLE_SERVER_CLIENT_ID=your-google-web-client-id
```

> Note: `10.0.2.2` is the Android emulator address for localhost. For a physical device use your machine's local IP address.

**4. Add `google-services.json`**

Place your `google-services.json` in `android/app/`. This file must contain both the Android OAuth client (type 1) and Web OAuth client (type 3). Obtain from Google Cloud Console under APIs & Services → Credentials.

**5. Set up ADB reverse (Android emulator only)**

```bash
adb reverse tcp:5274 tcp:5274
```

**6. Run the app**
```bash
flutter run
```

### App Features
- Email/password login and registration with JWT authentication
- Native Google Sign In
- Home screen with transaction list, month/year filter, and custom date range filter
- Category filter chips
- Pagination with infinite scroll
- Add, edit and delete transactions
- File attachments (PNG, JPEG, SVG) per transaction
- Income vs expense comparison chart with category breakdown and date range filter
- PDF report export
- Profile screen with name, email, and logout
- Token refresh with rotation
- Secure token storage via flutter_secure_storage

---

## Google Sign In Setup

The app uses native Google Sign In (not browser redirect). Two OAuth credentials are required in Google Cloud Console:

1. **Android OAuth client** — requires package name and SHA-1 fingerprint
2. **Web OAuth client** — used by the backend to verify the ID token

Both client IDs must be present in `google-services.json`. The Web client ID must also be set in `.env` as `GOOGLE_SERVER_CLIENT_ID`.

To get the SHA-1 fingerprint for debug builds:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

---

## Local Development Notes

- The backend runs on HTTP for local development. Google OAuth via browser redirect requires HTTPS and is not functional locally — native Google Sign In via the Flutter app works correctly.
- `adb reverse` is required when testing on Android emulator against a locally hosted backend.
- File attachments are stored in `wwwroot/uploads/transactions/` and served as static files.
- When hosting the backend publicly, update `BASE_URL` in the Flutter `.env` file to the hosted URL.

---

## Pending
- Azure hosting
- Flutter file attachment UI (image picker and display)
- Google OAuth browser flow (requires HTTPS hosting)
