import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Page temporaire pour tester tous les composants du dossier core/
/// À supprimer une fois les tests validés
class TestCorePage extends ConsumerStatefulWidget {
  const TestCorePage({super.key});

  @override
  ConsumerState<TestCorePage> createState() => _TestCorePageState();
}

class _TestCorePageState extends ConsumerState<TestCorePage> {
  String _apiResult = 'Pas encore testé';
  String _modelResult = 'Pas encore testé';
  String _errorResult = 'Pas encore testé';
  String _authResult = 'Pas encore testé';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Core Components'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTestSection(
                'Test API Client',
                _apiResult,
                _testApi,
                Colors.green,
              ),
              const SizedBox(height: 20),
              _buildTestSection(
                'Test Modèles (Sérialisation)',
                _modelResult,
                _testModels,
                Colors.orange,
              ),
              const SizedBox(height: 20),
              _buildTestSection(
                'Test Gestion d\'Erreurs',
                _errorResult,
                _testErrorHandling,
                Colors.red,
              ),
              const SizedBox(height: 20),
              _buildTestSection(
                'Test Authentification',
                _authResult,
                _testAuth,
                Colors.purple,
              ),
              const SizedBox(height: 20),
              _buildConstantsSection(),
              const SizedBox(height: 20),
              _buildLoggerSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestSection(
    String title,
    String result,
    VoidCallback onTest,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Résultat: $result',
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onTest,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
              ),
              child: Text('Tester $title'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConstantsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Constants (core/utils/constants.dart)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // TODO: Remplacer par vos vraies constantes
            const Text('API_BASE_URL: [Ajouter votre URL]'),
            const Text('APP_VERSION: [Ajouter votre version]'),
            const Text('TIMEOUT: [Ajouter votre timeout]'),
          ],
        ),
      ),
    );
  }

  Widget _buildLoggerSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Logger (Vérifiez la console)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _testLogger,
              child: const Text('Tester Logger'),
            ),
          ],
        ),
      ),
    );
  }

  // Méthodes de test à adapter selon vos implémentations

  void _testApi() async {
    try {
      setState(() => _apiResult = 'Test en cours...');
      
      // TODO: Remplacer par votre ApiClient
      // final response = await ApiClient().get('/test');
      // if (response.statusCode == 200) {
      //   setState(() => _apiResult = 'API OK - Réponse: ${response.data}');
      // }
      
      // Simulation pour l'exemple
      await Future.delayed(const Duration(seconds: 1));
      setState(() => _apiResult = 'API OK - Simulation réussie');
      
    } catch (e) {
      setState(() => _apiResult = 'Erreur API: $e');
    }
  }

  void _testModels() {
    try {
      setState(() => _modelResult = 'Test en cours...');
      
      // TODO: Tester vos modèles BaseResponse, ErrorModel, etc.
      // final testData = {'message': 'test', 'success': true};
      // final model = BaseResponse.fromJson(testData);
      // final json = model.toJson();
      
      // Simulation pour l'exemple
      setState(() => _modelResult = 'Modèles OK - Sérialisation réussie');
      
    } catch (e) {
      setState(() => _modelResult = 'Erreur Modèles: $e');
    }
  }

  void _testErrorHandling() {
    try {
      setState(() => _errorResult = 'Test en cours...');
      
      // TODO: Tester votre ErrorHandler
      // throw ApiException('Test erreur');
      
      // Simulation d'une erreur gérée
      setState(() => _errorResult = 'Gestion d\'erreur OK');
      
    } catch (e) {
      setState(() => _errorResult = 'Erreur capturée: $e');
    }
  }

  void _testAuth() async {
    try {
      setState(() => _authResult = 'Test en cours...');
      
      // TODO: Tester votre AuthService
      // final authService = ref.read(authServiceProvider);
      // final result = await authService.login('test@test.com', 'password');
      
      // Simulation pour l'exemple
      await Future.delayed(const Duration(seconds: 1));
      setState(() => _authResult = 'Auth OK - Connexion simulée');
      
    } catch (e) {
      setState(() => _authResult = 'Erreur Auth: $e');
    }
  }

  void _testLogger() {
    // TODO: Utiliser votre Logger
    // Logger.info('Test du logger depuis TestCorePage');
    // Logger.error('Test erreur logger');
    
    print('INFO: Test du logger depuis TestCorePage');
    print('ERROR: Test erreur logger');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Messages envoyés dans la console'),
      ),
    );
  }
}
