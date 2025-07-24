# FarmTrackr - Goat Farm Management System

A comprehensive Flutter application for managing goat farms, tracking livestock, and monitoring farm operations.

## Features

- **Goat Management**
  - Track individual goats with detailed profiles
  - Record weight logs and growth metrics
  - Monitor health records and medical history
  - QR code and NFC tag scanning support
  - Photo management for each goat

- **Farm Analytics**
  - Financial performance tracking
  - Weight progression charts
  - Expense monitoring
  - Sales tracking and reporting

- **Staff Management**
  - Caretaker profiles and assignments
  - Role-based access control
  - Activity logging

- **Health Monitoring**
  - Vaccination schedules
  - Medical records
  - Health alerts and reminders

- **Financial Tools**
  - Expense tracking
  - Sales records
  - Financial reporting
  - Revenue analytics

- **Reporting**
  - PDF report generation
  - Data export capabilities
  - Email integration for reports
  - Customizable reporting periods

## Technical Stack

- **Frontend**: Flutter SDK ^3.1.0
- **Backend**: Supabase
- **Authentication**: Supabase Auth
- **Storage**: Supabase Storage
- **Database**: PostgreSQL (via Supabase)
- **State Management**: Riverpod
- **Navigation**: Go Router
- **Charts**: FL Chart
- **Data Persistence**: Shared Preferences
- **File Operations**: Path Provider
- **PDF Generation**: PDF package
- **Email**: Mailer package

## Getting Started

### Prerequisites

- Flutter SDK (^3.1.0)
- Dart SDK
- Supabase account
- IDE (VS Code or Android Studio)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/BaseerAhmedTahir/FarmTrackr.git
```

2. Navigate to the project directory:
```bash
cd goat_tracker
```

3. Create a `.env` file in the root directory with your Supabase credentials:
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

4. Install dependencies:
```bash
flutter pub get
```

5. Run the application:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart           # Application entry point
├── providers.dart      # Riverpod providers
├── router.dart         # Navigation routes
├── models/            # Data models
├── screens/           # UI screens
├── services/          # Business logic
├── widgets/           # Reusable widgets
└── theme/            # App theming
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Testing

Run the tests using:
```bash
flutter test
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Supabase team for the backend infrastructure
- All contributors who help improve the project

## Support

For support, email support@farmtrackr.com or join our Slack channel.
