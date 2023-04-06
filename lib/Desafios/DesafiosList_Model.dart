class Desafio {
  final String nome;

  Desafio({required this.nome});

  factory Desafio.fromMap(Map<String, dynamic> map) {
    return Desafio(nome: map['Nome do desafio']);
  }
}
