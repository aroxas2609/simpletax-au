from flask import Flask, render_template, redirect, url_for, request, session, send_file
from flask_wtf import FlaskForm
from wtforms import StringField, DecimalField, DateField, BooleanField, IntegerField, SubmitField
from wtforms.validators import DataRequired, Optional
import os
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import letter
from io import BytesIO

app = Flask(__name__)
app.secret_key = os.urandom(24)

# Forms
class PersonalForm(FlaskForm):
    full_name = StringField('Full Name', validators=[DataRequired()])
    dob = DateField('Date of Birth', validators=[DataRequired()])
    address = StringField('Residential Address', validators=[DataRequired()])
    tfn = StringField('Tax File Number (optional)', validators=[Optional()])
    has_spouse = BooleanField('Do you have a spouse?')
    spouse_taxable_income = DecimalField('Spouse\'s Taxable Income', validators=[Optional()])
    submit = SubmitField('Next')

class IncomeForm(FlaskForm):
    salary = DecimalField('Salary/Wages', validators=[DataRequired()])
    interest = DecimalField('Interest Income', validators=[Optional()])
    dividends = DecimalField('Dividend Income', validators=[Optional()])
    rental = DecimalField('Rental Income (optional)', validators=[Optional()])
    other = DecimalField('Other Income', validators=[Optional()])
    submit = SubmitField('Next')

class DeductionsForm(FlaskForm):
    car_expenses = DecimalField('Car Expenses', validators=[Optional()])
    home_office = DecimalField('Home Office', validators=[Optional()])
    self_education = DecimalField('Self Education', validators=[Optional()])
    work_clothing = DecimalField('Work Clothing', validators=[Optional()])
    tools_equipment = DecimalField('Tools & Equipment', validators=[Optional()])
    phone_internet = DecimalField('Phone & Internet', validators=[Optional()])
    professional_memberships = DecimalField('Professional Memberships', validators=[Optional()])
    other_deductions = DecimalField('Other Deductions', validators=[Optional()])
    submit = SubmitField('Next')

class DepreciationForm(FlaskForm):
    division_43 = DecimalField('Division 43 (Building)', validators=[Optional()])
    division_40 = DecimalField('Division 40 (Plant & Equipment)', validators=[Optional()])
    submit = SubmitField('Next')

class OffsetsForm(FlaskForm):
    private_health = DecimalField('Private Health Insurance', validators=[Optional()])
    spouse_offset = DecimalField('Spouse Offset', validators=[Optional()])
    education_expenses = DecimalField('Education Expenses', validators=[Optional()])
    other_offsets = DecimalField('Other Offsets', validators=[Optional()])
    tax_withheld = DecimalField('Tax Withheld', validators=[Optional()])
    submit = SubmitField('Calculate')

# Routes
@app.route('/', methods=['GET', 'POST'])
def home():
    return redirect(url_for('personal'))

@app.route('/personal', methods=['GET', 'POST'])
def personal():
    form = PersonalForm()
    if form.validate_on_submit():
        session['personal'] = form.data
        return redirect(url_for('income'))
    return render_template('personal.html', form=form)

@app.route('/income', methods=['GET', 'POST'])
def income():
    form = IncomeForm()
    if form.validate_on_submit():
        session['income'] = form.data
        return redirect(url_for('deductions'))
    return render_template('income.html', form=form)

@app.route('/deductions', methods=['GET', 'POST'])
def deductions():
    form = DeductionsForm()
    if form.validate_on_submit():
        session['deductions'] = form.data
        return redirect(url_for('depreciation'))
    return render_template('deductions.html', form=form)

@app.route('/depreciation', methods=['GET', 'POST'])
def depreciation():
    form = DepreciationForm()
    if form.validate_on_submit():
        session['depreciation'] = form.data
        return redirect(url_for('offsets'))
    return render_template('depreciation.html', form=form)

@app.route('/offsets', methods=['GET', 'POST'])
def offsets():
    form = OffsetsForm()
    if form.validate_on_submit():
        session['offsets'] = form.data
        return redirect(url_for('summary'))
    return render_template('offsets.html', form=form)

@app.route('/about')
def about():
    return render_template('about.html')

