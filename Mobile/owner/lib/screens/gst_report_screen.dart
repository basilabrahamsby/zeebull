import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/kpi_summary.dart';

// ── GST Report Info Data ────────────────────────────────────────────────────

class _GstReportInfo {
  final String title;
  final String description;
  final List<String> includes;
  final String calculation;
  final String use;
  final String filingRef;
  final List<String> keyFields;

  const _GstReportInfo({
    required this.title,
    required this.description,
    required this.includes,
    required this.calculation,
    required this.use,
    required this.filingRef,
    required this.keyFields,
  });
}

const _gstLiabilityInfo = _GstReportInfo(
  title: 'GST Liability Report',
  description:
      'A summary of your net GST obligation — how much GST you collected from guests (output) versus how much you paid on purchases (input/ITC).',
  includes: [
    'Total Output GST collected from room, food & service billing',
    'Total Input Tax Credit (ITC) from vendor purchase invoices',
    'Net GST Payable = Output GST − ITC',
    'Whether you have excess ITC credit or a liability',
  ],
  calculation:
      'Output GST is calculated from all checkout invoices (room tariff × applicable GST rate + food orders GST + service charges GST). '
      'Input GST is the total GST paid on your vendor purchases. '
      'Net Payable = Output GST − Input ITC. A positive value means you must pay the difference to the GST portal.',
  use:
      'Use this report to determine how much GST you need to remit to the government for the filing period. '
      'This is the core figure for GSTR-3B filing (due by the 20th of the following month). '
      'If ITC > Output, the surplus carries forward as a credit.',
  filingRef: 'GSTR-3B – Table 3.1 (Outward Supplies) & Table 4 (ITC)',
  keyFields: [
    'Output GST (Collected from guests)',
    'Input ITC (Paid on purchases)',
    'Net GST Payable',
    'Excess ITC (if any)',
  ],
);

const _gstDetailedBreakdown = _GstReportInfo(
  title: 'Why These Numbers Matter',
  description: 'Understanding CGST, SGST & IGST',
  includes: [
    'CGST (Central GST) — half the GST rate, goes to Central Government',
    'SGST (State GST) — half the GST rate, goes to Kerala State Government',
    'IGST (Integrated GST) — for interstate transactions, goes fully to Centre then distributed',
    'Hotels typically charge 12% GST on rooms ≤₹7,500/night and 18% on rooms above',
    'Restaurants charge 5% GST (no ITC) or 18% GST with ITC',
  ],
  calculation:
      'For a room charged at ₹5,000/night: Taxable = ₹5,000, CGST = ₹300 (6%), SGST = ₹300 (6%), Total = ₹5,600. '
      'For rooms above ₹7,500: 18% applies → 9% CGST + 9% SGST.',
  use:
      'Understanding the split helps verify that the correct tax rates are applied. '
      'CGST and SGST are always equal. IGST applies when the guest is from another state and the transaction is B2B.',
  filingRef: 'GSTR-1 (Outward Supplies) & GSTR-3B',
  keyFields: ['CGST Rate', 'SGST Rate', 'IGST Rate', 'Taxable Value', 'Tax Slab'],
);

// ── Info Sheet Widget ────────────────────────────────────────────────────────

