import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SimpleBarChart extends StatelessWidget {
  final List<String> labels;
  final List<int> values;
  final String yAxisLabel;
  final String? subtitle;

  const SimpleBarChart({
    super.key,
    required this.labels,
    required this.values,
    required this.yAxisLabel,
    this.subtitle,
  });

  static const List<Color> _mutedColors = [
    Color(0xFFEF9A9A),
    Color(0xFFA5D6A7),
    Color(0xFF9FA8DA),
    Color(0xFFFFE082),
    Color(0xFF80CBC4),
    Color(0xFFB39DDB),
    Color(0xFFF48FB1),
    Color(0xFF90CAF9),
    Color(0xFFFFCC80),
    Color(0xFFB0BEC5),
  ];

  @override
	Widget build(BuildContext context) {
		final maxValue =
				values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b);
		final total = values.fold<int>(0, (a, b) => a + b);

		const double pixelsPerBar = 32; // density
		final double chartWidth =
				(labels.length * pixelsPerBar).clamp(
					MediaQuery.of(context).size.width,
					double.infinity,
				);

		return Column(
			children: [
				// ---------- SUBTITLE ----------
				if (subtitle != null)
					Padding(
						padding: const EdgeInsets.only(bottom: 12),
						child: Text(
							subtitle!.replaceAll('{total}', total.toString()),
							style: Theme.of(context)
									.textTheme
									.bodyMedium
									?.copyWith(color: Colors.black54),
						),
					),

				// ---------- CHART ----------
				SizedBox(
					height: MediaQuery.of(context).size.height * 0.70, // 70% of screen
					child: SingleChildScrollView(
						scrollDirection: Axis.horizontal,
						child: SizedBox(
							width: chartWidth,
							child: Padding(
								padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
								child: BarChart(
									BarChartData(
										alignment: BarChartAlignment.spaceAround,
										maxY: (maxValue * 1.2).ceilToDouble(),

										// ---------- GRID ----------
										gridData: FlGridData(
											show: true,
											drawVerticalLine: false,
											horizontalInterval:
													maxValue <= 0 ? 1 : (maxValue / 6).ceilToDouble(),
											getDrawingHorizontalLine: (value) => FlLine(
												color: Colors.grey.withOpacity(0.35),
												strokeWidth: 1,
												dashArray: [6, 6],
											),
										),

										borderData: FlBorderData(show: false),

										// ---------- TITLES ----------
										titlesData: FlTitlesData(
											topTitles: const AxisTitles(
												sideTitles: SideTitles(showTitles: false),
											),
											rightTitles: const AxisTitles(
												sideTitles: SideTitles(showTitles: false),
											),

											leftTitles: AxisTitles(
												sideTitles: SideTitles(
													showTitles: true,
													reservedSize: 42,
													getTitlesWidget: (value, _) => Text(
														value.toInt().toString(),
														style: const TextStyle(fontSize: 10),
													),
												),
											),

											bottomTitles: AxisTitles(
												sideTitles: SideTitles(
													showTitles: true,
													interval: 1,
													reservedSize: 150,
													getTitlesWidget: (value, meta) {
														final index = value.toInt();
														if (index < 0 || index >= labels.length) {
															return const SizedBox.shrink();
														}

														return SideTitleWidget(
															axisSide: meta.axisSide,
															space: 6,
															child: SizedBox(
																height: 130,
																child: Align(
																	alignment: Alignment.topCenter,
																	child: RotatedBox(
																		quarterTurns: 1,
																		child: Text(
																			labels[index],
																			maxLines: 1,          // force single line
																			softWrap: false,      // disable wrapping
																			overflow: TextOverflow.visible, // allow long text
																			textAlign: TextAlign.left,
																			style: const TextStyle(
																				fontSize: 11,
																				color: Colors.black87,
																			),
																		),
																	),
																),
															),
														);
													},
												),
											),
										),

										// ---------- BARS ----------
										barGroups: List.generate(values.length, (i) {
											final color = _mutedColors[i % _mutedColors.length];
											return BarChartGroupData(
												x: i,
												barRods: [
													BarChartRodData(
														toY: values[i].toDouble(),
														width: 16,
														borderRadius: BorderRadius.circular(4),
														color: color.withOpacity(0.75),
													),
												],
												showingTooltipIndicators: [0],
											);
										}),

										// ---------- VALUE LABELS ----------
										barTouchData: BarTouchData(
											enabled: false,
											touchTooltipData: BarTouchTooltipData(
												tooltipBgColor: Colors.transparent,
												tooltipPadding: EdgeInsets.zero,
												tooltipMargin: 6,
												getTooltipItem: (_, __, rod, ___) {
													return BarTooltipItem(
														rod.toY.toInt().toString(),
														const TextStyle(
															fontSize: 12,
															fontWeight: FontWeight.bold,
															color: Colors.black,
														),
													);
												},
											),
										),
									),
								),
							),
						),
					),
				),
			],
		);
	}
}