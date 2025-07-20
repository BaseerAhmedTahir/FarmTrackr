import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _ReportCard(
            title: 'Goat Population',
            description: 'View current goat count and demographics',
            icon: Icons.bar_chart,
            onTap: () {
              // TODO: Navigate to goat population report
            },
          ),
          const SizedBox(height: 16),
          _ReportCard(
            title: 'Financial Summary',
            description: 'View income, expenses, and profit/loss',
            icon: Icons.monetization_on,
            onTap: () {
              // TODO: Navigate to financial report
            },
          ),
          const SizedBox(height: 16),
          _ReportCard(
            title: 'Health Records',
            description: 'View vaccination and treatment history',
            icon: Icons.healing,
            onTap: () {
              // TODO: Navigate to health records report
            },
          ),
          const SizedBox(height: 16),
          _ReportCard(
            title: 'Sales History',
            description: 'View all sales transactions',
            icon: Icons.sell,
            onTap: () {
              // TODO: Navigate to sales report
            },
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _ReportCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 48,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
