import 'package:flutter/material.dart';
import 'package:gasjm/app/data/models/pedido_model.dart'; 

class ShoppingCart extends StatelessWidget {
  final List<PedidoModel> product;
  ShoppingCart({Key? key, required this.product}) ;

  

int cantidad=1;

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
        backgroundColor: Color.fromRGBO(240, 241, 248, 1.0),
      appBar: AppBar(
        elevation: 0.8,
        foregroundColor: Colors.black,
        backgroundColor: Color.fromRGBO(240, 241, 248, 1.0), 
            leading: IconButton(
        icon: Icon(Icons.arrow_back),
        tooltip: "Back",
        onPressed: () => Navigator.pop(context),
        color: Colors.black,
    ),
      ),
       body: Padding(
            padding: EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          top: 25.0,
        ),
        child: Container(  
          child: Column(
              children: [ 
                 
                 Row(
                   children: [
           Text(
          "Shopping cart",
          style:
              TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                    ),
                   ],
                 ) ,
                 _cartItems(),
                  //  SizedBox(height: 30.0,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total",style: TextStyle(fontWeight:FontWeight.bold),),
              Text("\$480.00",style: TextStyle(fontWeight:FontWeight.bold),),
            ],
          ),  
           SizedBox(height: 15.0,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Dlivery charge",style: TextStyle(fontWeight:FontWeight.bold),),
              Text("\40.00",style: TextStyle(fontWeight:FontWeight.bold),),
            ],
          ),
             SizedBox(height: 15.0,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Sub Total",style: TextStyle(fontWeight:FontWeight.bold),),
              Text("\$520.00",style: TextStyle(fontWeight:FontWeight.bold),),
            ],
          ),
                     SizedBox(height: 35.0,),
           Row(
             children: [
               Expanded(
                            child: TextButton(
  style: ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(Colors.purple),
    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
  ),
  onPressed: () { },
  child: Text(' PROCEED TO CHECKOUT '),
),
               ),
             ],
           ),
 SizedBox(height: 50.0,),
              ],
            ),
        )
       ),
    );
  }

    Widget _cartItems() { 
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: ListView.builder( 
      itemCount: product.length,
      itemBuilder: (context, index) {
        return Card(
        
          color: Color.fromRGBO(240, 241, 248, 1.0),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
               Container(
                 width: 100.0,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(20.0)
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(3.0),
                    child: Image.asset(
                      product[index].diaEntregaPedido,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Column( 
               children:  [
                  Text(
                  product[index].diaEntregaPedido,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5.0),
                Text(
                  product[index].cantidadPedido.toString(),
                  style: TextStyle(
                    color: Colors.black45,
                  ),
                ), 
                 Row(
                children:[  
           
                IconButton(
                  onPressed: (){},
                 icon: Icon(Icons.crop_square, color:Colors.grey,size: 20.0,)
                 ),
              
                 Text("$cantidad", style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                  ),
                    IconButton(
                  onPressed: (){},
                 icon: Icon(Icons.add,color: Colors.purple,size: 20.0,)
                 ), 
                ], 
              
              ), 
               ]
              ),
                
                Text(
                  "\$${product[index].idCliente}",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ), 
              ],
            ),
          ),
        );
      },
    ),
  
      ),
    );
  }

}
