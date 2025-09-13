import 'package:flutter/material.dart';

class AdvancedSearchScreen extends StatelessWidget {
  const AdvancedSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Busca Avançada'),
      ),
      body: Center(
        child: Text(
          'Tela de busca avançada em construção',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}
