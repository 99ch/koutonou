import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';

/// Widget pour les filtres de commandes
class OrderFilters extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilters;

  const OrderFilters({super.key, required this.onApplyFilters});

  @override
  State<OrderFilters> createState() => _OrderFiltersState();
}

class _OrderFiltersState extends State<OrderFilters> {
  int? _selectedStateId;
  int? _selectedCustomerId;
  DateTime? _startDate;
  DateTime? _endDate;

  final _customerController = TextEditingController();

  @override
  void dispose() {
    _customerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        children: [
          // En-tête
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.filter_list),
                const SizedBox(width: 8),
                const Text(
                  'Filtres',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _clearAllFilters,
                  child: const Text('Effacer tout'),
                ),
              ],
            ),
          ),

          // Contenu des filtres
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filtre par état
                  _buildStateFilter(),

                  const SizedBox(height: 24),

                  // Filtre par client
                  _buildCustomerFilter(),

                  const SizedBox(height: 24),

                  // Filtre par période
                  _buildDateRangeFilter(),
                ],
              ),
            ),
          ),

          // Boutons d'action
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    child: const Text('Appliquer'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'État de la commande',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Consumer<OrderProvider>(
          builder: (context, provider, child) {
            if (provider.orderStates.isEmpty) {
              return const Text('Chargement des états...');
            }

            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: provider.orderStates.map((state) {
                final isSelected = _selectedStateId == state.id;

                return FilterChip(
                  label: Text(state.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedStateId = selected ? state.id : null;
                    });
                  },
                  avatar: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Color(
                        int.parse(
                          '0xFF${(state.color ?? '#000000').replaceAll('#', '')}',
                        ),
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCustomerFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Client',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _customerController,
          decoration: const InputDecoration(
            hintText: 'ID du client',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            _selectedCustomerId = int.tryParse(value);
          },
        ),
      ],
    );
  }

  Widget _buildDateRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Période',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _selectDate(true),
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  _startDate != null
                      ? _formatDate(_startDate!)
                      : 'Date de début',
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text('à'),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _selectDate(false),
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  _endDate != null ? _formatDate(_endDate!) : 'Date de fin',
                ),
              ),
            ),
          ],
        ),
        if (_startDate != null || _endDate != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _startDate = null;
                    _endDate = null;
                  });
                },
                icon: const Icon(Icons.clear),
                label: const Text('Effacer les dates'),
              ),
              const Spacer(),
              // Boutons de sélection rapide
              TextButton(
                onPressed: () => _setQuickDateRange(7),
                child: const Text('7 jours'),
              ),
              TextButton(
                onPressed: () => _setQuickDateRange(30),
                child: const Text('30 jours'),
              ),
            ],
          ),
        ],
      ],
    );
  }

  void _selectDate(bool isStartDate) async {
    final initialDate = isStartDate ? _startDate : _endDate;
    final firstDate = DateTime.now().subtract(const Duration(days: 365));
    final lastDate = DateTime.now().add(const Duration(days: 365));

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (date != null) {
      setState(() {
        if (isStartDate) {
          _startDate = date;
          // Si la date de fin est antérieure, la réinitialiser
          if (_endDate != null && _endDate!.isBefore(date)) {
            _endDate = null;
          }
        } else {
          _endDate = date;
          // Si la date de début est postérieure, la réinitialiser
          if (_startDate != null && _startDate!.isAfter(date)) {
            _startDate = null;
          }
        }
      });
    }
  }

  void _setQuickDateRange(int days) {
    setState(() {
      _endDate = DateTime.now();
      _startDate = DateTime.now().subtract(Duration(days: days));
    });
  }

  void _clearAllFilters() {
    setState(() {
      _selectedStateId = null;
      _selectedCustomerId = null;
      _startDate = null;
      _endDate = null;
      _customerController.clear();
    });
  }

  void _applyFilters() {
    final filters = <String, dynamic>{};

    if (_selectedStateId != null) {
      filters['state'] = _selectedStateId;
    }

    if (_selectedCustomerId != null) {
      filters['customer'] = _selectedCustomerId;
    }

    if (_startDate != null && _endDate != null) {
      filters['startDate'] = _startDate;
      filters['endDate'] = _endDate;
    }

    widget.onApplyFilters(filters);
    Navigator.of(context).pop();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
