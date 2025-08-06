import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shipping_provider.dart';
import 'carriers_page.dart';
import 'zones_page.dart';
import 'deliveries_page.dart';
import 'ranges_page.dart';

class ShippingDashboardPage extends StatefulWidget {
  const ShippingDashboardPage({super.key});

  @override
  State<ShippingDashboardPage> createState() => _ShippingDashboardPageState();
}

class _ShippingDashboardPageState extends State<ShippingDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ShippingProvider>();
      provider.loadCarriers();
      provider.loadZones();
      provider.loadDeliveries();
      provider.loadPriceRanges();
      provider.loadWeightRanges();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shipping & Logistics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshAll(),
          ),
        ],
      ),
      body: Consumer<ShippingProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Statistics Cards
                _buildStatsSection(provider),

                const SizedBox(height: 24),

                // Quick Actions
                _buildQuickActionsSection(),

                const SizedBox(height: 24),

                // Management Sections
                _buildManagementSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsSection(ShippingProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vue d\'ensemble',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Transporteurs',
                value: provider.carriers.length.toString(),
                subtitle:
                    '${provider.carriers.where((c) => c.isActive).length} actifs',
                icon: Icons.local_shipping,
                color: Colors.blue,
                onTap: () => _navigateToCarriers(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Zones',
                value: provider.zones.length.toString(),
                subtitle:
                    '${provider.zones.where((z) => z.isActive).length} actives',
                icon: Icons.public,
                color: Colors.green,
                onTap: () => _navigateToZones(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Livraisons',
                value: provider.deliveries.length.toString(),
                subtitle: 'Configurations actives',
                icon: Icons.delivery_dining,
                color: Colors.orange,
                onTap: () => _navigateToDeliveries(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Ranges',
                value:
                    (provider.priceRanges.length + provider.weightRanges.length)
                        .toString(),
                subtitle:
                    '${provider.priceRanges.length} prix, ${provider.weightRanges.length} poids',
                icon: Icons.tune,
                color: Colors.purple,
                onTap: () => _navigateToRanges(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions rapides',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                title: 'Nouveau transporteur',
                subtitle: 'Ajouter un transporteur',
                icon: Icons.add_business,
                color: Colors.blue,
                onTap: () => _showAddCarrierDialog(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                title: 'Nouvelle zone',
                subtitle: 'Créer une zone géographique',
                icon: Icons.add_location,
                color: Colors.green,
                onTap: () => _showAddZoneDialog(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManagementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gestion',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Carriers Section
        _buildManagementTile(
          title: 'Transporteurs',
          subtitle: 'Gérer les transporteurs et leurs configurations',
          icon: Icons.local_shipping,
          color: Colors.blue,
          onTap: () => _navigateToCarriers(),
        ),
        const SizedBox(height: 8),

        // Zones Section
        _buildManagementTile(
          title: 'Zones géographiques',
          subtitle: 'Configurer les zones de livraison',
          icon: Icons.public,
          color: Colors.green,
          onTap: () => _navigateToZones(),
        ),
        const SizedBox(height: 8),

        // Deliveries Section
        _buildManagementTile(
          title: 'Livraisons',
          subtitle: 'Gérer les configurations de livraison',
          icon: Icons.delivery_dining,
          color: Colors.orange,
          onTap: () => _navigateToDeliveries(),
        ),
        const SizedBox(height: 8),

        // Ranges Section
        _buildManagementTile(
          title: 'Ranges de prix et poids',
          subtitle: 'Configurer les tranches tarifaires',
          icon: Icons.tune,
          color: Colors.purple,
          onTap: () => _navigateToRanges(),
        ),
      ],
    );
  }

  Widget _buildManagementTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  void _refreshAll() {
    final provider = context.read<ShippingProvider>();
    provider.loadCarriers();
    provider.loadZones();
    provider.loadDeliveries();
    provider.loadPriceRanges();
    provider.loadWeightRanges();
  }

  void _navigateToCarriers() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const CarriersPage()));
  }

  void _navigateToZones() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const ZonesPage()));
  }

  void _navigateToDeliveries() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const DeliveriesPage()));
  }

  void _navigateToRanges() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const RangesPage()));
  }

  void _showAddCarrierDialog() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const CarriersPage()));
  }

  void _showAddZoneDialog() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const ZonesPage()));
  }
}
