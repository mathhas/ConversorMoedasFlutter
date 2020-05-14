import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // 1 (pega a requisição http)
import 'dart:async'; // 1 (torna assincrono, DEVIDO AO TEMPO DE EXECUÇÃO LENTO DA DEVOLUÇÃO DE RESPOSTA DA API )
import 'dart:convert'; // converte json para dart

const request =
    "https://api.hgbrasil.com/finance?format=json-cors&key=314e0dc2";
// faz a requisição do dados da api para a aplicação

void main() async //uso da biblioteca async, para validar o uso da função await
{
  /* 1 - ao fazer a requisição do site, existe uma espera para nao travar o funcionamento
  do app enquanto isso, usar linha abaixo mais as duas bibliotecas import do meio*/
  runApp(MaterialApp(
    home: Home(),
    //theme: para fazer as bordas do textfield
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));
}

// 1 - função para printar o map (e as partes que quiser do map)
Future<Map> getData() async {
  //http.get é uma função que retorna um dado futuro, await = esperando... por esse dado
  http.Response response = await http.get(request);
  return json.decode(response.body);
  // se fizer o response sem o .body, sai a mensagem padrao de objeto (instance...)
}

//para criar de forma rapida: digitar stful
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //controladores, para limpar os botoes, saber o que tem neles e se houve alteração. Pode usar os dois tipos de declaração abaixo
  TextEditingController realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  //variaveis para salvar o dolar e euro
  double dolar;
  double euro;
  double libra;
  double peso;

  //func para resetar os campos com o botao refresh
  void _resetFields() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  //func para saber quando houve alteração nos campos
  void realChanged(String text) {
    //transforma o texto de real para um double
    double real = double.parse(text);

    //faz as mudanças das demais cotações de acordo com o preço do real
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
    //se usasse o as precision, ia ficar um valor anormal para dinheiro, com E^n por exemplo, o as fixed define apenas quantas casas decimais,
  }

  void dolarChanged(String text) {
    //como essa variavel dolar tem o mesmo nome da variavel que recebe o valor de compra do dolar, para se referir a variavel dolar de fora, usa o this.dolar
    double dolar = double.parse(text);

    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = ((dolar * this.dolar) / euro).toStringAsFixed(2);
  }

  void euroChanged(String text) {
    //como essa variavel euro tem o mesmo nome da variavel que recebe o valor de compra do euro, para se referir a variavel euro de fora, usa o this.euro
    double euro = double.parse(text);

    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = ((euro * this.euro) / dolar).toStringAsFixed(2);
  }
//---------------------------------------------interface----------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //o scaffold permite colocar a barra
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Conversor de Moedas"),
        backgroundColor: Colors.amber,
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _resetFields,
          )
        ],
      ),
      body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                    child: Text("Carregando Dados...",
                        style: TextStyle(color: Colors.amber, fontSize: 25.0),
                        textAlign: TextAlign.center));
              default:
                if (snapshot.hasError) {
                  return Center(
                      child: Text("Erro ao carregar Dados, tente novamente",
                          style:
                              TextStyle(color: Colors.amber, fontSize: 25.0)));
                } else {
                  //passado os casos de sem resposta, esperando, ou erro (acima), pegar os dados e construir a tela com os dados
                  dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                  libra = snapshot.data["results"]["currencies"]["GBP"]["buy"];
                  peso = snapshot.data["results"]["currencies"]["ARS"]["buy"];
                  //o snapshot é a captura da tela com os dados json, o restante dos colchetes, sao para acessar os dados na forma mapadentro do json
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10.0),
                    //uma coluna para organizar os widgets verticalmente
                    child: Column(
                      //organizar tudo no centro...
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        //criação padrao da coluna para adicionar filhos aqui dentro eu começo a criar os widgets a aparecerem
                        Icon(Icons.monetization_on,
                            size: 150.0, color: Colors.amber),
                        //Divider(),
                        buildTextField(
                            "Reais", "R\$", realController, realChanged),
                        Divider(),
                        buildTextField(
                            "Dólares", "US\$", dolarController, dolarChanged),
                        Divider(),
                        buildTextField(
                            "Euros", "€", euroController, euroChanged),
                        Divider(),
                        Text(
                            "Cotação Atualizada:\nUSD: ${dolar.toStringAsFixed(2)} - EUR: ${euro.toStringAsFixed(2)}\n\nOutras Cotações:\nGBP: ${libra.toStringAsFixed(2)}(Libras) - ARS: ${peso.toStringAsFixed(2)}(Pesos)",
                            style:
                                TextStyle(color: Colors.amber, fontSize: 20.0),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}

//para evitar repetir o codigo 3 vezees do textfield, fazer uma função que o constroi
Widget buildTextField(String label, String prefix,
    TextEditingController controler, Function changed) {
  return TextField(
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefix),
    style: TextStyle(color: Colors.amber, fontSize: 25.0),
    controller: controler,
    onChanged: changed,
    keyboardType: TextInputType.number,
  );
}
