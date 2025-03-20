import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyectos_flutter/Model/TarjetaPaysat.dart';
import 'package:proyectos_flutter/Provider/CardPaysatProvider.dart';

class CardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cardProvider = Provider.of<CardProviderPaysat>(context);
    // ignore: unused_local_variable
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF04F4F0),
        toolbarHeight: 100,
        title: const Padding(
          padding: EdgeInsets.only(top: 30.0),
          child: Text(
            "Tarjetas PAYSat",
            style: TextStyle(
              color: Color(0xFF000080),
              fontWeight: FontWeight.w800,
              fontSize: 32,
              letterSpacing: -0.5,
            ),
          ),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 30),

              // Card Section
              FutureBuilder<CreditCardPaysat?>(
                future: cardProvider.getUserCard(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF000080),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        "Error: ${snapshot.error}",
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return Column(
                      children: [
                        // Imagen superior
                        Image.asset(
                          'assets/tarjetaVisaPaysat.jpg',
                          width: double.infinity,
                          height:
                              250, // Puedes ajustar el tamaño según necesites
                          fit: BoxFit.cover, // Ajusta cómo se adapta la imagen
                        ),
                        // Animated container for new card creation
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF04F4F0), Color(0xFF000080)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                await cardProvider.showCreateCardDialog(
                                  context,
                                  CreditCardPaysat(
                                    cardNumber: '',
                                    cardHolderName: '',
                                    expirationDate: '',
                                    cvv: '',
                                    cardType: 'VISA',
                                    isValid: true,
                                    saldo: 0.0,
                                    uid: '',
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 20,
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 12),
                                    Text(
                                      "¡La quiero ya!",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  // Card Display
                  CreditCardPaysat card = snapshot.data!;
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6F6F), Color(0xFFFF4545)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6F6F).withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: const Text(
                                "Tarjeta crédito",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: const Row(
                                children: [
                                  Text(
                                    "VISA",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    "Credit",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "NOMBRE DEL TITULAR",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              card.cardHolderName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "NÚMERO DE TARJETA",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              card.cardNumber,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 4,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              // Welcome Message
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: FutureBuilder<CreditCardPaysat?>(
                  future: cardProvider.getUserCard(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return const Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.star,
                                color: Color(0xFF000080),
                                size: 28,
                              ),
                              SizedBox(width: 12),
                              Text(
                                "¡Bienvenido a PAYSat!",
                                style: TextStyle(
                                  color: Color(0xFF000080),
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 12),
                              Icon(
                                Icons.star,
                                color: Color(0xFF000080),
                                size: 28,
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Gracias por usar nuestra tarjeta PAYSat... ¡Tu historial crediticio está comenzando a crecer!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF000080),
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const Column(
                        children: [
                          Center(
                            child: Text(
                              "¡La nueva era de la Banca, con tu visa Prepagada!\n",
                              style: TextStyle(
                                color: Color(0xFF000080),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign
                                  .center, // Opcional, asegura el centrado si el texto es multilineal
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Recarga, Controla y Disfruta.\n\n Banca digital + Visa PAYSat : Tu dupla perfecta.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF000080),
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
