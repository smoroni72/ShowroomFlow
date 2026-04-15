import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> uploadProducts() async {

  final firestore = FirebaseFirestore.instance;

  final products = [

    {
      "code": "FEDI7340Q",
      "name": "Giacca lana",
      "categoryId": "c1",
      "category": "giacche",
      "layer": "outerwear",
      "price": 299,
      "image": "assets/images/FEDI7340Q.png"
    },

    {
      "code": "FEDI7341Q",
      "name": "Poncho",
      "categoryId": "c1",
      "category": "giacche",
      "layer": "outerwear",
      "price": 299,
      "image": "assets/images/FEDI7341Q.png"
    },

    {
      "code": "FEDI7622C",
      "name": "Capospalla lana",
      "categoryId": "c1",
      "category": "giacche",
      "layer": "outerwear",
      "price": 299,
      "image": "assets/images/FEDI7622C.png"
    },

    {
      "code": "FEDI7700Q",
      "name": "Giubbetto",
      "categoryId": "c1",
      "category": "giacche",
      "layer": "outerwear",
      "price": 299,
      "image": "assets/images/FEDI7700Q.png"
    },

    {
      "code": "FEDI7101G",
      "name": "Maglia marrone",
      "categoryId": "c2",
      "category": "maglie",
      "layer": "top",
      "price": 89,
      "image": "assets/images/FEDI7101G.png"
    },

    {
      "code": "FEDI7103V",
      "name": "Maglia marrone scuro",
      "categoryId": "c2",
      "category": "maglie",
      "layer": "top",
      "price": 89,
      "image": "assets/images/FEDI7103V.png"
    },

    {
      "code": "FEDI7300D",
      "name": "Maglia zip",
      "categoryId": "c2",
      "category": "maglie",
      "layer": "top",
      "price": 89,
      "image": "assets/images/FEDI7300D.png"
    },

    {
      "code": "FEDI7302TVe",
      "name": "Gilet lana",
      "categoryId": "c2",
      "category": "maglie",
      "layer": "top",
      "price": 89,
      "image": "assets/images/FEDI7302TVe.png"
    },

    {
      "code": "FEDI7342C",
      "name": "Maglione lungo",
      "categoryId": "c2",
      "category": "maglie",
      "layer": "top",
      "price": 89,
      "image": "assets/images/FEDI7342C.png"
    },

    {
      "code": "FEDI7418C",
      "name": "Scaldacuore",
      "categoryId": "c2",
      "category": "maglie",
      "layer": "top",
      "price": 89,
      "image": "assets/images/FEDI7418C.png"
    },

    {
      "code": "FEDI7303P",
      "name": "Pantalone tortora",
      "categoryId": "c3",
      "category": "pantaloni",
      "layer": "bottom",
      "price": 149,
      "image": "assets/images/FEDI7303P.png"
    },

    {
      "code": "FEDI7800P",
      "name": "Pantalone beige",
      "categoryId": "c3",
      "category": "pantaloni",
      "layer": "bottom",
      "price": 149,
      "image": "assets/images/FEDI7800P.png"
    },

    {
      "code": "FEDI7812P",
      "name": "Pantalone grigio",
      "categoryId": "c3",
      "category": "pantaloni",
      "layer": "bottom",
      "price": 149,
      "image": "assets/images/FEDI7812P.png"
    },

    {
      "code": "FEDI7814P",
      "name": "Pantalone scuro",
      "categoryId": "c3",
      "category": "pantaloni",
      "layer": "bottom",
      "price": 149,
      "image": "assets/images/FEDI7814P.png"
    },

    {
      "code": "FEDI7304A",
      "name": "Dress marrone",
      "categoryId": "c4",
      "category": "abiti",
      "layer": "dress",
      "price": 149,
      "image": "assets/images/FEDI7304A.png"
    },

    {
      "code": "FEDI7409A",
      "name": "Dress grigio",
      "categoryId": "c4",
      "category": "abiti",
      "layer": "dress",
      "price": 149,
      "image": "assets/images/FEDI7409A.png"
    },

    {
      "code": "FEDI7821A",
      "name": "Dress da sera",
      "categoryId": "c4",
      "category": "abiti",
      "layer": "dress",
      "price": 149,
      "image": "assets/images/FEDI7821A.png"
    },

    {
      "code": "FEDI7355A",
      "name": "Cappello basico",
      "categoryId": "c6",
      "category": "accessori",
      "layer": "hat",
      "price": 149,
      "image": "assets/images/FEDI7355A.png"
    },

    {
      "code": "FEDI7552W",
      "name": "Cappello pon pon",
      "categoryId": "c6",
      "category": "accessori",
      "layer": "hat",
      "price": 149,
      "image": "assets/images/FEDI7552W.png"
    },
    {
      "code": "FEDI7326WU",
      "name": "Grigia cotone",
      "categoryId": "c5",
      "category": "accessori",
      "layer": "scarf",
      "price": 149,
      "image": "assets/images/FEDI7326WU.png"
    },

    {
      "code": "FEDI7327W",
      "name": "Nera lana",
      "categoryId": "c5",
      "category": "accessori",
      "layer": "scarf",
      "price": 149,
      "image": "assets/images/FEDI7327W.png"
    },

    {
      "code": "FEDI7327WU",
      "name": "Grigia lana",
      "categoryId": "c5",
      "category": "accessori",
      "layer": "scarf",
      "price": 149,
      "image": "assets/images/FEDI7327WU.png"
    },

    {
      "code": "FEDI7353W",
      "name": "Marrone lana",
      "categoryId": "c5",
      "category": "accessori",
      "layer": "scarf",
      "price": 149,
      "image": "assets/images/FEDI7353W.png"
    },

    {
      "code": "FEDI7354W",
      "name": "Coprispalle",
      "categoryId": "c5",
      "category": "accessori",
      "layer": "scarf",
      "price": 149,
      "image": "assets/images/FEDI7354W.png"
    },

    {
      "code": "FEDI7551W",
      "name": "Marrone cotone",
      "categoryId": "c5",
      "category": "accessori",
      "layer": "scarf",
      "price": 149,
      "image": "assets/images/FEDI7551W.png"
    },

    {
      "code": "FEDI7513W",
      "name": "Guanti oro",
      "categoryId": "c6",
      "category": "accessori",
      "layer": "gloves",
      "price": 149,
      "image": "assets/images/FEDI7513W.png"
    },

    {
      "code": "FEDI7514W",
      "name": "Guanti lana",
      "categoryId": "c6",
      "category": "accessori",
      "layer": "gloves",
      "price": 149,
      "image": "assets/images/FEDI7514W.png"
    },
  ];

  for (final p in products) {

    await firestore.collection("products").doc(p["code"] as String).set({

      "brandId": "b1",
      "categoryId": p["categoryId"],
      "category": p["category"],
      "code": p["code"],
      "name": p["name"],
      "price": p["price"],
      "visible": true,
      "gender": "female",
      "layer": p["layer"],
      "images": [p["image"]],

      "variants": [
        {"id": "v1", "size": "S", "color": "01"},
        {"id": "v2", "size": "M", "color": "01"},
        {"id": "v3", "size": "L", "color": "01"},
      ]
    });

  }

  print("Prodotti aggiornati su Firestore!");
}