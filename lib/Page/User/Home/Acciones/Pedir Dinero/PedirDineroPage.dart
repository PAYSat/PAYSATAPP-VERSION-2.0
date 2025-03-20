import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyectos_flutter/Provider/PedirProvider.dart';
import 'package:proyectos_flutter/Page/User/Home/HomePage.dart';

class PedirDineroPage extends StatelessWidget {
  const PedirDineroPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PedirProvider(),
      child: const PedirPageView(),
    );
  }
}

class PedirPageView extends StatelessWidget {
  const PedirPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PedirProvider>(context);

    Widget _buildContactInfo() {
      if (provider.selectedContact == null) {
        return const Text(
          'Selecciona o busca un contacto',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        );
      }

      if (provider.getNombres.isNotEmpty && provider.getApellidos.isNotEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${provider.getNombres} ${provider.getApellidos}',
              style: const TextStyle(fontSize: 16, color: Colors.black),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              provider.selectedContact!.phones.first.number,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            provider.selectedContact!.displayName,
            style: const TextStyle(fontSize: 16, color: Colors.black),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            provider.selectedContact!.phones.first.number,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      );
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF06ECE5),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomePage()),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pide dinero',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => provider.selectContact(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Text(
                              '¿A quién le vas a pedir? ',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w500),
                            ),
                            Text('👋', style: TextStyle(fontSize: 20)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: _buildContactInfo()),
                            const Icon(Icons.chevron_right,
                                color: Colors.black54),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text(
                            '¿Cuánta plata? ',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                          Text('💰', style: TextStyle(fontSize: 20)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        keyboardType: TextInputType.number,
                        onChanged: provider.updateAmount,
                        decoration: const InputDecoration(
                          prefixText: '\$',
                          border: InputBorder.none,
                          hintText: '0.00',
                        ),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF26A69A),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text(
                            '¿Por qué se lo pides? ',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                          Text('💭', style: TextStyle(fontSize: 20)),
                        ],
                      ),
                      TextField(
                        onChanged: provider.updateReason,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Escribe la razón...',
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: provider.isFormValid()
                          ? () async {
                              await provider.createMoneyRequest(
                                  context); // Llama al método para crear la solicitud
                            }
                          : null,
                      style: TextButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 252, 26, 26),
                        disabledBackgroundColor: const Color(0xFFB4B4B4),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Pedir dinero',
                        style: TextStyle(
                          color: provider.isFormValid()
                              ? const Color(0xFF000080)
                              : const Color(0xFF666666),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