void _showGstInfoSheet(BuildContext context, _GstReportInfo info) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (ctx, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Container(
              margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF064E3B), Color(0xFF022C22)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      info.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.all(20),
                children: [
                  // Description
                  Text(
                    info.description,
                    style: TextStyle(color: Colors.grey[700], fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 20),

                  // What it includes
                  _infoSection(
                    label: '📋 What This Report Includes',
                    color: const Color(0xFF064E3B),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: info.includes
                          .map((item) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 3),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 6, right: 8),
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF064E3B),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        item,
                                        style: const TextStyle(fontSize: 13, height: 1.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // How it calculates
                  _infoSection(
                    label: '🧮 How It\'s Calculated',
                    color: const Color(0xFFC5A880),
                    bgColor: const Color(0xFFC5A880).withOpacity(0.08),
                    child: Text(
                      info.calculation,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF92400E), height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Key fields
                  _infoSection(
                    label: '🔑 Key Fields',
                    color: Colors.grey.shade600,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: info.keyFields
                          .map((f) => Chip(
                                label: Text(f, style: const TextStyle(fontSize: 11)),
                                backgroundColor: Colors.grey[100],
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Use and filing reference
                  _infoSection(
                    label: '✅ Purpose & Filing Use',
                    color: const Color(0xFF059669),
                    bgColor: const Color(0xFFF0FDF4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          info.use,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF065F46), height: 1.5),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF059669).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '📂 ${info.filingRef}',
                            style: const TextStyle(
                              color: Color(0xFF065F46),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _infoSection({
  required String label,
  required Color color,
  required Widget child,
  Color? bgColor,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: bgColor ?? Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: color,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    ),
  );
}

// ── Main Screen ────────────────────────────────────────────────────────────

class GstReportScreen extends StatelessWidget {
  final KpiSummary kpi;

  const GstReportScreen({super.key, required this.kpi});

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.currency(locale: "en_IN", symbol: "₹");
    final netLiability = kpi.totalOutputTax - kpi.totalInputTax;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF064E3B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "GST Liability Report",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF064E3B),
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: Color(0xFF064E3B)),
            tooltip: 'About this report',
            onPressed: () => _showGstInfoSheet(context, _gstLiabilityInfo),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Info banner ────────────────────────────────────────────────
            GestureDetector(
              onTap: () => _showGstInfoSheet(context, _gstLiabilityInfo),
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF064E3B).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF064E3B).withOpacity(0.12)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline_rounded, color: Color(0xFF064E3B), size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tap ⓘ to learn what this report includes, how taxes are calculated, and how to use it for GST filing.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF064E3B), fontWeight: FontWeight.bold, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Output GST Card ────────────────────────────────────────────
            _buildSummaryCard(
              context,
              "Output GST (Collected from Guests)",
              kpi.totalOutputTax,
              const Color(0xFFDC2626),
              format,
              "Liability",
              infoKey: 'output',
            ),
            const SizedBox(height: 16),

            // ── Input ITC Card ────────────────────────────────────────────
            _buildSummaryCard(
              context,
              "Input GST / ITC (Paid on Purchases)",
              kpi.totalInputTax,
              const Color(0xFF059669),
              format,
              "Asset",
              infoKey: 'input',
            ),
            const SizedBox(height: 24),

            // ── Net Liability Card ─────────────────────────────────────────
            _buildNetLiabilityCard(context, netLiability, format),
            const SizedBox(height: 32),

            // ── Tax rates reference card ───────────────────────────────────
            GestureDetector(
              onTap: () => _showGstInfoSheet(context, _gstDetailedBreakdown),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.015),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF064E3B).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.calculate_outlined, color: Color(0xFF064E3B), size: 22),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'GST Rates & CGST/SGST/IGST Explained',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A)),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Tap to learn about tax slabs, splitting rules & interstate transactions',
                              style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              "Note: This is an estimated report based on Checkout and Purchase records. For official filing, verify with your CA or the GST portal ledger.",
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    double amount,
    Color color,
    NumberFormat fmt,
    String type, {
    String? infoKey,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.08),
              child: Icon(
                type == "Liability" ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title, 
                    style: const TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    fmt.format(amount),
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.w800, 
                      color: color,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.info_outline_rounded, size: 20),
              color: const Color(0xFF94A3B8),
              tooltip: 'Learn more',
              onPressed: () => _showGstInfoSheet(context, _gstLiabilityInfo),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetLiabilityCard(BuildContext context, double amount, NumberFormat fmt) {
    final isPayable = amount > 0;
    final bgColor = isPayable ? const Color(0xFFFDF8F2) : const Color(0xFFF0FDF4);
    final borderColor = isPayable ? const Color(0xFFC5A880).withOpacity(0.3) : const Color(0xFF86EFAC);
    final textColor = isPayable ? const Color(0xFFDC2626) : const Color(0xFF059669);
    final labelColor = isPayable ? const Color(0xFF92400E) : const Color(0xFF065F46);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Net GST Payable", 
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _showGstInfoSheet(context, _gstLiabilityInfo),
                  child: const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF64748B)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              fmt.format(amount.abs()),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: textColor,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isPayable ? "You need to pay this to GST portal" : "You have excess ITC credit",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: labelColor,
              ),
            ),
            if (isPayable) ...[
              const SizedBox(height: 6),
              Text(
                'Due by 20th of next month (GSTR-3B)',
                style: TextStyle(fontSize: 11, color: const Color(0xFFC5A880), fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
