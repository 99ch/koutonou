// Page de test pour les widgets partagés
// Démontre l'utilisation de tous les composants shared

import 'package:flutter/material.dart';
import '../shared/shared.dart';

class SharedWidgetsTestPage extends StatefulWidget {
  const SharedWidgetsTestPage({super.key});

  @override
  State<SharedWidgetsTestPage> createState() => _SharedWidgetsTestPageState();
}

class _SharedWidgetsTestPageState extends State<SharedWidgetsTestPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  int _selectedTab = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧪 Test Widgets Partagés'),
        elevation: 0,
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody() {
    switch (_selectedTab) {
      case 0:
        return _buildButtonsSection();
      case 1:
        return _buildFormsSection();
      case 2:
        return _buildLoadersSection();
      case 3:
        return _buildDialogsSection();
      case 4:
        return _buildExtensionsSection();
      default:
        return _buildButtonsSection();
    }
  }

  Widget _buildBottomNav() {
    return NavigationBar(
      selectedIndex: _selectedTab,
      onDestinationSelected: (index) {
        setState(() {
          _selectedTab = index;
        });
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.smart_button), label: 'Boutons'),
        NavigationDestination(icon: Icon(Icons.input), label: 'Formulaires'),
        NavigationDestination(icon: Icon(Icons.refresh), label: 'Loaders'),
        NavigationDestination(icon: Icon(Icons.message), label: 'Dialogs'),
        NavigationDestination(icon: Icon(Icons.extension), label: 'Extensions'),
      ],
    );
  }

  Widget _buildButtonsSection() {
    return ListView(
      padding: context.responsivePadding,
      children: [
        _buildSectionHeader('🎯 Boutons'),
        const SizedBox(height: 16),

        // Boutons principaux
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Boutons principaux',
                  style: context.textStyles.titleMedium,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    AppButton(
                      text: 'Primaire',
                      type: AppButtonType.primary,
                      onPressed: () =>
                          context.showSuccess('Bouton primaire pressé !'),
                    ),
                    AppButton(
                      text: 'Secondaire',
                      type: AppButtonType.secondary,
                      onPressed: () =>
                          context.showMessage('Bouton secondaire pressé !'),
                    ),
                    AppButton(
                      text: 'Outlined',
                      type: AppButtonType.outlined,
                      onPressed: () =>
                          context.showWarning('Bouton outlined pressé !'),
                    ),
                    AppButton(
                      text: 'Text',
                      type: AppButtonType.text,
                      onPressed: () =>
                          context.showError('Bouton text pressé !'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Boutons avec icônes
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Boutons avec icônes',
                  style: context.textStyles.titleMedium,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    AppButton.icon(
                      text: 'Télécharger',
                      icon: Icons.download,
                      onPressed: () => _showLoadingDemo(),
                    ),
                    AppButton.icon(
                      text: 'Partager',
                      icon: Icons.share,
                      type: AppButtonType.outlined,
                      onPressed: () => _showBottomSheetDemo(),
                    ),
                    AppButton.icon(
                      text: 'Favoris',
                      icon: Icons.favorite,
                      type: AppButtonType.text,
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Tailles de boutons
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tailles de boutons',
                  style: context.textStyles.titleMedium,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    AppButton(
                      text: 'Petit',
                      size: AppButtonSize.small,
                      onPressed: () {},
                    ),
                    AppButton(
                      text: 'Moyen',
                      size: AppButtonSize.medium,
                      onPressed: () {},
                    ),
                    AppButton(
                      text: 'Grand',
                      size: AppButtonSize.large,
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppButton(
                  text: 'Bouton pleine largeur',
                  fullWidth: true,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // États de boutons
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('États de boutons', style: context.textStyles.titleMedium),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    AppButton.loading(text: 'Chargement...'),
                    AppButton(text: 'Désactivé', onPressed: null),
                    AppButton(
                      text: _isLoading ? 'Chargement...' : 'Charger',
                      loading: _isLoading,
                      onPressed: _isLoading
                          ? null
                          : () {
                              setState(() => _isLoading = true);
                              Future.delayed(const Duration(seconds: 2), () {
                                if (mounted) setState(() => _isLoading = false);
                              });
                            },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormsSection() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: context.responsivePadding,
        children: [
          _buildSectionHeader('📝 Formulaires'),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Champs de saisie',
                    style: context.textStyles.titleMedium,
                  ),
                  const SizedBox(height: 16),

                  FormInputField.email(
                    controller: _emailController,
                    required: true,
                    validator: Validators.combine([
                      Validators.required,
                      Validators.email,
                    ]),
                  ),
                  const SizedBox(height: 16),

                  FormInputField.password(
                    controller: _passwordController,
                    required: true,
                    validator: (value) => Validators.password(
                      value,
                      minLength: 8,
                      requireUppercase: true,
                      requireNumbers: true,
                    ),
                  ),
                  const SizedBox(height: 16),

                  FormInputField.phone(controller: _phoneController),
                  const SizedBox(height: 16),

                  const FormInputField(
                    label: 'Recherche',
                    hint: 'Tapez votre recherche...',
                    type: InputFieldType.search,
                    prefixIcon: Icons.search,
                  ),
                  const SizedBox(height: 16),

                  const FormInputField(
                    label: 'Commentaire',
                    hint: 'Écrivez votre commentaire...',
                    type: InputFieldType.multiline,
                    maxLines: 3,
                    helperText: 'Maximum 500 caractères',
                    maxLength: 500,
                  ),
                  const SizedBox(height: 24),

                  AppButton(
                    text: 'Valider le formulaire',
                    fullWidth: true,
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        context.showSuccess('Formulaire valide !');
                      } else {
                        context.showError('Veuillez corriger les erreurs');
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadersSection() {
    return ListView(
      padding: context.responsivePadding,
      children: [
        _buildSectionHeader('⏳ Indicateurs de chargement'),
        const SizedBox(height: 16),

        // Loaders circulaires
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Loaders circulaires',
                  style: context.textStyles.titleMedium,
                ),
                const SizedBox(height: 16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AppLoader(
                      type: LoaderType.circular,
                      size: LoaderSize.small,
                    ),
                    AppLoader(
                      type: LoaderType.circular,
                      size: LoaderSize.medium,
                    ),
                    AppLoader(
                      type: LoaderType.circular,
                      size: LoaderSize.large,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Autres types de loaders
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Autres loaders', style: context.textStyles.titleMedium),
                const SizedBox(height: 16),
                const AppLoader(
                  type: LoaderType.linear,
                  message: 'Chargement en cours...',
                ),
                const SizedBox(height: 20),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AppLoader(type: LoaderType.dots),
                    AppLoader(type: LoaderType.pulse),
                    AppLoader(type: LoaderType.spinner),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Loader avec progression
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Loader avec progression',
                  style: context.textStyles.titleMedium,
                ),
                const SizedBox(height: 16),
                const AppLoader.progress(
                  value: 0.7,
                  message: 'Téléchargement... 70%',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDialogsSection() {
    return ListView(
      padding: context.responsivePadding,
      children: [
        _buildSectionHeader('💬 Dialogues'),
        const SizedBox(height: 16),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Types de dialogues',
                  style: context.textStyles.titleMedium,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    AppButton(
                      text: 'Information',
                      type: AppButtonType.outlined,
                      onPressed: () => _showInfoDialog(),
                    ),
                    AppButton(
                      text: 'Succès',
                      type: AppButtonType.outlined,
                      onPressed: () => _showSuccessDialog(),
                    ),
                    AppButton(
                      text: 'Avertissement',
                      type: AppButtonType.outlined,
                      onPressed: () => _showWarningDialog(),
                    ),
                    AppButton(
                      text: 'Erreur',
                      type: AppButtonType.outlined,
                      onPressed: () => _showErrorDialog(),
                    ),
                    AppButton(
                      text: 'Confirmation',
                      type: AppButtonType.outlined,
                      onPressed: () => _showConfirmationDialog(),
                    ),
                    AppButton(
                      text: 'Bottom Sheet',
                      type: AppButtonType.outlined,
                      onPressed: () => _showBottomSheetDemo(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExtensionsSection() {
    return ListView(
      padding: context.responsivePadding,
      children: [
        _buildSectionHeader('🔧 Extensions'),
        const SizedBox(height: 16),

        // Extensions String
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Extensions String',
                  style: context.textStyles.titleMedium,
                ),
                const SizedBox(height: 16),
                _buildExtensionExample(
                  'Email valide',
                  'test@example.com'.isValidEmail.toString(),
                ),
                _buildExtensionExample('Capitalize', 'hello world'.capitalize),
                _buildExtensionExample('Title Case', 'hello world'.titleCase),
                _buildExtensionExample('Initiales', 'John Doe'.initials),
                _buildExtensionExample('Slug', 'Hello World!'.toSlug),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Extensions Number
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Extensions Number',
                  style: context.textStyles.titleMedium,
                ),
                const SizedBox(height: 16),
                _buildExtensionExample('Prix', 29.99.toCurrency()),
                _buildExtensionExample('Pourcentage', 0.75.toPercentage()),
                _buildExtensionExample('Formaté', 1234567.toFormattedString()),
                _buildExtensionExample('Taille fichier', 1048576.toFileSize()),
                _buildExtensionExample('Durée', 3665.toReadableDuration()),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Extensions Date
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Extensions Date', style: context.textStyles.titleMedium),
                const SizedBox(height: 16),
                _buildExtensionExample(
                  'Date française',
                  DateTime.now().toFrenchDate,
                ),
                _buildExtensionExample(
                  'Heure française',
                  DateTime.now().toFrenchTime,
                ),
                _buildExtensionExample('Jour', DateTime.now().frenchDayName),
                _buildExtensionExample('Mois', DateTime.now().frenchMonthName),
                _buildExtensionExample(
                  'Est aujourd\'hui',
                  DateTime.now().isToday.toString(),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Extensions Context
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Extensions Context',
                  style: context.textStyles.titleMedium,
                ),
                const SizedBox(height: 16),
                _buildExtensionExample(
                  'Largeur écran',
                  '${context.screenWidth.toInt()}px',
                ),
                _buildExtensionExample(
                  'Hauteur écran',
                  '${context.screenHeight.toInt()}px',
                ),
                _buildExtensionExample(
                  'Mode sombre',
                  context.isDarkMode.toString(),
                ),
                _buildExtensionExample(
                  'Écran mobile',
                  context.isSmallScreen.toString(),
                ),
                _buildExtensionExample(
                  'Orientation',
                  context.isPortrait ? 'Portrait' : 'Paysage',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: context.textStyles.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildExtensionExample(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: context.textStyles.bodyMedium),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: context.textStyles.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: context.colors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLoadingDemo() async {
    LoadingDialog.show(context, message: 'Téléchargement en cours...');
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      LoadingDialog.hide(context);
      context.showSuccess('Téléchargement terminé !');
    }
  }

  void _showInfoDialog() {
    CustomDialog.show(
      context,
      const CustomDialog.info(
        title: 'Information',
        message:
            'Ceci est un dialogue d\'information avec des détails importants.',
        actions: [DialogAction(text: 'OK', isPrimary: true)],
      ),
    );
  }

  void _showSuccessDialog() {
    CustomDialog.showSuccess(
      context,
      message: 'L\'opération s\'est terminée avec succès !',
    );
  }

  void _showWarningDialog() {
    CustomDialog.show(
      context,
      const CustomDialog.warning(
        title: 'Attention',
        message: 'Cette action nécessite votre attention.',
        actions: [
          DialogAction(text: 'Annuler'),
          DialogAction(text: 'Continuer', isPrimary: true),
        ],
      ),
    );
  }

  void _showErrorDialog() {
    CustomDialog.showError(
      context,
      message: 'Une erreur inattendue s\'est produite.',
    );
  }

  void _showConfirmationDialog() async {
    final result = await CustomDialog.showConfirmation(
      context,
      title: 'Confirmation',
      message: 'Êtes-vous sûr de vouloir effectuer cette action ?',
    );

    if (result == true && mounted) {
      context.showSuccess('Action confirmée !');
    }
  }

  void _showBottomSheetDemo() {
    CustomBottomSheet.show(
      context,
      CustomBottomSheet(
        title: 'Partager',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copier le lien'),
              onTap: () {
                Navigator.pop(context);
                context.showSuccess('Lien copié !');
              },
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Envoyer par email'),
              onTap: () {
                Navigator.pop(context);
                context.showMessage('Email envoyé !');
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Partager'),
              onTap: () {
                Navigator.pop(context);
                context.showMessage('Partagé !');
              },
            ),
          ],
        ),
      ),
    );
  }
}