def calculate_tax_au_2024_25(income, deductions, depreciation, offsets, personal_info):
    # Parse and sum all income fields
    salary = float(income.get('salary') or 0)
    interest = float(income.get('interest') or 0)
    dividends = float(income.get('dividends') or 0)
    rental = float(income.get('rental') or 0)
    other = float(income.get('other') or 0)
    total_income = salary + interest + dividends + rental + other

    # Parse and sum all deduction fields
    car_expenses = float(deductions.get('car_expenses') or 0)
    home_office = float(deductions.get('home_office') or 0)
    self_education = float(deductions.get('self_education') or 0)
    work_clothing = float(deductions.get('work_clothing') or 0)
    tools_equipment = float(deductions.get('tools_equipment') or 0)
    phone_internet = float(deductions.get('phone_internet') or 0)
    professional_memberships = float(deductions.get('professional_memberships') or 0)
    other_deductions = float(deductions.get('other_deductions') or 0)
    total_deductions = car_expenses + home_office + self_education + work_clothing + tools_equipment + phone_internet + professional_memberships + other_deductions

    # Add depreciation
    division_43 = float(depreciation.get('division_43') or 0)
    division_40 = float(depreciation.get('division_40') or 0)
    total_depreciation = division_43 + division_40
    total_deductions += total_depreciation

    # Taxable income
    taxable_income = max(0, total_income - total_deductions)

    # Tax payable (ATO brackets)
    if taxable_income <= 18200:
        basic_tax = 0
    elif taxable_income <= 45000:
        basic_tax = 0.19 * (taxable_income - 18200)
    elif taxable_income <= 120000:
        basic_tax = 5092 + 0.325 * (taxable_income - 45000)
    elif taxable_income <= 180000:
        basic_tax = 29467 + 0.37 * (taxable_income - 120000)
    else:
        basic_tax = 51667 + 0.45 * (taxable_income - 180000)

    # Medicare levy (2%)
    medicare_levy = 0.02 * taxable_income

    # Medicare levy surcharge (if no private health)
    private_health_amount = float(offsets.get('private_health') or 0)
    has_private_health = private_health_amount > 0
    medicare_surcharge = 0
    
    if not has_private_health:
        # Use combined income for families (spouse + dependents)
        has_spouse = personal_info.get('has_spouse', False)
        spouse_income = float(personal_info.get('spouse_taxable_income') or 0) if has_spouse else 0
        combined_income = taxable_income + spouse_income
        family_threshold = 186000 if has_spouse else 93000  # Double threshold for families
        
        if combined_income > family_threshold + 51000:  # 144k for singles, 186k + 51k = 237k for families
            medicare_surcharge = 0.015 * taxable_income
        elif combined_income > family_threshold + 15000:  # 108k for singles, 186k + 15k = 201k for families
            medicare_surcharge = 0.0125 * taxable_income
        elif combined_income > family_threshold:  # 93k for singles, 186k for families
            medicare_surcharge = 0.01 * taxable_income

    # Low Income Tax Offset (LITO)
    lito = 0
    if taxable_income <= 37500:
        lito = 700
    elif taxable_income <= 45000:
        lito = 700 - 0.05 * (taxable_income - 37500)
    elif taxable_income <= 66667:
        lito = 325 - 0.015 * (taxable_income - 45000)
    # else lito = 0
    lito = max(0, lito)

    # Total offsets
    spouse_offset = float(offsets.get('spouse_offset') or 0)
    education_expenses = float(offsets.get('education_expenses') or 0)
    other_offsets_amount = float(offsets.get('other_offsets') or 0)
    total_offsets = lito + spouse_offset + education_expenses + other_offsets_amount

    # Tax withheld
    tax_withheld = float(offsets.get('tax_withheld') or 0)

    # Total tax payable
    total_tax_payable = basic_tax + medicare_levy + medicare_surcharge - total_offsets
    total_tax_payable = max(0, total_tax_payable)  # Tax can't be negative

    # Refund or amount owing
    refund = tax_withheld - total_tax_payable

    return {
        'total_income': total_income,
        'total_deductions': total_deductions,
        'taxable_income': taxable_income,
        'basic_tax': basic_tax,
        'medicare_levy': medicare_levy,
        'medicare_surcharge': medicare_surcharge,
        'lito': lito,
        'spouse_offset': spouse_offset,
        'total_offsets': total_offsets,
        'total_tax_payable': total_tax_payable,
        'tax_withheld': tax_withheld,
        'refund': refund,
        'has_spouse': has_spouse if 'has_spouse' in locals() else personal_info.get('has_spouse', False),
        'combined_income': combined_income if 'combined_income' in locals() else taxable_income
    }

@app.route('/summary')
def summary():
    personal = session.get('personal', {})
    income = session.get('income', {})
    deductions = session.get('deductions', {})
    depreciation = session.get('depreciation', {})
    offsets = session.get('offsets', {})
    result = calculate_tax_au_2024_25(income, deductions, depreciation, offsets, personal)
    return render_template('summary.html', personal=personal, income=income, deductions=deductions, depreciation=depreciation, offsets=offsets, result=result)

