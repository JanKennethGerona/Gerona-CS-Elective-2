import '../models/product.dart';

class LegoCatalog {
  static const List<Product> products = [
    Product(
      id: '75192',
      name: 'Millennium Falcon',
      setNumber: '75192',
      pieceCount: '7,541 pcs',
      price: 849.99,
      ageRange: '16+',
      rating: 4.9,
      imageUrl: 'assets/images/75192.jpg',
      description:
          'Welcome to the largest, most detailed LEGO Star Wars Millennium Falcon model we’ve ever created. Featuring upper and lower quad laser cannons, landing legs, lowering boarding ramp, and a 4-minifigure cockpit with detachable canopy.',
    ),
    Product(
      id: '10281',
      name: 'Bonsai Tree',
      setNumber: '10281',
      pieceCount: '878 pcs',
      price: 49.99,
      ageRange: '18+',
      rating: 4.8,
      imageUrl: 'assets/images/10281.jpg',
      description:
          'The art of bonsai has captured the imaginations of tree lovers for centuries. Now you can celebrate this ancient art with the LEGO Bonsai Tree building kit. Includes interchangeable green leaves and vibrant pink cherry blossom blooms.',
    ),
    Product(
      id: '92176',
      name: 'NASA Apollo Saturn V',
      setNumber: '92176',
      pieceCount: '1,969 pcs',
      price: 119.99,
      ageRange: '14+',
      rating: 4.9,
      imageUrl: 'assets/images/92176.jpg',
      description:
          'Born to explore: build and display this majestic meter-high LEGO brick model of the NASA Apollo Saturn V. Packed with authentic details, it features 3 removable rocket stages, including the lunar lander and lunar orbiter.',
    ),
    Product(
      id: '10294',
      name: 'LEGO Titanic',
      setNumber: '10294',
      pieceCount: '9,090 pcs',
      price: 679.99,
      ageRange: '18+',
      rating: 5.0,
      imageUrl: 'assets/images/10294.jpg',
      description:
          'A faithful 1:200 scale model of the legendary vessel. Measuring over 53 in. (135 cm) long, this colossal model divides into three sections, revealing cross-sections of the grand staircase, boiler room, smoking lounge, and promenade.',
    ),
    Product(
      id: '42143',
      name: 'Ferrari Daytona SP3',
      setNumber: '42143',
      pieceCount: '3,778 pcs',
      price: 449.99,
      ageRange: '18+',
      rating: 4.7,
      imageUrl: 'assets/images/42143.jpg',
      description:
          'Experience the pinnacle of supercar engineering with this LEGO Technic Ferrari Daytona SP3. Features an 8-speed sequential gearbox with paddle shifter, a V12 engine with moving pistons, and classic red butterfly doors.',
    ),
    Product(
      id: '71043',
      name: 'Hogwarts Castle',
      setNumber: '71043',
      pieceCount: '6,020 pcs',
      price: 469.99,
      ageRange: '16+',
      rating: 4.9,
      imageUrl: 'assets/images/71043.jpg',
      description:
          'Make magic come to life at the LEGO Harry Potter Hogwarts Castle! This highly detailed collectible has over 6,000 pieces and offers a rewarding build experience with towers, chambers, Hagrid\'s hut, and the Whomping Willow.',
    ),
    Product(
      id: '10276',
      name: 'Colosseum',
      setNumber: '10276',
      pieceCount: '9,036 pcs',
      price: 549.99,
      ageRange: '18+',
      rating: 4.6,
      imageUrl: 'assets/images/10276.jpg',
      description:
          'Nowhere on Earth compares to the majesty of the Colosseum of Rome. Prepare to escape your everyday life as you take on the largest ever LEGO build of its time. Faithfully mimics the classical architectural columns and surviving facade.',
    ),
    Product(
      id: '21325',
      name: 'Medieval Blacksmith',
      setNumber: '21325',
      pieceCount: '2,164 pcs',
      price: 179.99,
      ageRange: '18+',
      rating: 4.9,
      imageUrl: 'assets/images/21325.jpg',
      description:
          'Take a break from modern life and build this evocative LEGO Ideas Medieval Blacksmith display model. The 3-level building has a removable roof and upper levels for easy access to the fully furnished bedroom, kitchen, and workshop with glowing forge.',
    ),
    Product(
      id: '76178',
      name: 'Daily Bugle',
      setNumber: '76178',
      pieceCount: '3,772 pcs',
      price: 349.99,
      ageRange: '18+',
      rating: 4.8,
      imageUrl: 'assets/images/76178.jpg',
      description:
          'The ultimate 32-inch-tall Marvel Spider-Man celebration! Includes 25 minifigures including Spider-Man, Venom, Green Goblin, Doctor Octopus, Daredevil, and Punisher, with destructible walls and classic comic newspaper offices.',
    ),
    Product(
      id: '10312',
      name: 'Jazz Club',
      setNumber: '10312',
      pieceCount: '2,899 pcs',
      price: 229.99,
      ageRange: '18+',
      rating: 4.7,
      imageUrl: 'assets/images/10312.jpg',
      description:
          'Take your seat for an evening of live music with the LEGO Icons Jazz Club. Incorporates modular building sections featuring a jazz stage, pizzeria, tailor\'s workshop, and a rooftop greenhouse with an eclectic cast of musician minifigures.',
    ),
  ];

  static Product? findById(String id) {
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
