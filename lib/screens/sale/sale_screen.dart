import 'package:flutter/material.dart';
import 'package:goat_tracker/models/goat.dart';
import 'package:goat_tracker/models/sale.dart';
import 'package:goat_tracker/services/goat_service.dart';
import 'package:goat_tracker/services/sale_service.dart';
import 'package:intl/intl.dart';

class SaleScreen extends StatefulWidget {
  const SaleScreen({super.key});

  @override
  State<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> {
  final _saleService = SaleService();
  final _goatService = GoatService();
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _buyerNameController = TextEditingController();
  final _buyerContactController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _saleDate = DateTime.now();
  Goat? _selectedGoat;
  bool _isLoading = false;
  List<Goat> _availableGoats = [];

  @override
  void initState() {
    super.initState();
    _loadAvailableGoats();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _buyerNameController.dispose();
    _buyerContactController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableGoats() async {
    try {
      final goats = await _goatService.getAllGoats();
      setState(() {
        _availableGoats = goats.where((g) => g.status == GoatStatus.active).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading goats: $e')),
        );
      }
    }
  }

  Future<void> _showAddSaleDialog() async {
    _selectedGoat = null;
    _priceController.clear();
    _buyerNameController.clear();
    _buyerContactController.clear();
    _notesController.clear();
    _saleDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Sale'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<Goat>(
                    value: _selectedGoat,
                    decoration: const InputDecoration(labelText: 'Select Goat'),
                    items: _availableGoats.map((goat) => DropdownMenuItem(
                      value: goat,
                      child: Text('${goat.name} (${goat.tagNumber})'),
                    )).toList(),
                    validator: (value) => value == null ? 'Please select a goat' : null,
                    onChanged: (value) => setState(() => _selectedGoat = value),
                  ),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: 'Sale Price'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter a price';
                      if (double.tryParse(value) == null) return 'Please enter a valid number';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _buyerNameController,
                    decoration: const InputDecoration(labelText: 'Buyer Name'),
                  ),
                  TextFormField(
                    controller: _buyerContactController,
                    decoration: const InputDecoration(labelText: 'Buyer Contact'),
                  ),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(labelText: 'Notes'),
                    maxLines: 3,
                  ),
                  ListTile(
                    title: const Text('Sale Date'),
                    subtitle: Text(DateFormat('MMM d, y').format(_saleDate)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _saleDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _saleDate = date);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : () => _submitSale(context),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitSale(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGoat == null) return;

    setState(() => _isLoading = true);

    try {
      await _saleService.createSale(
        goatId: _selectedGoat!.id,
        salePrice: double.parse(_priceController.text),
        saleDate: _saleDate,
        buyerName: _buyerNameController.text.isNotEmpty ? _buyerNameController.text : null,
        buyerContact: _buyerContactController.text.isNotEmpty ? _buyerContactController.text : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sale added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding sale: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales'),
      ),
      body: StreamBuilder<List<Sale>>(
        stream: _saleService.watchSales(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final sales = snapshot.data ?? [];

          if (sales.isEmpty) {
            return const Center(
              child: Text('No sales recorded'),
            );
          }

          return ListView.builder(
            itemCount: sales.length,
            itemBuilder: (context, index) {
              final sale = sales[index];
              return ListTile(
                leading: const Icon(Icons.sell),
                title: Text('Sale: \$${sale.salePrice.toStringAsFixed(2)}'),
                subtitle: Text(
                  'Date: ${DateFormat('MMM d, y').format(sale.saleDate)}\n'
                  'Buyer: ${sale.buyerName ?? 'Not specified'}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.info),
                  onPressed: () {
                    // TODO: Show sale details
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSaleDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales'),
      ),
      body: StreamBuilder<List<Sale>>(
        stream: _saleService.watchSales(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final sales = snapshot.data ?? [];

          if (sales.isEmpty) {
            return const Center(
              child: Text('No sales recorded'),
            );
          }

          return ListView.builder(
            itemCount: sales.length,
            itemBuilder: (context, index) {
              final sale = sales[index];
              return ListTile(
                leading: const Icon(Icons.sell),
                title: Text('Sale: \$${sale.salePrice.toStringAsFixed(2)}'),
                subtitle: Text(
                  'Date: ${DateFormat('MMM d, y').format(sale.saleDate)}\n'
                  'Buyer: ${sale.buyerName ?? 'Not specified'}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.info),
                  onPressed: () {
                    // TODO: Show sale details
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSaleDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
