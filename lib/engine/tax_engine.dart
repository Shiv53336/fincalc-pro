import 'dart:math';

class TaxSlab {
  final double lower;
  final double upper;
  final double rate;
  const TaxSlab(this.lower, this.upper, this.rate);
}

class TaxResult {
  final double grossIncome;
  final double standardDeduction;
  final double totalDeductions;
  final double taxableIncome;
  final double taxBeforeRebate;
  final double rebate87A;
  final double taxAfterRebate;
  final double surcharge;
  final double cess;
  final double totalTax;
  final String regime;

  const TaxResult({
    required this.grossIncome,
    required this.standardDeduction,
    required this.totalDeductions,
    required this.taxableIncome,
    required this.taxBeforeRebate,
    required this.rebate87A,
    required this.taxAfterRebate,
    required this.surcharge,
    required this.cess,
    required this.totalTax,
    required this.regime,
  });
}

class TaxEngine {
  // FY 2025-26 NEW REGIME slabs (Union Budget 2025)
  static const List<TaxSlab> newRegimeSlabs = [
    TaxSlab(0, 400000, 0.00),
    TaxSlab(400000, 800000, 0.05),
    TaxSlab(800000, 1200000, 0.10),
    TaxSlab(1200000, 1600000, 0.15),
    TaxSlab(1600000, 2000000, 0.20),
    TaxSlab(2000000, 2400000, 0.25),
    TaxSlab(2400000, double.infinity, 0.30),
  ];

  // OLD REGIME slabs (Individual below 60)
  static const List<TaxSlab> oldRegimeSlabs = [
    TaxSlab(0, 250000, 0.00),
    TaxSlab(250000, 500000, 0.05),
    TaxSlab(500000, 1000000, 0.20),
    TaxSlab(1000000, double.infinity, 0.30),
  ];

  static double _calculateSlabTax(double taxableIncome, List<TaxSlab> slabs) {
    double tax = 0;
    for (final slab in slabs) {
      if (taxableIncome > slab.lower) {
        double taxable = min(taxableIncome, slab.upper) - slab.lower;
        tax += taxable * slab.rate;
      }
    }
    return tax;
  }

  static double _calculateSurcharge(double tax, double taxableIncome, {bool isNewRegime = false}) {
    if (taxableIncome <= 5000000) return 0;
    if (taxableIncome <= 10000000) return tax * 0.10;
    if (taxableIncome <= 20000000) return tax * 0.15;
    // New Regime: surcharge capped at 25% (since FY 2023-24)
    if (isNewRegime) return tax * 0.25;
    if (taxableIncome <= 50000000) return tax * 0.25;
    return tax * 0.37;
  }

  /// NEW REGIME for FY 2025-26
  static TaxResult calculateNewRegime({
    required double grossSalary,
    double otherIncome = 0,
  }) {
    double grossIncome = grossSalary + otherIncome;
    double stdDeduction = 75000;
    double taxableIncome = max(grossIncome - stdDeduction, 0);

    double taxBeforeRebate = _calculateSlabTax(taxableIncome, newRegimeSlabs);

    // Section 87A: If taxable income <= 12,00,000, rebate up to 60,000
    double rebate = 0;
    if (taxableIncome <= 1200000) {
      rebate = min(taxBeforeRebate, 60000);
    }

    double taxAfterRebate = max(taxBeforeRebate - rebate, 0);
    double surcharge = _calculateSurcharge(taxAfterRebate, taxableIncome, isNewRegime: true);
    double cess = (taxAfterRebate + surcharge) * 0.04;
    double totalTax = taxAfterRebate + surcharge + cess;

    return TaxResult(
      grossIncome: grossIncome,
      standardDeduction: stdDeduction,
      totalDeductions: stdDeduction,
      taxableIncome: taxableIncome,
      taxBeforeRebate: taxBeforeRebate,
      rebate87A: rebate,
      taxAfterRebate: taxAfterRebate,
      surcharge: surcharge,
      cess: cess,
      totalTax: totalTax,
      regime: 'New',
    );
  }

  /// OLD REGIME for FY 2025-26
  static TaxResult calculateOldRegime({
    required double grossSalary,
    double otherIncome = 0,
    double deduction80C = 0,
    double deduction80D = 0,
    double deductionNPS = 0,
    double homeLoanInterest = 0,
    double hraExemption = 0,
    double deduction80G = 0,
    double deduction80E = 0,
    double deduction80TTA = 0,
  }) {
    double grossIncome = grossSalary + otherIncome;
    double stdDeduction = 50000;

    double ded80C = min(deduction80C, 150000);
    double ded80D = min(deduction80D, 75000);
    double dedNPS = min(deductionNPS, 50000);
    double dedHomeLoan = min(homeLoanInterest, 200000);
    double ded80TTA = min(deduction80TTA, 10000);
    // 80G and 80E have no fixed upper cap — user enters eligible amount directly
    double ded80G = deduction80G;
    double ded80E = deduction80E;

    double totalDeductions =
        stdDeduction + ded80C + ded80D + dedNPS + dedHomeLoan + hraExemption +
        ded80G + ded80E + ded80TTA;
    double taxableIncome = max(grossIncome - totalDeductions, 0);

    double taxBeforeRebate = _calculateSlabTax(taxableIncome, oldRegimeSlabs);

    // Section 87A (Old): If taxable income <= 5,00,000, rebate up to 12,500
    double rebate = 0;
    if (taxableIncome <= 500000) {
      rebate = min(taxBeforeRebate, 12500);
    }

    double taxAfterRebate = max(taxBeforeRebate - rebate, 0);
    double surcharge = _calculateSurcharge(taxAfterRebate, taxableIncome);
    double cess = (taxAfterRebate + surcharge) * 0.04;
    double totalTax = taxAfterRebate + surcharge + cess;

    return TaxResult(
      grossIncome: grossIncome,
      standardDeduction: stdDeduction,
      totalDeductions: totalDeductions,
      taxableIncome: taxableIncome,
      taxBeforeRebate: taxBeforeRebate,
      rebate87A: rebate,
      taxAfterRebate: taxAfterRebate,
      surcharge: surcharge,
      cess: cess,
      totalTax: totalTax,
      regime: 'Old',
    );
  }
}
