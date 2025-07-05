# SimpleTax AU - Australian Tax Return Calculator

A modern, user-friendly Australian tax return calculator built with Flask. Calculate your tax return for the 2024-25 financial year with detailed breakdowns and PDF export functionality.

## 🌟 Features

- **Complete Tax Calculation**: ATO 2024-25 rates and brackets
- **Step-by-Step Process**: 6-step guided tax return
- **Modern UI**: Beautiful, responsive design with Bootstrap 5
- **Real-time Calculations**: See totals update as you type
- **Spouse Support**: Medicare Levy Surcharge and spouse offset calculations
- **Depreciation Schedule**: Division 43 and Division 40 support
- **PDF Export**: Download your tax summary as PDF
- **Mobile Friendly**: Works perfectly on all devices

## 🛠️ Tech Stack

- **Backend**: Flask (Python)
- **Frontend**: Bootstrap 5, HTML5, CSS3, JavaScript
- **Forms**: WTForms with validation
- **PDF Generation**: ReportLab
- **Styling**: Custom CSS with gradients and animations

## 📋 Tax Features Included

### Income Types
- Salary/Wages
- Interest Income
- Dividend Income
- Rental Income
- Other Income

### Deductions
- Work-related car expenses
- Home office expenses
- Self-education expenses
- Work-related clothing
- Tools & equipment
- Phone & internet
- Professional memberships
- Other deductions

### Depreciation
- Division 43 (Building allowance)
- Division 40 (Plant & equipment)

### Offsets & Rebates
- Private health insurance
- Spouse offset
- Education expenses
- Other offsets

### Tax Calculations
- Basic tax (ATO 2024-25 brackets)
- Medicare Levy (2%)
- Medicare Levy Surcharge
- Low Income Tax Offset (LITO)
- Final refund/amount owing

## 🚀 Quick Start

### Local Development

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd SimpleTax
   ```

2. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

3. **Run the application**
   ```bash
   python app.py
   ```

4. **Open your browser**
   Navigate to `http://127.0.0.1:5000`

### Production Deployment

This app is ready for deployment on:
- **Render** (Recommended - Free tier available)
- **Heroku**
- **Railway**
- **PythonAnywhere**

## 📱 Usage

1. **Personal Details**: Enter your name, date of birth, and spouse information
2. **Income**: Input all sources of income
3. **Deductions**: Add work-related expenses and other deductions
4. **Depreciation**: Include depreciation schedule amounts
5. **Offsets**: Enter tax offsets and rebates
6. **Summary**: Review your complete tax calculation
7. **Export**: Download your tax summary as PDF

## 🔧 Configuration

The app uses Flask's built-in session management and doesn't require a database. All calculations are performed in real-time using the latest ATO rates.

## 📄 License

This project is for educational and demonstration purposes. Please consult with a qualified tax professional for actual tax advice.

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

## 📞 Support

For questions or support, please open an issue in the repository.

---

**Disclaimer**: This application is for demonstration purposes only and should not be used for actual tax filing without professional verification. 