@app.route('/export_pdf')
def export_pdf():
    personal = session.get('personal', {})
    income = session.get('income', {})
    deductions = session.get('deductions', {})
    depreciation = session.get('depreciation', {})
    offsets = session.get('offsets', {})
    result = calculate_tax_au_2024_25(income, deductions, depreciation, offsets, personal)
    
    # Create PDF using reportlab
    buffer = BytesIO()
    p = canvas.Canvas(buffer, pagesize=letter)
    width, height = letter
    
    # Title
    p.setFont("Helvetica-Bold", 16)
    p.drawString(50, height - 50, "SimpleTax AU - Tax Return Summary")
    
    # Personal Details
    p.setFont("Helvetica-Bold", 12)
    p.drawString(50, height - 100, "Personal Details:")
    p.setFont("Helvetica", 10)
    p.drawString(50, height - 120, f"Name: {personal.get('full_name', '')}")
    p.drawString(50, height - 140, f"Date of Birth: {personal.get('dob', '')}")
    p.drawString(50, height - 160, f"Address: {personal.get('address', '')}")
    
    # Income
    p.setFont("Helvetica-Bold", 12)
    p.drawString(50, height - 200, "Income:")
    p.setFont("Helvetica", 10)
    p.drawString(50, height - 220, f"Salary/Wages: ${income.get('salary', 0)}")
    p.drawString(50, height - 240, f"Interest Income: ${income.get('interest', 0)}")
    p.drawString(50, height - 260, f"Dividend Income: ${income.get('dividends', 0)}")
    p.drawString(50, height - 280, f"Rental Income: ${income.get('rental', 0)}")
    p.drawString(50, height - 300, f"Other Income: ${income.get('other', 0)}")
    p.drawString(50, height - 320, f"Total Income: ${result['total_income']:.2f}")
    
    # Deductions
    p.setFont("Helvetica-Bold", 12)
    p.drawString(50, height - 360, "Deductions:")
    p.setFont("Helvetica", 10)
    p.drawString(50, height - 380, f"Car Expenses: ${deductions.get('car_expenses', 0)}")
    p.drawString(50, height - 400, f"Home Office: ${deductions.get('home_office', 0)}")
    p.drawString(50, height - 420, f"Self Education: ${deductions.get('self_education', 0)}")
    p.drawString(50, height - 440, f"Work Clothing: ${deductions.get('work_clothing', 0)}")
    p.drawString(50, height - 460, f"Tools & Equipment: ${deductions.get('tools_equipment', 0)}")
    p.drawString(50, height - 480, f"Phone & Internet: ${deductions.get('phone_internet', 0)}")
    p.drawString(50, height - 500, f"Professional Memberships: ${deductions.get('professional_memberships', 0)}")
    p.drawString(50, height - 520, f"Other Deductions: ${deductions.get('other_deductions', 0)}")
    
    # Add depreciation if applicable
    has_depreciation = division_43 > 0 or division_40 > 0
    if has_depreciation:
        p.drawString(50, height - 540, f"Division 43 depreciation: ${division_43}")
        p.drawString(50, height - 560, f"Division 40 depreciation: ${division_40}")
        p.drawString(50, height - 580, f"Total depreciation: ${division_43 + division_40}")
        p.drawString(50, height - 600, f"Total Deductions: ${result['total_deductions']:.2f}")
    else:
        p.drawString(50, height - 540, f"Total Deductions: ${result['total_deductions']:.2f}")
    
    # Tax Calculation
    p.setFont("Helvetica-Bold", 12)
    y_offset = -620 if has_depreciation else -560
    p.drawString(50, height + y_offset, "Tax Calculation:")
    p.setFont("Helvetica", 10)
    p.drawString(50, height + y_offset - 20, f"Taxable Income: ${result['taxable_income']:.2f}")
    p.drawString(50, height + y_offset - 40, f"Basic Tax: ${result['basic_tax']:.2f}")
    p.drawString(50, height + y_offset - 60, f"Medicare Levy: ${result['medicare_levy']:.2f}")
    p.drawString(50, height + y_offset - 80, f"Medicare Surcharge: ${result['medicare_surcharge']:.2f}")
    p.drawString(50, height + y_offset - 100, f"Total Offsets: ${result['total_offsets']:.2f}")
    p.drawString(50, height + y_offset - 120, f"Total Tax Payable: ${result['total_tax_payable']:.2f}")
    p.drawString(50, height + y_offset - 140, f"Tax Withheld: ${result['tax_withheld']:.2f}")
    
    # Final Result
    p.setFont("Helvetica-Bold", 12)
    p.drawString(50, height + y_offset - 180, "Final Result:")
    p.setFont("Helvetica-Bold", 14)
    if result['refund'] >= 0:
        p.drawString(50, height + y_offset - 200, f"REFUND: ${result['refund']:.2f}")
    else:
        p.drawString(50, height + y_offset - 200, f"AMOUNT OWING: ${abs(result['refund']):.2f}")
    
    p.showPage()
    p.save()
    buffer.seek(0)
    return send_file(buffer, download_name='tax_summary.pdf', as_attachment=True)

@app.route('/reset')
def reset():
    session.clear()
    return redirect(url_for('personal'))

if __name__ == '__main__':
    # For production, use environment variables
    port = int(os.environ.get('PORT', 5000))
    debug = os.environ.get('FLASK_ENV') == 'development'
    app.run(host='0.0.0.0', port=port, debug=debug) 