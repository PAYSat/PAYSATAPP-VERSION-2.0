import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyectos_flutter/Model/TarjetaVisa.dart';
import 'package:proyectos_flutter/Page/User/Home/Acciones/RecargarDinero/AgregarTarjetaCredito.dart';
import 'package:proyectos_flutter/Page/User/Home/Acciones/RecargarDinero/ConfirmacionRecargarCredito.dart';
import 'package:proyectos_flutter/Page/User/Home/Acciones/RecargarDinero/RecargarDineroPage.dart';
import 'package:proyectos_flutter/Provider/CardVisaProvider.dart';

class ListaTarjetaCredito extends StatefulWidget {
  const ListaTarjetaCredito({Key? key}) : super(key: key);

  @override
  State<ListaTarjetaCredito> createState() => _ListaTarjetaCreditoState();
}

class _ListaTarjetaCreditoState extends State<ListaTarjetaCredito> {
  bool _isSelectionMode = false;
  Set<int> _selectedCards = {};
  List<CreditCardVisa> _cards = [];
  bool _isLoading = true;
  String _headerText = 'Elige desde qué tarjeta quieres recargar';

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedCards.clear();
      _headerText = _isSelectionMode
          ? 'Elige cuál tarjeta deseas eliminar'
          : 'Elige desde qué tarjeta quieres recargar';
    });
  }

  Future<void> _loadCards() async {
    try {
      final cards = await context.read<CardVisaProvider>().getCardsVisaDebito(
            context: context,
            cardType: 'credit',
          );
      if (mounted) {
        setState(() {
          _cards = cards;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showDeleteConfirmationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFF7F7F).withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_rounded,
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                '¿Estás seguro?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Se eliminarán ${_selectedCards.length} tarjeta(s) seleccionada(s)',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Eliminar',
                      style: TextStyle(
                        color: Color(0xFFFF7F7F),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (result == true) {
      await _deleteSelectedCards();
    }
  }

  Future<void> _deleteSelectedCards() async {
    try {
      final cardProvider = context.read<CardVisaProvider>();
      for (int index in _selectedCards) {
        if (index < _cards.length) {
          await cardProvider.deleteCardVisaCredito(_cards[index].id!, context);
        }
      }
      setState(() {
        _isSelectionMode = false;
        _selectedCards.clear();
        _headerText = 'Elige desde qué tarjeta quieres recargar';
      });
      await _loadCards();
    } catch (e) {
      // Error handling done in deleteCardVisa
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF04F4F0),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _buildAppBar(),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: _cards.isNotEmpty
                          ? _buildCardsList()
                          : _buildEmptyState(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.black,
            onPressed: () {
              if (_isSelectionMode) {
                _toggleSelectionMode();
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RecargarDinero(),
                  ),
                );
              }
            },
          ),
          Expanded(
            child: Text(
              _isSelectionMode ? 'Selecciona las tarjetas' : 'Elige tu tarjeta',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          if (_cards.isNotEmpty)
            IconButton(
              icon:
                  Icon(_isSelectionMode ? Icons.delete : Icons.delete_outline),
              color: _isSelectionMode && _selectedCards.isEmpty
                  ? Colors.grey
                  : Colors.black,
              onPressed: _isSelectionMode
                  ? (_selectedCards.isEmpty
                      ? null
                      : _showDeleteConfirmationDialog)
                  : _toggleSelectionMode,
            ),
        ],
      ),
    );
  }

  Widget _buildCardsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: Text(
            _headerText,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _cards.length + 1,
            itemBuilder: (context, index) {
              if (index < _cards.length) {
                return _buildCardItem(_cards[index], index);
              } else {
                return _buildAddCardButton();
              }
            },
          ),
        ),
        if (!_isSelectionMode) _buildBottomSection(),
      ],
    );
  }

  Widget _buildCardItem(CreditCardVisa card, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          if (_isSelectionMode) {
            setState(() {
              if (_selectedCards.contains(index)) {
                _selectedCards.remove(index);
              } else {
                _selectedCards.add(index);
              }
            });
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ConfirmacionRecargarCredito(selectedCard: card),
              ),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _selectedCards.contains(index)
                ? const Color(0xFFFF7F7F)
                : const Color.fromARGB(255, 5, 22, 247),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              if (_isSelectionMode)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Icon(
                    _selectedCards.contains(index)
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: Colors.white,
                  ),
                ),
              const Text(
                'VISA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nombre',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      card.cardHolderName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '•${card.cardNumber.substring(card.cardNumber.length - 4)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.credit_card,
                size: 120,
                color: Color(0xFFFF7F7F),
              ),
              const SizedBox(height: 24),
              const Text(
                'Aún no tienes tarjetas\nCredito registradas.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 1, 1, 56),
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Registra tus tarjetas de credito y evita tiempos\npara enviar o recargar dinero.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              _buildAddCardButton(),
            ],
          ),
        ),
        _buildHelpButton(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildAddCardButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF04F4F0),
          width: 2,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: const Icon(
          Icons.credit_card_outlined,
          color: Colors.black87,
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Agregar',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            Text(
              'Nueva tarjeta de Credito',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        trailing: const Icon(
          Icons.add,
          color: Color(0xFF04F4F0),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AgregarTarjetaCredito(),
            ),
          ).then((_) => _loadCards());
        },
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          '¡Ya puedes recargar saldo\nde forma automática!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF7F7F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Conocer más'),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.monetization_on,
                    size: 80,
                    color: Color(0xFFFFD700),
                  ),
                ],
              ),
            ),
          ),
          _buildHelpButton(),
        ],
      ),
    );
  }

  Widget _buildHelpButton() {
    return TextButton.icon(
      onPressed: () {},
      icon: const Icon(
        Icons.help_outline,
        color: Colors.black87,
      ),
      label: const Text(
        '¿Necesitas ayuda?',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
