import 'package:flutter/material.dart';
import '../models/address_model.dart';

/// Widget pour afficher une carte adresse
class AddressCard extends StatelessWidget {
  final Address address;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;
  final bool isSelected;

  const AddressCard({
    super.key,
    required this.address,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isSelected ? 4 : 1,
      color: isSelected
          ? Theme.of(context).primaryColor.withOpacity(0.05)
          : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec alias et type
              Row(
                children: [
                  Icon(
                    _getAddressIcon(),
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          address.alias,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          address.addressType,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  if (showActions) ...[
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit?.call();
                            break;
                          case 'delete':
                            onDelete?.call();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('Modifier'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Supprimer',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              // Nom complet
              Text(
                address.fullName,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
              ),

              // Entreprise si présente
              if (address.hasCompany) ...[
                const SizedBox(height: 4),
                Text(
                  address.company!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Colors.blue[700],
                  ),
                ),
              ],

              const SizedBox(height: 8),

              // Adresse complète
              Text(
                address.fullAddress,
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 12),

              // Informations supplémentaires
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (address.hasPhone)
                    _buildInfoChip(
                      icon: Icons.phone,
                      label: address.phone!,
                      context: context,
                    ),
                  if (address.hasMobilePhone)
                    _buildInfoChip(
                      icon: Icons.smartphone,
                      label: address.phoneMobile!,
                      context: context,
                    ),
                  if (address.hasVatNumber)
                    _buildInfoChip(
                      icon: Icons.business_center,
                      label: 'TVA: ${address.vatNumber}',
                      context: context,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getAddressIcon() {
    if (address.isCustomerAddress) return Icons.home;
    if (address.isManufacturerAddress) return Icons.factory;
    if (address.isSupplierAddress) return Icons.local_shipping;
    if (address.isWarehouseAddress) return Icons.warehouse;
    return Icons.location_on;
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required BuildContext context,
  }) {
    return Chip(
      avatar: Icon(icon, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 11)),
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: VisualDensity.compact,
    );
  }
}
